local MobVisualToStation = {
	["STOVE_NW_CITY_01.ASC"] = CraftingStation.Stove,
	["BSANVIL_OC.MDS"] = CraftingStation.Anvil,
	["LAB_PSI.ASC"] = CraftingStation.AlchemyBench
}

CraftingStationNames <- {
    [CraftingStation.Stove] = "Kuchenka",
    [CraftingStation.Anvil] = "Kowadło",
    [CraftingStation.AlchemyBench] = "Stół alchemiczny"
}


Interface.CraftMenu <- {
    window = GUI.Window({
        positionPx = {x = 0.05 * Resolution.x, y = 0.05 * Resolution.y},
        sizePx = {width = 0.9 * Resolution.x, height = 0.90 * Resolution.y},
        file = "MENU_INGAME.TGA",
        color = {a = 255}
    }),

    CurrentRecipe = null,
    CurrentStationRecipes = [],

    "show" : function(stationType) {
        Interface.baseInterface(true, PLAYER_GUI.CRAFTMENU);
        window.setVisible(true);
		local topicCraft = CraftingStationNames[stationType] || "Stanowisko Rzemieślnicze";
        this.Topic.setText(topicCraft);
        this.Topic.setRelativePositionPx((0.9 * Resolution.x - textWidthPx(topicCraft)) / 2, this.Topic.getRelativePositionPx().y);
        populateCraftingList(stationType);
    },

    "hide" : function() {
        Interface.baseInterface(false);
        window.setVisible(false);
    }
};

Interface.CraftMenu.window.setColor({r = 255, g = 0, b = 0, a = 255});

Interface.CraftMenu.Topic <- GUI.Label({
    relativePositionPx = {x = 0.16 * Resolution.x, y = 0.02 * Resolution.y},
    text = "",
    collection = Interface.CraftMenu.window
});

Interface.CraftMenu.leave <- GUI.Button({
    relativePositionPx = {x = 0.75 * Resolution.x, y = 0.83 * Resolution.y},
    sizePx = {width = 0.10 * Resolution.x, height = 0.03 * Resolution.y},
    file = "INV_TITEL.TGA",
    label = {text = "Wyjdź"},
    collection = Interface.CraftMenu.window
});

Interface.CraftMenu.NumberInput <- GUI.NumberInput({
	relativePositionPx = {x = 0.04 * Resolution.x, y = 0.81 * Resolution.y},
	sizePx = {width = 0.2 * Resolution.x, height = 0.04 * Resolution.y},
	font = "FONT_OLD_20_WHITE_HI.TGA",
	file = "BLACK.TGA",
	color = {a = 150},
	align = Align.Center,
	placeholder = "Ilość",
	paddingPx = 2,
	collection = Interface.CraftMenu.window
})

Interface.CraftMenu.itemsToCraft <- GUI.List({
	relativePositionPx = {x = 0.3 * Resolution.x, y = 0.1 * Resolution.y},
	sizePx = {width = 0.2 * Resolution.x, height = 0.7 * Resolution.y},
	marginPx = [20],
	rowHeightPx = 50,
	file = "MENU_INGAME.TGA",
	scrollbar = {
		range = { file = "MENU_INGAME.TGA", indicator = {file = "BAR_MISC.TGA"} },
		increaseButton = {file = "O.TGA"},
		decreaseButton = {file = "U.TGA"}
	},
	collection = Interface.CraftMenu.window
});

Interface.CraftMenu.arrow <- GUI.Label({
    relativePositionPx = {x = 0.51 * Resolution.x, y = 0.425 * Resolution.y},
    text = "-->",
    collection = Interface.CraftMenu.window
});
Interface.CraftMenu.arrow.setScale(2, 2);

Interface.CraftMenu.itemsToGet <- GUI.List({
	relativePositionPx = {x = 0.55 * Resolution.x, y = 0.1 * Resolution.y},
	sizePx = {width = 0.2 * Resolution.x, height = 0.7 * Resolution.y},
	marginPx = [20],
	rowHeightPx = 50,
	file = "MENU_INGAME.TGA",
	scrollbar = {
		range = { file = "MENU_INGAME.TGA", indicator = {file = "BAR_MISC.TGA"} },
		increaseButton = {file = "O.TGA"},
		decreaseButton = {file = "U.TGA"}
	},
	collection = Interface.CraftMenu.window
});

function updateCreateButtonText() {
    if (!Interface.CraftMenu.CurrentRecipe) return;
    local amount = Interface.CraftMenu.NumberInput.getValue();
    if (amount <= 0) amount = 1;
    local recipeName = Interface.CraftMenu.CurrentRecipe.name;
    local buttonText = "Stwórz " + recipeName + " (x" + amount + ")";
    Interface.CraftMenu.create.setText(buttonText);
}

function updateDynamicLists() {
    local recipe = Interface.CraftMenu.CurrentRecipe;
    if (!recipe) return;
    local amount = Interface.CraftMenu.NumberInput.getValue();
    if (amount <= 0) amount = 1;
    Interface.CraftMenu.itemsToCraft.clear();
    Interface.CraftMenu.itemsToGet.clear();
    
    if (recipe.requiredLevel > 0 && recipe.professionType != null) {
        local professionName = getProfessionName(recipe.professionType);
        local levelInfo = professionName + ": " + recipe.requiredLevel;
        Interface.CraftMenu.itemsToCraft.addRow({ text = levelInfo, file = "MENU_INGAME.TGA" });
    }
    
    foreach(ingredient in recipe.itemsToCraft) {
        local item = Item(ingredient.item);
        local totalQuantity = ingredient.quantity * amount;
        local text = item.name + " (" + totalQuantity + "x)";
        Interface.CraftMenu.itemsToCraft.addRow({ text = text, file = "MENU_INGAME.TGA" });
    }
    local resultItem = Item(recipe.resultItem);
    local totalResultQuantity = recipe.resultQuantity * amount;
    local resultText = resultItem.name + " (" + totalResultQuantity + "x)";
    Interface.CraftMenu.itemsToGet.addRow({ text = resultText, file = "MENU_INGAME.TGA" });
    updateCreateButtonText();
}

function showRecipeDetails(recipe) {
    if (!recipe) return;
    Interface.CraftMenu.CurrentRecipe = recipe;
    Interface.CraftMenu.NumberInput.setText(1);
    updateDynamicLists();
}

class CraftingList extends GUI.List {
    constructor(arg) { base.constructor(arg); }
    function _createVisibleRow(id) {
        local row = base._createVisibleRow(id);
        row.bind(EventType.Click, function(clickedButton) {
            local recipeIndex = clickedButton.getDataRowId();
            if (recipeIndex >= 0 && recipeIndex < Interface.CraftMenu.CurrentStationRecipes.len()) {
                local selectedRecipe = Interface.CraftMenu.CurrentStationRecipes[recipeIndex];
                showRecipeDetails(selectedRecipe);
            }
        });
        return row;
    }
}

Interface.CraftMenu.Crafts_Window <- CraftingList({
	relativePositionPx = {x = 0.04 * Resolution.x, y = 0.05 * Resolution.y},
	sizePx = {width = 0.2 * Resolution.x, height = 0.75 * Resolution.y},
	marginPx = [20],
	rowHeightPx = 50,
	file = "BLACK.TGA",
	color = {a = 180},
	scrollbar = {
		range = { file = "MENU_INGAME.TGA", indicator = {file = "BAR_MISC.TGA"} },
		increaseButton = {file = "O.TGA"},
		decreaseButton = {file = "U.TGA"}
	},
	collection = Interface.CraftMenu.window
});

Interface.CraftMenu.create <- GUI.Button({
    relativePositionPx = {x = 0.35 * Resolution.x, y = 0.81 * Resolution.y},
    sizePx = {width = 0.35 * Resolution.x, height = 0.05 * Resolution.y},
    file = "INV_TITEL.TGA",
    label = {text = "Stwórz"},
    collection = Interface.CraftMenu.window
});

Interface.CraftMenu.create.bind(EventType.Click, function(element) {
    if (Interface.CraftMenu.CurrentRecipe) {
        local amount = Interface.CraftMenu.NumberInput.getValue();
        if (amount <= 0) amount = 1;
        

        local packet = Packet();
        packet.writeUInt8(PacketId.Crafting);
        packet.writeUInt8(PacketCrafting.RequestCraft);
        packet.writeString(Interface.CraftMenu.CurrentRecipe.resultItem);
        packet.writeInt32(amount);
        packet.send(RELIABLE_ORDERED);
    }
});

Interface.CraftMenu.NumberInput.bind(EventType.Change, function(element) {
    updateDynamicLists();
});

Interface.CraftMenu.leave.bind(EventType.Click, function(element) {
	Interface.CraftMenu.hide();
    useClosestMobQueued(heroId, "", -1);
});


function populateCraftingList(stationType) {
    Interface.CraftMenu.Crafts_Window.clear();
    Interface.CraftMenu.itemsToCraft.clear();
    Interface.CraftMenu.itemsToGet.clear();
    Interface.CraftMenu.CurrentStationRecipes.clear();
    
    foreach(recipe in CraftingRecipes) {
        if (recipe.mob == stationType) {
            Interface.CraftMenu.CurrentStationRecipes.push(recipe);
        }
    }
    
    foreach(recipe in Interface.CraftMenu.CurrentStationRecipes) {
        local recipeText = recipe.name;
        
        if (recipe.requiredLevel > 0 && recipe.professionType != null) {
            recipeText += " /T" + recipe.requiredLevel + "/";
        }
        
        Interface.CraftMenu.Crafts_Window.addRow({ text = recipeText, file = "Menu_Choice_Back.TGA" });
    }
    
    if (Interface.CraftMenu.CurrentStationRecipes.len() > 0) {
        showRecipeDetails(Interface.CraftMenu.CurrentStationRecipes[0]);
    } else {
        Interface.CraftMenu.CurrentRecipe = null;
        Interface.CraftMenu.create.setText("Stwórz");
    }
}


function onInteractionWithCraftingMob(playerid, address, type)
{
    if(playerid != heroId) return;
    local mob = MobInter(address);
    if (!mob) return;
    local mobVisual = mob.visual.toupper();
    if (mobVisual in MobVisualToStation) {
        local stationType = MobVisualToStation[mobVisual];
        Interface.CraftMenu.show(stationType);
    }
}

addEventHandler("onMobInterStartInteraction", onInteractionWithCraftingMob);


