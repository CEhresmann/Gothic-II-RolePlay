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

    hpMax = 100
    manaMax = 30
    hp = 100
    mana = 30

    magicLvl = 0;
    
    learningPoints = 10;
    
    professions = null

    body = "";
    skin = 0;
    head = "";
    face = 0;

    weapon = null

    fatness = 0.0
    scale_x = 1.0
    scale_y = 1.0
    scale_z = 1.0

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

        hpMax = 100
        manaMax = 30
        hp = 100
        mana = 30

        magicLvl = 0;
        
        learningPoints = 10;

        professions = array(ProfessionType.COUNT, 0);

        body = "";
        skin = 0;
        head = "";
        face = 0;

        weapon = [0,0,0,0]

        fatness = 0.0
        scale_x = 1.0
        scale_y = 1.0
        scale_z = 1.0
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

		hp = getPlayerHealth(pid);
		mana = getPlayerMana(pid);

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

		if (getTickCount() % 60000 == 0) {
			Database.saveItems(pid);
		}
	}
    function respawn()
    {
        setPlayerPosition(pid, CFG.DefaultPosition.x, CFG.DefaultPosition.y, CFG.DefaultPosition.z);
        setPlayerAngle(pid, CFG.DefaultPosition.angle);
        spawnPlayer(pid);

        setPlayerStrength(pid, str);
        setPlayerDexterity(pid, dex);

        setPlayerMana(pid, mana);
        setPlayerMaxMana(pid, manaMax);

        setPlayerHealth(pid, hp);
        setPlayerMaxHealth(pid, hpMax);

        setPlayerTalent(pid, TALENT_MAGE, magicLvl)

        setPlayerVisual(pid, body, skin, head, face);

        setPlayerFatness(pid, fatness);
        setPlayerScale(pid, scale_x, scale_y, scale_z);

        setPlayerSkillWeapon(pid, WEAPON_1H, weapon[0]);
        setPlayerSkillWeapon(pid, WEAPON_2H, weapon[1]);
        setPlayerSkillWeapon(pid, WEAPON_BOW, weapon[2]);
        setPlayerSkillWeapon(pid, WEAPON_CBOW, weapon[3]);

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

        local salt = Bcrypt.generateSalt(12, 'b');
        local hashedPassword = Bcrypt.hash(pass, salt);

        name = username;
        password = hashedPassword;

        setPlayerName(pid, username);
        spawnPlayer(pid);
        setClassPlayer(pid, 0, 0);
		setPlayerMana(pid, mana);
        setPlayerMaxMana(pid, manaMax);
        setPlayerTalent(pid, TALENT_MAGE, magicLvl)

        setPlayerHealth(pid, hp);
        setPlayerMaxHealth(pid, hpMax);
		setPlayerStrength(pid, str);
        setPlayerDexterity(pid, dex);
		setPlayerSkillWeapon(pid, WEAPON_1H, weapon[0]);
        setPlayerSkillWeapon(pid, WEAPON_2H, weapon[1]);
        setPlayerSkillWeapon(pid, WEAPON_BOW, weapon[2]);
        setPlayerSkillWeapon(pid, WEAPON_CBOW, weapon[3]);

        fatness = 0.0;
        scale_x = 1.0;
        scale_y = 1.0;
        scale_z = 1.0;

        setPlayerFatness(pid, fatness);
        setPlayerScale(pid, scale_x, scale_y, scale_z);

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
		packet.writeInt16(pid);
        packet.send(pid, RELIABLE_ORDERED);
        packet = null;
    }

	function loadAccount(username, pass)
	{
		foreach (player in Player) {
			if (player.loggIn && player.name == username) {
				addNotification(pid, "To konto jest ju¿ zalogowane na serwerze.");
				return;
			}
		}

		local storedData = Database.checkExistPlayer(username);
		if(!storedData)
		{
			addNotification(pid, "Podane konto nie istnieje.");
			return;
		}

		if(storedData.ck == 1) {
			addNotification(pid, "To konto zosta³o oznaczone jako CK (Character Kill) i nie mo¿na siê na nie zalogowaæ.");
			return;
		}

		if(!Bcrypt.compare(pass, storedData.password))
		{
			addNotification(pid, "Zle has³o.");
			return;
		}

		name = username;
		password = storedData.password;

		setPlayerName(pid, username);
		spawnPlayer(pid);

		Database.loadAccount(this);
		Database.loadItems(pid);

		loggIn = true;
		callEvent("onPlayerLoggIn", pid);

		local packet = Packet();
		packet.writeUInt8(PacketId.Player);
		packet.writeUInt8(PacketPlayer.LoggIn);
		packet.writeInt16(pid);
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
        hpMax = 100;
        manaMax = 30;
        hp = 100
        mana = 30
        magicLvl = 0;
        
        learningPoints = 0;

        professions = array(ProfessionType.COUNT, 0);
        
        body = "";
        skin = 0;
        head = "";
        face = 0;
        weapon = [0,0,0,0];
        
        fatness = 0.0;
        scale_x = 1.0;
        scale_y = 1.0;
        scale_z = 1.0;
    }
    function setFatness(value)
    {
        fatness = value.tofloat();
        setPlayerFatness(pid, fatness);
    }

    function setScale(x, y, z)
    {
        scale_x = x.tofloat();
        scale_y = y.tofloat();
        scale_z = z.tofloat();
        setPlayerScale(pid, scale_x, scale_y, scale_z);
    }

    function getFatness()
    {
        return fatness;
    }

    function getScale()
    {
        return { x = scale_x, y = scale_y, z = scale_z };
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
        case PacketPlayer.UseItem:
            playerUseItemClient(pid, packet.readString())
        break;
        case PacketPlayer.Fatness:
            Player[pid].setFatness(packet.readFloat());
        break;
        case PacketPlayer.Scale:
            Player[pid].setScale(packet.readFloat(), packet.readFloat(), packet.readFloat());
        break;
    }
})

addEventHandler("onPlayerRespawn", function(pid) {
    if (!isNpc(pid) && pid in Player) {
        Player[pid].respawn();
    }
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

addEventHandler("onPlayerDead", function(pid, killerid) {
	setPlayerRespawnTime(pid, 0);
	SendSystemMessage(pid, "Umar³eœ, odrodzisz siê za minute!", {r=255, g=0, b=0});
	setTimer(function() {
		respawnPlayer(pid);
		setPlayerHealth(pid, 20);
	}, 60000, 1);
});

addEventHandler("onExit", function() {
    local onlinePlayers = getOnlinePlayers();
    
    foreach (playerId in onlinePlayers) {
        if (playerId in Player && Player[playerId].loggIn) {
            try {
                Database.updatePlayer(Player[playerId]);
                Database.saveItems(playerId);
            } catch (e) {
                serverLog("B³¹d podczas zapisywania gracza " + playerId + ": " + e);
            }
        }
        
        kick(playerId, "Serwer jest wy³¹czany. Zapraszamy ponownie póŸniej!");
    }
    
    setTimer(function() {
        serverLog("Wyrzucono " + onlinePlayers.len() + " graczy z serwera.");
    }, 1000, 1);
});
