
enum MONSTER_STATUS
{
    SPAWN,
    SEARCH,
    WARN,
    RUN,
    ATTACK,
    BACK
}

class Npc extends Bot
{
    constructor(_name, _x, _y, _z, _angle, _armor, _melee, _ranged, _bodyModel, _bodyTxt, _headModel, _headTxt)
    {
        base.constructor(_name)

        bodyModel = _bodyModel;
        bodyTxt = _bodyTxt;
        headModel = _headModel;
        headTxt = _headTxt;

        position = {x = _x, y = _y, z = _z};
        angle = _angle;

        str = 1000;
        dex = 1000;

        hp = 100000;
        hpMax = 100000;

        armor = _armor;
        melee = _melee;
        ranged = _ranged;
    }

    function update()
    {
        if(schedule)
            schedule.update();
    }

    function onGetScheduleEvent(id)
    {
        schedule.onStartActivity(id);
    }

    function hitByPlayer(pid, dmg)
    {
        kick(pid, "Nie bij NPC!");
    }
}

function createNPC(name,x,y,z,angle,armor,melee,ranged,bodyModel,bodyTxt,headModel,headTxt,animation)
{
    local bot = Npc(name,x,y,z,angle,armor,melee,ranged,bodyModel,bodyTxt,headModel,headTxt)
    bot.animation = animation;
    return BotIntegration.add(bot);
}