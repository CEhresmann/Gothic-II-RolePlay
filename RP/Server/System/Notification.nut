
function addNotification(pid, text)
{
    local packet = Packet();
    packet.writeUInt8(PacketId.Other);
    packet.writeUInt8(PacketOther.Notification);
    packet.writeString(text);
    packet.send(pid, RELIABLE_ORDERED);
    packet = null;
}