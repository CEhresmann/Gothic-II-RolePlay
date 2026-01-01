
builderCamera <- {};

builderCamera.active <- false;
builderCamera.speedMoving <- 1;
builderCamera.activeKeys <- [];

function builderCamera::start()
{
    local pos = getPlayerPosition(heroId);

    active = true;
    Camera.movementEnabled = false
    Camera.modeChangeEnabled = false;
}

function builderCamera::end()
{
    active = false;

    Camera.movementEnabled = true
    Camera.modeChangeEnabled = true
    Camera.targetVob = Vob(getPlayerPtr(heroId));
}

function builderCamera::keyHandler(key)
{
    if(!active)
        return;

    switch(key)
    {
        case KEY_E: case KEY_Q: case KEY_DOWN: case KEY_UP: case KEY_LEFT: case KEY_RIGHT: case KEY_A: case KEY_D: case KEY_W: case KEY_S:
            builderCamera.activeKeys.append(key);
        break;
    }
}

local function renderHandler()
{
    if(!isBuilderActive())
        return;

    if(builderCamera.activeKeys.len() == 0)
        return;

    local position = Camera.getPosition();
    local rotation = Camera.getRotation();

    local speed = builderCamera.speedMoving;
    if(isKeyPressed(KEY_LSHIFT))
        speed = speed * 5;


    foreach(index, key in builderCamera.activeKeys)
    {
        if(!isKeyPressed(key))
        {
            builderCamera.activeKeys.remove(index);
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
                rotation.y = rotation.y + speed;
            break;
            case KEY_A: // Change rotation
                rotation.y = rotation.y - speed;
            break;
            case KEY_W: // Change rotation
                rotation.x = rotation.x + speed;
            break;
            case KEY_S: // Change rotation
                rotation.x = rotation.x - speed;
            break;
        }
    }

    Camera.setPosition(position.x, position.y, position.z);
    Camera.setRotation(rotation.x, rotation.y, rotation.z);
}

addEventHandler("onRender", renderHandler);