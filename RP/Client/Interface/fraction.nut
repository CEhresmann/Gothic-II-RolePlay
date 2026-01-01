

Interface.Fraction <- {
    //window = GUI.Window(anx(Resolution.x/2-250), any(Resolution.y/2 - 150), anx(500), any(300), "MENU_INGAME.TGA", null, false)
	window = GUI.Window({
		positionPx = {x = 0.40 * Resolution.x, y = 0.30 * Resolution.y},
        sizePx = {width = 0.24 * Resolution.x, height = 0.25 * Resolution.y},
		file = "MENU_INGAME.TGA"
		color = {a = 180}
	})
    draws = []

    "show" : function() {
        Interface.baseInterface(true, PLAYER_GUI.FRACTION);
        window.setColor({r = 255, g = 0, b = 0});
        window.setVisible(true);
        change();
    }

    "hide" : function() {
        foreach(_draw in draws)
            _draw = null;

        draws.clear();

        Interface.baseInterface(false);
        window.setVisible(false);
    }

    "change" : function() {
        foreach(_draw in draws)
            _draw = null;

        draws.clear();

        local resignY = any(Resolution.y/2 - 130);
        foreach(_text in CFG.FractionDescription[Player.fractionId])
        {
            draws.append(Label(anx(Resolution.x/2-240), resignY, _text));
            resignY = resignY + any(30);
        }

        foreach(_draw in draws)
            _draw.visible = true;
    }
}

addEventHandler("onKeyDown", function(key) {
    if(key != KEY_ESCAPE)
        return;

    if(Player.gui != PLAYER_GUI.FRACTION)
        return;

    Interface.Fraction.hide();
})

