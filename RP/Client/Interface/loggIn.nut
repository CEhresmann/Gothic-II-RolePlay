Interface.LoggIn <- {
    //window = GUI.Window(anx(Resolution.x/2-250), any(Resolution.y/2 - 300), anx(500), any(460), "MENU_INGAME.TGA", null, false)
	window = GUI.Window({
		positionPx = {x = 0.32 * Resolution.x, y = 0.15 * Resolution.y},
        sizePx = {width = 0.35 * Resolution.x, height = 0.65 * Resolution.y},
		file = "MENU_INGAME.TGA"
		color = {a = 180}
	})

    "show" : function() {
        window.setVisible(true);
    }

    "hide" : function() {
        window.setVisible(false);
    }
};


Interface.LoggIn.logo <- /*GUI.Draw(anx(70), any(-40), CFG.Hostname, Interface.LoggIn.window) */ GUI.Draw({
		relativePositionPx = {x = 0.08 * Resolution.x, y = 0.1 * Resolution.y},
		text = CFG.Hostname,
		collection = Interface.LoggIn.window
	})


Interface.LoggIn.username <- /*GUI.Input(anx(20), any(120), anx(460), any(50), "DLG_CONVERSATION.TGA", "FONT_OLD_10_WHITE_HI.TGA", Input.Text, Align.Left, "...", 6, Interface.LoggIn.window) */ GUI.Input({
		relativePositionPx = {x = 0.075 * Resolution.x, y = 0.24 * Resolution.y}
        sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y}
		font = "FONT_OLD_10_WHITE_HI.TGA"
		file = "DLG_CONVERSATION.TGA"
		color = {a = 255}
		align = Align.Center
		placeholder = _L("Username")
		paddingPx = 5
		collection = Interface.LoggIn.window
	})
Interface.LoggIn.password <- /*GUI.Input(anx(20), any(220), anx(460), any(50), "DLG_CONVERSATION.TGA", "FONT_OLD_10_WHITE_HI.TGA", Input.Password, Align.Left, "...", 6, Interface.LoggIn.window) */ GUI.PasswordInput({
		relativePositionPx = {x = 0.075 * Resolution.x, y = 0.3 * Resolution.y}
        sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y}
		font = "FONT_OLD_10_WHITE_HI.TGA"
		file = "DLG_CONVERSATION.TGA"
		color = {a = 255}
		align = Align.Center
		placeholder = _L("Password")
		paddingPx = 5
		collection = Interface.LoggIn.window
	})

Interface.LoggIn.exitButton <- /*GUI.Button(anx(20), any(300), anx(210), any(50), "DLG_CONVERSATION.TGA", _L("Exit"), Interface.LoggIn.window) */ GUI.Button({
		relativePositionPx = {x = 0.10 * Resolution.x, y = 0.5 * Resolution.y},
        sizePx = {width = 0.15 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		draw = {text = _L("Exit")}
		collection = Interface.LoggIn.window
	})
Interface.LoggIn.loggInButton <- /*GUI.Button(anx(270), any(300), anx(210), any(50), "DLG_CONVERSATION.TGA", _L("Logg In"), Interface.LoggIn.window) */ GUI.Button({
		relativePositionPx = {x = 0.015 * Resolution.x, y = 0.44 * Resolution.y},
        sizePx = {width = 0.15 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		draw = {text = _L("Logg In")}
		collection = Interface.LoggIn.window
	})
Interface.LoggIn.registerButton <- /*GUI.Button(anx(20), any(370), anx(460), any(50), "DLG_CONVERSATION.TGA", _L("Register"), Interface.LoggIn.window) */ GUI.Button({
		relativePositionPx = {x = 0.18 * Resolution.x, y = 0.44 * Resolution.y},
        sizePx = {width = 0.15 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		draw = {text = _L("Register")}
		collection = Interface.LoggIn.window
	})

Interface.LoggIn.logo.setFont("FONT_OLD_20_WHITE_HI.TGA");
Interface.LoggIn.logo.setColor({r = 200, g = 0, b = 0});
Interface.LoggIn.window.setColor({r = 255, g = 0, b = 0});

if(CFG.LanguageSwitcher)
{
	Interface.LoggIn.lang <- {};

	foreach(langKey, lang in CFG.Languages)
		Interface.LoggIn.lang[langKey] <- /*GUI.Draw(anx(10) - anx(Resolution.x/2-250), any(Resolution.y/2 + 200 + 20*lang.layout), lang.text, Interface.LoggIn.window) */ GUI.Draw({
		positionPx = {x = 0.01 * Resolution.x, y = (0.9 + 0.02 * lang.layout) * Resolution.y}
		text = lang.text
		collection = Interface.LoggIn.window
	})
}

addEventHandler("onInit", function(){
	Camera.setPosition(2244, 1442, 2421);
    Interface.LoggIn.show();
	clearMultiplayerMessages();
	//setKeyLayout(CFG.Languages[CFG.DefaultLanguage].layout); -- Old, in the newest version API this function is deleted
    Interface.baseInterface(true,PLAYER_GUI.LOGGIN);
})

addEventHandler("GUI.onClick", function(self)
{
    if(Player.gui != PLAYER_GUI.LOGGIN)
        return;

	switch (self)
	{
		case Interface.LoggIn.exitButton:
			exitGame();
		break;

		case Interface.LoggIn.registerButton:
			Interface.LoggIn.hide();
			Interface.Register.show();
			Player.gui = PLAYER_GUI.REGISTER;
		break;

		case Interface.LoggIn.loggInButton:
			local username = Interface.LoggIn.username.getText();
			local password = Interface.LoggIn.password.getText();
			local hashedPassword = md5(password);
			Player.packetLoggIn(username, hashedPassword);
		break;
	}

	if(!CFG.LanguageSwitcher)
		return;

	foreach(keyLang, _button in Interface.LoggIn.lang)
	{
		if(_button == self)
			setPlayerLanguage(keyLang);
	}
})


addEventHandler("onChangeLanguage", function(lang) {
	Interface.LoggIn.username.setPlaceholder(_L("Username"))
	Interface.LoggIn.password.setPlaceholder(_L("Password"))

	Interface.LoggIn.exitButton.setText(_L("Exit"))
	Interface.LoggIn.loggInButton.setText(_L("Logg In"))
	Interface.LoggIn.registerButton.setText(_L("Register"))
});

setUnloadCallback(function() {
	Interface.LoggIn.window.setVisible(false);
});

setReloadCallback(function() {
    // Ukryj stare GUI
    Interface.LoggIn.window.setVisible(true);
});