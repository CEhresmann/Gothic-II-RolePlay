/**
 * @class PlayerService
 * @description
 * Contains the business logic for player-related operations.
 *
 * This class acts as a coordinator between the domain entities (PlayerEntity)
 * and the data access layer (PlayerRepository). It orchestrates complex
 * operations and enforces application-specific rules.
 */
class PlayerService {
    playerRepository = null;
    playerEntities = null; // A collection to hold active player entities

    constructor() {
        this.playerRepository = PlayerRepository();
        this.playerEntities = [];
        for (local i = 0; i < getMaxSlots(); i++) {
            this.playerEntities.append(PlayerEntity(i));
        }
    }

    /**
     * Handles the player registration process.
     * @param {integer} pid - The player's ID.
     * @param {string} username - The desired username.
     * @param {string} password - The plaintext password.
     */
    function registerPlayer(pid, username, password) {
        if (playerRepository.findByName(username)) {
            addNotification(pid, "This account already exists.");
            return;
        }

        local salt = Bcrypt.generateSalt(12, 'b');
        local hashedPassword = Bcrypt.hash(password, salt);

        local player = getPlayerEntity(pid);
        player.name = username;
        player.passwordHash = hashedPassword;
        player.isLoggedIn = true;

        // Save the new player to the database
        playerRepository.save(player);
        
        // Sync state with the game engine
        applyEntityToGame(player);
        
        // Notify client
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.Register);
        packet.writeInt16(pid);
        packet.send(pid, RELIABLE_ORDERED);

        callEvent("onPlayerLoggedIn", pid);
    }

    /**
     * Handles the player login process.
     * @param {integer} pid - The player's ID.
     * @param {string} username - The username.
     * @param {string} password - The plaintext password.
     */
    function loginPlayer(pid, username, password) {
        local storedData = playerRepository.findByName(username);
        if (!storedData) {
            addNotification(pid, "This account does not exist.");
            return;
        }

        if (storedData.ck == 1) {
            addNotification(pid, "This account is marked as CK and cannot be logged into.");
            return;
        }

        if (!Bcrypt.compare(password, storedData.password)) {
            addNotification(pid, "Incorrect password.");
            return;
        }

        local player = getPlayerEntity(pid);
        player.name = username;
        
        // Load all data from the database into the entity
        playerRepository.load(player);
        player.isLoggedIn = true;

        // Apply the loaded state to the player in the game world
        applyEntityToGame(player);

        // Notify client
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.LoggIn);
        packet.writeInt16(pid);
        packet.send(pid, RELIABLE_ORDERED);
        
        callEvent("onPlayerLoggedIn", pid);
    }

    /**
     * Saves the player's current state to the database.
     * @param {integer} pid - The player's ID.
     */
    function savePlayerState(pid) {
        local player = getPlayerEntity(pid);
        if (player.isLoggedIn) {
            try {
                // First, update the entity with the current game state
                updateEntityFromGame(player);
                // Then, save the entity to the database
                playerRepository.save(player);
            } catch (e) {
                logError("[Service] Failed to save player data for PID " + pid + ": " + e);
            }
        }
    }

    /**
     * Handles player disconnects, saving their state and resetting the entity.
     * @param {integer} pid - The player's ID.
     */
    function onPlayerDisconnect(pid) {
        savePlayerState(pid);
        getPlayerEntity(pid).resetState();
    }
    
    /**
     * Retrieves the PlayerEntity for a given player ID.
     * @param {integer} pid - The player's ID.
     * @returns {PlayerEntity}
     */
    function getPlayerEntity(pid) {
        return this.playerEntities[pid];
    }

    // --- Helper methods to sync entity state with the game engine ---

    /**
     * Applies the state from a PlayerEntity to the actual player in the game.
     * @param {PlayerEntity} entity
     */
    function applyEntityToGame(entity) {
        local pid = entity.pid;
        setPlayerName(pid, entity.name);
        spawnPlayer(pid);
        
        // Apply stats, visual, position, etc.
        setPlayerStrength(pid, entity.strength);
        setPlayerDexterity(pid, entity.dexterity);
        // ... and so on for all attributes
        
        // Give items
        foreach(instance, amount in entity.items) {
            giveItem(pid, instance, amount);
        }
    }

    /**
     * Updates a PlayerEntity with the current state from the game world.
     * @param {PlayerEntity} entity
     */
    function updateEntityFromGame(entity) {
        local pid = entity.pid;
        
        entity.currentHealth = getPlayerHealth(pid);
        entity.currentMana = getPlayerMana(pid);
        // ... update position, stats, etc. from game functions
    }
}
