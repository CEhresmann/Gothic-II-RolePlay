// Worlddraws.nut
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
                local text = packet.readString();
                local x = packet.readFloat();
                local y = packet.readFloat();
                local z = packet.readFloat();
                local distance = packet.readInt32();
                local r = packet.readUInt8();
                local g = packet.readUInt8();
                local b = packet.readUInt8();
                local a = packet.readUInt8();
                
                local draw3D = Draw3d(x, y, z);
                draw3D.distance = distance;
                draw3D.insertText(text);
                draw3D.visible = true;
                draw3D.color = Color(r, g, b, a);
                
                AllDraws3D.append({id = id, draw = draw3D});
            break;

            case PacketOther.Draw3DRemove:
                local id = packet.readInt16();

                foreach(index, drawData in AllDraws3D)
                {
                    if(drawData.id == id)
                    {
                        drawData.draw.visible = false;
                        AllDraws3D.remove(index);
                        break;
                    }
                }
            break;
        }
    }
}

addEventHandler("onPacket", Draw3DIntegration.packetHandler);