local headmodel = ["Hum_Head_FatBald", "Hum_Head_Fighter", "Hum_Head_Pony", "Hum_Head_Bald", "Hum_Head_Thief", "Hum_Head_Psionic", 
                   "HUM_HEAD_BABE", "HUM_HEAD_BABE1", "HUM_HEAD_BABE2", "HUM_HEAD_BABE3", "HUM_HEAD_BABE4", 
                   "HUM_HEAD_BABE5", "HUM_HEAD_BABE6", "HUM_HEAD_BABE7", "HUM_HEAD_BABE8"];
local bodymodel = ["Hum_Body_Naked0", "Hum_Body_Babe0"];


if (!("packetFatness" in Player)) {
    function Player::packetFatness(value) {
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.Fatness);
        packet.writeFloat(value);
        packet.send(RELIABLE_ORDERED);
    }
}

if (!("packetScale" in Player)) {
    function Player::packetScale(x, y, z) {
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.Scale);
        packet.writeFloat(x);
        packet.writeFloat(y);
        packet.writeFloat(z);
        packet.send(RELIABLE_ORDERED);
    }
}


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
        if (this.changingElements.len() > 0) {
            foreach(_ass in this.changingElements)
                _ass.setVisible(false);

            this.changingElements.clear();
        }

        playAni(heroId, "S_WALK");
        this.workingSide = opt;

        switch (opt)
        {
            case 1:
                this.changingElements = [
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.3 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = _L("Man") } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.4 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = _L("Woman") } })
                ];
            break;
			case 2:
				local totalBodyTextures = CFG.BodyTexturesAmount;
				local texturesPerPage = 6;
				local maxScrollValue = totalBodyTextures - texturesPerPage;

				this.changingElements = [
					GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.3 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "HUM_BODY_NAKED_V0_C0.TGA", label = { text = "" } }),
					GUI.Button({ positionPx = { x = 0.81 * Resolution.x, y = 0.3 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "HUM_BODY_NAKED_V1_C0.TGA", label = { text = "" } }),
					GUI.Button({ positionPx = { x = 0.81 * Resolution.x, y = 0.41 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "HUM_BODY_NAKED_V2_C0.TGA", label = { text = "" } }),
					GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.41 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "HUM_BODY_NAKED_V3_C0.TGA", label = { text = "" } }),
					GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.52 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "HUM_BODY_NAKED_V4_C0.TGA", label = { text = "" } }),
					GUI.Button({ positionPx = { x = 0.81 * Resolution.x, y = 0.52 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "HUM_BODY_NAKED_V5_C0.TGA", label = { text = "" } }),
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

				local currentChangingElements = this.changingElements;

				this.changingElements[6].range.bind(EventType.Change, function(self) {
					local val = self.getValue();
					for(local i = 0; i < 6; i++) {
						local textureId = val + i;
						if (textureId >= totalBodyTextures) textureId = totalBodyTextures - 1;
						currentChangingElements[i].setFile("HUM_BODY_NAKED_V" + textureId + "_C0.TGA");
					}
				});
			break;
            case 3:
                local totalHeadModels = headmodel.len();
                local modelsPerPage = 6;
                local maxScrollValue = totalHeadModels - modelsPerPage;
                if (maxScrollValue < 0) maxScrollValue = 0;

                this.changingElements = [
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.31 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.37 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.43 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.49 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.55 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.61 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = "" } }),
                    GUI.ScrollBar({
                        positionPx = { x = 0.92 * Resolution.x, y = 0.31 * Resolution.y },
                        sizePx = { width = 0.015 * Resolution.x, height = 0.35 * Resolution.y },
                        range = {
                            file = "MENU_INGAME.TGA",
                            indicator = { file = "BAR_MISC.TGA" },
                            orientation = Orientation.Vertical,
                            minimum = 0,
                            maximum = maxScrollValue,
                            step = 1,
                            value = 0
                        },
                        increaseButton = { file = "U.TGA" },
                        decreaseButton = { file = "O.TGA" }
                    })
                ];

                local currentVisualInterface = this;
                local function updateHeadModelButtons(scrollValue) {
                    for(local i = 0; i < 6; i++) {
                        local modelIndex = scrollValue + i;
                        if (modelIndex < totalHeadModels) {
                            currentVisualInterface.changingElements[i].setText(_L("Head") + " " + (modelIndex + 1));
                            currentVisualInterface.changingElements[i].setVisible(true);
                        } else {
                            currentVisualInterface.changingElements[i].setVisible(false);
                        }
                    }
                }

                updateHeadModelButtons(0);

                this.changingElements[6].range.bind(EventType.Change, function(self) {
                    updateHeadModelButtons(self.getValue());
                });
            break;
            case 4:
				local totalHeadTextures = CFG.HeadTexturesAmount;
				local texturesPerPage = 6;
				local maxScrollValue = totalHeadTextures - texturesPerPage;
                this.changingElements = [
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.3 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "Hum_Head_V0_C0.TGA", label = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.81 * Resolution.x, y = 0.3 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "Hum_Head_V1_C0.TGA", label = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.81 * Resolution.x, y = 0.41 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "Hum_Head_V2_C0.TGA", label = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.41 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "Hum_Head_V3_C0.TGA", label = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.52 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "Hum_Head_V4_C0.TGA", label = { text = "" } }),
                    GUI.Button({ positionPx = { x = 0.81 * Resolution.x, y = 0.52 * Resolution.y }, sizePx = { width = 0.1 * Resolution.x, height = 0.1 * Resolution.y }, file = "Hum_Head_V5_C0.TGA", label = { text = "" } }),
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

				local currentChangingElements = this.changingElements;

				this.changingElements[6].range.bind(EventType.Change, function(self) {
					local val = self.getValue();
					for(local i = 0; i < 6; i++) {
						local textureId = val + i;
						if (textureId >= totalHeadTextures) textureId = totalHeadTextures - 1;
						currentChangingElements[i].setFile("Hum_Head_V" + textureId + "_C0.TGA");
					}
				});
            break;
            case 5:
                this.changingElements = [
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.31 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = _L("Normal") } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.36 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = _L("Tired") } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.41 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = _L("Woman") } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.46 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = _L("Chill") } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.51 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = _L("Army") } }),
                    GUI.Button({ positionPx = { x = 0.7 * Resolution.x, y = 0.56 * Resolution.y }, sizePx = { width = 0.2 * Resolution.x, height = 0.05 * Resolution.y }, file = "MENU_INGAME.TGA", label = { text = _L("Mage") } })
                ];
            break;
            case 6: // Fatness
                local currentFatness = getPlayerFatness(heroId);
                this.changingElements = [
                    GUI.ScrollBar({
                        positionPx = { x = 0.7 * Resolution.x, y = 0.4 * Resolution.y },
                        sizePx = { width = 0.2 * Resolution.x, height = 0.02 * Resolution.y },
                        range = {
                            file = "MENU_INGAME.TGA",
                            indicator = { file = "BAR_MISC.TGA" },
                            orientation = Orientation.Horizontal,
                            minimum = -50,
                            maximum = 200,
                            step = 1,
                            value = (currentFatness * 100).tointeger()
                        },
                        increaseButton = { file = "R.TGA" },
                        decreaseButton = { file = "L.TGA" }
                    }),
                    GUI.Label({
                        positionPx = { x = 0.7 * Resolution.x, y = 0.43 * Resolution.y },
                        label = { text = "", align = Align.Center }
                    })
                ];

                this.changingElements[1].setText("Grubość: " + (currentFatness * 100).tointeger() + "%");

                local currentChangingElements = this.changingElements;
                this.changingElements[0].range.bind(EventType.Change, function(self) {
                    local fatnessValue = self.getValue() / 100.0;
                    //setPlayerFatness(heroId, fatnessValue);
                    Player.packetFatness(fatnessValue);
                    currentChangingElements[1].setText("Grubość: " + self.getValue() + "%");
                });
                break;

            case 7: // Scale
                local currentScale = getPlayerScale(heroId);
                this.changingElements = [
                    GUI.Label({
                        positionPx = { x = 0.7 * Resolution.x, y = 0.3 * Resolution.y },
                        label = { text = "", align = Align.Center }
                    }),
                    GUI.ScrollBar({
                        positionPx = { x = 0.7 * Resolution.x, y = 0.33 * Resolution.y },
                        sizePx = { width = 0.2 * Resolution.x, height = 0.02 * Resolution.y },
                        range = {
                            file = "MENU_INGAME.TGA",
                            indicator = { file = "BAR_MISC.TGA" },
                            orientation = Orientation.Horizontal,
                            minimum = 75,
                            maximum = 110,
                            step = 1,
                            value = (currentScale.x * 100).tointeger()
                        },
                        increaseButton = { file = "R.TGA" },
                        decreaseButton = { file = "L.TGA" }
                    })
                ];

                this.changingElements[0].setText("Wysokość: " + format("%.2f", currentScale.x));

                local currentChangingElements = this.changingElements;

                this.changingElements[1].range.bind(EventType.Change, function(self) {
                    local scaleValue = self.getValue() / 100.0;
                    //setPlayerScale(heroId, scaleValue, scaleValue, scaleValue);
                    Player.packetScale(scaleValue, scaleValue, scaleValue);
                    currentChangingElements[0].setText("Wysokość: " + format("%.2f", scaleValue));
                });
                break;
        }

        foreach(_butt in this.changingElements)
            _butt.setVisible(true);
    },
};

Interface.Visual.window.setColor({r = 255, g = 0, b = 0});
Interface.Visual.maleButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.04 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		label = {text = _L("Sex")},
		collection = Interface.Visual.window
	})
Interface.Visual.bodyButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.1 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		label = {text = _L("Skin")},
		collection = Interface.Visual.window
	})
Interface.Visual.headButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.16 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		label = {text = _L("Head")},
		collection = Interface.Visual.window
	})
Interface.Visual.faceButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.22 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		label = {text = _L("Face")},
		collection = Interface.Visual.window
	})
Interface.Visual.walkButton <- GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.28 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA",
		label = {text = _L("Walking style")},
		collection = Interface.Visual.window
	})
Interface.Visual.fatnessButton <- GUI.Button({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.34 * Resolution.y},
    sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
    file = "DLG_CONVERSATION.TGA",
    label = {text = "Grubość"},
    collection = Interface.Visual.window
})

Interface.Visual.scaleButton <- GUI.Button({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.40 * Resolution.y},
    sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
    file = "DLG_CONVERSATION.TGA",
    label = {text = "Wysokość"},
    collection = Interface.Visual.window
})
Interface.Visual.leftButton <- GUI.Button({
		positionPx = {x = 0.4 * Resolution.x, y = 0.85 * Resolution.y},
        sizePx = {width = 0.03 * Resolution.x, height = 0.04 * Resolution.y},
		file = "L.TGA",
		label = {text = ""}
	})

Interface.Visual.rightButton <- GUI.Button({
		positionPx = {x = 0.55 * Resolution.x, y = 0.85 * Resolution.y},
        sizePx = {width = 0.03 * Resolution.x, height = 0.04 * Resolution.y},
		file = "R.TGA",
		label = {text = ""}
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
        case Interface.Visual.fatnessButton: Interface.Visual.showCurrentOption(6); break;
        case Interface.Visual.scaleButton: Interface.Visual.showCurrentOption(7); break;
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
            local scrollValue = changingElements[6].range.getValue();
            foreach(id, _butt in changingElements) {
                if (_butt == self && id < 6) {
                    local modelIndex = scrollValue + id;
                    if (modelIndex < headmodel.len()) {
                        setPlayerVisual(heroId, wyglad.bodyModel, wyglad.bodyTxt, headmodel[modelIndex], wyglad.headTxt);
                    }
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
                local baseTextureId = floor(val / 100.0 * 15);
                for(local i = 0; i < 6; i++) {
                    local textureId = baseTextureId + i;
                    if (textureId > 15) textureId = 15;
                    changingElements[i].setFile("HUM_BODY_NAKED_V" + textureId + "_C0.TGA");
                }
            }
            break;
        case 4:
            if (self == changingElements[6]) {
                local val = self.range.getValue();
                local baseTextureId = floor(val / 150.0 * 153);
                for(local i = 0; i < 6; i++) {
                    local textureId = baseTextureId + i;
                    if (textureId > 158) textureId = 158;
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
    Interface.Visual.fatnessButton.setText("Grubość");
    Interface.Visual.scaleButton.setText("Wysokość");
});