/**
 * @file PlayerController.nut
 * @description
 * Entry point for the player module.
 *
 * This file initializes the PlayerService and registers all necessary
 * game event handlers, delegating the logic to the service layer.
 * It acts as the bridge between the game engine's event system and business logic.
 */

// Include the new architectural components
include("PlayerEntity.nut");
include("PlayerRepository.nut");
include("PlayerService.nut");

// Global instance of the player service
PlayerService <- PlayerService();

// --- Event Handlers ---

::addEventHandler("onPacket", function(pid, packet) {
    local packetType = packet.readUInt8();
    if (packetType != PacketId.Player) return;

    local playerPacketType = packet.readUInt8();
    switch (playerPacketType) {
        case PacketPlayer.Register:
            local username = packet.readString();
            local password = packet.readString();
            PlayerService.registerPlayer(pid, username, password);
            break;
        case PacketPlayer.LoggIn:
            local username = packet.readString();
            local password = packet.readString();
            PlayerService.loginPlayer(pid, username, password);
            break;
        // ... other packet handlers will delegate to PlayerService
    }
});

::addEventHandler("onPlayerDisconnect", function(pid, reason) {
    PlayerService.onPlayerDisconnect(pid);
});

::addEventHandler("onExit", function() {
    local onlinePlayers = getOnlinePlayers();
    foreach (playerId in onlinePlayers) {
        PlayerService.savePlayerState(playerId);
        kick(playerId, "Server is shutting down. Please come back later!");
    }
});

// We can add other event handlers here (onPlayerDead, onSecond, etc.)
// and have them call appropriate methods in the PlayerService.
