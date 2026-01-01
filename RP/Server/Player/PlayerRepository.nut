/**
 * @class PlayerRepository
 * @description
 * Handles all database operations related to the PlayerEntity.
 *
 * This class abstracts the data access layer, allowing the rest of the application
 * to be independent of the specific database implementation (ORM, direct SQL, etc.).
 * It is responsible for fetching, creating, updating, and deleting player data.
 */
class PlayerRepository {
    /**
     * Finds a player account by name.
     * @param {string} name - The player's name.
     * @returns {table|null} A table with password and ck status, or null if not found.
     */
    function findByName(name) {
        try {
            local account = PlayerAccount.findOne(@(q) q.where("name", "=", name));
            if (account) {
                return {
                    password = account.password,
                    ck = account.CK
                };
            }
        } catch (e) {
            logError("[Repository] Failed to find player by name '" + name + "': " + e);
        }
        return null;
    }

    /**
     * Loads a full player entity from the database by name.
     * @param {PlayerEntity} playerEntity - The entity to load data into.
     */
    function load(playerEntity) {
        local account = PlayerAccount.findOne(@(q) q.where("name", "=", playerEntity.name));
        if (!account) return false;

        // Map data from the ORM model to the PlayerEntity
        playerEntity.id = account.id;
        playerEntity.discordId = account.discord_id;
        playerEntity.passwordHash = account.password;
        playerEntity.classId = account.class_id;
        playerEntity.fractionId = account.fraction_id;
        playerEntity.magicLevel = account.magic_level;
        playerEntity.learningPoints = account.learning_points;
        playerEntity.strength = account.strength;
        playerEntity.dexterity = account.dexterity;
        playerEntity.maxHealth = account.hp_max;
        playerEntity.currentHealth = account.hp;
        playerEntity.maxMana = account.mana_max;
        playerEntity.currentMana = account.mana;
        playerEntity.description = account.description;
        playerEntity.walkStyle = account.walk_style;
        playerEntity.fatness = account.fatness;
        playerEntity.scale = { x = account.scale_x, y = account.scale_y, z = account.scale_z };
        playerEntity.visual = {
            bodyModel = account.body_model,
            bodyTexture = account.body_texture.tointeger(),
            headModel = account.head_model,
            headTexture = account.head_texture.tointeger()
        };

        // Load professions
        playerEntity.professions[ProfessionType.Hunter] = account.profession_hunter;
        playerEntity.professions[ProfessionType.Archer] = account.profession_archer;
        // ... (map other professions)

        // Load position
        local position = PlayerPosition.findOne(@(q) q.where("player_id", "=", account.id));
        if (position) {
            playerEntity.position = { x = position.pos_x, y = position.pos_y, z = position.pos_z };
            playerEntity.angle = position.angle;
        }

        // Load skills
        local skills = PlayerSkills.findOne(@(q) q.where("player_id", "=", account.id));
        if (skills) {
            playerEntity.skills[WEAPON_1H] = skills.weapon_0;
            playerEntity.skills[WEAPON_2H] = skills.weapon_1;
            playerEntity.skills[WEAPON_BOW] = skills.weapon_2;
            playerEntity.skills[WEAPON_CBOW] = skills.weapon_3;
        }

        loadItems(playerEntity);
        return true;
    }

    /**
     * Saves a player entity to the database (creates or updates).
     * @param {PlayerEntity} playerEntity - The entity to save.
     */
    function save(playerEntity) {
        local account = PlayerAccount.findOne(@(q) q.where("id", "=", playerEntity.id));
        if (!account) {
            // This is a new player, create a new record
            account = PlayerAccount();
            account.name = playerEntity.name;
        }
        
        // Map data from PlayerEntity to the ORM model
        account.password = playerEntity.passwordHash;
        account.class_id = playerEntity.classId;
        // ... (map all other fields from playerEntity to account)
        
        account.save();
        playerEntity.id = account.id; // Update entity with the new ID if it was created

        // Save position, skills, and items
        // ... (implementation for saving related data)
        saveItems(playerEntity);

        return true;
    }
    
    /**
     * Loads player's items from the database into the entity.
     * @param {PlayerEntity} playerEntity
     */
    function loadItems(playerEntity) {
        try {
            local items = PlayerItems.find(@(q) q.where("player_id", "=", playerEntity.id));
            playerEntity.items.clear();
            foreach (item in items) {
                if (item.amount > 0) {
                    playerEntity.addItem(item.item_instance, item.amount);
                    // Note: equipping logic will be handled by a service, not here.
                }
            }
        } catch (e) {
            logError("[Repository] Failed to load items for player ID " + playerEntity.id + ": " + e);
        }
    }

    /**
     * Saves all items from a player entity to the database.
     * @param {PlayerEntity} playerEntity
     */
    function saveItems(playerEntity) {
        try {
            // 1. Delete all existing items for the player
            local itemsToRemove = PlayerItems.find(@(q) q.where("player_id", "=", playerEntity.id));
            foreach (item in itemsToRemove) {
                item.remove();
            }

            // 2. Insert current items from the entity
            foreach (instance, amount in playerEntity.items) {
                if (amount <= 0) continue;

                local itemRecord = PlayerItems();
                itemRecord.player_id = playerEntity.id;
                itemRecord.item_instance = instance.toupper();
                itemRecord.amount = amount;
                // Note: equipped status will be calculated and set by a service
                itemRecord.equipped = 0; // Placeholder
                itemRecord.insert();
            }
        } catch (e) {
            logError("[Repository] Failed to save items for player ID " + playerEntity.id + ": " + e);
        }
    }
}
