
class BotActivity
{
    constructor()
    {
        targetPosition = null;
        targetAnimation = "";
        onHour = 0;
        onMinute = 0;

        isRuning = false;
        runAnimation = "";

        way = null;
    }

    function go(bot)
    {
        if(bot.streamer == -1)
        {
            end(bot);
            way = null;
            return true;
        }

        if(bot.animation != runAnimation)
            bot.playAnimation(runAnimation);

        if(way == null)
        {
            end(bot);
            way = null;
            return true;
        }
        else
        {
            way.checkForBot(bot);

            if(way.isEnd)
            {
                end(bot);
                way = null;
                return true;
            }
        }

        return false;
    }

    function end(bot)
    {
        bot.setPosition(targetPosition.x, targetPosition.y, targetPosition.z);
        bot.setAngle(targetPosition.angle);
        bot.playAnimation(targetAnimation);
    }

    function start(bot)
    {
        if(bot.instance == "PC_HERO")
        {
            if(isRuning)
                runAnimation = "S_RUNL";
            else
                runAnimation = "S_WALKL";
        }
        else
        {
            if(isRuning)
                runAnimation = "S_FISTRUNL";
            else
                runAnimation = "S_FISTWALKL";
        }

        if(getDistance2d(bot.position.x, bot.position.z, targetPosition.x, targetPosition.z) > 300)
            way = BotWaypoint(getNearestWaypoint(CFG.BotWaypointMap, bot.position.x, bot.position.y, bot.position.z).name, getNearestWaypoint(CFG.BotWaypointMap,targetPosition.x, targetPosition.y, targetPosition.z).name)
    }

    targetPosition = null;
    targetAnimation = "";
    onHour = 0;
    onMinute = 0;

    isRuning = false;
    runAnimation = "";

    way = null;
}