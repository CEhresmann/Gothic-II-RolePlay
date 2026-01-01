local npcSounds = {};

addEventHandler("onPacket", function(packet) {
    try {
        local packetCategory = packet.readUInt8();

        if (packetCategory == PacketId.Bot) {
            local packetType = packet.readUInt8();

            if (packetType == PacketBot.PlaySound) {
                local npcId = packet.readInt32();
                local soundName = packet.readString();

                playNPCSound(npcId, soundName);
            }
        }
    } catch (e) {
        print("Error reading packet: " + e);
        print("Packet bytes: " + packet.bytesUsed);
    }
});

function playNPCSound(npcId, soundName) {
    try {
        if (soundName in npcSounds) {
            local sound = npcSounds[soundName];
            sound.setTargetPlayer(npcId);

            if (sound.isPlaying()) {
                sound.stop();
            }

            sound.play();
        } else {
            try {
                npcSounds[soundName] <- Sound3d(soundName + ".wav");
                npcSounds[soundName].volume = 0.8;
                npcSounds[soundName].radius = 2000;
                npcSounds[soundName].ambient = false;

                local sound = npcSounds[soundName];
                sound.setTargetPlayer(npcId);
                sound.play();
            } catch (e) {
                print("Failed to load sound: " + soundName + ".wav - " + e);
            }
        }
    } catch (e) {
        print("Error in playNPCSound: " + e);
    }
}
