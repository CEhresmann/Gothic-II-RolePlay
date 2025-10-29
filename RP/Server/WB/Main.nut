class VobModel extends ORM.Model </ table="worldbuilder_vobs" />
{
    </ primary_key = true, auto_increment = true />
    id = 0;
    </ type = "VARCHAR(255)" />
    name = "";
    </ type = "FLOAT" />
    x = 0.0;
    </ type = "FLOAT" />
    y = 0.0;
    </ type = "FLOAT" />
    z = 0.0;
    </ type = "INTEGER" />
    rotx = 0;
    </ type = "INTEGER" />
    roty = 0;
    </ type = "INTEGER" />
    rotz = 0;
    </ type = "BOOLEAN" />
    isStatic = false;
	</ type = "INTEGER" />
    vobType = 0;
    </ type = "VARCHAR(255)" />
    keyInstance = "";
}

WorldBuilder <- {
    players = [],
    vobs = []
};

function WorldBuilder::onInit() { WorldBuilder.loadVobs(); }

function WorldBuilder::loadVobs()
{
    try {
        local vobsFromDb = VobModel.findAll();
        foreach(dbVob in vobsFromDb) WorldBuilder.vobs.append(dbVob);
    } catch (e) {}
}

function WorldBuilder::commandInit(pid, params)
{
    if (checkPermission(pid, LEVEL.MOD)){
        local alreadyBuilder = false;
        foreach(_pid in WorldBuilder.players) {
            if (_pid == pid) {
                alreadyBuilder = true;
                break;
            }
        }
        if (!alreadyBuilder) WorldBuilder.players.append(pid);
        SendSystemMessage(pid, "WB: Zalogowano do World Buildera. U¿yj F12, aby rozpocz¹æ budowanie.", {r=0,g=255,b=0});
        local packet = Packet();
        packet.writeUInt8(PacketId.WorldBuilder);
        packet.writeUInt8(PacketWorldBuilder.Player);
        packet.send(pid, RELIABLE_ORDERED);
        packet = null;
    }
}

addCommand("wb", WorldBuilder.commandInit);

function WorldBuilder::onPacket(pid, packet)
{
    local packetId = packet.readUInt8();
    if (packetId != PacketId.WorldBuilder) return;
    local isBuilder = false;
    foreach(_pid in WorldBuilder.players) {
        if (_pid == pid) {
            isBuilder = true;
            break;
        }
    }
    if (!isBuilder) return;
    packetId = packet.readUInt8();
    switch(packetId)
    {
        case PacketWorldBuilder.Vob:
            local name = packet.readString();
            local posx = packet.readFloat();
            local posy = packet.readFloat();
            local posz = packet.readFloat();
            local rotx = packet.readInt16();
            local roty = packet.readInt16();
            local rotz = packet.readInt16();
            local isStatic = packet.readBool();
            local vobType = packet.readUInt8();
            local keyInstance = "";
            if (vobType == VobType.Door) {
                keyInstance = packet.readString();
            }

            local existingVob = null;
            try {
                existingVob = VobModel.findOne("name = ? AND x = ? AND y = ? AND z = ? AND vobType = ?",
                    [name, posx, posy, posz, vobType]);
            } catch (e) {}

            if (existingVob != null) {
                SendSystemMessage(pid, "WB: Vob '" + name + "' ju¿ istnieje na tej pozycji.", {r=255,g=0,b=0});
                return;
            }

            try {
                local newVob = VobModel();
                newVob.name = name;
                newVob.x = posx;
                newVob.y = posy;
                newVob.z = posz;
                newVob.rotx = rotx;
                newVob.roty = roty;
                newVob.rotz = rotz;
                newVob.isStatic = isStatic;
                newVob.vobType = vobType;
                newVob.keyInstance = keyInstance;
                newVob.insert();
                SendSystemMessage(pid, "WB: Vob '" + name + "' zosta³ zapisany w bazie danych (ID: " + newVob.id + ").", {r=0,g=255,b=0});

                if (CFG.WorldBuilderTrueBuilding) {
                    WorldBuilder.vobs.append(newVob);
                    local updatePacket = Packet();
                    updatePacket.writeUInt8(PacketId.WorldBuilder);
                    updatePacket.writeUInt8(PacketWorldBuilder.Vob);
                    updatePacket.writeInt32(newVob.id);
                    updatePacket.writeString(newVob.name);
                    updatePacket.writeFloat(newVob.x);
                    updatePacket.writeFloat(newVob.y);
                    updatePacket.writeFloat(newVob.z);
                    updatePacket.writeInt16(newVob.rotx);
                    updatePacket.writeInt16(newVob.roty);
                    updatePacket.writeInt16(newVob.rotz);
                    updatePacket.writeBool(newVob.isStatic);
                    updatePacket.writeUInt8(newVob.vobType);
                    if (newVob.vobType == VobType.Door) {
                        updatePacket.writeString(newVob.keyInstance);
                    }
                    updatePacket.sendToAll(RELIABLE_ORDERED);
                    updatePacket = null;
                }
            } catch (e) {
                SendSystemMessage(pid, "WB: B³šd zapisu voba do bazy danych: " + e, {r=255,g=0,b=0});
            }
        break;
		case PacketWorldBuilder.VobRemove:
			local vobIdToRemove = packet.readInt32();
			try {
				local vobToRemove = VobModel.findOne(@(q) q.where("id", "=", vobIdToRemove));

				if (vobToRemove != null)
				{
					local vobName = vobToRemove.name;
					local vobId = vobToRemove.id;
					
					vobToRemove.remove();

					SendSystemMessage(pid, "WB: Vob '" + vobName + "' (ID: " + vobId + ") zosta³ usuniêty z bazy danych.", {r=0,g=255,b=0});

					foreach(i, vob in WorldBuilder.vobs) {
						if (vob.id == vobId) {
							WorldBuilder.vobs.remove(i);
							break;
						}
					}

					local removePacket = Packet();
					removePacket.writeUInt8(PacketId.WorldBuilder);
					removePacket.writeUInt8(PacketWorldBuilder.VobRemove);
					removePacket.writeInt32(vobId);
					removePacket.sendToAll(RELIABLE_ORDERED);
				}
				else
				{
					SendSystemMessage(pid, "WB: Nie znaleziono voba o ID " + vobIdToRemove + " w bazie danych.", {r=255,g=0,b=0});
				}

			} catch(e) {
				SendSystemMessage(pid, "WB: Wyst¹pi³ b³¹d podczas usuwania voba o ID " + vobIdToRemove + ": " + e, {r=255,g=0,b=0});
				print("B³¹d usuwania voba: " + e);
			}
		break;
    }
}


function WorldBuilder::onPlayerJoin(pid)
{
    if (WorldBuilder.vobs.len() == 0) return;
    foreach(vob in WorldBuilder.vobs) {
        local packet = Packet();
        packet.writeUInt8(PacketId.WorldBuilder);
        packet.writeUInt8(PacketWorldBuilder.Vob);
        packet.writeInt32(vob.id);
        packet.writeString(vob.name);
        packet.writeFloat(vob.x);
        packet.writeFloat(vob.y);
        packet.writeFloat(vob.z);
        packet.writeInt16(vob.rotx);
        packet.writeInt16(vob.roty);
        packet.writeInt16(vob.rotz);
        packet.writeBool(vob.isStatic);
		packet.writeUInt8(vob.vobType);
        if (vob.vobType == VobType.Door) {
            packet.writeString(vob.keyInstance);
        }
        packet.send(pid, RELIABLE_ORDERED);
        packet = null;
    }
}

addEventHandler("onInit", WorldBuilder.onInit);
addEventHandler("onPacket", WorldBuilder.onPacket);
addEventHandler("onPlayerJoin", WorldBuilder.onPlayerJoin);

