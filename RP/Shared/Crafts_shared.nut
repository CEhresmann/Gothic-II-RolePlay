CraftingRecipes <- [];


function Craft(resultItem, details) {
    local recipe = {
        resultItem = resultItem,
        resultQuantity = 1,
        name = details.rawin("name") ? details.name : "Bez nazwy",
        itemsToCraft = details.rawin("itemsToCraft") ? details.itemsToCraft : [],
        mob = details.rawin("mob") ? details.mob : null,
        requiredLevel = details.rawin("requiredLevel") ? details.requiredLevel : 0,
        professionType = details.rawin("professionType") ? details.professionType : null
    };
    CraftingRecipes.push(recipe);
}

function getProfessionName(professionType) {
    switch(professionType) {
        case ProfessionType.Hunter: return "Myśliwy";
        case ProfessionType.Archer: return "Łuczarz";
        case ProfessionType.Blacksmith: return "Kowal";
        case ProfessionType.Armorer: return "Płatnerz";
        case ProfessionType.Alchemist: return "Alchemik";
        case ProfessionType.Cook: return "Kucharz";
        default: return "Nieznana profesja";
    }
}