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
	isInteractive = false,
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
		packet.writeBool(vobManaged.isInteractive);
        packet.send(RELIABLE_ORDERED);

        savedVobs.append({
            name = vobManaged.name,
            x = _zvobpos.x,
            y = _zvobpos.y,
            z = _zvobpos.z,
            cdStatic = _zvob.cdStatic,
			isInteractive = vobManaged.isInteractive
        });
    }
    end();
}

function isVobAlreadySaved(vobManaged)
{
    local _zvobpos = vobManaged.element.getPosition();

    foreach(savedVob in builder.savedVobs) {
        if (savedVob.name == vobManaged.name &&
            abs(savedVob.x - _zvobpos.x) < 1.0 &&
            abs(savedVob.y - _zvobpos.y) < 1.0 &&
            abs(savedVob.z - _zvobpos.z) < 1.0 &&
			savedVob.isInteractive == vobManaged.isInteractive) {
            return true;
        }
    }
    return false;
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
	local isInteractive = builder.isInteractive;

    if(isInteractive)
	{
		newVob = MobInter(builder.list[vobsSelection.cat][vobsSelection.sId].name);
		newVob.name = "";
	}
    else
	{
		newVob = Vob(builder.list[vobsSelection.cat][vobsSelection.sId].name);
	}

    newVob.setPosition(currentVobPosition.x, currentVobPosition.y, currentVobPosition.z);
    newVob.setRotation(currentVobRotation.x, currentVobRotation.y, currentVobRotation.z);
    newVob.cdStatic = currentVob.cdStatic;
    newVob.cdDynamic = currentVob.cdStatic;
    newVob.addToWorld();

    manager.append({element = newVob, name = builder.list[vobsSelection.cat][vobsSelection.sId].name, isInteractive = isInteractive});
    builder.localVobs.append({
        name = builder.list[vobsSelection.cat][vobsSelection.sId].name,
        x = currentVobPosition.x,
        y = currentVobPosition.y,
        z = currentVobPosition.z,
		isInteractive = isInteractive
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
            Camera.setTargetVob(builder.vob);
        break;
        case 3: builderCamera.start(); break;
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
            local name = packet.readString();
            local x = packet.readFloat();
            local y = packet.readFloat();
            local z = packet.readFloat();
            local rotx = packet.readInt16();
            local roty = packet.readInt16();
            local rotz = packet.readInt16();
            local isStatic = packet.readBool();
			local isInteractive = packet.readBool();

            local isLocalVob = false;
            foreach(localVob in builder.localVobs) {
                if (localVob.name == name &&
                    abs(localVob.x - x) < 1.0 &&
                    abs(localVob.y - y) < 1.0 &&
                    abs(localVob.z - z) < 1.0 &&
					localVob.isInteractive == isInteractive) {
                    isLocalVob = true;
                    break;
                }
            }

            if (!isLocalVob) {
                addVob(x,y,z,rotx,roty,rotz,isStatic,name, isInteractive);
            }
        break;
    }
}

function isBuilderActive() { return builder.active; }

function addVob(x,y,z,rotx,roty,rotz,isStatic,name, isInteractive, synchronized = true)
{
    local duplicate = false;
    foreach(managedVob in builder.manager) {
        if (managedVob.name == name) {
            local pos = managedVob.element.getPosition();
            if (abs(pos.x - x) < 1.0 && abs(pos.y - y) < 1.0 && abs(pos.z - z) < 1.0 && managedVob.isInteractive == isInteractive) {
                duplicate = true;
                break;
            }
        }
    }

    if (!duplicate) {
		local placeVob;
		if(isInteractive)
		{
			placeVob = MobInter(name);
			placeVob.name = "";
		}
		else
			placeVob = Vob(name);

        placeVob.setPosition(x,y,z);
        placeVob.setRotation(rotx, roty, rotz);
        placeVob.cdStatic = isStatic;
        placeVob.cdDynamic = isStatic;
        placeVob.addToWorld();

        builder.manager.append({element = placeVob, name = name, isInteractive = isInteractive});

        builder.savedVobs.append({
            name = name,
            x = x,
            y = y,
            z = z,
            cdStatic = isStatic,
			isInteractive = isInteractive
        });
    }
}

addEventHandler("onPacket", packetHandler);

