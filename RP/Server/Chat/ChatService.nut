/**
 * @file ChatService.nut
 * @description
 * Manages chat modes, command execution, and message dispatching.
 */
class ChatService {
    playerChatModes = null;
    lastPrivateMessage = null;

    constructor() {
        this.playerChatModes = {};
        this.lastPrivateMessage = {};
    }

    // --- Chat Mode Management ---

    function onPlayerJoin(pid) {
        playerChatModes[pid] <- "IC";
        sendSystemMessage(pid, "Welcome! Chat mode is set to IC. Press V to toggle OOC.");
        updateClientChatMode(pid);
    }

    function onPlayerDisconnect(pid) {
        if (pid in playerChatModes) delete playerChatModes[pid];
        if (pid in lastPrivateMessage) delete lastPrivateMessage[pid];
    }

    function toggleChatMode(pid) {
        if (!(pid in playerChatModes)) playerChatModes[pid] <- "IC";
        playerChatModes[pid] = (playerChatModes[pid] == "IC") ? "OOC" : "IC";
        updateClientChatMode(pid);
    }
    
    function getPlayerChatMode(pid) {
        return (pid in playerChatModes) ? playerChatModes[pid] : "IC";
    }

    // --- Message Dispatching ---

    function handlePublicMessage(pid, message) {
        local chatMode = getPlayerChatMode(pid);
        local prefix, prefixColor, contentColor, distance;

        if (chatMode == "IC") {
            prefix = getPlayerName(pid) + " says: ";
            prefixColor = { r = 255, g = 255, b = 0 };
            contentColor = { r = 255, g = 255, b = 255 };
            distance = 1500;
        } else {
            prefix = getPlayerName(pid) + " (OOC): ";
            prefixColor = { r = 255, g = 255, b = 255 };
            contentColor = { r = 200, g = 200, b = 200 };
            distance = 1500;
        }
        sendNearbyMessage(pid, chatMode, prefix, prefixColor, message, contentColor, distance);
    }

    function sendPrivateMessage(senderPid, targetPid, message) {
        if (!isPlayerConnected(targetPid)) {
            sendSystemMessage(senderPid, "Error: Player with ID " + targetPid + " is not online.");
            return;
        }
        
        lastPrivateMessage[senderPid] <- targetPid;
        lastPrivateMessage[targetPid] <- senderPid;

        local senderPrefix = "[PM -> " + getPlayerName(targetPid) + "]: ";
        local receiverPrefix = "[PM <- " + getPlayerName(senderPid) + "]: ";

        sendSystemMessage(senderPid, senderPrefix + message, {r=100, g=200, b=255}, {r=200, g=230, b=255});
        sendSystemMessage(targetPid, receiverPrefix + message, {r=255, g=150, b=100}, {r=255, g=200, b=180});
    }

    function replyToPrivateMessage(pid, message) {
        if (!(pid in lastPrivateMessage)) {
            sendSystemMessage(pid, "Error: You have no recent conversation to reply to.");
            return;
        }
        local targetId = lastPrivateMessage[pid];
        sendPrivateMessage(pid, targetId, message);
    }

    // --- Client Updates ---

    function updateClientChatMode(pid) {
        local response = createUpdateChatModeResponse(playerChatModes[pid]);
        local p = Packet();
        p.writeUInt8(PacketId.Other);
        p.writeUInt8(PacketOther.ChatMessage);
        writeChatPacket(response, p);
        p.send(pid, RELIABLE);
    }
}
