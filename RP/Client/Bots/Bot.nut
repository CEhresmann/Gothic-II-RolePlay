enum ATTACK_MODE
{
    MOVE,
    LEFT,
    RIGHT,
    NORMAL,
}

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

        isStreamer = false;
        element = createNpc(_name);

        schedule = null;
    }

    function setSchedule(tab)
    {
        if(type(tab) != "array" || tab.len() == 0)
            return;

        //schedule = BotSchedule(this, tab);
    }

    function setHealth(val)
    {
        if(hp == 0 && val != 0) {
            unspawnNpc(element);
            spawn();
        }
        hp = val;
        setPlayerHealth(element, val);
    }

    function synchronizePositionFromPlayer(x,y,z)
    {
        local pos = getPlayerPosition(element);
        position.x = x;
        position.y = y;
        position.z = z;

        if(getDistance3d(x, y, z, pos.x, pos.y, pos.z) > 50)
            setPlayerPosition(element,x,y,z);
    }

    function setPosition(x,y,z) {
        position = {x = x, y = y, z = z}
        setPlayerPosition(element, x,y,z);
    }

    function setAngle(val) {
        angle = val;
        setPlayerAngle(element, val);
    }

    function setWeaponMode(val) {
        weaponMode = val;
        setPlayerWeaponMode(element, val);
    }

    function playAnimation(val) {
        animation = val;
        playAni(element, val);
    }

    function attack(pid, mode) {
        if(weaponMode == 0)
            beastAttack(pid);
        else
            weaponAttack(pid, mode);
    }

    function weaponAttack(pid, mode)
    {
        local posP = getPlayerPosition(element);
		local posH = getPlayerPosition(pid);

		local angLerp = getVectorAngle(posP.x, posP.z, posH.x, posH.z);
        setPlayerAngle(element, angLerp);

        if(getPlayerWeaponMode(element) != weaponMode)
            setPlayerWeaponMode(element, weaponMode);

        switch(mode)
        {
            case ATTACK_MODE.MOVE:
                if(pid == heroId)
                    attackPlayer(element, pid, ATTACK_SWORD_FRONT);
                else
                    playAni(element,weaponMode == 3 ? "T_1HATTACKMOVE":"T_2HATTACKMOVE");
            break;
            case ATTACK_MODE.NORMAL:
                if(pid == heroId)
                    attackPlayer(element, pid, ATTACK_SWORD_FRONT);
                else
                    playAni(element,weaponMode == 3 ? "T_1HATTACKMOVE":"T_2HATTACKMOVE");
            break;
            case ATTACK_MODE.LEFT:
                if(pid == heroId)
                    attackPlayer(element, pid, ATTACK_SWORD_LEFT);
                else
                    playAni(element,weaponMode == 3 ? "T_1HATTACKL":"T_2HATTACKL");
            break;
            case ATTACK_MODE.RIGHT:
                if(pid == heroId)
                    attackPlayer(element, pid, ATTACK_SWORD_RIGHT);
                else
                    playAni(element,weaponMode == 3 ? "T_1HATTACKR":"T_2HATTACKR");
            break;
        }
    }

    function beastAttack(pid)
    {
        local posP = getPlayerPosition(element);
		local posH = getPlayerPosition(pid);

		local angLerp = getVectorAngle(posP.x, posP.z, posH.x, posH.z);
        setPlayerAngle(element, angLerp);

        if(pid == heroId)
            attackPlayer(element, pid, ATTACK_FRONT);
        else
            playAni(element,"S_FISTATTACK");
    }

    function spawn()
    {
        spawnNpc(element);

        setPlayerInstance(element, instance);
        setPlayerName(element, getPlayerName(element))
        setPlayerMaxHealth(element, hpMax);
        setPlayerHealth(element, hp);
        setPlayerStrength(element, str);
        setPlayerDexterity(element, dex);
        setPlayerPosition(element, position.x, position.y, position.z);
        setPlayerAngle(element, angle);

        if(instance == "PC_HERO")
        {
            setPlayerVisual(element, bodyModel, bodyTxt, headModel, headTxt);

            setPlayerSkillWeapon(element, 0, weapon[0]);
            setPlayerSkillWeapon(element, 1, weapon[1]);
            setPlayerSkillWeapon(element, 2, weapon[2]);
            setPlayerSkillWeapon(element, 3, weapon[3]);

            if(armor != -1) equipArmor(element, armor);
            if(melee != -1) equipMeleeWeapon(element, melee);
            if(ranged != -1) equipRangedWeapon(element, ranged);
        }
    }

    function respawn(x,y,z)
    {
        unspawnNpc(element);
        hp = hpMax;
        spawn();

        position = {x = x, y = y, z = z}
        setPlayerPosition(element, x,y,z);
    }

    function unspawn()
    {
        unspawnNpc(element);
        isStreamer = false;
    }

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

    isStreamer = false;
    element = null;

    schedule = null;
}