Craft("ItFoMutton", {
    name = "Smażone mięso",
	mob = CraftingStation.Stove
	professionType = ProfessionType.Cook,
	requiredLevel = 1,
    itemsToCraft = [
        { item = "ItFoMuttonRaw", quantity = 1 }
    ]
});

Craft("ItFo_FishSoup", {
    name = "Zupa Rybna",
	mob = CraftingStation.Stove
	professionType = ProfessionType.Cook,
	requiredLevel = 2,
    itemsToCraft = [
        { item = "ItFo_Fish", quantity = 2 },
        { item = "ItFo_Water", quantity = 1 }
    ]
});
