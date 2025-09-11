
enum MONSTER_STATUS
{
    SPAWN,
    SEARCH,
    WARN,
    RUN,
    ATTACK,
    BACK
}

class Monster extends Bot
{
    constructor(zType)
    {
        base.constructor(zType.name)
        basePosition = {x = 0, y = 0, z = 0}

        str = zType.str;
        dex = zType.str;
        hp = zType.hp;
        hpMax = zType.hpMax;
        exp = zType.exp;

        instance = zType.instance;
        spawnTime = zType.spawnTime;

        wayBack = null;
        timer = 0;

        status = MONSTER_STATUS.SEARCH;
        target = -1;

        protection = [0,0,0,0,0];
        lastAttacks = [];
    }

    function update()
    {
        switch(status)
        {
            case MONSTER_STATUS.SPAWN:
                respawnAction();
            break;
            case MONSTER_STATUS.SEARCH:
                searchAction();

                if(schedule && status == MONSTER_STATUS.SEARCH)
                    schedule.update();
            break;
            case MONSTER_STATUS.WARN:
                warnAction();
            break;
            case MONSTER_STATUS.RUN:
                runAction();
            break;
            case MONSTER_STATUS.ATTACK:
                attackAction();
            break;
            case MONSTER_STATUS.BACK:
                backAction();
            break;
        }
    }

    function onPositionSynchronize()
    {
        switch(status)
        {
            case MONSTER_STATUS.BACK:
                backAction();
            break;
            case MONSTER_STATUS.RUN:
                runAction();
            break;
        }
    }

    function onLostAnyTarget()
    {
        switch(status)
        {
            case MONSTER_STATUS.BACK:
                wayBack = null;
                setPosition(basePosition.x,basePosition.y,basePosition.z)
                reset();
            break;
            case MONSTER_STATUS.RUN:
                reset();
            break;
        }
    }

    function respawnAction()
    {
        timer = timer - 1;
        if(timer <= 0)
        {
            position = { x = basePosition.x, y = basePosition.y, z = basePosition.z}
            for(local i = 0; i < getMaxSlots(); i++)
                if(isPlayerConnected(i))
                    BotIntegration.packetRespawn(this, i);


            BotIntegration.onBotPosition(id, basePosition.x, basePosition.y, basePosition.z);
            hp = hpMax;
            status = MONSTER_STATUS.SEARCH;
        }
    }

    function searchAction()
    {
        foreach(_player in getPlayersBot(id)) {
            if(!isTargetable(_player))
                continue;

            if(!isInArea(_player, 1200))
                continue;

            if(!isInEye(_player))
                continue;

            timer = 4;
            target = _player;
            status = MONSTER_STATUS.WARN;
        }
    }

    function warnAction()
    {
        if(!isTargetable(target)) {
            reset();
            return;
        }

        timer++;
        turnIntoPlayer(target);

        if(timer % 5 == 0)
            playAnimation("T_WARN");

        if(timer >= 15 || isInArea(target, 600))
        {
            timer = 0;
            status = MONSTER_STATUS.RUN;
            runAction();
            return;
        }
    }

    function runAction()
    {
        local pos = getPlayerPosition(target);
        if(!isTargetable(target) || !isInArea(target, 2000)) {
            reset();
            return;
        }

        if(isOutAreaHome())
        {
            if(wayBack == null)
                wayBack = BotWaypoint(getNearestWaypoint(CFG.BotWaypointMap,position.x, position.y, position.z).name, getNearestWaypoint(CFG.BotWaypointMap,basePosition.x, basePosition.y, basePosition.z).name);

            status = MONSTER_STATUS.BACK;
            return;
        }

        if(isInArea(target, 300)) {
            status = MONSTER_STATUS.ATTACK;
            timer = 1;
            attackAction();
            return;
        }

        turnIntoPlayer(target);
        if(animation != "S_FISTRUNL")
            playAnimation("S_FISTRUNL");
    }

    function attackAction()
    {
        if(!isTargetable(target)) {
            reset();
            return;
        }

        if(!isInArea(target, 300)) {
            status = MONSTER_STATUS.RUN;
            runAction();
            return;
        }

        if(animation == "S_FISTRUNL") {
            playAnimation("T_FISTATTACKMOVE");
            hitTarget(target);
        }

        timer ++;

        if(timer < 5)
            return;

        timer = 0;
        local chance = rand() % 10;

        if(chance > 3) {
            hitTarget(target);
        }else
            playAnimation("T_FISTPARADEJUMPB");
    }


    function backAction()
    {
        foreach(_player in getPlayersBot(id)) {
            if(!isTargetable(_player))
                continue;

            if(!isInArea(_player, 400))
                continue;

            wayBack = null;
            timer = 4;
            target = _player;
            status = MONSTER_STATUS.ATTACK;
            return;
        }

        hp = hp + abs(hpMax * 0.05);
        if(hp > hpMax)
            hp = hpMax;

        setHealth(hp);

        if(animation != "S_FISTRUNL")
            playAnimation("S_FISTRUNL");

        if(wayBack == null)
        {
            turnIntoHome();
            if(isBotInHome())
            {
                setHealth(hpMax);
                reset();
            }
        }else{
            wayBack.checkForBot(this);
            if(wayBack.isEnd)
                wayBack = null;
        }
    }

    function reset()
    {
        status = MONSTER_STATUS.SEARCH;
        target = -1;
        timer = 0;
        playAnimation("T_WARN");
    }

    function isInArea(pid, distance)
    {
        local pos = getPlayerPosition(pid);
        return getDistance3d(position.x, position.y, position.z, pos.x, pos.y, pos.z) <= distance;
    }

    function isTargetable(pid)
    {
        return (isPlayerConnected(pid) && getPlayerHealth(pid) > 0 && isPlayerSpawned(pid) && !Player[pid].botProtection);
    }

    function isOutAreaHome()
    {
        return getDistance3d(position.x, position.y, position.z, basePosition.x, basePosition.y, basePosition.z) > 2500;
    }

    function isBotInHome()
    {
        return getDistance3d(position.x, position.y, position.z, basePosition.x, basePosition.y, basePosition.z) < 300;
    }

    function turnIntoPlayer(pid)
    {
        local pos = getPlayerPosition(pid);
        local _angle = getVectorAngle(position.x,position.z,pos.x,pos.z);
        local angleDiff = abs(_angle - angle);

        if(angleDiff > 10)
            setAngle(_angle);
    }

    function turnIntoHome()
    {
        local _angle = getVectorAngle(position.x,position.z,basePosition.x,basePosition.z);
        local angleDiff = abs(_angle - angle);

        if(angleDiff > 10)
            setAngle(_angle);
    }

    function die(pid)
    {
        status = MONSTER_STATUS.SPAWN;
        timer = spawnTime;
        target = -1;

        playAnimation("T_DEATH");
        callEvent("onBotDeath", pid, this);
    }

    function hitByPlayer(pid, dmg)
    {
        switch(status)
        {
            case MONSTER_STATUS.SEARCH:
                target = pid;
                status = MONSTER_STATUS.RUN;
                runAction();
            break;
            case MONSTER_STATUS.WARN:
                timer = 0;
                target = pid;
                status = MONSTER_STATUS.RUN;
                runAction();
            break;
        }

	    hp = hp - dmg;

        if(hp <= 0) {
            hp = 0;
            die(pid);
        }

        setHealth(hp);

        lastAttacks.append(pid);
        if(lastAttacks.len() > 2)
            lastAttacks.remove(0);
        else
            return;

        if(lastAttacks[1] != target && lastAttacks[0] != target)
            target = pid;
    }

    function hitPlayer(targetId)
    {
        local dmg = str;
        setPlayerHealth(targetId, getPlayerHealth(targetId) - dmg);
    }

    function onLostStreamer(pid)
    {
        if(target != pid)
            return;

        reset();
    }

    timer = 0;
    spawnTime = 0;

    exp = 0;

    target = -1;
    status = -1;

    lastAttacks = null;
    basePosition = null;
    protection = null;
    wayBack = null;
}

function createMonster(_type, x,y,z)
{
    local bot = Monster(_type);
    bot.position = {x = x, y = y, z = z};
    bot.basePosition = {x = x, y = y, z = z};
    return BotIntegration.add(bot);
}
