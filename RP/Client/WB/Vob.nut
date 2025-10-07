
local activeKeys = [];

function builder::placeVob()
{
    local pos = Camera.getPosition();
    builder.vob = Vob(builder.list["Wszystkie"][0].name);
    builder.vob.cdStatic = false;
    builder.vob.setPosition(pos.x+300,pos.y,pos.z);
    builder.vob.cdStatic = true;


    builder.vob.addToWorld();
}

function builder::vobKeyHandler(key)
{
    switch(key)
    {
        case KEY_E: case KEY_Q: case KEY_DOWN: case KEY_UP: case KEY_LEFT: case KEY_RIGHT: case KEY_A: case KEY_D: case KEY_W: case KEY_S:
            activeKeys.append(key);
        break;
    }
}

function builder::changeVob(visual)
{
    vob.visual = visual;
}

local function renderHandler()
{
    if(activeKeys.len() == 0)
        return;

    local position = builder.vob.getPosition();
    local rotation = builder.vob.getRotation();

    local speed = 1;
    if(isKeyPressed(KEY_LSHIFT))
        speed = speed * 5;


    foreach(index, key in activeKeys)
    {
        if(!isKeyPressed(key))
        {
            activeKeys.remove(index);
            continue;
        }

        switch(key)
        {
            case KEY_DOWN: // Move forward vob using rotation
                position.x = position.x - (sin(rotation.y * 3.14 / 180.0) * speed);
                position.z = position.z - (cos(rotation.y * 3.14 / 180.0) * speed);
            break;
            case KEY_UP: // Move back vob using rotation
                position.x = position.x + (sin(rotation.y * 3.14 / 180.0) * speed);
                position.z = position.z + (cos(rotation.y * 3.14 / 180.0) * speed);
            break;
            case KEY_LEFT: // Move left vob using rotation
                position.x = position.x + (sin(((rotation.y - 90) - floor(rotation.y / 360) * 360) * 3.14 / 180.0) * speed);
                position.z = position.z + (cos(((rotation.y - 90) - floor(rotation.y / 360) * 360) * 3.14 / 180.0) * speed);
            break;
            case KEY_RIGHT: // Move right vob using rotation
                position.x = position.x + (sin(((rotation.y + 90) - floor(rotation.y / 360) * 360) * 3.14 / 180.0) * speed);
                position.z = position.z + (cos(((rotation.y + 90) - floor(rotation.y / 360) * 360) * 3.14 / 180.0) * speed);
            break;
            case KEY_Q:
                position.y = position.y + speed;
            break;
            case KEY_E:
                position.y = position.y - speed;
            break;
            case KEY_D: // Change rotation
                rotation.y = rotation.y + 1;
            break;
            case KEY_A: // Change rotation
                rotation.y = rotation.y - 1;
            break;
            case KEY_W: // Change rotation
                rotation.x = rotation.x + 1;
            break;
            case KEY_S: // Change rotation
                rotation.x = rotation.x - 1;
            break;
        }
    }

    builder.vob.setPosition(position.x, position.y, position.z);
    builder.vob.setRotation(rotation.x, rotation.y, rotation.z);
}

addEventHandler("onRender", renderHandler);