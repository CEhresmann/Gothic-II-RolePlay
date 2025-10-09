function findRecipeByResult(resultItemInstance) {
    foreach(recipe in CraftingRecipes) {
        if (recipe.resultItem == resultItemInstance) {
            return recipe;
        }
    }
    return null;
}

function playerHasAllIngredients(playerid, recipe, amount) {
    foreach(ingredient in recipe.itemsToCraft) {
        local requiredAmount = ingredient.quantity * amount;
        if (hasPlayerItem(playerid, ingredient.item) < requiredAmount) {
            return false;
        }
    }
    return true;
}

function playerHasRequiredLevel(playerid, recipe) {
    if (recipe.requiredLevel <= 0 || recipe.professionType == null) {
        return true;
    }
    
    local playerLevel = getPlayerProfessionLevel(playerid, recipe.professionType);
    return playerLevel >= recipe.requiredLevel;
}

function onPacket(playerid, packet) {
    if (packet.readUInt8() != PacketId.Crafting) return;
    if (packet.readUInt8() != PacketCrafting.RequestCraft) return;

    local resultItemInstance = packet.readString();
    local amount = packet.readInt32();

    local recipe = findRecipeByResult(resultItemInstance);
    if (recipe == null) {
        addNotification(playerid, "Nieznany przepis!");
        return;
    }

    if (!playerHasRequiredLevel(playerid, recipe)) {
        local professionName = getProfessionName(recipe.professionType);
        addNotification(playerid, "Wymagany poziom " + professionName + ": " + recipe.requiredLevel);
        return;
    }

    if (playerHasAllIngredients(playerid, recipe, amount)) {
        foreach(ingredient in recipe.itemsToCraft) {
            local amountToRemove = ingredient.quantity * amount;
            removeItem(playerid, ingredient.item, amountToRemove);
        }

        local amountToGive = recipe.resultQuantity * amount;
        giveItem(playerid, recipe.resultItem, amountToGive);
        
        addNotification(playerid, "Stworzono przedmiot "+recipe.name+" w iloœci: (x"+amountToGive+")!");
    } else {
        addNotification(playerid, "Nie masz wystarczaj¹cych sk³adników!");
    }
}

addEventHandler("onPacket", onPacket);