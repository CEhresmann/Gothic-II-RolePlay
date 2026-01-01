local tickTime = 0;

addEventHandler("onInit", function()
{
	setTimer(function()
	{
		callEvent("onTick");
		tickTime = tickTime + 50;
	}, 50, 0);

	setTimer(function()
	{
		callEvent("onSecond");
    }, 1000, 0);

    setTimer(function()
	{
		callEvent("onMinute");
	}, 1000 * 60, 0);
});

function getTickCount()
{
	return tickTime;
}

