if (!("PacketId" in getroottable())) {
    ::PacketId <- {
        WorldBuilder = 3
    }
}

if (!("PacketWorldBuilder" in getroottable())) {
    ::PacketWorldBuilder <- {
        Player = 1,
        Vob = 2
    }
}

builder <- {
    gui = null,
    vob = null,
    cameraDrawLabel = null,
    manager = [],
    savedVobs = [],
    list = {
        "Wszystkie" : [],
        "Budowle" : [],
        "Mieszkanie" : [],
        "Inne" : [],
    },
    active = false,
    cameraMode = 1,
    access = false,
	vobType = VobType.Static,
    doorKey = "",
    localVobs = []
}

function builder::start()
{
    if(access == false) return;
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
    Camera.setTargetPlayer(heroId);
    Camera.modeChangeEnabled = true;

    for (local i = manager.len() - 1; i >= 0; i--) {
        local vobManaged = manager[i];
        if (!isVobAlreadySaved(vobManaged)) {
            if (vobManaged.element != null) {
                vobManaged.element.removeFromWorld();
            }
            manager.remove(i);
        }
    }
}

function builder::save()
{
    foreach(vobManaged in manager)
    {
        if (isVobAlreadySaved(vobManaged)) {
            continue;
        }

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
		packet.writeUInt8(vobManaged.vobType);
        if (vobManaged.vobType == VobType.Door) {
            packet.writeString(vobManaged.keyInstance);
        }
        packet.send(RELIABLE_ORDERED);

        savedVobs.append({
            id = null, 
            name = vobManaged.name,
            x = _zvobpos.x,
            y = _zvobpos.y,
            z = _zvobpos.z,
            cdStatic = _zvob.cdStatic,
			vobType = vobManaged.vobType,
            keyInstance = vobManaged.keyInstance
        });
    }
    end();
}

function isVobAlreadySaved(vobManaged)
{
    return vobManaged.id != null;
}

function builder::keyHandler(key)
{
    switch(key)
    {
        case KEY_F12: end(); break;
        case KEY_RETURN: setUpVob(); break;
    }
    if(cameraMode == 3) builderCamera.keyHandler(key)
    else vobKeyHandler(key);
}

function builder::setUpVob()
{
    local currentVob = builder.vob;
    local currentVobPosition = currentVob.getPosition();
    local currentVobRotation = currentVob.getRotation();

	local newVob;
	local vobType = builder.vobType;
    local vobName = builder.list[vobsSelection.cat][vobsSelection.sId].name;
    local keyInstance = builder.doorKey;

    switch(vobType)
    {
        case VobType.Static:
            newVob = Vob(vobName);
            break;
        case VobType.Interactive:
            newVob = MobInter(vobName);
            newVob.name = "";
            break;
        case VobType.Door:
            newVob = MobDoor(vobName);
            newVob.name = "";
            if (keyInstance != "") {
                newVob.keyInstance = keyInstance;
                newVob.locked = true;
            }
            break;
    }


    newVob.setPosition(currentVobPosition.x, currentVobPosition.y, currentVobPosition.z);
    newVob.setRotation(currentVobRotation.x, currentVobRotation.y, currentVobRotation.z);
    newVob.cdStatic = currentVob.cdStatic;
    newVob.cdDynamic = currentVob.cdStatic;
    newVob.addToWorld();

    manager.append({id = null, element = newVob, name = vobName, vobType = vobType, keyInstance = keyInstance});
    builder.localVobs.append({
        id = null,
        name = vobName,
        x = currentVobPosition.x,
        y = currentVobPosition.y,
        z = currentVobPosition.z,
		vobType = vobType,
        keyInstance = keyInstance
    });

}

function builder::onBuilderCameraChange()
{
    switch(cameraMode)
    {
        case 1:
            Camera.movementEnabled = false
            Camera.modeChangeEnabled = false;
        break;
        case 2:
            Camera.movementEnabled = true
            Camera.modeChangeEnabled = false;
            if (builder.vob) Camera.setTargetVob(builder.vob);
        break;
        case 3: builderCamera.start(); break;
    }
}

function builder::focusOnVob(vobInstance) {
    if (vobInstance) {
        builder.cameraMode = 2;
        if (builder.cameraDrawLabel) {
            builder.cameraDrawLabel.setText("Tryb kamery: Vob");
        }
        Camera.setTargetVob(vobInstance);
        Camera.movementEnabled = true;
        Camera.modeChangeEnabled = false;
    }
}

local function keyHandler(key)
{
    if(builder.active) {
        builder.keyHandler(key);
        return;
    }
    if(Player.gui != -1) return;
    if(key == KEY_F12) builder.start();
}

addEventHandler("onKeyDown", keyHandler);

local function packetHandler(packet)
{
    local packetId = packet.readUInt8();
    if(packetId != PacketId.WorldBuilder) return;
    packetId = packet.readUInt8();
    switch(packetId)
    {
        case PacketWorldBuilder.Player:
            builder.access = true;
            break;
        case PacketWorldBuilder.Vob:
            local id = packet.readInt32();
            local name = packet.readString();
            local x = packet.readFloat();
            local y = packet.readFloat();
            local z = packet.readFloat();
            local rotx = packet.readInt16();
            local roty = packet.readInt16();
            local rotz = packet.readInt16();
            local isStatic = packet.readBool();
			local vobType = packet.readUInt8();
            local keyInstance = "";
            if (vobType == VobType.Door) {
                keyInstance = packet.readString();
            }

            local wasLocalVob = false;
            foreach(managedVob in builder.manager) {
                if (managedVob.id == null) {
                    local pos = managedVob.element.getPosition();
                    if (managedVob.name == name &&
                        abs(pos.x - x) < 1.0 &&
                        abs(pos.y - y) < 1.0 &&
                        abs(pos.z - z) < 1.0 &&
                        managedVob.vobType == vobType)
                    {
                        managedVob.id = id;
                        foreach(saved in builder.savedVobs) {
                             if (saved.id == null && saved.name == name && abs(saved.x - x) < 1.0 && abs(saved.y - y) < 1.0 && abs(saved.z - z) < 1.0 && saved.vobType == vobType) {
                                saved.id = id;
                                break;
                            }
                        }
                        wasLocalVob = true;
                        break;
                    }
                }
            }

            if (!wasLocalVob) {
                addVob(id, x,y,z,rotx,roty,rotz,isStatic,name, vobType, true, keyInstance);
            }
        break;
        case PacketWorldBuilder.VobRemove:
            local vobIdToRemove = packet.readInt32();

            for (local i = builder.manager.len() - 1; i >= 0; i--) {
                if (builder.manager[i].id == vobIdToRemove) {
                    if (builder.manager[i].element) {
                        builder.manager[i].element.removeFromWorld();
                    }
                    builder.manager.remove(i);
                    break;
                }
            }
            for (local i = builder.savedVobs.len() - 1; i >= 0; i--) {
                if (builder.savedVobs[i].id == vobIdToRemove) {
                    builder.savedVobs.remove(i);
                    break;
                }
            }
            if (builderManager.active) {
                builderManager.openRenders();
            }
            break;
    }
}

function isBuilderActive() { return builder.active; }

function addVob(id, x,y,z,rotx,roty,rotz,isStatic,name, vobType, synchronized = true, keyInstance = "")
{
    local duplicate = false;
    foreach(managedVob in builder.manager) {
        if (managedVob.id != null && managedVob.id == id) {
            duplicate = true;
            break;
        }
    }

    if (!duplicate) {
		local placeVob;
		switch(vobType)
        {
            case VobType.Static:
                placeVob = Vob(name);
                break;
            case VobType.Interactive:
                placeVob = MobInter(name);
                placeVob.name = "";
                break;
            case VobType.Door:
                placeVob = MobDoor(name);
                placeVob.name = "";
                if (keyInstance != "") {
                    placeVob.keyInstance = keyInstance;
                    placeVob.locked = true;
                }
                break;
        }

        if (placeVob) {
            placeVob.setPosition(x,y,z);
            placeVob.setRotation(rotx, roty, rotz);
            placeVob.cdStatic = isStatic;
            placeVob.cdDynamic = isStatic;
            placeVob.addToWorld();

            builder.manager.append({id = id, element = placeVob, name = name, vobType = vobType, keyInstance = keyInstance});

            builder.savedVobs.append({
                id = id,
                name = name,
                x = x,
                y = y,
                z = z,
                cdStatic = isStatic,
                vobType = vobType,
                keyInstance = keyInstance
            });
        }
    }
}

addEventHandler("onPacket", packetHandler);

