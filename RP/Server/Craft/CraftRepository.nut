/**
 * @file CraftRepository.nut
 * @description Defines and provides access to all crafting recipes.
 */
class CraftRepository {
    recipes = null;

    constructor() {
        this.recipes = {};
        
        // --- Load all recipes here ---
        // Example:
        // local swordRecipe = {
        //     name = "Simple Sword",
        //     resultItem = "ITMW_1H_SWORD_01",
        //     resultQuantity = 1,
        //     professionType = ProfessionType.Blacksmith,
        //     requiredLevel = 1,
        //     itemsToCraft = [
        //         { item = "ITMI_IRON_ORE", quantity = 5 },
        //         { item = "ITMI_WOOD", quantity = 1 }
        //     ]
        // };
        // addRecipe(swordRecipe);
        
        // This should be populated from a config file or a database in a real scenario
        // For now, we'll keep the logic from Shared/Crafts_shared.nut
        foreach(recipe in CraftingRecipes) {
            addRecipe(recipe);
        }
    }

    function addRecipe(recipe) {
        if ("resultItem" in recipe) {
            recipes[recipe.resultItem.toupper()] <- recipe;
        }
    }

    function findByResult(resultItemInstance) {
        return recipes.rawin(resultItemInstance.toupper()) ? recipes[resultItemInstance.toupper()] : null;
    }
}
