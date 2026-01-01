/**
 * @file CraftService.nut
 * @description Handles the business logic of crafting items.
 */
class CraftService {
    craftRepository = null;
    playerService = null;

    constructor(repo, pService) {
        this.craftRepository = repo;
        this.playerService = pService;
    }

    /**
     * Attempts to craft an item for a player.
     * @param {integer} pid - The player's ID.
     * @param {string} resultItemInstance - The instance of the item to craft.
     * @param {integer} amount - The number of times to craft.
     */
    function attemptCraft(pid, resultItemInstance, amount) {
        local recipe = craftRepository.findByResult(resultItemInstance);
        if (!recipe) {
            addNotification(pid, "Unknown recipe!");
            return;
        }

        local playerEntity = playerService.getPlayerEntity(pid);
        if (!playerEntity) return;

        // 1. Check profession level
        if ("professionType" in recipe && recipe.professionType != null) {
            if (playerEntity.professions[recipe.professionType] < recipe.requiredLevel) {
                addNotification(pid, "Required profession level not met.");
                return;
            }
        }
        
        // 2. Check ingredients
        foreach (ingredient in recipe.itemsToCraft) {
            if (!playerEntity.hasItem(ingredient.item, ingredient.quantity * amount)) {
                addNotification(pid, "You do not have enough ingredients.");
                return;
            }
        }

        // 3. All checks passed, perform the craft
        foreach (ingredient in recipe.itemsToCraft) {
            playerEntity.removeItem(ingredient.item, ingredient.quantity * amount);
            removeItem(pid, ingredient.item, ingredient.quantity * amount); // Sync with game
        }

        local amountToGive = recipe.resultQuantity * amount;
        playerEntity.addItem(recipe.resultItem, amountToGive);
        giveItem(pid, recipe.resultItem, amountToGive); // Sync with game

        addNotification(pid, "Crafted " + recipe.name + " (x" + amountToGive + ")!");
    }
}
