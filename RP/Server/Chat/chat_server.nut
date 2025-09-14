local playerChatMode = {};
local chatCommands = {};

function addChatCommand(commandName, handlerFunction) {
    if (commandName in chatCommands) {
        print("[WARNING] Komenda '" + commandName + "' jest juz zarejestrowana!");
        return false;
    }
    
    chatCommands[commandName] <- handlerFunction;
    print("[SYSTEM] Zarejestrowano komende: /" + commandName);
    return true;
}

SendSystemMessage <- function(target, message, prefixColor = {r=0, g=255, b=0}, messageColor = {r=255, g=255, b=255}, chatMode = "IC") {
    local packet = createDisplayMultiColorChatMessage(chatMode, "(!) ", prefixColor, message, messageColor);
    
    local p = Packet();
    p.writeUInt8(PacketId.Other);
    p.writeUInt8(PacketOther.ChatMessage);
    writeChatPacket(packet, p);
    
    if (target == null) {
        p.sendToAll(RELIABLE);
    } else if (isPlayerConnected(target)) {
        p.send(target, RELIABLE);
    }
}

addEventHandler("onPlayerJoin", function(pid) {
    playerChatMode[pid] <- "IC";
    SendSystemMessage(pid, "Witaj! Tryb czatu ustawiony na IC. Naciœnij V, aby prze³¹czyæ na OOC.");
    
    local response = createUpdateChatModeResponse(playerChatMode[pid]);
    local p = Packet();
    p.writeUInt8(PacketId.Other);
    p.writeUInt8(PacketOther.ChatMessage);
    writeChatPacket(response, p);
    p.send(pid, RELIABLE);
});

addEventHandler("onPlayerDisconnect", function(pid, reason) {
    if (pid in playerChatMode) {
        delete playerChatMode[pid];
    }
});

addEventHandler("onPacket", function(pid, packet) {
    local mainId = packet.readUInt8();
    
    if (mainId == PacketId.Other) {
        local subId = packet.readUInt8();
        
        if (subId == PacketOther.ChatMessage) {
            try {
                local chatPacket = readChatPacket(packet);
                
                if (chatPacket.type == ChatPacketType.ToggleChatModeRequest) {
                    if (!(pid in playerChatMode)) playerChatMode[pid] <- "IC";
                    playerChatMode[pid] = (playerChatMode[pid] == "IC") ? "OOC" : "IC";
                    
                    local response = createUpdateChatModeResponse(playerChatMode[pid]);
                    local p = Packet();
                    p.writeUInt8(PacketId.Other);
                    p.writeUInt8(PacketOther.ChatMessage);
                    writeChatPacket(response, p);
                    p.send(pid, RELIABLE);
                }
            } catch (e) {}
        }
    }
});

addEventHandler("onPlayerMessage", function(pid, message) {
    if (!(pid in playerChatMode)) {
        playerChatMode[pid] <- "IC";
    }

    if (message.len() > 0 && message[0] == '/') {
        return;
    }

    local chatMode = playerChatMode[pid];
    local prefix, prefixColor, contentColor;
    local distance = 1500;

    if (chatMode == "IC") {
        prefix = getPlayerName(pid) + " mówi: ";
        prefixColor = { r = 255, g = 255, b = 0 };
        contentColor = { r = 255, g = 255, b = 255 };
    } else {
        prefix = getPlayerName(pid) + " (OOC): ";
        prefixColor = { r = 255, g = 255, b = 255 };
        contentColor = { r = 200, g = 200, b = 200 };
    }

    sendNearbyMultiColorMessage(pid, chatMode, prefix, prefixColor, message, contentColor, distance);

    local notifyPacket = createNewMessageNotify(chatMode);
    local p = Packet();
    p.writeUInt8(PacketId.Other);
    p.writeUInt8(PacketOther.ChatMessage);
    writeChatPacket(notifyPacket, p);

    for (local i = 0; i < getMaxSlots(); i++) {
        if (isPlayerConnected(i) && i != pid && (i in playerChatMode) && playerChatMode[i] != chatMode) {
            p.send(i, RELIABLE);
        }
    }

    return false;
});

function sendNearbyMultiColorMessage(senderId, chatMode, prefix, prefixColor, content, contentColor, distance) {
    local senderPosition = getPlayerPosition(senderId);
    if (!senderPosition) return;

    local packet = createDisplayMultiColorChatMessage(chatMode, prefix, prefixColor, content, contentColor);
    local p = Packet();
    p.writeUInt8(PacketId.Other);
    p.writeUInt8(PacketOther.ChatMessage);
    writeChatPacket(packet, p);

    for (local i = 0; i < getMaxSlots(); i++) {
        if (isPlayerConnected(i)) {
            local receiverPosition = getPlayerPosition(i);
            if (receiverPosition && getDistance3d(senderPosition.x, senderPosition.y, senderPosition.z, receiverPosition.x, receiverPosition.y, receiverPosition.z) <= distance) {
                p.send(i, RELIABLE);
            }
        }
    }
}

addEventHandler("onPlayerCommand", function(pid, command, params) {
    if (!(pid in playerChatMode)) return;

    if (command in chatCommands) {
        chatCommands[command](pid, params);
        return;
    }

    if (playerChatMode[pid] == "OOC") return;

    local prefix = "";
    local content = "";
    local color, distance;

    switch(command) {
        case "me":
            prefix = "# " + getPlayerName(pid) + " ";
            content = params + " #";
            color = { r = 200, g = 150, b = 255 };
            distance = 1500;
            break;
            
        case "do":
            prefix = "";
            content = params + " (( " + getPlayerName(pid) + " ))";
            color = { r = 100, g = 200, b = 255 };
            distance = 1500;
            break;
            
        case "sz":
            prefix = getPlayerName(pid) + " szepcze: ";
            content = params;
            color = { r = 220, g = 220, b = 220 };
            distance = 500;
            break;
            
        case "k":
            prefix = getPlayerName(pid) + " krzyczy: ";
            content = params + "!";
            color = { r = 255, g = 100, b = 100 };
            distance = 4000;
            break;
            
        default:
            return;
    }
    
    sendNearbyMultiColorMessage(pid, "IC", prefix, color, content, color, distance);
});

function addChatCommand(commandName, handlerFunction) {
    chatCommands[commandName] <- function(pid, params) {
        handlerFunction(pid, params);
    };
}