
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
                local drawId = packet.readInt16();
                local text = packet.readString();
                local x = packet.readFloat();
                local y = packet.readFloat();
                local z = packet.readFloat();
                local distance = packet.readInt32();
                local r = packet.readUInt8();
                local g = packet.readUInt8();
                local b = packet.readUInt8();
                local a = packet.readUInt8();
                
                local projector = Projector3d(x, y, z, distance);
                local label = Label(0, 0, text);
                label.color = Color(r, g, b, a);
                label.visible = false;
                
                projector.onVisibilityChange = function(visible) {
                    label.visible = visible;
                }
                
                projector.onUpdate = function(screenPositionPx, deltaDistance) {
                    label.setPositionPx(screenPositionPx.x - label.widthPx / 2.0, screenPositionPx.y);
                    label.visible = true;
                }
                
                local drawObj = {
                    id = drawId, 
                    projector = projector,
                    label = label
                };
                
                AllDraws3D.append(drawObj);
            break;

            case PacketOther.Draw3DRemove:
                local drawId = packet.readInt16();

                foreach(index, drawData in AllDraws3D)
                {
                    if(drawData.id == drawId)
                    {
                        drawData.label.visible = false;
                        AllDraws3D.remove(index);
                        break;
                    }
                }
            break;
        }
    }
}

addEventHandler("onPacket", Draw3DIntegration.packetHandler);