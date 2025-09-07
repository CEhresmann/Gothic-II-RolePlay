
const CREDENTIALS_KEY = "loginCredentials";

Interface.LoggIn <- {	
	window = GUI.Window({
		positionPx = {x = 0.32 * Resolution.x, y = 0.15 * Resolution.y},
		sizePx = {width = 0.35 * Resolution.x, height = 0.65 * Resolution.y},
		file = "MENU_INGAME.TGA",
		color = {a = 180}
	}),

	"show" : function() {
		window.setVisible(true);
		Chat.setVisible(false);
	},

	"hide" : function() {
		window.setVisible(false);
		Chat.setVisible(true);
	}
};

Interface.LoggIn.logo <- GUI.Draw({
		relativePositionPx = {x = 0.08 * Resolution.x, y = 0.1 * Resolution.y},
		text = CFG.Hostname,
		collection = Interface.LoggIn.window
	})

Interface.LoggIn.username <- GUI.Input({
		relativePositionPx = {x = 0.075 * Resolution.x, y = 0.24 * Resolution.y},
		sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
		font = "FONT_OLD_10_WHITE_HI.TGA",
		file = "DLG_CONVERSATION.TGA",
		color = {a = 255},
		align = Align.Center,
		placeholder = _L("Username"),
		paddingPx = 5,
		collection = Interface.LoggIn.window
	})

Interface.LoggIn.password <- GUI.PasswordInput({
		relativePositionPx = {x = 0.075 * Resolution.x, y = 0.3 * Resolution.y},
		sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
		font = "FONT_OLD_10_WHITE_HI.TGA",
		file = "DLG_CONVERSATION.TGA",
		color = {a = 255},
		align = Align.Center,
		placeholder = _L("Password"),
		paddingPx = 5,
		collection = Interface.LoggIn.window
	})


Interface.LoggIn.rememberMeCheckbox <- GUI.CheckBox({
    relativePositionPx = {x = 0.1 * Resolution.x, y = 0.37 * Resolution.y},
    sizePx = {width = 0.02 * Resolution.x, height = 0.025 * Resolution.y},
    checkedFile = "INV_SLOT_EQUIPPED_HIGHLIGHTED_FOCUS.TGA",
    uncheckedFile = "INV_SLOT_EQUIPPED_FOCUS.TGA",
    collection = Interface.LoggIn.window
});

Interface.LoggIn.rememberMeDraw <- GUI.Draw({
    text = _L("Remember me"),
    relativePositionPx = {x = 0.14 * Resolution.x, y = 0.37 * Resolution.y},
    collection = Interface.LoggIn.window
});


Interface.LoggIn.loggInButton <- GUI.Button({
		relativePositionPx = {x = 0.075 * Resolution.x, y = 0.42 * Resolution.y},
		sizePx = {width = 0.095 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		draw = {text = _L("Logg In")},
		collection = Interface.LoggIn.window
	})

Interface.LoggIn.registerButton <- GUI.Button({
		relativePositionPx = {x = 0.18 * Resolution.x, y = 0.42 * Resolution.y},
		sizePx = {width = 0.095 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		draw = {text = _L("Register")},
		collection = Interface.LoggIn.window
	})

Interface.LoggIn.exitButton <- GUI.Button({
		relativePositionPx = {x = 0.075 * Resolution.x, y = 0.48 * Resolution.y},
		sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		draw = {text = _L("Exit")},
		collection = Interface.LoggIn.window
	})


Interface.LoggIn.logo.setFont("FONT_OLD_20_WHITE_HI.TGA");
Interface.LoggIn.logo.setColor({r = 200, g = 0, b = 0});
Interface.LoggIn.window.setColor({r = 255, g = 0, b = 0});
Interface.LoggIn.rememberMeDraw.setColor({r = 255, g = 255, b = 255});
Interface.LoggIn.rememberMeCheckbox.setColor({r = 255, g = 255, b = 255});

if(CFG.LanguageSwitcher)
{
	Interface.LoggIn.lang <- {};

	foreach(langKey, lang in CFG.Languages)
		Interface.LoggIn.lang[langKey] <- GUI.Draw({
		positionPx = {x = 0.01 * Resolution.x, y = (0.9 + 0.02 * lang.layout) * Resolution.y},
		text = lang.text,
		collection = Interface.LoggIn.window
	})
}

addEventHandler("onInit", function(){
	Camera.setPosition(2244, 1442, 2421);
	Interface.LoggIn.show();
	clearMultiplayerMessages();
	Interface.baseInterface(true,PLAYER_GUI.LOGGIN);
	
	local savedCredentials = LocalStorage.getItem(CREDENTIALS_KEY);
	if (savedCredentials != null && typeof savedCredentials == "table") {
		if ("username" in savedCredentials && "password" in savedCredentials) {
			Interface.LoggIn.username.setText(savedCredentials.username);
			Interface.LoggIn.password.setText(savedCredentials.password);
			Interface.LoggIn.rememberMeCheckbox.setChecked(true);
		}
	}
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
            
            if (Interface.LoggIn.rememberMeCheckbox.getChecked()) {
                local credentials = {
                    username = username,
                    password = password
                };
                LocalStorage.setItem(CREDENTIALS_KEY, credentials);
            } else {
                LocalStorage.removeItem(CREDENTIALS_KEY);
            }

			Player.packetLoggIn(username, password);
		break;
        
        case Interface.LoggIn.rememberMeCheckbox:
            if (!Interface.LoggIn.rememberMeCheckbox.getChecked()) {
                LocalStorage.removeItem(CREDENTIALS_KEY);
            }
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
    Interface.LoggIn.rememberMeDraw.setText(_L("Remember me"))
	Interface.LoggIn.exitButton.setText(_L("Exit"))
	Interface.LoggIn.loggInButton.setText(_L("Logg In"))
	Interface.LoggIn.registerButton.setText(_L("Register"))
});

setUnloadCallback(function() {
	Interface.LoggIn.window.setVisible(false);
});

setReloadCallback(function() {
	Interface.LoggIn.window.setVisible(true);
});
