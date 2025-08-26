
enum ONEH_STATUS
{
    SPAWN,
    SEARCH,
    RUN,
    ATTACK,
    BACK
}

enum ONEH_ATTACK
{
    MOVE,
    LEFT,
    RIGHT,
    NORMAL
}

class OneH extends Bot
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

        armor = zType.armor;
        melee = zType.melee;
        ranged = zType.ranged;

        weapon = zType.weapon;

        wayBack = null;
        timer = 0;

        status = ONEH_STATUS.SEARCH;
        target = -1;

        protection = [0,0,0,0,0];
        lastAttacks = [];

        if(instance == "PC_HERO")
            runAnimation = "S_1HRUNL";
        else
            runAnimation = "S_FISTRUN";
    }

    function update()
    {
        switch(status)
        {
            case ONEH_STATUS.SPAWN:
                respawnAction();
            break;
            case ONEH_STATUS.SEARCH:
                searchAction();

                if(schedule && status == MONSTER_STATUS.SEARCH)
                    schedule.update();
            break;
            case ONEH_STATUS.RUN:
                runAction();
            break;
            case ONEH_STATUS.ATTACK:
                attackAction();
            break;
            case ONEH_STATUS.BACK:
                backAction();
            break;
        }
    }

    function onPositionSynchronize()
    {
        switch(status)
        {
            case ONEH_STATUS.BACK:
                backAction();
            break;
            case ONEH_STATUS.RUN:
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
            status = ONEH_STATUS.SEARCH;
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
            status = ONEH_STATUS.RUN;
        }
    }

    function runAction()
    {
        local pos = getPlayerPosition(target);
        if(!isTargetable(target) || !isInArea(target, 2000)) {
            reset();
            return;
        }

        if(weaponMode != 3)
            setWeaponMode(3);

        if(isOutAreaHome())
        {
            if(wayBack == null)
                wayBack = BotWaypoint(getNearestWaypoint(CFG.BotWaypointMap,position.x, position.y, position.z).name, getNearestWaypoint(CFG.BotWaypointMap,basePosition.x, basePosition.y, basePosition.z).name);

            status = ONEH_STATUS.BACK;
            return;
        }

        if(isInArea(target, 300)) {
            status = ONEH_STATUS.ATTACK;
            timer = 1;
            attackAction();
            return;
        }

        turnIntoPlayer(target);
        if(animation != runAnimation)
            playAnimation(runAnimation);
    }

    function attackAction()
    {
        if(!isTargetable(target)) {
            reset();
            return;
        }

        if(!isInArea(target, 300)) {
            status = ONEH_STATUS.RUN;
            playAnimation(runAnimation);
            runAction();
            return;
        }

        if(animation == runAnimation) {
            hitTarget(target, ONEH_ATTACK.MOVE);
            animation = "S_RUN";
        }

        timer ++;

        if(timer < 5)
            return;

        timer = 0;
        local chance = rand() % 15;

        switch(chance)
        {
            case 1: case 2:
                hitTarget(target, ONEH_ATTACK.NORMAL);
            break;
            case 4: case 5: case 6:
                hitTarget(target, ONEH_ATTACK.LEFT);
            break;
            case 8: case 7: case 9:
                hitTarget(target, ONEH_ATTACK.RIGHT);
            break;
            case 10: case 11: case 12:
                playAnimation("T_1HPARADE_0");
            break;
            default:
                playAnimation("T_1HPARADEJUMPB");
            break;
        }
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
            status = ONEH_STATUS.ATTACK;
            return;
        }

        hp = hp + abs(hpMax * 0.05);
        if(hp > hpMax)
            hp = hpMax;

        setHealth(hp);

        if(animation != runAnimation)
            playAnimation(runAnimation);

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
        status = ONEH_STATUS.SEARCH;
        target = -1;
        timer = 0;
        playAnimation("S_RUN");
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
        status = ONEH_STATUS.SPAWN;
        timer = spawnTime;
        target = -1;

        playAnimation("T_DEATH");
        callEvent("onBotDeath", pid, this);
    }

    function hitByPlayer(pid, dmg)
    {
        switch(status)
        {
            case ONEH_STATUS.SEARCH:
                target = pid;
                status = ONEH_STATUS.RUN;
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

    runAnimation = "";

    lastAttacks = null;
    basePosition = null;
    protection = null;
    wayBack = null;
}

function createOneH(_type, x,y,z)
{
    local bot = OneH(_type);
    bot.position = {x = x, y = y, z = z};
    bot.basePosition = {x = x, y = y, z = z};
    return BotIntegration.add(bot);
}
