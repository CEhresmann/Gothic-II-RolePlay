
class BotSchedule
{
    constructor(_bot, _activities)
    {
        bot = _bot;
        activities = [];

        workingSchedule = false;
        activeSchedule = 0;

        foreach(activity in _activities)
        {
            local model = BotActivity();
            model.targetPosition = activity.position;
            model.targetAnimation = activity.animation;
            model.onHour = activity.hour;
            model.onMinute = activity.minute;
            model.isRuning = activity.run;
            activities.append(model);

            local tag = "botSchedule_"+bot.id+"_"+(activities.len()-1);
            gameTimeEvent.add(activity.hour, activity.minute, tag)
        }
    }

    function update()
    {
        if(!workingSchedule)
            return;

        local res = activities[activeSchedule].go(bot);

        if(res)
            workingSchedule = false;
    }

    function onStartActivity(id)
    {
        local activity = activities[id];
        activity.start(bot);

        workingSchedule = true;
        activeSchedule = id;
    }

    bot = null;

    workingSchedule = false;
    activeSchedule = 0;

    activities = null;
}