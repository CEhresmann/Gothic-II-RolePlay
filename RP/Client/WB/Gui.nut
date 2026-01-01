builder.gui = GUI.Window({
	positionPx = {x = 0.67 * Resolution.x, y = 0.05 * Resolution.y}
	sizePx = {width = 0.30 * Resolution.x, height = 0.45 * Resolution.y}
	file = "MENU_INGAME.TGA"
	color = {a = 200}
})
builder.gui.setColor({r = 255, g = 0, b = 0});


local vobPosition = GUI.Label({
	position = {x = anx(5), y = 8129-any(25)},
	text = ""
})


builder.cameraDrawLabel = GUI.Label({
	relativePositionPx = {x = 0.06 * Resolution.x, y = 0.05 * Resolution.y},
	text = "Tryb kamery: Statyczna",
	collection = builder.gui
})

local changeCamera = GUI.Button({
	relativePositionPx = {x = 0.01 * Resolution.x, y = 0.05 * Resolution.y}
	sizePx = {width = 0.05 * Resolution.x, height = 0.03 * Resolution.y}
	file = "RED.TGA"
	label = {text = "Zmien"}
	collection = builder.gui
})


local vobDraw = GUI.Label({
	relativePositionPx = {x = 0.06 * Resolution.x, y = 0.1 * Resolution.y}
	text = "Vob 0 ("+builder.list["Wszystkie"][0].name+")",
	collection = builder.gui
})

local changeVob = GUI.Button({
	relativePositionPx = {x = 0.01 * Resolution.x, y = 0.1 * Resolution.y}
	sizePx = {width = 0.05 * Resolution.x, height = 0.03 * Resolution.y}
	file = "RED.TGA"
	label = {text = "Zmien"}
	collection = builder.gui
})


local toGround = GUI.Button({
	relativePositionPx = {x = 0.18 * Resolution.x, y = 0.15 * Resolution.y}
	sizePx = {width = 0.1 * Resolution.x, height = 0.03 * Resolution.y}
	file = "RED.TGA"
	label = {text = "Do ziemi"}
	collection = builder.gui
})

local collisionChange = GUI.Button({
	relativePositionPx = {x = 0.02 * Resolution.x, y = 0.15 * Resolution.y}
	sizePx = {width = 0.1 * Resolution.x, height = 0.03 * Resolution.y}
	file = "RED.TGA"
	label = {text = "Kolizja: tak"}
	collection = builder.gui
})

local vobTypeLabel = GUI.Label({
    relativePositionPx = {x = 0.06 * Resolution.x, y = 0.20 * Resolution.y},
    text = "Typ: Statyczny",
    collection = builder.gui
})

local changeVobType = GUI.Button({
	relativePositionPx = {x = 0.01 * Resolution.x, y = 0.20 * Resolution.y},
	sizePx = {width = 0.05 * Resolution.x, height = 0.03 * Resolution.y},
	file = "RED.TGA",
	label = {text = "Zmien"},
	collection = builder.gui
})

local doorKeyInput = GUI.Input({
    relativePositionPx = {x = 0.02 * Resolution.x, y = 0.25 * Resolution.y},
    sizePx = {width = 0.26 * Resolution.x, height = 0.03 * Resolution.y},
    file = "BLACK.TGA",
    placeholder = "Instancja klucza (np. ITKE_KEY_01)",
    visible = false,
    collection = builder.gui
})


local saveManager = GUI.Button({
	relativePositionPx = {x = 0.02 * Resolution.x, y = 0.35 * Resolution.y}
	sizePx = {width = 0.25 * Resolution.x, height = 0.03 * Resolution.y}
	file = "RED.TGA"
	label = {text = "Zapisz"}
	collection = builder.gui
})

local checkManager = GUI.Button({
	relativePositionPx = {x = 0.02 * Resolution.x, y = 0.4 * Resolution.y}
	sizePx = {width = 0.25 * Resolution.x, height = 0.03 * Resolution.y}
	file = "RED.TGA"
	label = {text = "Rozstawione Voby"}
	collection = builder.gui
})

function builder::showGUI()
{
    if (gui) gui.setVisible(true);
    if (vobPosition) vobPosition.setVisible(true);
    setCursorVisible(true);
}

function builder::hideGUI()
{
    if (gui) gui.setVisible(false);
    if (vobPosition) vobPosition.setVisible(false);
    setCursorVisible(false);

    if(vobsSelection && vobsSelection.active) vobsSelection.end();
    if(builderManager && builderManager.active) builderManager.end();
}

addEventHandler("GUI.onClick", function(self)
{
    if(!isBuilderActive())
        return;

	switch (self)
	{
		case changeCamera:
            builder.cameraMode++;
            if(builder.cameraMode > 3)
                builder.cameraMode = 1;

			switch(builder.cameraMode)
            {
                case 1: builder.cameraDrawLabel.setText("Tryb kamery: Statyczna"); break;
                case 2: builder.cameraDrawLabel.setText("Tryb kamery: Vob"); break;
                case 3: builder.cameraDrawLabel.setText("Tryb kamery: Wolna"); break;
            }
            builder.onBuilderCameraChange();
        break
        case changeVob:
            if(builderManager.active) builderManager.end();
            vobsSelection.active ? vobsSelection.end() : vobsSelection.start();
        break;
        case saveManager:
            builder.save();
        break;
        case collisionChange:
            if(collisionChange.getText() == "Kolizja: tak") {
                builder.vob.cdStatic = false;
                collisionChange.setText("Kolizja: nie")
            }else{
                builder.vob.cdStatic = true;
                collisionChange.setText("Kolizja: tak")
            }
        break;
        case toGround:
            builder.vob.floor()
        break;
        case checkManager:
            if(vobsSelection.active) vobsSelection.end();
            builderManager.active ? builderManager.end() : builderManager.start();
        break;
		case changeVobType:
            builder.vobType++;
            if (builder.vobType > VobType.Door) {
                builder.vobType = VobType.Static;
            }
            switch(builder.vobType) {
                case VobType.Static:
                    vobTypeLabel.setText("Typ: Statyczny");
                    doorKeyInput.setVisible(false);
                    builder.doorKey = "";
                    doorKeyInput.setText("");
                    break;
                case VobType.Interactive:
                    vobTypeLabel.setText("Typ: Interaktywny");
                    doorKeyInput.setVisible(false);
                    builder.doorKey = "";
                    doorKeyInput.setText("");
                    break;
                case VobType.Door:
                    vobTypeLabel.setText("Typ: Drzwi");
                    doorKeyInput.setVisible(true);
                    break;
            }
        break;
	}
})

addEventHandler("GUI.onChange", function(self) {
    if (!isBuilderActive()) return;
    if (self == doorKeyInput) {
        builder.doorKey = self.getValue();
    }
});


addEventHandler("onRender", function() {
    if(!isBuilderActive() || !builder.vob)
        return;

    local pos = builder.vob.getPosition();
    local rot = builder.vob.getRotation();

    vobPosition.setText("x:"+ pos.x.tointeger() + ", y:"+pos.y.tointeger()+", z:"+pos.z.tointeger()+"  rot: "+rot.x.tointeger() + ", "+rot.y.tointeger());

})

function setBuilderVobCollisionOn()
{
    if(collisionChange.getText() == "Kolizja: tak") {
        builder.vob.cdStatic = true;
    }else{
        builder.vob.cdStatic = false;
    }
}

