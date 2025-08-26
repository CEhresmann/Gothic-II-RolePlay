class Bot
{
    constructor(_name)
    {
        id = -1;
        name = _name;

        str = 10;
        dex = 10;

        hp = 40;
        hpMax = 40;

        armor = -1;
        melee = -1;
        ranged = -1;

        bodyModel = -1;
        bodyTxt = -1;
        headModel = -1;
        headTxt = -1;

        angle = 0;
        position = {x = 0, y = 0, z = 0};

        weapon = [0,0,0,0];
        weaponMode = 0;

        animation = "S_WALKL";
        instance = "PC_HERO";

        streamer = -1;

        grid = null;
        action = null;
        schedule = null;
    }

    function setSchedule(tab)
    {
        if(type(tab) != "array" || tab.len() == 0)
            return;

        schedule = BotSchedule(this, tab);
    }

    function setHealth(val)
    {
        hp = val;

        foreach(_player in getPlayersBot(id))
            BotIntegration.packetHealth(this, _player);
    }

    function playAnimation(anim)
    {
        animation = anim;

        foreach(_player in getPlayersBot(id))
            BotIntegration.packetAnimation(this, _player);
    }

    function updateChunk()
    {
        local chunk = Grid.find(position.x,position.z);
        if(grid != chunk)
        {
            grid.removeBot(id);
            chunk.addBot(id);

            grid = chunk;
        }
    }

    function setPosition(x,y,z)
    {
        position = {x = x, y = y, z = z};
        updateChunk();

        for(local i = 0; i < getMaxSlots(); i++)
            if(isPlayerConnected(i))
                BotIntegration.packetPosition(this, i);
    }

    function setWeaponMode(val)
    {
        weaponMode = val;
        for(local i = 0; i < getMaxSlots(); i++)
            if(isPlayerConnected(i))
                BotIntegration.packetWeaponMode(this, i);
    }

    function setAngle(val)
    {
        angle = val;
        for(local i = 0; i < getMaxSlots(); i++)
            if(isPlayerConnected(i))
                BotIntegration.packetAngle(this, i);
    }

    function hitTarget(target, mode=-1)
    {
        for(local i = 0; i < getMaxSlots(); i++)
            if(isPlayerConnected(i))
                BotIntegration.packetAttack(this, target, i, mode);
    }

    function spawn(pid)
    {
        if(streamer == -1)
        {
            streamer = pid;
            BotIntegration.packetSpawn(id, pid, true);
            return;
        }

        BotIntegration.packetSpawn(id, pid, false);
    }

    function unspawn(pid)
    {
        if(streamer == pid)
        {
            onLostStreamer(pid);
            findNewStreamer();
        }

        BotIntegration.packetUnSpawn(id, pid);
    }

    function findNewStreamer(exclude = -1)
    {
        local players = getPlayersBot(id);

        local ping = 10000;
        local currPlayer = -1;

        foreach(player in players)
        {
            if(getPlayerPing(player) < ping)
            {
                if(isPlayerSpawned(player) && exclude != player)
                {
                    currPlayer = player;
                    ping = getPlayerPing(player);
                }
            }
        }
        streamer = currPlayer;

        if(streamer != -1)
            BotIntegration.packetStreamer(this, streamer);
        else
            onLostAnyTarget();
    }

    function getEyeArea(dis)
	{
		local rot = angle;
		local pos = clone position;

        if(CFG.BotEyeVision == false)
            return pos;

		if(rot < 0)
			rot += (ceil(abs(rot)/360.0))*360;
        else
			rot -= (floor(rot/360))*360.0;

		if(rot%90==0)
		{
			if(rot == 0)		pos.z += dis;
			else if(rot == 90)	pos.x += dis;
			else if(rot == 180)	pos.z -= dis;
			else if(rot == 270)	pos.x -= dis;
		}
		else
		{
			local mrot = (floor(rot/90))*90;
			local a = cos((rot - mrot) * ( PI / 180 )) * dis;
			local b = sin((rot - mrot) * ( PI / 180 )) * dis;

			if(rot > 270)		{ pos.x -= a; pos.z += b;}
			else if(rot > 180)	{ pos.x -= b; pos.z -= a;}
			else if(rot > 90)	{ pos.x += a; pos.z -= b;}
			else if(rot > 0)	{ pos.x += b; pos.z += a;}
		}

		return pos;
	}

    function isInEye(pid)
    {
        local pos = getPlayerPosition(pid), range = 1000;
		local eye1 = getEyeArea(range);

		if(getDistance2d(pos.x, pos.z, eye1.x, eye1.z) < range && abs(pos.y - eye1.y) < 300 )
			return true;

        return false;
    }

    function onPlayerDisconnect(pid)
    {
        if(streamer == pid)
        {
            onLostStreamer(pid);
            findNewStreamer(pid);
        }
    }

    function onPositionSynchronize() {}
    function onLostAnyTarget() {}
    function onLostStreamer(pid) {}
    function onGetScheduleEvent(id) {};

    id = -1;
    name = null;
    str = -1;
    dex = -1;

    hp = -1;
    hpMax = -1;

    armor = -1;
    melee = -1;
    ranged = -1;

    bodyModel = -1;
    bodyTxt = -1;
    headModel = -1;
    headTxt = -1;

    weapon = null;
    weaponMode = 0;

    animation = null;
    position = null;
    angle = 0;
    instance = null;

    streamer = -1;

    grid = null;
    action = null;
    schedule = null;
}

