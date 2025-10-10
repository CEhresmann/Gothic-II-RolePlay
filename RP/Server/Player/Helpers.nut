_setPlayerStrength <- setPlayerStrength;
_setPlayerDexterity <- setPlayerDexterity;
_setPlayerHealth <- setPlayerHealth;
_setPlayerMaxHealth <- setPlayerMaxHealth;
_setPlayerMaxMana <- setPlayerMaxMana;
_setPlayerMagicLevel <- setPlayerMagicLevel;
_setPlayerSkillWeapon <- setPlayerSkillWeapon;
_setPlayerVisual <- setPlayerVisual;
_playAni <- playAni;

function setPlayerStrength(pid, val)
{
	if (!isNpc(pid) && pid in Player) {
		Player[pid].str = val;
		_setPlayerStrength(pid, val);
	}
	_setPlayerStrength(pid, val);
}

function getPlayerStrength(pid)
{
    return Player[pid].str;
}

function setPlayerDexterity(pid, val)
{
	if (!isNpc(pid) && pid in Player) {
		Player[pid].dex = val;
		_setPlayerDexterity(pid, val);
	}
	_setPlayerDexterity(pid, val);
}

function getPlayerDexterity(pid)
{
    return Player[pid].dex;
}

function setPlayerMaxMana(pid, val)
{
	if (!isNpc(pid) && pid in Player) {
		Player[pid].manaMax = val;
		_setPlayerMaxMana(pid, val);
	}
	_setPlayerMaxMana(pid, val);
}

function getPlayerMaxMana(pid)
{
    return Player[pid].manaMax;
}

function completeHealth(pid)
{
	setPlayerHealth(pid, getPlayerMaxHealth(pid));
}

function setPlayerHealth(pid, val)
{
	if (!isNpc(pid) && pid in Player) {
		if(val < 0)
			val = 0;

		_setPlayerHealth(pid, val)
	}
	_setPlayerHealth(pid, val)
}

function setPlayerMaxHealth(pid, val)
{
	if (!isNpc(pid) && pid in Player) {
		Player[pid].hpMax = val;
		_setPlayerMaxHealth(pid, val)
	}
	_setPlayerMaxHealth(pid, val)
}

function getPlayerMaxHealth(pid)
{
    return Player[pid].hpMax;
}

function setPlayerMagicLevel(pid, val)
{
    Player[pid].magicLvl = val;
	_setPlayerMagicLevel(pid, val);
}

function getPlayerMagicLevel(pid)
{
    return Player[pid].magicLvl;
}

function setPlayerSkillWeapon(pid, id, val)
{
	if (!isNpc(pid) && pid in Player) {
		Player[pid].weapon[id] = val;
		_setPlayerSkillWeapon(pid, id, val);
	}
	_setPlayerSkillWeapon(pid, id, val);
}

function getPlayerSkillWeapon(pid, id)
{
    return Player[pid].weapon[id];
}

function setPlayerWalkStyle(pid, animationName)
{
	if (!isNpc(pid) && pid in Player) {
		try {
			removePlayerOverlay(pid, "HUMANS_MAGE.MDS");
			removePlayerOverlay(pid, "HUMANS_BABE.MDS");
			removePlayerOverlay(pid, "HUMANS_MILITIA.MDS");
			removePlayerOverlay(pid, "HUMANS_RELAXED.MDS");
			removePlayerOverlay(pid, "HUMANS_ARROGANCE.MDS");
			removePlayerOverlay(pid, "HUMANS_TIRED.MDS");

			switch(animationName.tolower())
			{
				case "humans_tired":
					applyPlayerOverlay(pid, "HUMANS_TIRED.MDS");
					Player[pid].walkStyleString = "humans_tired";
					break;
				case "humans_babe":
					applyPlayerOverlay(pid, "HUMANS_BABE.MDS");
					Player[pid].walkStyleString = "humans_babe";
					break;
				case "humans_militia":
					applyPlayerOverlay(pid, "HUMANS_MILITIA.MDS");
					Player[pid].walkStyleString = "humans_militia";
					break;
				case "humans_relaxed":
					applyPlayerOverlay(pid, "HUMANS_RELAXED.MDS");
					Player[pid].walkStyleString = "humans_relaxed";
					break;
				case "humans_mage":
					applyPlayerOverlay(pid, "HUMANS_MAGE.MDS");
					Player[pid].walkStyleString = "humans_mage";
					break;
				default:
					Player[pid].walkStyleString = "humans";
					break;
			}
			
			
		} catch (e) {
			print("[ERROR] setPlayerWalkStyle failed: " + e);
		}
	}
}

function getPlayerWalkingStyle(pid)
{
    return Player[pid].walk;
}

function setPlayerVisual(pid, body, skin, head, face)
{
	if (!isNpc(pid) && pid in Player) {
		Player[pid].body = body;
		Player[pid].skin = skin;
		Player[pid].head = head;
		Player[pid].face = face;
		_setPlayerVisual(pid, body, skin, head, face)
	}
	_setPlayerVisual(pid, body, skin, head, face)
}

function getDistancePlayerToPlayer(playerOne, playerTwo)
{
	local posOne = getPlayerPosition(playerOne);
	local posTwo = getPlayerPosition(playerTwo);

	return getDistance3d(posOne.x, posOne.y, posOne.z, posTwo.x, posTwo.y, posTwo.z);
}

function setPlayerDescription(pid, value)
{
	Player[pid].description = value;
	
	local packet = Packet()
	packet.writeUInt8(PacketId.Player);
	packet.writeUInt8(PacketPlayer.Description);
	packet.writeInt16(pid);
	packet.writeString(value);
	packet.sendToAll(RELIABLE_ORDERED);
	packet = null;
}

function playAni(pid, value)
{
	if (!isNpc(pid) && pid in Player) {
		local packet = Packet()
		packet.writeUInt8(PacketId.Player);
		packet.writeUInt8(PacketPlayer.Animation);
		packet.writeInt16(pid);
		packet.writeString(value);
		packet.sendToAll(RELIABLE_ORDERED);
		packet = null;	
	}
	_playAni(pid, value)
}

function calculateCritChance(attr, weapondmg, chance)
{
	local _rand = rand() % 100;
	if(_rand <= chance)
		return attr + weapondmg;
	
	return 0;
}


function getPlayerLearningPoints(pid)
{
    if (!isNpc(pid) && pid in Player && Player[pid].loggIn) {
        return Player[pid].learningPoints;
    }
    return 0;
}


function setPlayerLearningPoints(pid, amount)
{
    if (!isNpc(pid) && pid in Player && Player[pid].loggIn) {
        Player[pid].learningPoints = amount;
        
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.UpdateLP); 
        packet.writeInt32(Player[pid].learningPoints);
        packet.send(pid, RELIABLE_ORDERED);
        packet = null;
    }
}

function addPlayerLearningPoints(pid, amount)
{
    if (!isNpc(pid) && pid in Player && Player[pid].loggIn) {
        local currentPoints = getPlayerLearningPoints(pid);
        setPlayerLearningPoints(pid, currentPoints + amount);
    }
}


function syncProfessionsWithClient(pid)
{
    if (!isNpc(pid) && pid in Player && Player[pid].loggIn) {
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.UpdateProfessions);

        foreach(level in Player[pid].professions) {
            packet.writeInt32(level);
        }
        
        packet.send(pid, RELIABLE_ORDERED);
        packet = null;
    }
}


function setPlayerProfessionLevel(pid, professionId, level)
{
    if (!isNpc(pid) && pid in Player && Player[pid].loggIn) {
        if (professionId >= 0 && professionId < ProfessionType.COUNT) {
            Player[pid].professions[professionId] = level;
            syncProfessionsWithClient(pid);
        }
    }
}

function getPlayerProfessionLevel(pid, professionId)
{
    if (!isNpc(pid) && pid in Player && Player[pid].loggIn) {
        if (professionId >= 0 && professionId < ProfessionType.COUNT) {
            return Player[pid].professions[professionId];
        }
    }
    return 0;
}
