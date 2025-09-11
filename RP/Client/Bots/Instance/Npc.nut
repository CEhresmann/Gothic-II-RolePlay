class Npc extends Bot
{
    animation = null;
    isDialogue = false;

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

        // [FIX] Usunięto przestarzałe 'Items.id()'.
        // Nowe API G2O przyjmuje bezpośrednio tekstowe nazwy instancji przedmiotów.
        armor = _armor;
        melee = _melee;
        ranged = _ranged;
    }

    function onUpdate()
    {
        // 'element' jest właściwością dziedziczoną z klasy 'Bot', która przechowuje ID bota.
        if (element == null || !isPlayerStreamed(element))
            return;

        if (getPlayerAni(element) == animation)
            return;

        if (isDialogue)
            return;

        playAni(element, animation);
    }

    function playDialogue()
    {
        if (element == null) return;
        isDialogue = true;
        playGesticulation(element);
    }

    function stopDialogue()
    {
        if (element == null) return;
        isDialogue = false;
        playAni(element, animation);
    }
}

function createNPC(name, x, y, z, angle, armor, melee, ranged, bodyModel, bodyTxt, headModel, headTxt, animation)
{
    local bot = Npc(name, x, y, z, angle, armor, melee, ranged, bodyModel, bodyTxt, headModel, headTxt);
    bot.animation = animation;
    return BotIntegration.add(bot);
}
