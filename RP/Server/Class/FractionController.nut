/**
 * @file FractionController.nut
 * @description
 * Entry point for the fraction/class module.
 */

// Include architectural components
include("FractionEntity.nut");
include("FractionLoader.nut");
include("FractionService.nut");

// --- Initialization ---

// 1. Load all fraction data
local AllFractions = LoadFractions();

// 2. Initialize the service, providing it with dependencies (fractions and the global PlayerService)
FractionService <- FractionService(AllFractions, PlayerService);


// --- Command Registration ---

/**
 * Handles the /awans command to promote a player to a new class.
 */
function command_awans(pid, params) {
    local args = sscanf("dd", params);
    if (!args) {
        sendMessageToPlayer(pid, 255, 0, 0, "USAGE: /awans [class_id] [player_id]");
        return;
    }

    local targetPlayerId = args[1];
    if (!isPlayerSpawned(targetPlayerId)) {
        sendMessageToPlayer(pid, 255, 0, 0, "Player with ID " + targetPlayerId + " is not online.");
        return;
    }

    if (!FractionService.isPlayerFractionLeader(pid)) {
        sendMessageToPlayer(pid, 255, 0, 0, "You are not a leader of your fraction.");
        return;
    }

    local commandingPlayerEntity = PlayerService.getPlayerEntity(pid);
    local targetClassId = args[0];
    
    local fraction = FractionService.getFraction(commandingPlayerEntity.fractionId);
    if (!fraction || !fraction.getClass(targetClassId)) {
        sendMessageToPlayer(pid, 255, 0, 0, "The specified class ID does not exist in your fraction.");
        foreach (key, classObj in fraction.classes) {
            sendMessageToPlayer(pid, 255, 255, 0, key + " - " + classObj.name);
        }
        return;
    }

    if (FractionService.setPlayerClass(targetPlayerId, commandingPlayerEntity.fractionId, targetClassId)) {
        local className = fraction.getClass(targetClassId).name;
        local targetName = getPlayerName(targetPlayerId);
        local promoterName = getPlayerName(pid);

        sendMessageToPlayer(pid, 0, 255, 0, "You have promoted " + targetName + " to " + className + ".");
        sendMessageToPlayer(targetPlayerId, 0, 255, 0, "You have been promoted to " + className + " by " + promoterName + ".");
    } else {
        sendMessageToPlayer(pid, 255, 0, 0, "Failed to set class for the player.");
    }
}

addCommand("awans", command_awans);
