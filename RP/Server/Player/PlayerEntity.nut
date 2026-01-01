/**
 * @class PlayerEntity
 * @description
 * Represents the core domain entity for a player.
 *
 * This class is a Plain Old Squirrel Object (POSO) that holds the player's state
 * and methods to manipulate that state. It is completely decoupled from the
 * database, network, and game engine specifics.
 */
class PlayerEntity {
    id = -1;
    pid = -1;
    name = "";
    passwordHash = "";
    discordId = null;

    isLoggedIn = false;
    
    strength = 10;
    dexterity = 10;
    maxHealth = 100;
    currentHealth = 100;
    maxMana = 30;
    currentMana = 30;
    magicLevel = 0;
    learningPoints = 10;

    position = { x = 0.0, y = 0.0, z = 0.0 };
    angle = 0.0;
    walkStyle = "HUMANS";
    fatness = 0.0;
    scale = { x = 1.0, y = 1.0, z = 1.0 };
    visual = {
        bodyModel = "",
        bodyTexture = 0,
        headModel = "",
        headTexture = 0
    };

    classId = 0;
    fractionId = 0;
    description = "";

    items = null;
    skills = null;
    professions = null;

    constructor(playerId) {
        this.pid = playerId;
        this.items = {};
        this.skills = array(WeaponType.COUNT, 10);
        this.professions = array(ProfessionType.COUNT, 0);

        if (CFG && CFG.DefaultPosition) {
            this.position = { 
                x = CFG.DefaultPosition.x, 
                y = CFG.DefaultPosition.y, 
                z = CFG.DefaultPosition.z 
            };
            this.angle = CFG.DefaultPosition.angle;
        }
        if (CFG && CFG.DefaultVisual) {
            this.visual = {
                bodyModel = CFG.DefaultVisual.Body,
                bodyTexture = CFG.DefaultVisual.Skin,
                headModel = CFG.DefaultVisual.Head,
                headTexture = CFG.DefaultVisual.Face
            };
        }
    }

    function resetState() {
        isLoggedIn = false;
        id = -1;
        name = "";
        passwordHash = "";
        discordId = null;
        description = "";
        
        strength = 10;
        dexterity = 10;
        maxHealth = 100;
        currentHealth = 100;
        maxMana = 30;
        currentMana = 30;
        magicLevel = 0;
        learningPoints = 10;

        items.clear();
        skills = array(WeaponType.COUNT, 10);
        professions = array(ProfessionType.COUNT, 0);
    }

    function setHealth(amount) {
        currentHealth = max(0, min(amount, maxHealth));
    }

    function setMana(amount) {
        currentMana = max(0, min(amount, maxMana));
    }

    function addItem(itemInstance, amount = 1) {
        local upperInstance = itemInstance.toupper();
        if (upperInstance in items) {
            items[upperInstance] += amount;
        } else {
            items[upperInstance] <- amount;
        }
    }

    function removeItem(itemInstance, amount = 1) {
        local upperInstance = itemInstance.toupper();
        if (upperInstance in items) {
            items[upperInstance] -= amount;
            if (items[upperInstance] <= 0) {
                items.rawdelete(upperInstance);
            }
        }
    }

    function hasItem(itemInstance, amount = 1) {
        local upperInstance = itemInstance.toupper();
        return (upperInstance in items && items[upperInstance] >= amount);
    }
}
