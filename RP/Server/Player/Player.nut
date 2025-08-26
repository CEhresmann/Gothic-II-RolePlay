
class _Player
{
    id = -1
    pid = -1;

    items = null
    loggIn = false
    botProtection = false

    description = null

    password = null
    name = -1
    classId = -1
    fractionId = -1

    posx = 0;
    posy = 0;
    posz = 0;

    angle = 0;

    walk = 0
    walkStyleString = "HUMANS"

    str = 0
    dex = 0

    hpMax = 40
    manaMax = 10

    magicLvl = 0;

    body = "";
    skin = 0;
    head = "";
    face = 0;

    weapon = null

    constructor(playerId)
    {
        id = -1;
        pid = playerId;

        description = "";

        items = {};
        loggIn = false;
        botProtection = false;

        password = "";
        name = "";
        classId = 0;
        fractionId = 0;

        posx = 0;
        posy = 0;
        posz = 0;

        angle = 0;

        walk = 0;

        str = 10
        dex = 10

        hpMax = 40
        manaMax = 10

        magicLvl = 0;

        body = "";
        skin = 0;
        head = "";
        face = 0;

        weapon = [0,0,0,0]
    }

	function onSecond()
	{
		if(loggIn == false)
			return;

		if (!isPlayerConnected(pid)) {
			return;
		}

		if (!isPlayerSpawned(pid)) {
			return;
		}

		local position = getPlayerPosition(pid);
		
		if (position == null) {
			return;
		}
		
		
		if (!("x" in position) || !("y" in position) || !("z" in position)) {
			return;
		}
		
		posx = position.x; 
		posy = position.y; 
		posz = position.z;
		angle = getPlayerAngle(pid);
		callEvent("onPlayerPositionChange", pid, posx, posy, posz);
	}
    function respawn()
    {
        setPlayerPosition(pid, CFG.DefaultPosition.x, CFG.DefaultPosition.y, CFG.DefaultPosition.z);
        setPlayerAngle(pid, CFG.DefaultPosition.angle);
        spawnPlayer(pid);

        setPlayerStrength(pid, str);
        setPlayerDexterity(pid, dex);

        setPlayerMana(pid, manaMax);
        setPlayerMaxMana(pid, manaMax);

        setPlayerHealth(pid, hpMax);
        setPlayerMaxHealth(pid, hpMax);

        setPlayerVisual(pid, body, skin, head, face);

        setPlayerSkillWeapon(pid, 0, getPlayerSkillWeapon(pid, 0));
        setPlayerSkillWeapon(pid, 1, getPlayerSkillWeapon(pid, 1));
        setPlayerSkillWeapon(pid, 2, getPlayerSkillWeapon(pid, 2));
        setPlayerSkillWeapon(pid, 3, getPlayerSkillWeapon(pid, 3));

        foreach (item, amount in Player[pid].items)
            _giveItem(pid, item, amount)
    }

    function newAccount(username, pass)
    {
        local checkExist = Database.checkExistPlayer(username);
        if(checkExist)
        {
            addNotification(pid, "Podane konto ju¿ istnieje.");
            return;
        }

        name = username;
        password = pass;

        setPlayerName(pid, username);
        spawnPlayer(pid);
        setClassPlayer(pid, 0, 0);
        setPlayerVisual(pid, CFG.DefaultVisual.Body, CFG.DefaultVisual.Skin, CFG.DefaultVisual.Head, CFG.DefaultVisual.Face)

        id = Database.getNextId();
        Database.createPlayer(this);

        setPlayerPosition(pid, CFG.DefaultPosition.x, CFG.DefaultPosition.y, CFG.DefaultPosition.z);
        setPlayerAngle(pid, CFG.DefaultPosition.angle);

        loggIn = true;
        callEvent("onPlayerLoggIn", pid);

        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.Register);
        packet.send(pid, RELIABLE_ORDERED);
        packet = null;
    }

    function loadAccount(username, pass)
    {
        local checkExist = Database.checkExistPlayer(username);
        if(!checkExist)
        {
            addNotification(pid, "Podane konto nie istnieje.");
            return;
        }

        if(checkExist != pass)
        {
            addNotification(pid, "Z³e has³o.");
            return;
        }

        name = username;
        password = pass;

        setPlayerName(pid, username);
        spawnPlayer(pid);

        Database.loadAccount(this);
        Database.loadItems(pid);

        loggIn = true;
        callEvent("onPlayerLoggIn", pid);

        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.LoggIn);
        packet.send(pid, RELIABLE_ORDERED);
        packet = null;
    }

    function disconnect(reason)
	{
		if (loggIn && isPlayerConnected(pid))
		{
			try {
				Database.updatePlayer(this);
				Database.saveItems(pid);
			} catch (e) {
				print("[ERROR] Failed to save player data: " + e);
			}
		}

		id = -1;
		items = {};
		loggIn = false;
		botProtection = false;
		description = "";
		password = "";
		name = "";
		classId = 0;
		fractionId = 0;
		walk = "";
		str = 10;
		dex = 10;
		hpMax = 40;
		manaMax = 10;
		magicLvl = 0;
		body = "";
		skin = 0;
		head = "";
		face = 0;
		weapon = [0,0,0,0];
	}
}

Player <- [];

for(local i = 0; i < getMaxSlots(); i ++)
    Player.append(_Player(i));


addEventHandler("onPacket", function(pid, packet) {
    local packetType = packet.readUInt8();
    if(packetType != PacketId.Player)
        return;

    packetType = packet.readUInt8();
    switch(packetType)
    {
        case PacketPlayer.Register:
            Player[pid].newAccount(packet.readString(), packet.readString())
        break;
        case PacketPlayer.LoggIn:
            Player[pid].loadAccount(packet.readString(), packet.readString())
        break;
        case PacketPlayer.Visual:
            setPlayerVisual(pid, packet.readString(), packet.readInt16(), packet.readString(), packet.readInt16());
        break;
        case PacketPlayer.Walk:
			local walkStyleId = packet.readInt16();
			local walkStyleName = "HUMANS";
			switch(walkStyleId) {
				case 1: walkStyleName = "HUMANS_TIRED"; break;
				case 2: walkStyleName = "HUMANS_BABE"; break;
				case 3: walkStyleName = "HUMANS_RELAXED"; break;
				case 4: walkStyleName = "HUMANS_MILITIA"; break;
				case 5: walkStyleName = "HUMANS_MAGE"; break;
			}
			setPlayerWalkStyle(pid, walkStyleName);
		break;

		case PacketPlayer.WalkString:
			local walkStyleName = packet.readString();
			setPlayerWalkStyle(pid, walkStyleName);
		break;
        case PacketPlayer.Trade:
            startPlayerTrade(pid, packet.readInt16(), packet.readString(), packet.readString(), packet.readInt16(), packet.readInt16())
        break;
        case PacketPlayer.UseItem:
            playerUseItemClient(pid, packet.readString())
        break;
    }
})

addEventHandler("onPlayerRespawn", function(pid) {
    Player[pid].respawn();
})

addEventHandler("onPlayerDisconnect", function(pid, res) {
    Player[pid].disconnect(res);
})

addEventHandler("onSecond", function() {
    foreach(_player in Player)
    {
        if (isPlayerConnected(_player.pid) && _player.loggIn) {
            try {
                _player.onSecond();
            } catch (e) {
                print("[ERROR] in player.onSecond for PID " + _player.pid + ": " + e);
            }
        }
    }
})

addEventHandler("onPlayerTakeItem", function(pid, item) {
    local instanceName = item.instance;
    
    if(Player[pid].items.rawin(instanceName)) {
        Player[pid].items[instanceName] = Player[pid].items[instanceName] + item.amount;
    } else {
        Player[pid].items[instanceName] <- item.amount;
    }
    
    print("[ITEM] Player " + pid + " took " + item.amount + "x " + instanceName);
})

addEventHandler("onPlayerDropItem", function(pid, item) {
    local instanceName = item.instance;
    
    if(Player[pid].items.rawin(instanceName)) {
        if(Player[pid].items[instanceName] > item.amount) {
            Player[pid].items[instanceName] = Player[pid].items[instanceName] - item.amount;
        } else {
            Player[pid].items.rawdelete(instanceName);
        }
    }
    
    print("[ITEM] Player " + pid + " dropped " + item.amount + "x " + instanceName);
})

addEventHandler("onPlayerJoin", function(pid) {
    local packet = Packet()
	packet.writeUInt8(PacketId.Player);
	packet.writeUInt8(PacketPlayer.Description);
	packet.writeInt16(pid);
	packet.writeString("");
	packet.sendToAll(RELIABLE_ORDERED);
	packet = null;

    for(local i = 0; i < getMaxSlots(); i ++)
    {
        if(!Player[i].loggIn)
            continue;

        local packet = Packet()
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.Description);
        packet.writeInt16(i);
        packet.writeString(Player[i].description);
        packet.send(pid, RELIABLE_ORDERED);
        packet = null;
    }
})
