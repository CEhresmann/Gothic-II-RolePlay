_setPlayerStrength <- setPlayerStrength;
_setPlayerDexterity <- setPlayerDexterity;
_setPlayerHealth <- setPlayerHealth;
_setPlayerMaxHealth <- setPlayerMaxHealth;
_setPlayerMaxMana <- setPlayerMaxMana;
_setPlayerMagicLevel <- setPlayerMagicLevel;
_setPlayerSkillWeapon <- setPlayerSkillWeapon;
_setPlayerVisual <- setPlayerVisual;

function setPlayerStrength(pid, val)
{
	Player[pid].str = val;
	_setPlayerStrength(pid, val);
}

function getPlayerStrength(pid)
{
    return Player[pid].str;
}

function setPlayerDexterity(pid, val)
{
	Player[pid].dex = val;
	_setPlayerDexterity(pid, val);
}

function getPlayerDexterity(pid)
{
    return Player[pid].dex;
}

function setPlayerMaxMana(pid, val)
{
	Player[pid].manaMax = val;
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
	if(val < 0)
		val = 0;

	_setPlayerHealth(pid, val)
}

function setPlayerMaxHealth(pid, val)
{
	Player[pid].hpMax = val;
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
	Player[pid].weapon[id] = val;
	_setPlayerSkillWeapon(pid, id, val);
}

function getPlayerSkillWeapon(pid, id)
{
    return Player[pid].weapon[id];
}

function setPlayerWalkStyle(pid, animationName)
{
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
                //Player[pid].walk = 1;
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

function getPlayerWalkingStyle(pid)
{
    return Player[pid].walk;
}

function setPlayerVisual(pid, body, skin, head, face)
{
	Player[pid].body = body;
	Player[pid].skin = skin;
	Player[pid].head = head;
	Player[pid].face = face;
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
	local packet = Packet()
	packet.writeUInt8(PacketId.Player);
	packet.writeUInt8(PacketPlayer.Animation);
	packet.writeInt16(pid);
	packet.writeString(value);
	packet.sendToAll(RELIABLE_ORDERED);
	packet = null;	
}

function calculateCritChance(attr, weapondmg, chance)
{
	local _rand = rand() % 100;
	if(_rand <= chance)
		return attr + weapondmg;
	
	return 0;
}
