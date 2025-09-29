addEventHandler("onKeyDown", function(key)
{
    if (key == KEY_F8 && !chatInputIsOpen())
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Admin);
        packet.writeUInt8(PacketAdmin.Fly);
        packet.send(RELIABLE_ORDERED);
    }
    else if (key == KEY_K && !chatInputIsOpen())
    {
        local packet = Packet();
        packet.writeUInt8(PacketId.Admin);
        packet.writeUInt8(PacketAdmin.Phase);
        packet.send(RELIABLE_ORDERED);
    }
});
