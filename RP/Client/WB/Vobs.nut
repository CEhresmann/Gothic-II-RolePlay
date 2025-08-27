
vobsSelection <- {};

vobsSelection.active <- false;
vobsSelection.cat <- "Wszystkie";
vobsSelection.sId <- 0;
vobsSelection.vob <- 0;

vobsSelection.renders <- [];
vobsSelection.catButtons <- [];

vobsSelection.window <- /*GUI.Window(50, any(30), anx(600), any(600), "MENU_INGAME.TGA"); */ GUI.Window({
		positionPx = {x = 50, y = any(30)}
		sizePx = {width = anx(600), height = any(600)}
		file = "MENU_INGAME.TGA"
		color = {a = 180}
	})
vobsSelection.slider <- /*GUI.Slider(anx(570), any(150), anx(30), any(400) anx(3), any(7), "MENU_INGAME.TGA", "BLACK.TGA", "RED.TGA", Orientation.Vertical, Align.Left, vobsSelection.window)*/ GUI.Slider({
		relativePositionPx = {x = anx(570), y = any(150)}
		sizePx = {width = anx(30), height = any(400)}
		marginPx = [anx(3), any(7)]
		file = "MENU_INGAME.TGA"
		indicator = {
			file = "BLACK.TGA"
			color = {r = 200, g = 200, b = 200}
		}
		indicatorSizePx = 15
		progress = {
			file = "RED.TGA"
			color = {r = 220, g = 200, b = 0}
		}
		minimum = 0
		maximum = 100
		step = 1
		orientation = Orientation.Vertical
		collection = vobsSelection.window
	})

vobsSelection.clickers <- [
    //GUI.Button(anx(20), any(150), anx(150), any(130), "MENU_INGAME.TGA", "", vobsSelection.window),
	GUI.Button({
		relativePositionPx = {x = anx(20), y = any(150)}
		sizePx = {width = anx(150), height = any(130)}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = vobsSelection.window
	}),
    //GUI.Button(anx(200), any(150), anx(150), any(130), "MENU_INGAME.TGA", "", vobsSelection.window),
	GUI.Button({
		relativePositionPx = {x = anx(200), y = any(150)}
		sizePx = {width = anx(150), height = any(130)}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = vobsSelection.window
	}),
    //GUI.Button(anx(380), any(150), anx(150), any(130), "MENU_INGAME.TGA", "", vobsSelection.window),
	GUI.Button({
		relativePositionPx = {x = anx(380), y = any(150)}
		sizePx = {width = anx(150), height = any(130)}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = vobsSelection.window
	}),
    //GUI.Button(anx(20), any(290), anx(150), any(130), "MENU_INGAME.TGA", "", vobsSelection.window),
	GUI.Button({
		relativePositionPx = {x = anx(20), y = any(290)}
		sizePx = {width = anx(150), height = any(130)}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = vobsSelection.window
	}),
    //GUI.Button(anx(200), any(290), anx(150), any(130), "MENU_INGAME.TGA", "", vobsSelection.window),
	GUI.Button({
		relativePositionPx = {x = anx(200), y = any(290)}
		sizePx = {width = anx(150), height = any(130)}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = vobsSelection.window
	}),
    //GUI.Button(anx(380), any(290), anx(150), any(130), "MENU_INGAME.TGA", "", vobsSelection.window),
	GUI.Button({
		relativePositionPx = {x = anx(380), y = any(290)}
		sizePx = {width = anx(150), height = any(130)}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = vobsSelection.window
	}),
    //GUI.Button(anx(20), any(430), anx(150), any(130), "MENU_INGAME.TGA", "", vobsSelection.window),
	GUI.Button({
		relativePositionPx = {x = anx(20), y = any(430)}
		sizePx = {width = anx(150), height = any(130)}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = vobsSelection.window
	}),
    //GUI.Button(anx(200), any(430), anx(150), any(130), "MENU_INGAME.TGA", "", vobsSelection.window),
	GUI.Button({
		relativePositionPx = {x = anx(200), y = any(430)}
		sizePx = {width = anx(150), height = any(130)}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = vobsSelection.window
	}),
    //GUI.Button(anx(380), any(430), anx(150), any(130), "MENU_INGAME.TGA", "", vobsSelection.window),
	GUI.Button({
		relativePositionPx = {x = anx(380), y = any(430)}
		sizePx = {width = anx(150), height = any(130)}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = vobsSelection.window
	})
];

foreach(val in vobsSelection.clickers)
    val.setColor({r = 255, g = 0, b = 0});

vobsSelection.window.setColor({r = 255, g = 0, b = 0});

function vobsSelection::start()
{
    active = true;
    window.setVisible(true);

    local id = 0;
    foreach(_cat, _val in builder.list)
    {
        local y = id/4;y = y.tointeger();
        //local button = GUI.Button(anx(20 + (id*135)), any(20 + (y*60)), anx(130), any(60), "RED.TGA", _cat, vobsSelection.window);
		local button = GUI.Button({
			relativePositionPx = {x = anx(20 + (id*135)), y = any(20 + (y*60))}
			sizePx = {width = anx(130), height = any(60)}
			file = "RED.TGA"
			draw = {text = _cat}
			collection = vobsSelection.window
		})
		
        vobsSelection.catButtons.append(button);
        id++;
    }

    foreach(_butt in vobsSelection.catButtons)
    {
        _butt.setVisible(true);
    }

    openRenders();
}

function vobsSelection::end()
{
    active = false;
    window.setVisible(false);
    vobsSelection.renders.clear();
}

function vobsSelection::openRenders()
{
    local listWhole = builder.list[vobsSelection.cat];
    vobsSelection.renders.clear();

    if(listWhole.len() <= 9)
        vobsSelection.slider.setVisible(false);
    else {
        vobsSelection.slider.setMaximum((listWhole.len()/3).tointeger() + 1);
        vobsSelection.slider.setVisible(true);
    }

    foreach(id, clicker in vobsSelection.clickers)
    {
        local rId = id + vobsSelection.vob;
        if((listWhole.len()-1) >= rId)
        {
            local pos = clicker.getPosition();
            local item = ItemRender(pos.x, pos.y, anx(150), any(130), listWhole[rId].name);

            clicker.setText(rId+"/"+listWhole.len())
            item.visible = true;
            item.lightingswell = true;
            clicker.draw.top();
            vobsSelection.renders.append(item);
        }
    }
}

addEventHandler("GUI.onClick", function(self)
{
    if(!isBuilderActive())
        return;

    foreach(_butt in vobsSelection.catButtons)
    {
        if(_butt == self)
        {
            vobsSelection.cat = _butt.getText();
            vobsSelection.openRenders();
            return;
        }
    }
    foreach(id, clicker in vobsSelection.clickers)
    {
        if(clicker != self)
            continue;

        vobsSelection.sId = vobsSelection.vob + id;
        setBuilderVobCollisionOn();
        builder.changeVob(builder.list[vobsSelection.cat][vobsSelection.sId].name);
        break;
    }
})

addEventHandler("GUI.onChange", function(self)
{
    if(!isBuilderActive())
        return;
        
	if(vobsSelection.slider != self)
        return;
    
    local val = self.getValue();
    vobsSelection.vob = val * 3;
    vobsSelection.openRenders()
})
