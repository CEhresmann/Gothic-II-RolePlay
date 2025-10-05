//builder.gui = GUI.Window(8129 - anx(450), any(100), anx(420), any(400), "MENU_INGAME.TGA")
builder.gui = GUI.Window({
	positionPx = {x = 0.67 * Resolution.x, y = 0.05 * Resolution.y}
	sizePx = {width = 0.30 * Resolution.x, height = 0.35 * Resolution.y}
	file = "MENU_INGAME.TGA"
	color = {a = 200}
})
builder.gui.setColor({r = 255, g = 0, b = 0});

//local vobPosition = GUI.Draw(anx(5), 8129-any(25), "");
local vobPosition = GUI.Draw({
	position = {x = anx(5), y = 8129-any(25)},
	text = ""
})

//local cameraDraw = GUI.Draw(anx(90), any(40), "Tryb kamery: Statyczna", builder.gui)
local cameraDraw = GUI.Draw({
	relativePositionPx = {x = 0.06 * Resolution.x, y = 0.05 * Resolution.y}
	text = "Tryb kamery: Statyczna",
	collection = builder.gui
})
//local changeCamera = GUI.Button(anx(10), any(40), anx(75), any(25), "RED.TGA", "Zmie?", builder.gui)
local changeCamera = GUI.Button({
	relativePositionPx = {x = 0.01 * Resolution.x, y = 0.05 * Resolution.y}
	sizePx = {width = 0.05 * Resolution.x, height = 0.03 * Resolution.y}
	file = "RED.TGA"
	draw = {text = "Zmieñ"}
	collection = builder.gui
})

//local vobDraw = GUI.Draw(anx(90), any(80), "Vob 0 ("+builder.list["Wszystkie"][0].name+")", builder.gui)
local vobDraw = GUI.Draw({
	relativePositionPx = {x = 0.06 * Resolution.x, y = 0.1 * Resolution.y}
	text = "Vob 0 ("+builder.list["Wszystkie"][0].name+")",
	collection = builder.gui
})
//local changeVob = GUI.Button(anx(10), any(80), anx(75), any(25), "RED.TGA", "Zmie?", builder.gui)
local changeVob = GUI.Button({
	relativePositionPx = {x = 0.01 * Resolution.x, y = 0.1 * Resolution.y}
	sizePx = {width = 0.05 * Resolution.x, height = 0.03 * Resolution.y}
	file = "RED.TGA"
	draw = {text = "Zmieñ"}
	collection = builder.gui
})

//local toGround = GUI.Button(anx(210), any(120), anx(200), any(25), "RED.TGA", "Do ziemii", builder.gui)
local toGround = GUI.Button({
	relativePositionPx = {x = 0.18 * Resolution.x, y = 0.15 * Resolution.y}
	sizePx = {width = 0.1 * Resolution.x, height = 0.03 * Resolution.y}
	file = "RED.TGA"
	draw = {text = "Do ziemi"}
	collection = builder.gui
})
//local collisionChange = GUI.Button(anx(10), any(120), anx(200), any(25), "RED.TGA", "Kolizja: tak", builder.gui)
local collisionChange = GUI.Button({
	relativePositionPx = {x = 0.02 * Resolution.x, y = 0.15 * Resolution.y}
	sizePx = {width = 0.1 * Resolution.x, height = 0.03 * Resolution.y}
	file = "RED.TGA"
	draw = {text = "Kolizja: tak"}
	collection = builder.gui
})

local interactiveVob = GUI.Button({
	relativePositionPx = {x = 0.02 * Resolution.x, y = 0.20 * Resolution.y},
	sizePx = {width = 0.15 * Resolution.x, height = 0.03 * Resolution.y},
	file = "RED.TGA",
	draw = {text = "Interaktywny: nie"},
	collection = builder.gui
})

//local saveManager = GUI.Button(anx(10), any(310), anx(400), any(25), "RED.TGA", "Zapisz", builder.gui)
local saveManager = GUI.Button({
	relativePositionPx = {x = 0.02 * Resolution.x, y = 0.25 * Resolution.y}
	sizePx = {width = 0.25 * Resolution.x, height = 0.03 * Resolution.y}
	file = "RED.TGA"
	draw = {text = "Zapisz"}
	collection = builder.gui
})
//local checkManager = GUI.Button(anx(10), any(350), anx(400), any(25), "RED.TGA", "Rozstawione Voby", builder.gui)
local checkManager = GUI.Button({
	relativePositionPx = {x = 0.02 * Resolution.x, y = 0.3 * Resolution.y}
	sizePx = {width = 0.25 * Resolution.x, height = 0.03 * Resolution.y}
	file = "RED.TGA"
	draw = {text = "Rozstawione Voby"}
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
                case 1: cameraDraw.setText("Tryb kamery: Statyczna"); break;
                case 2: cameraDraw.setText("Tryb kamery: Vob"); break;
                case 3: cameraDraw.setText("Tryb kamery: Wolna"); break;
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
		case interactiveVob:
            if(interactiveVob.getText() == "Interaktywny: tak") {
                builder.isInteractive = false;
                interactiveVob.setText("Interaktywny: nie")
            }else{
                builder.isInteractive = true;
                interactiveVob.setText("Interaktywny: tak")
            }
        break;
	}
})

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
