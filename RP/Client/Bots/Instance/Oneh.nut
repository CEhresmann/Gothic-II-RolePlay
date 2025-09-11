
class OneH extends Bot
{
    constructor(zType)
    {
        base.constructor(zType.name)

        str = zType.str;
        dex = zType.str;

        hp = zType.hp;
        hpMax = zType.hpMax;

        instance = zType.instance;

        bodyModel = "Hum_Body_Naked0";
        bodyTxt = 9;
        headModel = "Hum_Head_Psionic";
        headTxt = rand() % 100 + 1;

        weapon = zType.weapon;

        armor = Items.id(zType.armor);
        melee = Items.id(zType.melee);
        ranged = Items.id(zType.ranged);
    }

    function onUpdate() {}
}

function createOneH(_type, x,y,z)
{
    local bot = OneH(_type);
    bot.position = {x = x, y = y, z = z};
    return BotIntegration.add(bot);
}