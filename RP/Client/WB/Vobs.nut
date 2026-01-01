
vobsSelection <- {};

vobsSelection.active <- false;
vobsSelection.cat <- "Wszystkie";
vobsSelection.sId <- 0;
vobsSelection.vob <- 0;

vobsSelection.renders <- [];
vobsSelection.catButtons <- [];

vobsSelection.window <-GUI.Window({
		positionPx = {x = 0.02 * Resolution.x, y = 0.05 * Resolution.y}
		sizePx = {width = 0.40 * Resolution.x, height = 0.7 * Resolution.y}
		file = "MENU_INGAME.TGA"
		color = {a = 180}
	})
vobsSelection.slider <- GUI.Slider({
		relativePositionPx = {x = 0.35 * Resolution.x, y = 0.15 * Resolution.y}
		sizePx = {width = 0.015 * Resolution.x, height = 0.5 * Resolution.y}
		marginPx = [7, 3]
		file = "BLACK.TGA"
		indicator = {
			file = "WHITE.TGA"
			color = {r = 200, g = 200, b = 200}
		}
		indicatorSizePx = 15
		progress = {
			file = "YELLOW.TGA"
			color = {r = 220, g = 200, b = 0}
		}
		minimum = 0
		maximum = 100
		step = 1
		orientation = Orientation.Vertical
		collection = vobsSelection.window
	})

vobsSelection.clickers <- [
    GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.15 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = vobsSelection.window
	}),

	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.15 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = vobsSelection.window
	}),

	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.15 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = vobsSelection.window
	}),

	GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.32 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = vobsSelection.window
	}),

	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.32 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = vobsSelection.window
	}),

	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.32 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = vobsSelection.window
	}),

	GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.49 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = vobsSelection.window
	}),

	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.49 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = vobsSelection.window
	}),

	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.49 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = vobsSelection.window
	}),
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
        local by = id/4;
        by = by.tointeger();

        local button = GUI.Button({
            relativePositionPx = {x = 0.02 * Resolution.x + (id % 4 * 180), y = 0.05 * Resolution.y + (by * 60)}
            sizePx = {width = 0.08 * Resolution.x, height = 0.05 * Resolution.y}
            file = "RED.TGA"
            label = {text = _cat}
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
            local size = clicker.getSize();


            local item = ItemRender(pos.x, pos.y, size.width, size.height, listWhole[rId].name);
            item.visual = listWhole[rId].name;
            item.visible = true;
            item.lightingswell = true;

            item.rotY = 45;
            item.rotX = 15;

            clicker.setText(rId+"/"+listWhole.len());
            vobsSelection.renders.append(item);
        }
        else
        {

            clicker.setText("");


            if (id < vobsSelection.renders.len()) {
                vobsSelection.renders[id].visible = false;
            }
        }
    }
}


local vobsRotationCounter = 0;
local function updateVobsRenders()
{
    if (!vobsSelection.active) return;

    vobsRotationCounter++;
    foreach (id, render in vobsSelection.renders)
    {
        if (render && render.visible) {
            render.rotY = (vobsRotationCounter / 2) % 360;
        }
    }
}

addEventHandler("onRender", updateVobsRenders);

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

/*
setUnloadCallback(function() {
    // ukryj
	vobsSelection.end();
});

setReloadCallback(function() {
    //pokaż
	vobsSelection.start();
});*/
