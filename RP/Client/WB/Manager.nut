builderManager <- {}

builderManager.active <- false;
builderManager.vob <- 0;
builderManager.renders <- [];
builderManager.selectedVobIndex <- null;
builderManager.focusedVob <- null;

builderManager.window <- GUI.Window({
		positionPx = {x = 0.02 * Resolution.x, y = 0.0 * Resolution.y}
		sizePx = {width = 0.40 * Resolution.x, height = 1.0 * Resolution.y}
		file = "MENU_INGAME.TGA"
		color = {a = 180}
	})

builderManager.slider <- GUI.Slider({
		relativePositionPx = {x = 0.35 * Resolution.x, y = 0.05 * Resolution.y},
		sizePx = {width = 0.02 * Resolution.x, height = 0.9 * Resolution.y},
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

builderManager.deleteButton <- GUI.Button({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.92 * Resolution.y},
    sizePx = {width = 0.30 * Resolution.x, height = 0.05 * Resolution.y},
    file = "RED.TGA",
    label = {text = "Usuń"},
    collection = builderManager.window,
    visible = false
});


builderManager.clickers <- [
	GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.05 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.05 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.05 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.22 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.22 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.22 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.39 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.39 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.39 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.56 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.56 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.56 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.01 * Resolution.x, y = 0.73 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.12 * Resolution.x, y = 0.73 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
		collection = builderManager.window
	}),
	GUI.Button({
		relativePositionPx = {x = 0.23 * Resolution.x, y = 0.73 * Resolution.y}
		sizePx = {width = 0.1 * Resolution.x, height = 0.15 * Resolution.y}
		file = "MENU_INGAME.TGA"
		label = {text = ""}
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
    builderManager.deleteButton.setVisible(false);
    builderManager.selectedVobIndex = null;
    builderManager.focusedVob = null;

    if (builder.active && builder.vob != null) {
        builder.focusOnVob(builder.vob);
    }
}

function builderManager::openRenders()
{
    if(!builderManager.active)
        return;

    local listWhole = builder.manager;
    builderManager.renders.clear();

    if(listWhole.len() <= 15)
        builderManager.slider.setVisible(false);
    else {
        builderManager.slider.setMaximum((listWhole.len()/3).tointeger());
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
            clicker.setText(listWhole[rId].id != null ? rawstring(listWhole[rId].id) : "NEW");
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

    if (self == builderManager.deleteButton) {
        if (builderManager.selectedVobIndex != null) {
            local vobToRemove = builder.manager[builderManager.selectedVobIndex];
            if (vobToRemove && vobToRemove.id != null) {
                local packet = Packet();
                packet.writeUInt8(PacketId.WorldBuilder);
                packet.writeUInt8(PacketWorldBuilder.VobRemove);
                packet.writeInt32(vobToRemove.id);
                packet.send(RELIABLE_ORDERED);

                builderManager.selectedVobIndex = null;
                builderManager.focusedVob = null;
                builderManager.deleteButton.setVisible(false);
                if (builder.active) {
                    builder.focusOnVob(builder.vob);
                }
            }
        }
        return;
    }

    foreach(id, clicker in builderManager.clickers)
    {
        if(clicker != self)
            continue;

        local rId = id + builderManager.vob;
        if (rId < builder.manager.len()) {
            local vobToFocus = builder.manager[rId];
            builder.focusOnVob(vobToFocus.element);
            builderManager.selectedVobIndex = rId;
            builderManager.focusedVob = vobToFocus.element;
            builderManager.deleteButton.setVisible(true);
        }
    }
})

addEventHandler("GUI.onChange", function(self)
{
    if(!builderManager.active)
        return;

	if(builderManager.slider != self)
        return;

    local val = self.getValue();
    builderManager.vob = val * 3;
    builderManager.openRenders()
})

