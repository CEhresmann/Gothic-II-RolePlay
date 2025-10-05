
Interface.MenuGame <- {
	window = GUI.Window({
		positionPx = {x = 0.40 * Resolution.x, y = 0.30 * Resolution.y},
        sizePx = {width = 0.20 * Resolution.x, height = 0.325 * Resolution.y},
		file = "MENU_INGAME.TGA"
		color = {a = 255}
	})

    "show" : function() {
        Interface.baseInterface(true, PLAYER_GUI.MENUINGAME);
        window.setVisible(true);
    }

    "hide" : function() {
        Interface.baseInterface(false);
        window.setVisible(false);
    }

    "toggle" : function() {
        if(Player.gui == -1) {
            show();
            return;
        }

        if(Player.gui == PLAYER_GUI.MENUINGAME)
            hide();
    }
};

Interface.MenuGame.window.setColor({r = 255, g = 0, b = 0});
Interface.MenuGame.backButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.03 * Resolution.y},
        sizePx = {width = 0.18 * Resolution.x, height = 0.04 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		label = {text = _L("Back")}
		collection = Interface.MenuGame.window
	})
Interface.MenuGame.visualButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.08 * Resolution.y},
        sizePx = {width = 0.18 * Resolution.x, height = 0.04 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		label = {text = _L("Visual")}
		collection = Interface.MenuGame.window
	})
Interface.MenuGame.fractionButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.13 * Resolution.y},
        sizePx = {width = 0.18 * Resolution.x, height = 0.04 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		label = {text = _L("Fraction")}
		collection = Interface.MenuGame.window
	})
Interface.MenuGame.settingsButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.18 * Resolution.y},
        sizePx = {width = 0.18 * Resolution.x, height = 0.04 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		label = {text = _L("Settings")}
		collection = Interface.MenuGame.window
	})
Interface.MenuGame.exitButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.26 * Resolution.y},
        sizePx = {width = 0.18 * Resolution.x, height = 0.04 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		label = {text = _L("Exit")}
		collection = Interface.MenuGame.window
	})

addEventHandler("GUI.onClick", function(self)
{
    if(Player.gui != PLAYER_GUI.MENUINGAME)
        return;

	switch (self)
	{
		case Interface.MenuGame.backButton:
			Interface.MenuGame.hide();
		break;
        case Interface.MenuGame.visualButton:
            Interface.MenuGame.hide();
            Interface.Visual.show();
        break;
        case Interface.MenuGame.fractionButton:
            Interface.MenuGame.hide();
            Interface.Fraction.show();
        break;
        case Interface.MenuGame.settingsButton:
            Interface.MenuGame.hide();
            Interface.Settings.show();
        break;
		case Interface.MenuGame.exitButton:
			exitGame();
		break;
	}
})

addEventHandler("onKeyDown",function(key)
{
	if (chatInputIsOpen())
		return

	if (isConsoleOpen())
		return

    if(key == KEY_ESCAPE)
        Interface.MenuGame.toggle();
})

addEventHandler("onChangeLanguage", function(lang) {
    Interface.MenuGame.backButton.setText(_L("Back"));
    Interface.MenuGame.visualButton.setText(_L("Visual"));
    Interface.MenuGame.fractionButton.setText(_L("Fraction"));
    Interface.MenuGame.settingsButton.setText(_L("Settings"));
    Interface.MenuGame.exitButton.setText(_L("Exit"));
});

