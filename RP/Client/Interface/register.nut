
Interface.Register <- {
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

Interface.Register.logo <- /*GUI.Draw(anx(70), any(-40), CFG.Hostname, Interface.Register.window) */ GUI.Draw({
		relativePositionPx = {x = 0.08 * Resolution.x, y = 0.1 * Resolution.y},
		text = CFG.Hostname,
		collection = Interface.Register.window
	})

Interface.Register.username <- /*GUI.Input(anx(20), any(30), anx(460), any(50), "DLG_CONVERSATION.TGA", "FONT_OLD_10_WHITE_HI.TGA", Input.Text, Align.Left, "...", 6, Interface.Register.window)*/ GUI.Input({
		relativePositionPx = {x = 0.075 * Resolution.x, y = 0.24 * Resolution.y}
        sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y}
		font = "FONT_OLD_10_WHITE_HI.TGA"
		file = "DLG_CONVERSATION.TGA"
		color = {a = 255}
		align = Align.Center
		placeholder = _L("Username")
		paddingPx = 5
		collection = Interface.Register.window
	})

Interface.Register.password <- /*GUI.Input(anx(20), any(130), anx(460), any(50), "DLG_CONVERSATION.TGA", "FONT_OLD_10_WHITE_HI.TGA", Input.Password, Align.Left, "...", 6, Interface.Register.window)*/ GUI.PasswordInput({
		relativePositionPx = {x = 0.075 * Resolution.x, y = 0.3 * Resolution.y}
        sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y}
		font = "FONT_OLD_10_WHITE_HI.TGA"
		file = "DLG_CONVERSATION.TGA"
		color = {a = 255}
		align = Align.Center
		placeholder = _L("Password")
		paddingPx = 5
		collection = Interface.Register.window
	})
Interface.Register.passwordRepeat <- /*GUI.Input(anx(20), any(230), anx(460), any(50), "DLG_CONVERSATION.TGA", "FONT_OLD_10_WHITE_HI.TGA", Input.Password, Align.Left, "...", 6, Interface.Register.window)*/ GUI.PasswordInput({
		relativePositionPx = {x = 0.075 * Resolution.x, y = 0.35 * Resolution.y}
        sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y}
		font = "FONT_OLD_10_WHITE_HI.TGA"
		file = "DLG_CONVERSATION.TGA"
		color = {a = 255}
		align = Align.Center
		placeholder = _L("Password")
		paddingPx = 5
		collection = Interface.Register.window
	})

Interface.Register.exitButton <- /*GUI.Button(anx(20), any(320), anx(210), any(50), "DLG_CONVERSATION.TGA", _L("Exit"), Interface.Register.window)*/ GUI.Button({
		relativePositionPx = {x = 0.10 * Resolution.x, y = 0.5 * Resolution.y},
        sizePx = {width = 0.15 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		draw = {text = _L("Exit")}
		collection = Interface.Register.window
	})
Interface.Register.registerButton <- /*GUI.Button(anx(270), any(320), anx(210), any(50), "DLG_CONVERSATION.TGA", _L("Register"), Interface.Register.window)*/ GUI.Button({
		relativePositionPx = {x = 0.18 * Resolution.x, y = 0.44 * Resolution.y},
        sizePx = {width = 0.15 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		draw = {text = _L("Register")}
		collection = Interface.Register.window
	})

Interface.Register.loggInButton <- /*GUI.Button(anx(20), any(390), anx(460), any(50), "DLG_CONVERSATION.TGA", _L("Logg In"), Interface.Register.window)*/ GUI.Button({
		relativePositionPx = {x = 0.015 * Resolution.x, y = 0.44 * Resolution.y},
        sizePx = {width = 0.15 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		draw = {text = _L("Logg In")}
		collection = Interface.Register.window
	})

Interface.Register.logo.setFont("FONT_OLD_20_WHITE_HI.TGA");
Interface.Register.logo.setColor({r = 200, g = 0, b = 0});
Interface.Register.window.setColor({r = 255, g = 0, b = 0});

addEventHandler("GUI.onClick", function(self)
{
    if(Player.gui != PLAYER_GUI.REGISTER)
        return;

	switch (self)
	{
		case Interface.Register.exitButton:
			exitGame();
		break;

		case Interface.Register.loggInButton:
			Interface.Register.hide();
			Interface.LoggIn.show();
            Player.gui = PLAYER_GUI.LOGGIN;
		break;

		case Interface.Register.registerButton:
			if(Interface.Register.password.getText() != Interface.Register.passwordRepeat.getText())
			{
				intimate(_L("Incorrect password."));
				return;
			}
			if(Interface.Register.username.getText().len() < 3 || Interface.Register.password.getText().len() < 3)
			{
				intimate(_L("Incorrect password or username."));
				return;
			}
			Player.packetRegister(Interface.Register.username.getText(), md5(Interface.Register.password.getText()));
		break;
	}
})

addEventHandler("onChangeLanguage", function(lang) {
	Interface.Register.username.setPlaceholder(_L("Username"))
	Interface.Register.password.setPlaceholder(_L("Password"))
	Interface.Register.passwordRepeat.setPlaceholder(_L("Password"))

	Interface.Register.exitButton.setText(_L("Exit"))
	Interface.Register.loggInButton.setText(_L("Logg In"))
	Interface.Register.registerButton.setText(_L("Register"))
});