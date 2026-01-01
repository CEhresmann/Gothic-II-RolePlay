

addEvent("onGUIClose")
addEvent("onGUIOpen")
addEvent("onEndDialog")
addEvent("onChangeLanguage");
addEvent("onMinute");
addEvent("onSecond");
addEvent("onObjectInteraction");

Resolution <- getResolution();

addEventHandler("onInit", function()
{
    enable_DamageAnims(CFG.DamageAnims);
})


local function cmdHandler(cmd, params)
{
	switch (cmd)
	{
	    case "h":
		    startTradeCommand(params);
		break;
	}
}

addEventHandler("onCommand", cmdHandler);
