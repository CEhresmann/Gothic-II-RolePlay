/**
 * @file TradeEntity.nut
 * @description Domain entity for a trade session.
 */

enum TradeStatus {
    PENDING,  // Waiting for the target to accept the request
    ACTIVE,   // Both players are in the trade window
    ACCEPTED, // One player has accepted the trade
    CONFIRMED, // Both players have accepted, finalizing
    CLOSED    // Trade is finished (completed or cancelled)
}

class TradeSession {
    traderId = -1;
    targetId = -1;
    status = TradeStatus.PENDING;
    
    traderItems = null; // Items offered by the trader
    targetItems = null; // Items offered by the target
    
    traderAccepted = false;
    targetAccepted = false;
    
    createdAt = 0;

    constructor(p1, p2) {
        this.traderId = p1;
        this.targetId = p2;
        this.traderItems = [];
        this.targetItems = [];
        this.createdAt = getTickCount();
    }
    
    function getPartner(pid) {
        return (pid == traderId) ? targetId : traderId;
    }

    function hasAccepted(pid) {
        if (pid == traderId) return traderAccepted;
        if (pid == targetId) return targetAccepted;
        return false;
    }
    
    function setAccepted(pid, accepted) {
        if (pid == traderId) this.traderAccepted = accepted;
        if (pid == targetId) this.targetAccepted = accepted;

        // If one player accepts, and the other un-accepts by changing their offer, reset both
        if (!accepted) {
            this.traderAccepted = false;
            this.targetAccepted = false;
        }
    }
    
    function areBothAccepted() {
        return traderAccepted && targetAccepted;
    }
    
    function setItems(pid, items) {
        if (pid == traderId) this.traderItems = items;
        if (pid == targetId) this.targetItems = items;
        
        // Any change to the offer resets the acceptance status for both players
        this.traderAccepted = false;
        this.targetAccepted = false;
    }

    function getItems(pid) {
        if (pid == traderId) return traderItems;
        if (pid == targetId) return targetItems;
        return [];
    }
}
