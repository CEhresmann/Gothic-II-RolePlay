
class Monster extends Bot
{
    constructor(zType)
    {
        base.constructor(zType.name)

        str = zType.str;
        dex = zType.str;

        hp = zType.hp;
        hpMax = zType.hpMax;

        instance = zType.instance;
    }

    function onUpdate() {}
}

function createMonster(_type, x,y,z)
{
    local bot = Monster(_type);
    bot.position = {x = x, y = y, z = z};
    return BotIntegration.add(bot);
}