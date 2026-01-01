lootedNpcs <- {};
processedPackets <- {};


setTimer(function() {
    foreach (npcId, looted in lootedNpcs) {
        if (isPlayerConnected(npcId) && !isPlayerDead(npcId) && isNpc(npcId)) {
            delete lootedNpcs[npcId];
        }
    }
}, 30000, 0);


addEventHandler("onPlayerDead", function(playerid, killerid) {
    if (isNpc(playerid) && playerid in lootedNpcs) {
        delete lootedNpcs[playerid];
    }
});

addEventHandler("onPacket", function(playerid, packet) {
    local mainId = packet.readUInt8();
    
    if (mainId == PacketId.Other) {
        local subId = packet.readUInt8();
        
        if (subId == PacketOther.LootBody) {
            local npcId = packet.readInt32();
            
            local packetId = playerid + "_" + npcId + "_" + getTickCount();
            if (packetId in processedPackets) return;
            processedPackets[packetId] <- true;
            
            if (processedPackets.len() > 100) processedPackets.clear();
            
            if (isPlayerConnected(npcId) && isPlayerDead(npcId) && isNpc(npcId)) {
                if (!(npcId in lootedNpcs)) {
					if (getPlayerProfessionLevel(playerid, 0) >= 1){
						local npcName = getPlayerName(npcId);
						
						if (npcName in LootMobItems) {
							local lootPacket = Packet();
							lootPacket.writeUInt8(PacketId.Other);
							lootPacket.writeUInt8(PacketOther.LootData);
							lootPacket.writeInt32(npcId);
							lootPacket.writeString(npcName);
							
							local lootArray = LootMobItems[npcName];
							lootPacket.writeUInt8(lootArray.len());
							
							foreach (lootItem in lootArray) {
								lootPacket.writeString(lootItem.item);
								lootPacket.writeUInt16(lootItem.quantity);
							}
							
							lootPacket.send(playerid, RELIABLE);
						}
					}else {
						addNotification(playerid, "Nie posiadasz umiętności Myśliwego!");
					}
                }
            }
        }
        else if (subId == PacketOther.TakeAllLoot) {
            local npcId = packet.readInt32();
            
            if (isPlayerConnected(npcId) && isPlayerDead(npcId) && isNpc(npcId)) {
                if (!(npcId in lootedNpcs)) {
                    local npcName = getPlayerName(npcId);
                    
                    if (npcName in LootMobItems) {
                        giveLootToPlayer(playerid, npcName);
                        lootedNpcs[npcId] <- true;
                        
                        local responsePacket = Packet();
                        responsePacket.writeUInt8(PacketId.Other);
                        responsePacket.writeUInt8(PacketOther.Notification);
                        responsePacket.writeString("Zebrano wszystkie przedmioty!");
                        responsePacket.send(playerid, RELIABLE);
                    }
                } else {
                    local responsePacket = Packet();
                    responsePacket.writeUInt8(PacketId.Other);
                    responsePacket.writeUInt8(PacketOther.Notification);
                    responsePacket.writeString("To ciało zostało już wylootowane!");
                    responsePacket.send(playerid, RELIABLE);
                }
            }
        }
    }
});

function giveLootToPlayer(playerid, npcName) {
    local lootArray = LootMobItems[npcName];
    foreach (lootItem in lootArray) {
        giveItem(playerid, lootItem.item, lootItem.quantity);
    }
}