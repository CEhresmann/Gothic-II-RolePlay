local headmodel = ["Hum_Head_FatBald","Hum_Head_Fighter","Hum_Head_Pony","Hum_Head_Bald","Hum_Head_Thief","Hum_Head_Psionic"];
local bodymodel = ["Hum_Body_Naked0","Hum_Body_Babe0"];

Interface.Visual <- {
    workingSide = 0
    activeWalking = null
    changingElements = []

    //window = GUI.Window(anx(100), any(Resolution.y/2 - 200), anx(400), any(420), "MENU_INGAME.TGA", null, false)
	window = GUI.Window({
		positionPx = {x = 0.10 * Resolution.x, y = 0.30 * Resolution.y},
        sizePx = {width = 0.25 * Resolution.x, height = 0.50 * Resolution.y},
		file = "MENU_INGAME.TGA"
		color = {a = 180}
	})

    "show" : function() {
        Interface.baseInterface(true, PLAYER_GUI.VISUAL);
        window.setVisible(true);

        activeWalking = getPlayerPosition(heroId);
        changingElements.clear();

        Interface.Visual.leftButton.setVisible(true);
        Interface.Visual.rightButton.setVisible(true);
    }

    "hide" : function() {
        Interface.baseInterface(false);
        window.setVisible(false);

        if(changingElements.len() > 0) {
            foreach(_ass in changingElements)
                _ass.setVisible(false);

            changingElements.clear();
        }
        
        local visual = getPlayerVisual(heroId);
        Player.packetVisual(visual.bodyModel, visual.bodyTxt, visual.headModel, visual.headTxt);

        Interface.Visual.leftButton.setVisible(false);
        Interface.Visual.rightButton.setVisible(false);

        Interface.Visual.workingSide = 0;
    }

    "showCurrentOption" : function(opt)
    {
        if(changingElements.len() > 0) {
            foreach(_ass in changingElements)
                _ass.setVisible(false);

            changingElements.clear();
        }

        playAni(heroId, "S_WALK");
        workingSide = opt;

        switch(opt)
        {
            case 1:
                changingElements = [
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 280), anx(260), any(50), "MENU_INGAME.TGA", _L("Man")),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.3 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text =  _L("Man")}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 210), anx(260), any(50), "MENU_INGAME.TGA", _L("Woman")),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.4 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Woman")}
					})
                ];
                
                foreach(_butt in changingElements)
                    _butt.setVisible(true);
            break;
            case 2:
                changingElements = [
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 280), anx(120), any(80), "HUM_BODY_NAKED_V0_C0.TGA", ""),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.3 * Resolution.y},
						sizePx = {width = 0.1 * Resolution.x, height = 0.1 * Resolution.y},
						file = "HUM_BODY_NAKED_V0_C0.TGA"
						draw = {text = ""}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 180), anx(120), any(80), "HUM_BODY_NAKED_V1_C0.TGA", ""),
					GUI.Button({
						positionPx = {x = 0.81 * Resolution.x, y = 0.3 * Resolution.y},
						sizePx = {width = 0.1 * Resolution.x, height = 0.1 * Resolution.y},
						file = "HUM_BODY_NAKED_V1_C0.TGA"
						draw = {text = ""}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 80), anx(120), any(80), "HUM_BODY_NAKED_V2_C0.TGA", ""),
					GUI.Button({
						positionPx = {x = 0.81 * Resolution.x, y = 0.41 * Resolution.y},
						sizePx = {width = 0.1 * Resolution.x, height = 0.1 * Resolution.y},
						file = "HUM_BODY_NAKED_V2_C0.TGA"
						draw = {text = ""}
					})
                    //GUI.Button(anx(Resolution.x - 240), any(Resolution.y/2 - 280), anx(120), any(80), "HUM_BODY_NAKED_V3_C0.TGA", ""),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.41 * Resolution.y},
						sizePx = {width = 0.1 * Resolution.x, height = 0.1 * Resolution.y},
						file = "HUM_BODY_NAKED_V3_C0.TGA"
						draw = {text = ""}
					})
                    //GUI.Button(anx(Resolution.x - 240), any(Resolution.y/2 - 180), anx(120), any(80), "HUM_BODY_NAKED_V4_C0.TGA", ""),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.52 * Resolution.y},
						sizePx = {width = 0.1 * Resolution.x, height = 0.1 * Resolution.y},
						file = "HUM_BODY_NAKED_V4_C0.TGA"
						draw = {text = ""}
					})
                    //GUI.Button(anx(Resolution.x - 240), any(Resolution.y/2 - 80), anx(120), any(80), "HUM_BODY_NAKED_V5_C0.TGA", ""),
					GUI.Button({
						positionPx = {x = 0.81 * Resolution.x, y = 0.52 * Resolution.y},
						sizePx = {width = 0.1 * Resolution.x, height = 0.1 * Resolution.y},
						file = "HUM_BODY_NAKED_V5_C0.TGA"
						draw = {text = ""}
					})
					
                    //GUI.ScrollBar(anx(Resolution.x - 380), any(Resolution.y/2 + 20), anx(260), any(20), "MENU_INGAME.TGA", "BAR_MISC.TGA", "L.TGA", "R.TGA", Orientation.Horizontal),
					GUI.ScrollBar({
						positionPx = {x = 0.7 * Resolution.x, y = 0.63 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.02 * Resolution.y},
						range = {
							file = "MENU_INGAME.TGA"
							indicator = {file = "BAR_MISC.TGA"}
							orientation = Orientation.Horizontal
						}
						increaseButton = {file = "R.TGA"}
						decreaseButton = {file = "L.TGA"}
					})
                ]
				
				// Pobierz scrollbar i dodaj event handler
				local textureScrollBar = changingElements[6];
				textureScrollBar.range.bind(EventType.Change, function(self) {
					local scrollValue = self.getValue();
					local val = scrollValue / 5;
					val = floor(val);
					
					
					// Zaktualizuj tekstury przycisków
					changingElements[0].setFile("HUM_BODY_NAKED_V"+val+"_C0.TGA");
					changingElements[1].setFile("HUM_BODY_NAKED_V"+(val+1)+"_C0.TGA");
					changingElements[2].setFile("HUM_BODY_NAKED_V"+(val+2)+"_C0.TGA");
					changingElements[3].setFile("HUM_BODY_NAKED_V"+(val+3)+"_C0.TGA");
					changingElements[4].setFile("HUM_BODY_NAKED_V"+(val+4)+"_C0.TGA");
					changingElements[5].setFile("HUM_BODY_NAKED_V"+(val+5)+"_C0.TGA");
				});


                foreach(_butt in changingElements)
                    _butt.setVisible(true);

            break;
            case 3:
                changingElements = [
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 280), anx(260), any(50), "MENU_INGAME.TGA", _L("Head")+" 1"),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.31 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Head")+" 1"}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 210), anx(260), any(50), "MENU_INGAME.TGA", _L("Head")+" 2"),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.37 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Head")+" 2"}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 140), anx(260), any(50), "MENU_INGAME.TGA", _L("Head")+" 3"),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.43 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Head")+" 3"}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 70), anx(260), any(50), "MENU_INGAME.TGA", _L("Head")+" 4"),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.49 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Head")+" 4"}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 0), anx(260), any(50), "MENU_INGAME.TGA", _L("Head")+" 5"),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.55 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Head")+" 5"}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 + 70), anx(260), any(50), "MENU_INGAME.TGA", _L("Head")+" 6"),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.61 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Head")+" 6"}
					})
                ];

                foreach(_butt in changingElements)
                    _butt.setVisible(true);

            break;
            case 4:
                changingElements = [
                    GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.3 * Resolution.y},
						sizePx = {width = 0.1 * Resolution.x, height = 0.1 * Resolution.y},
						file = "Hum_Head_V0_C0.TGA"
						draw = {text = ""}
					})
					GUI.Button({
						positionPx = {x = 0.81 * Resolution.x, y = 0.3 * Resolution.y},
						sizePx = {width = 0.1 * Resolution.x, height = 0.1 * Resolution.y},
						file = "Hum_Head_V1_C0.TGA"
						draw = {text = ""}
					})
					GUI.Button({
						positionPx = {x = 0.81 * Resolution.x, y = 0.41 * Resolution.y},
						sizePx = {width = 0.1 * Resolution.x, height = 0.1 * Resolution.y},
						file = "Hum_Head_V2_C0.TGA"
						draw = {text = ""}
					})
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.41 * Resolution.y},
						sizePx = {width = 0.1 * Resolution.x, height = 0.1 * Resolution.y},
						file = "Hum_Head_V3_C0.TGA"
						draw = {text = ""}
					})
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.52 * Resolution.y},
						sizePx = {width = 0.1 * Resolution.x, height = 0.1 * Resolution.y},
						file = "Hum_Head_V4_C0_C0.TGA"
						draw = {text = ""}
					})
					GUI.Button({
						positionPx = {x = 0.81 * Resolution.x, y = 0.52 * Resolution.y},
						sizePx = {width = 0.1 * Resolution.x, height = 0.1 * Resolution.y},
						file = "Hum_Head_V5_C0.TGA"
						draw = {text = ""}
					})
					GUI.ScrollBar({
						positionPx = {x = 0.7 * Resolution.x, y = 0.63 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.02 * Resolution.y},
						range = {
							file = "MENU_INGAME.TGA"
							indicator = {file = "BAR_MISC.TGA"}
							orientation = Orientation.Horizontal
						}
						increaseButton = {file = "R.TGA"}
						decreaseButton = {file = "L.TGA"}
					})
                ]
                foreach(_butt in changingElements)
                    _butt.setVisible(true);

            break;

            case 5:
                changingElements = [
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 280), anx(260), any(50), "MENU_INGAME.TGA", _L("Normal")),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.31 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Normal")}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 210), anx(260), any(50), "MENU_INGAME.TGA", _L("Tired")),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.36 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Tired")}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 140), anx(260), any(50), "MENU_INGAME.TGA", _L("Woman")),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.41 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Woman")}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 70), anx(260), any(50), "MENU_INGAME.TGA", _L("Chill")),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.46 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Chill")}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 - 0), anx(260), any(50), "MENU_INGAME.TGA", _L("Army")),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.51 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Army")}
					})
                    //GUI.Button(anx(Resolution.x - 380), any(Resolution.y/2 + 70), anx(260), any(50), "MENU_INGAME.TGA", _L("Mage")),
					GUI.Button({
						positionPx = {x = 0.7 * Resolution.x, y = 0.56 * Resolution.y},
						sizePx = {width = 0.2 * Resolution.x, height = 0.05 * Resolution.y},
						file = "MENU_INGAME.TGA"
						draw = {text = _L("Mage")}
					})
                ];
                foreach(_butt in changingElements)
                    _butt.setVisible(true);
            
            break;

        }
    }
};

Interface.Visual.window.setColor({r = 255, g = 0, b = 0});
Interface.Visual.maleButton <- /*GUI.Button(anx(20), any(20), anx(360), any(60), "DLG_CONVERSATION.TGA", _L("Sex"), Interface.Visual.window)*/ GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.04 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		draw = {text = _L("Sex")}
		collection = Interface.Visual.window
	})
Interface.Visual.bodyButton <- /*GUI.Button(anx(20), any(100), anx(360), any(60), "DLG_CONVERSATION.TGA", _L("Skin"), Interface.Visual.window)*/ GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.1 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		draw = {text = _L("Skin")}
		collection = Interface.Visual.window
	})
Interface.Visual.headButton <- /*GUI.Button(anx(20), any(180), anx(360), any(60), "DLG_CONVERSATION.TGA", _L("Head"), Interface.Visual.window)*/ GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.16 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		draw = {text = _L("Head")}
		collection = Interface.Visual.window
	})
Interface.Visual.faceButton <- /*GUI.Button(anx(20), any(260), anx(360), any(60), "DLG_CONVERSATION.TGA", _L("Face"), Interface.Visual.window)*/ GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.22 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		draw = {text = _L("Face")}
		collection = Interface.Visual.window
	})
Interface.Visual.walkButton <- /*GUI.Button(anx(20), any(340), anx(360), any(60), "DLG_CONVERSATION.TGA", _L("Walking style"), Interface.Visual.window)*/ GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.28 * Resolution.y},
        sizePx = {width = 0.23 * Resolution.x, height = 0.05 * Resolution.y},
		file = "DLG_CONVERSATION.TGA"
		draw = {text = _L("Walking style")}
		collection = Interface.Visual.window
	})
Interface.Visual.leftButton <- /*GUI.Button(anx(Resolution.x/2 - 60), any(Resolution.y/2 + 200), anx(40), any(30), "L.TGA", "")*/ GUI.Button({
		positionPx = {x = 0.4 * Resolution.x, y = 0.85 * Resolution.y},
        sizePx = {width = 0.03 * Resolution.x, height = 0.04 * Resolution.y},
		file = "L.TGA"
		draw = {text = ""}
	})

Interface.Visual.rightButton <- /*GUI.Button(anx(Resolution.x/2 + 20), any(Resolution.y/2 + 200), anx(40), any(30), "R.TGA", "")*/ GUI.Button({
		positionPx = {x = 0.55 * Resolution.x, y = 0.85 * Resolution.y},
        sizePx = {width = 0.03 * Resolution.x, height = 0.04 * Resolution.y},
		file = "R.TGA"
		draw = {text = ""}
	})


addEventHandler("onRender", function() {
    if(Interface.Visual.workingSide == 0)
        return;

	if(Interface.Visual.workingSide == 5) {
		playAni(heroId, "S_WALKL");
		setPlayerPosition(heroId, Interface.Visual.activeWalking.x, Interface.Visual.activeWalking.y, Interface.Visual.activeWalking.z);
	}	
});


addEventHandler("GUI.onClick", function(self)
{
    if(Player.gui != PLAYER_GUI.VISUAL)
        return;

	switch (self)
	{
        case Interface.Visual.leftButton:
            if((getPlayerAngle(heroId) - 20) < 0)
                setPlayerAngle(heroId, 360);

            setPlayerAngle(heroId, getPlayerAngle(heroId) - 20);
        break;
        case Interface.Visual.rightButton:
            if((getPlayerAngle(heroId) + 20) > 360)
                setPlayerAngle(heroId, 0);

            setPlayerAngle(heroId, getPlayerAngle(heroId) + 20);
        break;
        case Interface.Visual.maleButton:
            Interface.Visual.showCurrentOption(1);
        break;
        case Interface.Visual.bodyButton:
            Interface.Visual.showCurrentOption(2);
        break;
        case Interface.Visual.headButton:
            Interface.Visual.showCurrentOption(3);
        break;
        case Interface.Visual.faceButton:
            Interface.Visual.showCurrentOption(4);
        break;
        case Interface.Visual.walkButton:
            Interface.Visual.showCurrentOption(5);
        break;

	}

    local wyglad = getPlayerVisual(heroId);
    local changingElements = Interface.Visual.changingElements;
    switch(Interface.Visual.workingSide)
    {
        case 1:
            if(self == changingElements[0])
                setPlayerVisual(heroId, bodymodel[0], wyglad.bodyTxt, wyglad.headModel, wyglad.headTxt);
            else if(self == changingElements[1])
                setPlayerVisual(heroId, bodymodel[1], wyglad.bodyTxt, wyglad.headModel, wyglad.headTxt);
        break;
        case 2:
            local val = changingElements[6].range.getValue()/5;
            val = floor(val);
            foreach(id, _butt in changingElements)
            {
                if(_butt == self)
                    setPlayerVisual(heroId, wyglad.bodyModel, (val + id).tointeger(), wyglad.headModel, wyglad.headTxt);
            }
        break;
        case 3:
            foreach(id, _butt in changingElements)
            {
                if(_butt == self)
                    setPlayerVisual(heroId, wyglad.bodyModel, wyglad.bodyTxt, headmodel[id], wyglad.headTxt);
            }
        break;
        case 4:
            local val = changingElements[6].range.getValue()*2;
            val = floor(val);
            foreach(id, _butt in changingElements)
            {
                if(_butt == self)
                    setPlayerVisual(heroId, wyglad.bodyModel, wyglad.bodyTxt, wyglad.headModel, val.tointeger() + id);
            }
        break;
        case 5:
            foreach(id, _butt in changingElements)
            {
                if(_butt == self)
                {
                    local walkStyleName = "HUMANS"; // DEFAULT
                    switch(id) {
                        case 0: walkStyleName = "HUMANS"; break;
                        case 1: walkStyleName = "HUMANS_TIRED"; break;
                        case 2: walkStyleName = "HUMANS_BABE"; break;
                        case 3: walkStyleName = "HUMANS_RELAXED"; break;
                        case 4: walkStyleName = "HUMANS_MILITIA"; break;
                        case 5: walkStyleName = "HUMANS_MAGE"; break;
                    }
                    Player.packetWalk(walkStyleName);
                }
            }
        break;
    }
})

addEventHandler("GUI.onChange", function (self) {
    if(Interface.Visual.workingSide == 0)
        return;

    local changingElements = Interface.Visual.changingElements;

    switch(Interface.Visual.workingSide)
    {
        case 2:
            if(self == changingElements[6])
            {
                local val = self.range.getValue()/5;
                val = floor(val);
                changingElements[0].setFile("HUM_BODY_NAKED_V"+val+"_C0.TGA");
                changingElements[1].setFile("HUM_BODY_NAKED_V"+(val+1)+"_C0.TGA");
                changingElements[2].setFile("HUM_BODY_NAKED_V"+(val+2)+"_C0.TGA");
                changingElements[3].setFile("HUM_BODY_NAKED_V"+(val+3)+"_C0.TGA");
                changingElements[4].setFile("HUM_BODY_NAKED_V"+(val+4)+"_C0.TGA");
                changingElements[5].setFile("HUM_BODY_NAKED_V"+(val+5)+"_C0.TGA");
            }
        break;
        case 4:
            if(self == changingElements[6])
            {
                local val = self.range.getValue()*2;
                val = floor(val);
                changingElements[0].setFile("Hum_Head_V"+val+"_C0.TGA");
                changingElements[1].setFile("Hum_Head_V"+(val+1)+"_C0.TGA");
                changingElements[2].setFile("Hum_Head_V"+(val+2)+"_C0.TGA");
                changingElements[3].setFile("Hum_Head_V"+(val+3)+"_C0.TGA");
                changingElements[4].setFile("Hum_Head_V"+(val+4)+"_C0.TGA");
                changingElements[5].setFile("Hum_Head_V"+(val+5)+"_C0.TGA");
            }
        break;
    }
})

addEventHandler("onKeyDown", function(key) {
    if(key != KEY_ESCAPE)
        return;

    if(Player.gui != PLAYER_GUI.VISUAL)
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
