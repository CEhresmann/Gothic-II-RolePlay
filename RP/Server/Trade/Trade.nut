local tradeRequests = {};
addEventHandler("onPacket", function(playerId, packet) {
    local mainId = packet.readUInt8();
    if (mainId == PacketId.Player) {
        local subId = packet.readUInt8();
        if (subId == PacketPlayer.Trade) {
            local packetType = packet.readUInt8();
            switch (packetType) {
                case 1:
                    local targetId = packet.readInt32();
                    local traderId = packet.readInt32();
                    handleTradeRequest(playerId, targetId, traderId);
                    break;
                case 3:
                    local traderId = packet.readInt32();
                    local accepted = packet.readBool();
                    local responderId = packet.readInt32();
                    handleDirectTradeResponse(playerId, traderId, accepted, responderId);
                    break;
                case 5:
                    local targetId = packet.readInt32();
                    local traderId = packet.readInt32();
                    handleTradeUpdate(playerId, targetId, traderId, packet);
                    break;
                case 6:
                    local partnerId = packet.readInt32();
                    local acceptorId = packet.readInt32();
                    handleTradeAccept(playerId, partnerId, acceptorId);
                    break;
                case 10:
                    local targetId = packet.readInt32();
                    local traderId = packet.readInt32();
                    handleTradeClose(playerId, targetId, traderId);
                    break;
            }
        }
    }
});
function handleTradeAccept(senderId, partnerId, acceptorId) {
    if (senderId != acceptorId) return;
    if (!(acceptorId in tradeRequests) || !("active" in tradeRequests[acceptorId]) || !tradeRequests[acceptorId].active || tradeRequests[acceptorId].target != partnerId) {
        return;
    }
    tradeRequests[acceptorId].tradeAccepted = true;
    local updatePacket = Packet();
    updatePacket.writeUInt8(PacketId.Player);
    updatePacket.writeUInt8(PacketPlayer.Trade);
    updatePacket.writeUInt8(11);
    updatePacket.send(acceptorId, RELIABLE);
    if (isPlayerConnected(partnerId)) {
         updatePacket.send(partnerId, RELIABLE);
    }
    if (("tradeAccepted" in tradeRequests[partnerId]) && tradeRequests[partnerId].tradeAccepted) {
        foreach(item in tradeRequests[acceptorId].offeredItems) {
            removeItem(acceptorId, item.instance, item.amount);
            giveItem(partnerId, item.instance, item.amount);
        }
        foreach(item in tradeRequests[partnerId].offeredItems) {
            removeItem(partnerId, item.instance, item.amount);
            giveItem(acceptorId, item.instance, item.amount);
        }
        
        Database.saveItems(acceptorId);
        Database.saveItems(partnerId);
        
        SendSystemMessage(acceptorId, "Wymiana zakoñczona pomyœlnie!", {r=0, g=255, b=0});
        SendSystemMessage(partnerId, "Wymiana zakoñczona pomyœlnie!", {r=0, g=255, b=0});
        local finalPacket = Packet();
        finalPacket.writeUInt8(PacketId.Player);
        finalPacket.writeUInt8(PacketPlayer.Trade);
        finalPacket.writeUInt8(7);
        finalPacket.send(acceptorId, RELIABLE);
        finalPacket.send(partnerId, RELIABLE);
        delete tradeRequests[acceptorId];
        delete tradeRequests[partnerId];
    }
}
function cancelTrade(cancelerId, partnerId, reasonMessage) {
    if (isPlayerConnected(partnerId)) {
        SendSystemMessage(partnerId, reasonMessage, {r=255, g=0, b=0});
        local cancelPacket = Packet();
        cancelPacket.writeUInt8(PacketId.Player);
        cancelPacket.writeUInt8(PacketPlayer.Trade);
        cancelPacket.writeUInt8(8);
        cancelPacket.writeInt32(partnerId);
        cancelPacket.writeInt32(cancelerId);
        cancelPacket.send(partnerId, RELIABLE);
    }
    if (cancelerId in tradeRequests) delete tradeRequests[cancelerId];
    if (partnerId in tradeRequests) delete tradeRequests[partnerId];
}
function handleTradeClose(senderId, targetId, traderId) {
    if (senderId != traderId) return;
    if (!(traderId in tradeRequests) || !("active" in tradeRequests[traderId]) || !tradeRequests[traderId].active) return;
    local partnerId = tradeRequests[traderId].target;
    cancelTrade(traderId, partnerId, getPlayerName(traderId) + " anulowa³ handel.");
}
function handleTradeUpdate(senderId, targetId, traderId, packet) {
    if (senderId != traderId) {
        SendSystemMessage(senderId, "B³¹d autoryzacji", {r=255, g=0, b=0});
        return;
    }
    if (!isPlayerConnected(targetId) || !isPlayerSpawned(targetId)) {
        SendSystemMessage(senderId, "Gracz nie jest dostêpny", {r=255, g=0, b=0});
        return;
    }
    if (!(traderId in tradeRequests) || tradeRequests[traderId].target != targetId || !("active" in tradeRequests[traderId]) || !tradeRequests[traderId].active) {
        SendSystemMessage(senderId, "Brak aktywnego handlu", {r=255, g=0, b=0});
        return;
    }
    local itemCount = packet.readUInt16();
    local itemsData = [];
    for (local i = 0; i < itemCount; i++) {
        local itemName = packet.readString();
        local itemInstance = packet.readString();
        local itemAmount = packet.readUInt16();
        itemsData.append({ name = itemName, instance = itemInstance, amount = itemAmount });
    }
    tradeRequests[traderId].offeredItems = itemsData;
    tradeRequests[traderId].tradeAccepted = false;
    tradeRequests[targetId].tradeAccepted = false;
    local updatePacket = Packet();
    updatePacket.writeUInt8(PacketId.Player);
    updatePacket.writeUInt8(PacketPlayer.Trade);
    updatePacket.writeUInt8(5);
    updatePacket.writeInt32(targetId);
    updatePacket.writeInt32(traderId);
    updatePacket.writeUInt16(itemsData.len());
    foreach (item in itemsData) {
        updatePacket.writeString(item.name);
        updatePacket.writeString(item.instance);
        updatePacket.writeUInt16(item.amount);
    }
    updatePacket.send(targetId, RELIABLE);
    local resetPacket = Packet();
    resetPacket.writeUInt8(PacketId.Player);
    resetPacket.writeUInt8(PacketPlayer.Trade);
    resetPacket.writeUInt8(12);
    resetPacket.send(traderId, RELIABLE);
    resetPacket.send(targetId, RELIABLE);
}
function handleDirectTradeResponse(playerId, traderId, accepted, responderId) {
    if (playerId != responderId) {
        SendSystemMessage(playerId, "B³¹d autoryzacji", {r=255, g=0, b=0});
        return;
    }
    if (!isPlayerConnected(traderId) || !isPlayerSpawned(traderId)) {
        SendSystemMessage(playerId, "Gracz nie jest dostêpny", {r=255, g=0, b=0});
        return;
    }
    if (!(traderId in tradeRequests) || tradeRequests[traderId].target != playerId) {
        SendSystemMessage(playerId, "Brak aktywnej proœby handlowej", {r=255, g=0, b=0});
        return;
    }
    if (!accepted) {
        SendSystemMessage(playerId, "Odrzucono proœbê o handel", {r=255, g=0, b=0});
        SendSystemMessage(traderId, getPlayerName(playerId) + " odrzuci³ handel", {r=255, g=0, b=0});
        delete tradeRequests[traderId];
        delete tradeRequests[playerId];
        return;
    }
    tradeRequests[traderId].handled = true;
    tradeRequests[playerId].handled = true;
    tradeRequests[traderId].active <- true;
    tradeRequests[playerId].active <- true;
    tradeRequests[traderId].tradeAccepted <- false;
    tradeRequests[playerId].tradeAccepted <- false;
    tradeRequests[traderId].offeredItems <- [];
    tradeRequests[playerId].offeredItems <- [];
    local responsePacket = Packet();
    responsePacket.writeUInt8(PacketId.Player);
    responsePacket.writeUInt8(PacketPlayer.Trade);
    responsePacket.writeUInt8(2);
    responsePacket.writeInt32(traderId);
    responsePacket.writeBool(accepted);
    responsePacket.writeInt32(playerId);
    responsePacket.send(traderId, RELIABLE);
    local openPacket1 = Packet();
    openPacket1.writeUInt8(PacketId.Player);
    openPacket1.writeUInt8(PacketPlayer.Trade);
    openPacket1.writeUInt8(9);
    openPacket1.writeInt32(playerId);
    openPacket1.writeInt32(traderId);
    openPacket1.send(playerId, RELIABLE);
    local openPacket2 = Packet();
    openPacket2.writeUInt8(PacketId.Player);
    openPacket2.writeUInt8(PacketPlayer.Trade);
    openPacket2.writeUInt8(9);
    openPacket2.writeInt32(traderId);
    openPacket2.writeInt32(playerId);
    openPacket2.send(traderId, RELIABLE);
    SendSystemMessage(playerId, "Rozpoczynasz handel z " + getPlayerName(traderId), {r=0, g=255, b=0});
    SendSystemMessage(traderId, "Rozpoczynasz handel z " + getPlayerName(playerId), {r=0, g=255, b=0});
}
function handleTradeRequest(senderId, targetId, traderId) {
    if (!isPlayerConnected(targetId) || !isPlayerSpawned(targetId)) {
        SendSystemMessage(senderId, "Gracz nie jest dostêpny", {r=255, g=0, b=0});
        return;
    }
    if (senderId != traderId) {
        SendSystemMessage(senderId, "B³¹d autoryzacji", {r=255, g=0, b=0});
        return;
    }
    if (senderId in tradeRequests) {
        SendSystemMessage(senderId, "Masz ju¿ aktywn¹ proœbê o handel", {r=255, g=0, b=0});
        return;
    }
    if (targetId in tradeRequests) {
        SendSystemMessage(senderId, "Gracz ma ju¿ aktywn¹ proœbê o handel", {r=255, g=0, b=0});
        return;
    }
    tradeRequests[senderId] <- {
        target = targetId,
        timestamp = getTickCount(),
        handled = false
    };
    tradeRequests[targetId] <- {
        target = senderId,
        timestamp = getTickCount(),
        handled = false
    };
    local requestPacket = Packet();
    requestPacket.writeUInt8(PacketId.Player);
    requestPacket.writeUInt8(PacketPlayer.Trade);
    requestPacket.writeUInt8(1);
    requestPacket.writeInt32(targetId);
    requestPacket.writeInt32(senderId);
    requestPacket.send(targetId, RELIABLE);
    SendSystemMessage(senderId, "Wys³ano proœbê o handel do " + getPlayerName(targetId), {r=255, g=255, b=255});
}
setTimer(function() {
    local currentTime = getTickCount();
    local toRemove = [];
    foreach (playerId, request in tradeRequests) {
        local isHandled = ("handled" in request) ? request.handled : false;
        local isActive = ("active" in request) ? request.active : false;
        if (!isActive && !isHandled && (currentTime - request.timestamp > 30000)) {
            toRemove.append(playerId);
        }
        else if (!isActive && isHandled) {
            toRemove.append(playerId);
        }
    }
    foreach (playerId in toRemove) {
        if (playerId in tradeRequests) {
            local request = tradeRequests[playerId];
            local isHandled = ("handled" in request) ? request.handled : false;
            local targetId = request.target;
            delete tradeRequests[playerId];
            if (targetId in tradeRequests && tradeRequests[targetId].target == playerId) {
                delete tradeRequests[targetId];
            }
            if (!isHandled) {
                SendSystemMessage(playerId, "Czas na odpowiedŸ wygas³", {r=255, g=0, b=0});
                if (isPlayerConnected(targetId)) {
                    SendSystemMessage(targetId, "Czas na odpowiedŸ wygas³", {r=255, g=0, b=0});
                }
            }
        }
    }
}, 10000, 0);
addEventHandler("onPlayerDisconnect", function(playerId, reason) {
    if (playerId in tradeRequests) {
        local partnerId = tradeRequests[playerId].target;
        cancelTrade(playerId, partnerId, getPlayerName(playerId) + " roz³¹czy³ siê.");
    }
});
addEventHandler("onPlayerDead", function(playerId, killerid) {
    if (playerId in tradeRequests) {
        local partnerId = tradeRequests[playerId].target;
        SendSystemMessage(playerId, "Handel przerwany - zgin¹³eœ", {r=255, g=0, b=0});
        cancelTrade(playerId, partnerId, getPlayerName(playerId) + " zgin¹³, handel przerwany.");
    }
});

