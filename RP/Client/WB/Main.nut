builder <- {
    gui = null,
    vob = null,
    manager = [],

    list = {
        "Wszystkie" : [],
        "Budowle" : [],
        "Mieszkanie" : [],
        "Inne" : [],
    },

    active = false,
    cameraMode = 1,

    access = false,
}

function builder::start()
{
    if(access == false)
        return;
         
    active = true;
    Interface.baseInterface(true, PLAYER_GUI.WORLDBUILDER);

    showGUI();
    placeVob();
    onBuilderCameraChange();
}

function builder::end()
{
    vob = null;
    Interface.baseInterface(false);

    hideGUI();
    active = false;

    manager.clear();
}

function builder::save()
{
    foreach(vobManaged in manager)
    {
        local _zvob = vobManaged.element;
        local _zvobpos = _zvob.getPosition();
        local _zvobrot = _zvob.getRotation();
        local packet = Packet();
        packet.writeUInt8(PacketId.WorldBuilder);
        packet.writeUInt8(PacketWorldBuilder.Vob);
        packet.writeString(vobManaged.name);
        packet.writeFloat(_zvobpos.x);
        packet.writeFloat(_zvobpos.y);
        packet.writeFloat(_zvobpos.z);
        packet.writeInt16(_zvobrot.x);
        packet.writeInt16(_zvobrot.y);
        packet.writeInt16(_zvobrot.z);
        packet.writeBool(_zvob.cdStatic);
        packet.send(RELIABLE_ORDERED);
        packet = null;
    }
    end();
}

function builder::keyHandler(key)
{
    switch(key)
    {
        case KEY_F12:
            end();
        break;
        case KEY_RETURN:
            setUpVob();
        break;
    }

    if(cameraMode == 3)
        builderCamera.keyHandler(key)
    else
        vobKeyHandler(key);
}

function builder::setUpVob()
{
    local currentVob = builder.vob;
    local currentVobPosition = currentVob.getPosition();
    local currentVobRotation = currentVob.getRotation();

    local newVob = Vob(builder.list[vobsSelection.cat][vobsSelection.sId].name);
    newVob.setPosition(currentVobPosition.x, currentVobPosition.y, currentVobPosition.z);
    newVob.setRotation(currentVobRotation.x, currentVobRotation.y, currentVobRotation.z);
    newVob.cdStatic = currentVob.cdStatic;
    builder.manager.append({element = newVob, name = builder.list[vobsSelection.cat][vobsSelection.sId].name});

    builderManager.openRenders();
    builder.vob.setPosition(currentVobPosition.x + 100, currentVobPosition.y, currentVobPosition.z);
}

function addVob(x,y,z,rotx,roty,rotz,isStatic,name,synchronized = true)
{
    local placeVob = Vob(name);
    placeVob.setPosition(x,y,z);
    placeVob.setRotation(rotx, roty, rotz);
    placeVob.cdDynamic = true;
    placeVob.cdStatic = isStatic;
    builder.manager.append({element = placeVob, name = name});
}

function builder::onBuilderCameraChange()
{
    switch(cameraMode)
    {
        case 1:
            _Camera.movementEnabled = false
            _Camera.modeChangeEnabled = false;
        break;
        case 2:
            _Camera.movementEnabled = true
            _Camera.modeChangeEnabled = false;
            _Camera.setTargetVob(builder.vob);
        break;
        case 3:
            builderCamera.start()
        break;
    }
}


local function keyHandler(key)
{
    if(builder.active) {
        builder.keyHandler(key);
        return;
    }

    if(Player.gui != -1)
        return;

    if(key == KEY_F12)
    {
        builder.start();
        return;
    }
}

addEventHandler("onKey", keyHandler);

local function packetHandler(packet)
{
    local packetId = packet.readUInt8();
    if(packetId != PacketId.WorldBuilder)
        return;  

    packetId = packet.readUInt8();
    switch(packetId)
    {
        case PacketWorldBuilder.Player:
            builder.access = true;
        break;
        case PacketWorldBuilder.Vob:
            local name = packet.readString();
            local x = packet.readFloat();
            local y = packet.readFloat();
            local z = packet.readFloat();
            local rotx = packet.readInt16();
            local roty = packet.readInt16();
            local rotz = packet.readInt16();
            local isStatic = packet.readBool();
            addVob(x,y,z,rotx,roty,rotz,isStatic,name)
        break;
    }
}

addEventHandler("onPacket", packetHandler);

function isBuilderActive()
{
    return builder.active;
}