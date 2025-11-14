local playerGodMode = false;

function handleGodModePacket(packet) {
    local enabled = packet.readBool();
    playerGodMode = enabled;
}

function onPlayerDamageClient(killerid, playerid, description) {
    if (playerGodMode && playerid == heroId) {
        description.damage = 0;
        return true;
    }

    return false;
}


addEventHandler("onKeyDown", function(key) {
    if (key == KEY_F8 && !chatInputIsOpen()) {
        local packet = Packet();
        packet.writeUInt8(PacketId.Admin);
        packet.writeUInt8(PacketAdmin.Fly);
        packet.send(RELIABLE_ORDERED);
    }
    else if (key == KEY_K && !chatInputIsOpen()) {
        local packet = Packet();
        packet.writeUInt8(PacketId.Admin);
        packet.writeUInt8(PacketAdmin.Phase);
        packet.send(RELIABLE_ORDERED);
    }
});

addEventHandler("onPacket", function(packet) {
    local packetId = packet.readUInt8();

    if (packetId == PacketId.Admin) {
        local adminPacketType = packet.readUInt8();

        if (adminPacketType == PacketAdmin.GodMode) {
            handleGodModePacket(packet);
        }
        else if (adminPacketType == PacketAdmin.Fly) {
        }
        else if (adminPacketType == PacketAdmin.Phase) {
        }
    }
});

addEventHandler("onPlayerDamageClient", onPlayerDamageClient);

function getGodModeStatus() {
    return playerGodMode;
}