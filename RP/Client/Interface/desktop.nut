
local desktopName = Label(100, 7320, "");
local className = Label(100, 7500, "");
local timeDraw = Label(0,0, "");

local nextTick = getTickCount() + 500;

addEventHandler("onRender", function()
{
    if(!timeDraw.visible)
        return;

    local tick = getTickCount();
    if (tick >= nextTick)
    {
        desktopName.text = _L("Nick: %s",getPlayerName(heroId));
        local timeDay = date();
        className.text = _L("Class: %s",getPlayerClass(heroId));
        timeDraw.text = timeDay.hour+":"+timeDay.min;
        timeDraw.setPosition(8100 - timeDraw.width, 7950);
        tick = getTickCount() + 1000;
    }
});

function setDesktopVisual(val)
{
    desktopName.visible = val;
    className.visible = val;
    timeDraw.visible = val;
}

addEventHandler("onGUIClose", function () {
    setDesktopVisual(true);
})

addEventHandler("onGUIOpen", function() {
    setDesktopVisual(false);
})