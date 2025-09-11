local headmodel = ["Hum_Head_FatBald", "Hum_Head_Fighter", "Hum_Head_Pony", "Hum_Head_Bald", "Hum_Head_Thief", "Hum_Head_Psionic"];
local bodymodel = ["Hum_Body_Naked0", "Hum_Body_Babe0"];

Interface.Visual <- {
    workingSide = 0,
    activeWalking = null,
    changingElements = [],

    window = GUI.Window({
        positionPx = { x = 0.10 * Resolution.x, y = 0.30 * Resolution.y },
        sizePx = { width = 0.25 * Resolution.x, height = 0.50 * Resolution.y },
        file = "MENU_INGAME.TGA",
        color = { a = 180 }
    }),

    "show" : function() {
        Interface.baseInterface(true, PLAYER_GUI.VISUAL);
        window.setVisible(true);

        activeWalking = getPlayerPosition(heroId);
        changingElements.clear();

        Interface.Visual.leftButton.setVisible(true);
        Interface.Visual.rightButton.setVisible(true);
    },

    "hide" : function() {
        Interface.baseInterface(false);
        window.setVisible(false);

        if (changingElements.len() > 0) {
            foreach(_ass in changingElements)
                _ass.setVisible(false);

            changingElements.clear();
        }

        local visual = getPlayerVisual(heroId);
        Player.packetVisual(visual.bodyModel, visual.bodyTxt, visual.headModel, visual.headTxt);

        Interface.Visual.leftButton.setVisible(false);
        Interface.Visual.rightButton.setVisible(false);

        Interface.Visual.workingSide = 0;
    },

    "showCurrentOption" : function(opt) {
        if (changingElements.len() > 0) {
            foreach(_ass in changingElements)
                _ass.setVisible(false);

            changingElements.clear();
        }

        playAni(heroId, "S_WALK");
        workingSide = opt;

        switch (opt)
        {
            case 1:
                changingElements = [
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.3 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Man") } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.4 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Woman") } })
                ];
            break;
			case 2:
				local totalBodyTextures = CFG.BodyTexturesAmount;
				local texturesPerPage = 6;
				local maxScrollValue = totalBodyTextures - texturesPerPage;
				
				changingElements = [
					GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.3 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "HUM_BODY_NAKED_V0_C0.TGA", draw = { text = "" } }),
					GUI.Button({ positionPx = { x = 0.81 * Resolution.x, y = 0.3 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "HUM_BODY_NAKED_V1_C0.TGA", draw = { text = "" } }),
					GUI.Button({ positionPx = { x = 0.81 * Resolution.x, y = 0.41 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "HUM_BODY_NAKED_V2_C0.TGA", draw = { text = "" } }),
					GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.41 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "HUM_BODY_NAKED_V3_C0.TGA", draw = { text = "" } }),
					GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.52 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "HUM_BODY_NAKED_V4_C0.TGA", draw = { text = "" } }),
					GUI.Button({ positionPx = { x = 0.81 * Resolution.x, y = 0.52 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "HUM_BODY_NAKED_V5_C0.TGA", draw = { text = "" } }),
					GUI.ScrollBar({
						positionPx = { x = 0.7 * Resolution.x, y = 0.63 * Resolution.y },
						sizePx = { width = 0.2 * Resolution.x, height = 0.02 * Resolution.y },
						range = { 
							file = "MENU_INGAME.TGA", 
							indicator = { file = "BAR_MISC.TGA" }, 
							orientation = Orientation.Horizontal,
							minimum = 0,
							maximum = maxScrollValue,
							step = 1,
							value = 0
						},
						increaseButton = { file = "R.TGA" },
						decreaseButton = { file = "L.TGA" }
					})
				];
				
				local currentChangingElements = changingElements;
				
				changingElements[6].range.bind(EventType.Change, function(self) {
					local val = self.getValue();
					for(local i = 0; i < 6; i++) {
						local textureId = val + i;
						if (textureId >= totalBodyTextures) textureId = totalBodyTextures - 1;
						currentChangingElements[i].setFile("HUM_BODY_NAKED_V" + textureId + "_C0.TGA");
					}
				});
			break;
            case 3:
                changingElements = [
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.31 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Head") + " 1" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.37 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Head") + " 2" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.43 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Head") + " 3" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.49 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Head") + " 4" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.55 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Head") + " 5" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.61 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Head") + " 6" } })
                ];
            break;
            case 4:
				local totalHeadTextures = CFG.HeadTexturesAmount;
				local texturesPerPage = 6;
				local maxScrollValue = totalHeadTextures - texturesPerPage;
                changingElements = [
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.3 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "Hum_Head_V0_C0.TGA", draw = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.81 * Resolution.x, y = 0.3 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "Hum_Head_V1_C0.TGA", draw = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.81 * Resolution.x, y = 0.41 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "Hum_Head_V2_C0.TGA", draw = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.41 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "Hum_Head_V3_C0.TGA", draw = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.52 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "Hum_Head_V4_C0.TGA", draw = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.81 * Resolution.x, y = 0.52 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "Hum_Head_V5_C0.TGA", draw = { text = "" } }),
					GUI.ScrollBar({
						positionPx = { x = 0.7 * Resolution.x, y = 0.63 * Resolution.y },
						sizePx = { width = 0.2 * Resolution.x, height = 0.02 * Resolution.y },
						range = { 
							file = "MENU_INGAME.TGA", 
							indicator = { file = "BAR_MISC.TGA" }, 
							orientation = Orientation.Horizontal,
							minimum = 0,
							maximum = maxScrollValue,
							step = 1,
							value = 0
						},
						increaseButton = { file = "R.TGA" },
						decreaseButton = { file = "L.TGA" }
					})
				];
				
				local currentChangingElements = changingElements;
				
				changingElements[6].range.bind(EventType.Change, function(self) {
					local val = self.getValue();
					for(local i = 0; i < 6; i++) {
						local textureId = val + i;
						if (textureId >= totalHeadTextures) textureId = totalHeadTextures - 1;
						currentChangingElements[i].setFile("Hum_Head_V" + textureId + "_C0.TGA");
					}
				});
            break;
            case 5:
                changingElements = [
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.31 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Normal") } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.36 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Tired") } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.41 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Woman") } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.46 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Chill") } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.51 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Army") } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.56 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", draw = { text = _L("Mage") } })
                ];
            break;
        }

        foreach(_butt in changingElements)
            _butt.setVisible(true);
    },
};

Interface.Visual.window.setColor({r = 255, g = 0, b = 0});
Interface.Visual.maleButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.04 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		draw = {text = _L("Sex")},
		collection = Interface.Visual.window
	})
Interface.Visual.bodyButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.1 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		draw = {text = _L("Skin")},
		collection = Interface.Visual.window
	})
Interface.Visual.headButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.16 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		draw = {text = _L("Head")},
		collection = Interface.Visual.window
	})
Interface.Visual.faceButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.22 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		draw = {text = _L("Face")},
		collection = Interface.Visual.window
	})
Interface.Visual.walkButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.28 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		draw = {text = _L("Walking style")},
		collection = Interface.Visual.window
	})
Interface.Visual.leftButton <- GUI.Button({
		positionPx = {x = 0.4 * Resolution.x, y = 0.85 * Resolution.y},
        sizePx = {width = 0.03 * Resolution.x, height = 0.04 * Resolution.y},
		file = "L.TGA",
		draw = {text = ""}
	})

Interface.Visual.rightButton <- GUI.Button({
		positionPx = {x = 0.55 * Resolution.x, y = 0.85 * Resolution.y},
        sizePx = {width = 0.03 * Resolution.x, height = 0.04 * Resolution.y},
		file = "R.TGA",
		draw = {text = ""}
	})

addEventHandler("onRender", function() {
    if (Interface.Visual.workingSide == 0)
        return;

    if (Interface.Visual.workingSide == 5) {
        playAni(heroId, "S_WALKL");
        setPlayerPosition(heroId, Interface.Visual.activeWalking.x, Interface.Visual.activeWalking.y, Interface.Visual.activeWalking.z);
    }
});

addEventHandler("GUI.onClick", function(self)
{
    if (Player.gui != PLAYER_GUI.VISUAL) return;

    switch (self)
    {
        case Interface.Visual.leftButton:
            setPlayerAngle(heroId, (getPlayerAngle(heroId) - 20 + 360) % 360);
            break;
        case Interface.Visual.rightButton:
            setPlayerAngle(heroId, (getPlayerAngle(heroId) + 20) % 360);
            break;
        case Interface.Visual.maleButton: Interface.Visual.showCurrentOption(1); break;
        case Interface.Visual.bodyButton: Interface.Visual.showCurrentOption(2); break;
        case Interface.Visual.headButton: Interface.Visual.showCurrentOption(3); break;
        case Interface.Visual.faceButton: Interface.Visual.showCurrentOption(4); break;
        case Interface.Visual.walkButton: Interface.Visual.showCurrentOption(5); break;
    }

    local wyglad = getPlayerVisual(heroId);
    local changingElements = Interface.Visual.changingElements;
    if (changingElements.len() == 0) return;

    switch (Interface.Visual.workingSide)
    {
        case 1:
            if (self == changingElements[0])
                setPlayerVisual(heroId, bodymodel[0], wyglad.bodyTxt, wyglad.headModel, wyglad.headTxt);
            else if (self == changingElements[1])
                setPlayerVisual(heroId, bodymodel[1], wyglad.bodyTxt, wyglad.headModel, wyglad.headTxt);
            break;
        case 2:
            if (self != changingElements[6]) {
                local val = changingElements[6].range.getValue();
                local totalBodyTextures = CFG.BodyTexturesAmount;
                foreach(id, _butt in changingElements) {
                    if (_butt == self && id < 6) {
                        local textureId = val + id;
                        if (textureId >= totalBodyTextures) textureId = totalBodyTextures - 1;
                        setPlayerVisual(heroId, wyglad.bodyModel, textureId, wyglad.headModel, wyglad.headTxt);
                        break;
                    }
                }
            }
            break;
        case 3:
            foreach(id, _butt in changingElements) {
                if (_butt == self) {
                    setPlayerVisual(heroId, wyglad.bodyModel, wyglad.bodyTxt, headmodel[id], wyglad.headTxt);
                    break;
                }
            }
            break;
        case 4:
            if (self != changingElements[6]) {
                local val = changingElements[6].range.getValue();
                local totalHeadTextures = CFG.HeadTexturesAmount;
                foreach(id, _butt in changingElements) {
                    if (_butt == self && id < 6) {
                        local textureId = val + id;
                        if (textureId >= totalHeadTextures) textureId = totalHeadTextures - 1;
                        setPlayerVisual(heroId, wyglad.bodyModel, wyglad.bodyTxt, wyglad.headModel, textureId);
                        break;
                    }
                }
            }
            break;
        case 5:
            foreach(id, _butt in changingElements) {
                if (_butt == self) {
                    local walkStyleName = "HUMANS";
                    switch (id) {
                        case 1: walkStyleName = "HUMANS_TIRED"; break;
                        case 2: walkStyleName = "HUMANS_BABE"; break;
                        case 3: walkStyleName = "HUMANS_RELAXED"; break;
                        case 4: walkStyleName = "HUMANS_MILITIA"; break;
                        case 5: walkStyleName = "HUMANS_MAGE"; break;
                    }
                    Player.packetWalk(walkStyleName);
                    break;
                }
            }
            break;
    }
})

addEventHandler("GUI.onChange", function (self) {
    if (Interface.Visual.workingSide == 0 || Interface.Visual.changingElements.len() < 7) return;

    local changingElements = Interface.Visual.changingElements;

    switch (Interface.Visual.workingSide)
    {
        case 2:
            if (self == changingElements[6]) {
                local val = self.range.getValue();
                local baseTextureId = floor(val / 100.0 * 15); // Przeskalowanie wartości scrollbara na zakres tekstur ciała (0-15)
                for(local i = 0; i < 6; i++) {
                    local textureId = baseTextureId + i;
                    if (textureId > 15) textureId = 15; // Ograniczenie do maksymalnego ID
                    changingElements[i].setFile("HUM_BODY_NAKED_V" + textureId + "_C0.TGA");
                }
            }
            break;
        case 4:
            if (self == changingElements[6]) {
                local val = self.range.getValue();
                local baseTextureId = floor(val / 150.0 * 153); // Przeskalowanie wartości scrollbara na zakres tekstur głowy (0-153)
                for(local i = 0; i < 6; i++) {
                    local textureId = baseTextureId + i;
                    if (textureId > 158) textureId = 158; // Ograniczenie do maksymalnego ID
                    changingElements[i].setFile("Hum_Head_V" + textureId + "_C0.TGA");
                }
            }
            break;
    }
})

addEventHandler("onKeyDown", function(key) {
    if (key != KEY_ESCAPE)
        return;

    if (Player.gui != PLAYER_GUI.VISUAL)
        return;

    Interface.Visual.hide();
})

addEventHandler("onChangeLanguage", function(lang) {
    Interface.Visual.maleButton.setText(_L("Sex"));
    Interface.Visual.bodyButton.setText(_L("Skin"));
    Interface.Visual.headButton.setText(_L("Head"));
    Interface.Visual.faceButton.setText(_L("Face"));
    Interface.Visual.walkButton.setText(_L("Walking style"));
});