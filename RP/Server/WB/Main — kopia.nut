
WorldBuilder <- {};
WorldBuilder.players <- [];
WorldBuilder.vobs <- [];

function WorldBuilder::commandInit(pid, params)
{
	local args = sscanf("s", params);
	if (!args)
	{
		sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /worldbuilder name");
		return;
	}

    if(args[0] != CFG.WorldBuilderPassword)
    {
        sendMessageToPlayer(pid, 255, 0, 0, "ACP: Z³e has³o do world buildera.");
        return;
    }

    WorldBuilder.players.append(pid);
    sendMessageToPlayer(pid, 255, 0, 0, "ACP: Zalogowano do world buildera. Mo¿esz u¿yæ F12 aby zacz¹æ budowaæ.");

    local packet = Packet();
    packet.writeUInt8(PacketId.WorldBuilder);
    packet.writeUInt8(PacketWorldBuilder.Player);
    packet.send(pid, RELIABLE_ORDERED);
    packet = null;
}

addCommand("worldbuilder", WorldBuilder.commandInit);

function addVob(x,y,z,rotx,roty,rotz,isStatic,name,synchronized = true){
    WorldBuilder.vobs.append({x = x, y = y, z = z, rotx = rotx, roty = roty, rotz = rotz, isStatic = isStatic, name = name, synchronized = synchronized});
}

function WorldBuilder::onPacket(pid, packet)
{
    local packetId = packet.readUInt8();
    if(packetId != PacketId.WorldBuilder)
        return;

    local find = false;
    foreach(_pid in WorldBuilder.players)
        if(_pid == pid)
            find = true;

    if(find == false) return;

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
            local pfile = file("database/tools/worldbuilder.txt", "a+");
            pfile.write("addVob("+posx + "," + posy + "," + posz + "," + rotx + "," + roty + "," + rotz + "," + isStatic + ",\"" + name + "\");\n");
            pfile.close();

            if(CFG.WorldBuilderTrueBuilding)
            {
                WorldBuilder.vobs.append({x = posx, y = posy, z = posz, rotx = rotx, roty = roty, rotz = rotz, isStatic = isStatic, name = name, synchronized = false});
                local vob = WorldBuilder.vobs[WorldBuilder.vobs.len() - 1];

                local packet = Packet();
                packet.writeUInt8(PacketId.WorldBuilder);
                packet.writeUInt8(PacketWorldBuilder.Vob);
                packet.writeString(vob.name);
                packet.writeFloat(vob.x);
                packet.writeFloat(vob.y);
                packet.writeFloat(vob.z);
                packet.writeInt16(vob.rotx);
                packet.writeInt16(vob.roty);
                packet.writeInt16(vob.rotz);
                packet.writeBool(vob.isStatic);
                packet.sendToAll(RELIABLE_ORDERED);
                packet = null;
            }
        break;
    }
}

addEventHandler("onPacket", WorldBuilder.onPacket);


function WorldBuilder::onPlayerJoin(pid)
{
    foreach(vob in WorldBuilder.vobs)
    {
        if(vob.synchronized)
            continue;

        local packet = Packet();
        packet.writeUInt8(PacketId.WorldBuilder);
        packet.writeUInt8(PacketWorldBuilder.Vob);
        packet.writeString(vob.name);
        packet.writeFloat(vob.x);
        packet.writeFloat(vob.y);
        packet.writeFloat(vob.z);
        packet.writeInt16(vob.rotx);
        packet.writeInt16(vob.roty);
        packet.writeInt16(vob.rotz);
        packet.writeBool(vob.isStatic);
        packet.send(pid, RELIABLE_ORDERED);
        packet = null;
    }
}

addEventHandler("onPlayerJoin", WorldBuilder.onPlayerJoin);