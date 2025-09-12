class BotWaypoint
{
    constructor(end, start)
    {
        rWay = Way(CFG.BotWaypointMap, start, end);

        if(CFG.BotUseWaypoints == false)
            return false;
        
        currentWay = 0;

        currentPath = null;
        currentWaypoints = [];

        isEnd = false;

        foreach(_index, _tab in rWay.getWaypoints())
        {
            if(_tab != null)
                currentWaypoints.append(_tab);
        }

        currentPath = getWaypoint(CFG.BotWaypointMap, currentWaypoints[0]);
    }

    function checkForBot(bot)
    {
        local distance = getDistance3d(bot.position.x, bot.position.y, bot.position.z, currentPath.x, currentPath.y, currentPath.z);
        if(distance < 200)
        {
            if((currentWay-1) >= currentWaypoints.len())
            {
                isEnd = true;
                return;
            }

            currentWay ++;
            if(currentWay < currentWaypoints.len())
                currentPath = getWaypoint(CFG.BotWaypointMap, currentWaypoints[currentWay]);
        }else
            turnIntoPath(bot)
    }

    function turnIntoPath(bot)
    {
        local _angle = getVectorAngle(bot.position.x,bot.position.z,currentPath.x,currentPath.z);
        local angleDiff = abs(_angle - bot.angle);

        if(angleDiff > 10)
            bot.setAngle(_angle);
    }

    isEnd = false;

    currentWay = -1;
    currentWaypoints = -1;
    currentPath = null;

    rWay = null;
}