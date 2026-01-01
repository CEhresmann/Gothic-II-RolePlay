/**
 * @file TradeService.nut
 * @description Manages the lifecycle of trade sessions.
 */
class TradeService {
    activeSessions = null; // Keyed by player ID

    constructor() {
        this.activeSessions = {};
    }

    function hasActiveSession(pid) {
        return pid in activeSessions;
    }

    /**
     * Creates a new trade request.
     */
    function createRequest(traderId, targetId) {
        if (hasActiveSession(traderId) || hasActiveSession(targetId)) {
            sendSystemMessage(traderId, "One of the players is already busy.");
            return false;
        }

        local session = TradeSession(traderId, targetId);
        activeSessions[traderId] <- session;
        activeSessions[targetId] <- session;
        
        // Notify the target player
        // ... packet sending logic will be here ...
        sendSystemMessage(traderId, "Trade request sent to " + getPlayerName(targetId));
        sendSystemMessage(targetId, "You have a trade request from " + getPlayerName(traderId));
        return true;
    }

    /**
     * Responds to a trade request.
     */
    function handleResponse(responderId, accepted) {
        if (!hasActiveSession(responderId)) return;
        
        local session = activeSessions[responderId];
        if (session.status != TradeStatus.PENDING) return;

        if (accepted) {
            session.status = TradeStatus.ACTIVE;
            // Notify both players to open the trade window
            // ... packet sending logic ...
            sendSystemMessage(session.traderId, getPlayerName(session.targetId) + " accepted the trade.");
            sendSystemMessage(session.targetId, "You accepted the trade with " + getPlayerName(session.traderId));
        } else {
            closeSession(responderId, "Trade request declined.");
        }
    }

    /**
     * Updates the items offered by a player in a session.
     */
    function updateOffer(pid, items) {
        if (!hasActiveSession(pid)) return;
        local session = activeSessions[pid];
        if (session.status != TradeStatus.ACTIVE) return;

        session.setItems(pid, items);
        
        // Notify the partner about the updated offer
        // ... packet sending logic ...
    }

    /**
     * Marks a player's side of the trade as accepted.
     */
    function acceptTrade(pid) {
        if (!hasActiveSession(pid)) return;
        local session = activeSessions[pid];
        if (session.status != TradeStatus.ACTIVE) return;

        session.setAccepted(pid, true);

        if (session.areBothAccepted()) {
            finalizeTrade(session);
        } else {
            // Notify the partner that this player has accepted
            // ... packet sending logic ...
        }
    }

    /**
     * Finalizes the trade, exchanging items.
     */
    function finalizeTrade(session) {
        session.status = TradeStatus.CONFIRMED;
        
        // Exchange items
        foreach(item in session.traderItems) {
            removeItem(session.traderId, item.instance, item.amount);
            giveItem(session.targetId, item.instance, item.amount);
        }
        foreach(item in session.targetItems) {
            removeItem(session.targetId, item.instance, item.amount);
            giveItem(session.traderId, item.instance, item.amount);
        }
        
        sendSystemMessage(session.traderId, "Trade successful!");
        sendSystemMessage(session.targetId, "Trade successful!");

        closeSession(session.traderId, "");
    }

    /**
     * Closes an active trade session for any reason (cancel, complete, disconnect).
     */
    function closeSession(pid, reason) {
        if (!hasActiveSession(pid)) return;
        
        local session = activeSessions[pid];
        local partnerId = session.getPartner(pid);
        
        if (isPlayerConnected(partnerId) && reason != "") {
            sendSystemMessage(partnerId, reason);
        }

        // Notify clients to close the trade window
        // ... packet sending logic ...

        delete activeSessions[session.traderId];
        delete activeSessions[session.targetId];
    }
}
