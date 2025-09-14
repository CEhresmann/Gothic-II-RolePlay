builderManager <- {}

builderManager.active <- false;
builderManager.vob <- 0;
builderManager.renders <- [];

builderManager.window <- /*GUI.Window(50, any(30), anx(620), any(500), "MENU_INGAME.TGA");*/ GUI.Window({
		positionPx = {x = 0.02 * Resolution.x, y = 0.0 * Resolution.y}
		sizePx = {width = 0.40 * Resolution.x, height = 1.0 * Resolution.y}
		file = "MENU_INGAME.TGA"
		color = {a = 180}
	})

builderManager.slider <- /*GUI.Slider(anx(580), any(30), anx(30), any(440) anx(3), any(7), "MENU_INGAME.TGA", "BLACK.TGA", "RED.TGA", Orientation.Vertical, Align.Left, builderManager.window)*/ GUI.Slider({
		relativePositionPx = {x = 0.1 * Resolution.x, y = 0.05 * Resolution.y}
		sizePx = {width = 0.05 * Resolution.x, height = 0.01 * Resolution.y}
		marginPx = [3, 7]
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
		collection = builderManager.window
	})

builderManager.clickers <- [
    //GUI.Button(anx(20), any(20), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.05 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(160), any(20), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.05 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(300), any(20), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.05 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(440), any(20), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.22 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(20), any(140), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.22 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(160), any(140), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.22 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(300), any(140), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.39 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(440), any(140), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.39 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(20), any(260), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.39 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(160), any(260), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.56 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(300), any(260), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.56 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(440), any(260), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.56 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(20), any(380), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.73 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(160), any(380), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.73 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(300), any(380), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.73 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
    //GUI.Button(anx(440), any(380), anx(120), any(100), "MENU_INGAME.TGA", "", builderManager.window),
	GUI.Button({
		relativePositionPx = {x = anx(440), y = any(380)}
		sizePx = {width = anx(120), height = any(100)}
		file = "MENU_INGAME.TGA"
		draw = {text = ""}
		collection = builderManager.window
	}),
];


foreach(val in builderManager.clickers)
    val.setColor({r = 255, g = 0, b = 0});

builderManager.window.setColor({r = 255, g = 0, b = 0});


function builderManager::start()
{
    builderManager.active = true;
    builderManager.window.setVisible(true);

    openRenders();
}

function builderManager::end()
{
    builderManager.active = false;
    builderManager.renders.clear();
    builderManager.window.setVisible(false);
}

function builderManager::openRenders()
{
    if(!builderManager.active)
        return;

    local listWhole = builder.manager;
    builderManager.renders.clear();

    if(listWhole.len() <= 16)
        builderManager.slider.setVisible(false);
    else {
        builderManager.slider.setMaximum((listWhole.len()/4).tointeger() + 1);
        builderManager.slider.setVisible(true);
    }

    foreach(id, clicker in builderManager.clickers)
    {
        local rId = id + builderManager.vob;
        if((listWhole.len()-1) >= rId)
        {

            local pos = clicker.getPosition();
            local size = clicker.getSize();
            

            local item = ItemRender(pos.x, pos.y, size.width, size.height, listWhole[rId].name);
            item.visual = listWhole[rId].name; 
            item.visible = true;
            item.lightingswell = true;
            

            item.rotY = 45;
            item.rotX = 15;
            
            clicker.setText(rId+"/"+listWhole.len());
            builderManager.renders.append(item);
        }
        else
        {

            clicker.setText("");
            

            if (id < builderManager.renders.len()) {
                builderManager.renders[id].visible = false;
            }
        }
    }
}


local managerRotationCounter = 0;
local function updateManagerRenders()
{
    if (!builderManager.active) return;
    
    managerRotationCounter++;
    foreach (id, render in builderManager.renders)
    {
        if (render && render.visible) {
            render.rotY = (managerRotationCounter / 2) % 360;
        }
    }
}

addEventHandler("onRender", updateManagerRenders);

addEventHandler("GUI.onClick", function(self)
{
    if(!builderManager.active)
        return;

    foreach(id, clicker in builderManager.clickers)
    {
        if(clicker != self)
            continue;

        local rId = id + builderManager.vob;
        builder.manager.remove(rId);
    }
    builderManager.openRenders();
})

addEventHandler("GUI.onChange", function(self)
{
    if(!builderManager.active)
        return;

	if(builderManager.slider != self)
        return;

    local val = self.getValue();
    builderManager.vob = val * 4;
    builderManager.openRenders()
})
