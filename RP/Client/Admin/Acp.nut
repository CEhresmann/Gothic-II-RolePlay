
addEventHandler("onPacket", function (packet) {
        local id = packet.readUInt8();
        if(id != PacketId.Admin)
            return;
        
        id = packet.readUInt8();
        switch(id)
        {
            case PacketAdmin.Grid:
                local turnOff = packet.readInt16();
                WaypointGridView.toggle(turnOff);
            break;
        }
})