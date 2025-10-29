WaypointGridView <- {
    on = false,

    draws = [], lines = [],

    points = [],
};

WaypointGridView.toggle <- function(active)
{
    active == 1 ? show() : hide();
}

WaypointGridView.show <- function()
{
    on = true;
    local pWorld = getWorld();

    foreach(_index, _tab in mapWaypoints[pWorld])
    {
        local idDraw = draws.len();
        draws.append(Draw3d(_tab.position[0], _tab.position[1], _tab.position[2]))
        draws[idDraw].visible  = true;
        draws[idDraw].distance = 3000;
        draws[idDraw].insertText(_index);
        draws[idDraw].setColor(200, 0, 0)


        foreach(_way in _tab.ways)
        {
            local wayWP = mapWaypoints[pWorld][_way[0]];
            lines.append(Line3d(_tab.position[0], _tab.position[1], _tab.position[2], wayWP.position[0], wayWP.position[1], wayWP.position[2]));
            lines[lines.len() - 1].setColor(200, 0, 0);
        }
    }
}

WaypointGridView.hide <- function()
{
    on = false;

    draws.clear();
    lines.clear();
}

addEventHandler("onRender", function() {
    if(WaypointGridView.lines.len() == 0)
        return;

    local pos = getPlayerPosition(heroId);
    foreach(_line in WaypointGridView.lines)
    {
        local posLine = _line.getBegin();
        if(getDistance2d(pos.x, pos.z, posLine.x, posLine.z) < 3000)
            _line.visible = true;
        else
            _line.visible = false;
    }
})

addEventHandler("onKeyDown", function (key) {
    if(WaypointGridView.on == false)
        return;

    if(key == KEY_F12)
        WaypointGridViewManager.toggle()
})

WaypointGridViewManager <- {
    active = false,

    vob = Vob("SKULL.3DS"),
    keys = [], draws = [], lines = [],
    points = {},back = [],
    lastPoint = -1,
}

WaypointGridViewManager.toggle <- function()
{
    active == false ? show() : hide();
}

WaypointGridViewManager.show <- function()
{
    local pos = getPlayerPosition(heroId);
    active = true;

    Camera.setFreeze(true);
    Camera.setPosition(pos.x, pos.y + 1000, pos.z)
    Camera.setRotation(60,0,0);

    vob.setPosition(pos.x, pos.y, pos.z);
    vob.cdStatic = false;
    vob.cdDynamic = false;

    Player.gui = PLAYER_GUI.GRIDEDITOR;

    setFreeze(true);
    setCursorVisible(true);
}

WaypointGridViewManager.hide <- function()
{
    active = false;

    Camera.setDefaultCamera();
    Player.gui = -1;

    setFreeze(false);
    setCursorVisible(false);

    local packet = Packet();
    packet.writeUInt8(PacketId.Admin)
    packet.writeUInt8(PacketAdmin.Path)
    packet.send(RELIABLE_ORDERED);
    packet = null;

    foreach(over in WaypointGridViewManager.back)
    {
        local k = WaypointGridViewManager.points[over];
        local packet = Packet();
        packet.writeUInt8(PacketId.Admin)
        packet.writeUInt8(PacketAdmin.PathWay)
        packet.writeString(k.name);
        packet.writeFloat(k.position[0]);
        packet.writeFloat(k.position[1]);
        packet.writeFloat(k.position[2]);
        packet.writeInt16(k.ways.len());
        foreach(pathWay in k.ways)
        {
            packet.writeString(pathWay);
        }
        packet.send(RELIABLE_ORDERED);
        packet = null;
    }
}

WaypointGridViewManager.createUniqueName <- function ()
{
    local t = "OWN_PATH_"+WaypointGridViewManager.points.len();
    return t;
}

WaypointGridViewManager.placeObject <- function()
{
    local positionVob = vob.getPosition();

    if(lastPoint != -1)
    {
        foreach(_point in WaypointGridViewManager.points)
        {
            if(getDistance2d(_point.position[0], _point.position[2], positionVob.x, positionVob.z) < 150)
            {
                if(_point == lastPoint)
                {
                    return;
                }

                if(_point.ways.find(lastPoint.name) != null) {
                    lastPoint = _point;
                    return;
                }

                _point.ways.append(lastPoint.name);
                lines.append(Line3d(_point.position[0], _point.position[1], _point.position[2], lastPoint.position[0], lastPoint.position[1], lastPoint.position[2]));
                lines[lines.len() - 1].setColor(200, 0, 0);
                lines[lines.len() - 1].visible = true;
                lastPoint = _point;
                return;
            }
        }
    }

    local name = WaypointGridViewManager.createUniqueName();

    WaypointGridViewManager.points[name] <- {
        name = name,
        position = [positionVob.x,positionVob.y,positionVob.z],
        ways = [],
    }

    WaypointGridViewManager.back.append(name);

    lastPoint = WaypointGridViewManager.points[name];

    local idDraw = draws.len();
    draws.append(Draw3d(positionVob.x, positionVob.y, positionVob.z))
    draws[idDraw].visible  = true;
    draws[idDraw].distance = 3000;
    draws[idDraw].insertText(name);
    draws[idDraw].setColor(200, 0, 0);
}

addEventHandler("onKeyDown", function (key) {
    if(WaypointGridViewManager.active == false)
        return;

    if(Player.gui != PLAYER_GUI.GRIDEDITOR)
        return;

    switch(key)
    {
        case KEY_Q: case KEY_E: case KEY_W: case KEY_S: case KEY_A: case KEY_D: case KEY_LEFT: case KEY_RIGHT: case KEY_UP: case KEY_DOWN: WaypointGridViewManager.keys.append(key); break;
        case KEY_RETURN: WaypointGridViewManager.placeObject(); break;
        case KEY_BACK: WaypointGridViewManager.removeObject(); break;
    }
})

addEventHandler("onRender", function() {
    if(Player.gui != PLAYER_GUI.GRIDEDITOR)
        return;

    foreach(_ind, _key in WaypointGridViewManager.keys)
    {
        if(!isKeyPressed(_key))
            WaypointGridViewManager.keys.remove(_ind);


        local pPosition = getPlayerPosition(heroId);
        switch(_key)
        {
            case KEY_LEFT:
                local posCamera = Camera.getPosition();
                Camera.setPosition(posCamera.x + 5, posCamera.y, posCamera.z);
            break;
            case KEY_RIGHT:
                local posCamera = Camera.getPosition();
                Camera.setPosition(posCamera.x - 5, posCamera.y, posCamera.z);
            break;
            case KEY_UP:
                local posCamera = Camera.getPosition();
                Camera.setPosition(posCamera.x, posCamera.y, posCamera.z + 5);
            break;
            case KEY_DOWN:
                local posCamera = Camera.getPosition();
                Camera.setPosition(posCamera.x, posCamera.y, posCamera.z - 5);
            break;
            case KEY_A:
                local posVob = WaypointGridViewManager.vob.getPosition();
                WaypointGridViewManager.vob.setPosition(posVob.x - 5, posVob.y, posVob.z);
            break;
            case KEY_D:
                local posVob = WaypointGridViewManager.vob.getPosition();
                WaypointGridViewManager.vob.setPosition(posVob.x + 5, posVob.y, posVob.z);
            break;
            case KEY_W:
                local posVob = WaypointGridViewManager.vob.getPosition();
                WaypointGridViewManager.vob.setPosition(posVob.x, posVob.y, posVob.z + 5);
            break;
            case KEY_S:
                local posVob = WaypointGridViewManager.vob.getPosition();
                WaypointGridViewManager.vob.setPosition(posVob.x, posVob.y, posVob.z - 5);
            break;
            case KEY_Q:
                local posVob = WaypointGridViewManager.vob.getPosition();
                WaypointGridViewManager.vob.setPosition(posVob.x, posVob.y + 5, posVob.z);
            break;
            case KEY_E:
                local posVob = WaypointGridViewManager.vob.getPosition();
                WaypointGridViewManager.vob.setPosition(posVob.x, posVob.y - 5, posVob.z);
            break;
        }
    }
})
