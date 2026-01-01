class ObjectIntegration
{
    Objects = [];

    function add(obj)
    {
        Objects.append(obj);

        return Objects[Objects.len()-1];
    }

    function packetCall(name)
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Object);
        packet.writeUInt8(PacketObject.Call);
        packet.writeString(name);
        packet.send(RELIABLE_ORDERED);
        packet = null;
    }

    function checkObjects(key = -1)
    {
        foreach(obj in ObjectIntegration.Objects)
            obj.checkObjects(key);
    }
}

function addObject(name)
{
    local obj = Object(name);
    obj.id = ObjectIntegration.Objects.len();
    ObjectIntegration.add(obj);
    return obj;
}

addEventHandler("onSecond", ObjectIntegration.checkObjects)
addEventHandler("onKey", ObjectIntegration.checkObjects)