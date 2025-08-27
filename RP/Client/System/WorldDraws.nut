
local AllDraws3D = [];

class Draw3DIntegration
{
    function packetHandler(packet)
    {
        local id = packet.readUInt8();
        if(id != PacketId.Other)
            return;

        id = packet.readUInt8();
        switch(id)
        {
            case PacketOther.Draw3D:
                local id = packet.readInt16();
                local name = packet.readString();
                local draw3D = Draw3d(packet.readFloat(),packet.readFloat(),packet.readFloat());
                draw3D.distance = 1000;
                draw3D.insertText(name);
                draw3D.visible = true;
                draw3D.setColor(0, 200, 0);
                AllDraws3D.append({id = id, draw = draw3D});
            break;

            case PacketOther.Draw3DRemove:
                local id = packet.readInt16();

                foreach(_id, _draw in AllDraws3D)
                {
                    if(_draw.id == id)
                        AllDraws3D.remove(_id);
                }
            break;
        }
    }
}

addEventHandler("onPacket", Draw3DIntegration.packetHandler)