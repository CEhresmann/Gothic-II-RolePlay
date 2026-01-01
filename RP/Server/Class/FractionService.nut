/**
 * @file FractionService.nut
 * @description
 * Contains business logic for fraction and class-related operations.
 */
class FractionService {
    fractions = null;
    playerService = null;

    constructor(loadedFractions, playerSrv) {
        this.fractions = loadedFractions;
        this.playerService = playerSrv;
    }

    /**
     * Sets a player's class and fraction.
     * @param {integer} pid - The target player's ID.
     * @param {integer} fractionId - The ID of the fraction to set.
     * @param {integer} classId - The ID of the class to set.
     * @returns {boolean} True on success, false otherwise.
     */
    function setPlayerClass(pid, fractionId, classId) {
        if (!fractions.rawin(fractionId)) {
            logError("[FractionService] Attempted to assign non-existent fraction ID: " + fractionId);
            return false;
        }
        
        local fraction = fractions[fractionId];
        if (!fraction.getClass(classId)) {
            logError("[FractionService] Attempted to assign non-existent class ID: " + classId);
            return false;
        }

        local playerEntity = playerService.getPlayerEntity(pid);
        if (playerEntity) {
            playerEntity.fractionId = fractionId;
            playerEntity.classId = classId;
            
            // Notify the client about the change
            local packet = Packet();
            packet.writeUInt8(PacketId.Player);
            packet.writeUInt8(PacketPlayer.SetClass);
            packet.writeInt16(fractionId);
            packet.writeInt16(classId);
            packet.send(pid, RELIABLE_ORDERED);
            
            return true;
        }
        return false;
    }

    /**
     * Checks if a player is a leader of their fraction.
     * @param {integer} pid - The player's ID.
     * @returns {boolean}
     */
    function isPlayerFractionLeader(pid) {
        local playerEntity = playerService.getPlayerEntity(pid);
        if (playerEntity && fractions.rawin(playerEntity.fractionId)) {
            local fraction = fractions[playerEntity.fractionId];
            local playerClass = fraction.getClass(playerEntity.classId);
            return (playerClass && playerClass.isLeader);
        }
        return false;
    }
    
    /**
     * Gets a fraction entity by its ID.
     * @param {integer} fractionId
     * @returns {FractionEntity|null}
     */
    function getFraction(fractionId) {
        return fractions.rawin(fractionId) ? fractions[fractionId] : null;
    }
}
