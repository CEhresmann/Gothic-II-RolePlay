/**
 * @file ChatController.nut
 * @description
 * Entry point for the chat module. Initializes the service,
 * loads commands, and registers event handlers.
 */

// Include architectural components
include("ChatService.nut");

// Global instances
ChatService <- ChatService();
ChatCommands <- {};

/**
 * Registers a chat command.
 * @param {string} commandName - The name of the command (e.g., "pm").
 * @param {function} handler - The function to execute.
 */
function addChatCommand(commandName, handler) {
    if (commandName in ChatCommands) {
        logWarning("[Chat] Command '" + commandName + "' is already registered!");
        return;
    }
    ChatCommands[commandName] <- handler;
}

// --- Load all commands from the Commands directory ---
local commandFiles = listFiles("RP/Server/Chat/Commands/*.nut");
foreach (file in commandFiles) {
    include(file);
    logInfo("[Chat] Loaded command file: " + file);
}


// --- Event Handlers ---

addEventHandler("onPlayerJoin", function(pid) {
    ChatService.onPlayerJoin(pid);
});

addEventHandler("onPlayerDisconnect", function(pid, reason) {
    ChatService.onPlayerDisconnect(pid);
});

addEventHandler("onPacket", function(pid, packet) {
    local mainId = packet.readUInt8();
    if (mainId == PacketId.Other && packet.readUInt8() == PacketOther.ChatMessage) {
        try {
            local chatPacket = readChatPacket(packet);
            if (chatPacket.type == ChatPacketType.ToggleChatModeRequest) {
                ChatService.toggleChatMode(pid);
            }
        } catch (e) {
            logError("[Chat] Error processing chat packet: " + e);
        }
    }
});

addEventHandler("onPlayerMessage", function(pid, message) {
    if (message.len() > 0 && message[0] == '/') {
        return; // Command, will be handled by onPlayerCommand
    }
    ChatService.handlePublicMessage(pid, message);
    return false; // Suppress default message handling
});

addEventHandler("onPlayerCommand", function(pid, command, params) {
    if (command in ChatCommands) {
        try {
            ChatCommands[command](pid, params);
        } catch (e) {
            logError("[Chat] Error executing command '" + command + "': " + e);
            sendSystemMessage(pid, "An error occurred while executing the command.");
        }
    } else {
        // Handle other types of commands like /me, /do if they aren't in the Commands folder
    }
});
