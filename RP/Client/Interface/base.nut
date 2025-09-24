
Interface <- {};

function Interface::baseInterface(value, id = -1)
{
    Camera.setFreeze(value);

    setHudMode(HUD_HEALTH_BAR,(!value).tointeger());
    setHudMode(HUD_MANA_BAR,(!value).tointeger());

    for(local i = 0; i<200; i++)
      disableKey(i, value);
    
    Player.gui = id;

    if(id != -1)
      callEvent("onGUIOpen");
    else
      callEvent("onGUIClose");

    disableKey(1, true);
    setFreeze(value)
	ShowChat(!value);
	setCursorVisible(value)
}

/*
addEventHandler("GUI.onMouseIn", function(self)
{
    if(Player.gui == -1)
        return;

    if(self instanceof GUI.Button || self instanceof GUI.Input)
		local color = self.getColor();
		self.setColor({r = color.r, g = color.g, b = color.b, a = 200});
})

addEventHandler("GUI.onMouseOut", function(self)
{
    if(Player.gui == -1)
        return;

    if(self instanceof GUI.Button || self instanceof GUI.Input)
		local color = self.getColor();
		self.setColor({r = color.r, g = color.g, b = color.b, a = 255});
})*/