class ObjectIntegration
{
    Objects = [];

    function add(obj)
    {
        Objects.append(obj);

        return Objects[Objects.len()-1];
    }

    function onPacket(pid, packet)
    {
        local id = packet.readUInt8();
        if(id != PacketId.Object)
            return;

        id = packet.readUInt8();
        switch(id)
        {
            case PacketObject.Call:
                callEvent("onObjectInteraction", packet.readString())
            break;
        }
    }
}

function addObject(name)
{
    local obj = Object(name);
    obj.id = ObjectIntegration.Objects.len();
    ObjectIntegration.add(obj);
    return obj;
}

addEventHandler("onPacket", ObjectIntegration.onPacket)