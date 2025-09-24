
addEventHandler("onInit", function()
{
	setTimer(function()
	{
		callEvent("onSecond");
    }, 1000, 0);

    setTimer(function()
	{
		callEvent("onMinute");
	}, 1000 * 60, 0);
});
