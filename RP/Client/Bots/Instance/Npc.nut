
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

        instance = "PC_HERO";

        str = 1000;
        dex = 1000;

        hp = 10000;
        hpMax = 10000;

        armor = Items.id(_armor);
        melee = Items.id(_melee);
        ranged = Items.id(_ranged);

        isDialogue = false;
    }

    function onUpdate()
    {
        if(getPlayerAni(element) == animation)
            return

        if(isDialogue)
            return;

        playAni(element, animation)
    }


    function playDialogue()
    {
        isDialogue = true;
        playGesticulation(element);
    }

    function stopDialogue()
    {
        isDialogue = false;
        playAni(element, animation);
    }

    isDialogue = false;
}

function createNPC(name,x,y,z,angle,armor,melee,ranged,bodyModel,bodyTxt,headModel,headTxt,animation)
{
    local bot = Npc(name,x,y,z,angle,armor,melee,ranged,bodyModel,bodyTxt,headModel,headTxt);
    bot.animation = animation;
    return BotIntegration.add(bot);
}