/**
 * @file TradeController.nut
 * @description Entry point for the trade module.
 */

include("TradeEntity.nut");
include("TradeService.nut");

TradeService <- TradeService();

addEventHandler("onPacket", function(playerId, packet) {
    local mainId = packet.readUInt8();
    if (mainId != PacketId.Player) return;
    
    local subId = packet.readUInt8();
    if (subId != PacketPlayer.Trade) return;

    local packetType = packet.readUInt8();
    switch (packetType) {
        case 1: // Request Trade
            local targetId = packet.readInt32();
            TradeService.createRequest(playerId, targetId);
            break;
        case 3: // Respond to Request
            local accepted = packet.readBool();
            TradeService.handleResponse(playerId, accepted);
            break;
        case 5: // Update Offer
            local itemCount = packet.readUInt16();
            local items = [];
            for (local i = 0; i < itemCount; i++) {
                items.append({
                    name = packet.readString(),
                    instance = packet.readString(),
                    amount = packet.readUInt16()
                });
            }
            TradeService.updateOffer(playerId, items);
            break;
        case 6: // Accept Trade
            TradeService.acceptTrade(playerId);
            break;
        case 10: // Close/Cancel Trade
            TradeService.closeSession(playerId, getPlayerName(playerId) + " cancelled the trade.");
            break;
    }
});

addEventHandler("onPlayerDisconnect", function(playerId, reason) {
    if (TradeService.hasActiveSession(playerId)) {
        TradeService.closeSession(playerId, getPlayerName(playerId) + " disconnected.");
    }
});

addEventHandler("onPlayerDead", function(playerId, killerId) {
    if (TradeService.hasActiveSession(playerId)) {
        TradeService.closeSession(playerId, getPlayerName(playerId) + " died.");
    }
});
