local focusedNpcId = null;
local lastLootTime = 0;
local lastLootNpcId = null;
local currentLootNpcId = null;
local currentLootItems = [];
local itemRenders = [];
local getItems = Sound("INV_CLOSE.WAV");

Interface.LootMenu <- {
    window = GUI.Window({
        positionPx = {x = 0.26 * Resolution.x, y = 0.40 * Resolution.y},
        sizePx = {width = 0.472 * Resolution.x, height = 0.32 * Resolution.y},
        file = "MENU_INGAME.TGA",
        color = {a = 255}
    }),

    "show" : function(npcId, npcName, lootItems = null) {
        Interface.baseInterface(true, PLAYER_GUI.LOOTMENU);
        window.setVisible(true);
        currentLootNpcId = npcId;
        
        currentLootItems = lootItems;
        
        updateLootSlots();
    },

    "hide" : function() {
        Interface.baseInterface(false);
        window.setVisible(false);
        currentLootNpcId = null;
        currentLootItems = [];
        
        clearItemRenders();
    },

    "toggle" : function() {
        if(Player.gui == -1) {
            if (currentLootNpcId != null) {
                show(currentLootNpcId, "", currentLootItems);
            }
            return;
        }

        if(Player.gui == PLAYER_GUI.LOOTMENU)
            hide();
    }
};

Interface.LootMenu.window.setColor({r = 255, g = 0, b = 0, a = 255});

Interface.LootMenu.Topic <- GUI.Draw({
    relativePositionPx = {x = 0.16 * Resolution.x, y = 0.02 * Resolution.y},
    text = "Uzyskane Przedmioty:",
    collection = Interface.LootMenu.window
});

Interface.LootMenu.slots <- [];
for (local i = 0; i < 4; i++) {
    Interface.LootMenu.slots.push(GUI.Button({
        relativePositionPx = {x = (0.02 + i * 0.11) * Resolution.x, y = 0.05 * Resolution.y},
        sizePx = {width = 0.10 * Resolution.x, height = 0.16 * Resolution.y},
        file = "MENU_INGAME.TGA",
        draw = {text = ""},
        collection = Interface.LootMenu.window
    }));
}

Interface.LootMenu.get <- GUI.Button({
    relativePositionPx = {x = 0.27 * Resolution.x, y = 0.23 * Resolution.y},
    sizePx = {width = 0.15 * Resolution.x, height = 0.04 * Resolution.y},
    file = "INV_TITEL.TGA",
    draw = {text = "Zabierz wszystko"},
    collection = Interface.LootMenu.window
});

Interface.LootMenu.leave <- GUI.Button({
    relativePositionPx = {x = 0.05 * Resolution.x, y = 0.23 * Resolution.y},
    sizePx = {width = 0.15 * Resolution.x, height = 0.04 * Resolution.y},
    file = "INV_TITEL.TGA",
    draw = {text = "Zostaw"},
    collection = Interface.LootMenu.window
});

function clearItemRenders() {
    foreach (render in itemRenders) {
        render.visible = false;
    }
    itemRenders.clear();
}

function updateLootSlots() {
    clearItemRenders();
    
    for (local i = 0; i < 4; i++) {
        if (i < currentLootItems.len()) {
            local item = currentLootItems[i];
            
            local slotPos = Interface.LootMenu.slots[i].getPosition();
            local slotSize = Interface.LootMenu.slots[i].getSize();
            
            local itemRender = ItemRender(
                slotPos.x,
                slotPos.y,
                slotSize.width,
                slotSize.height,
                item.instance
            );
            
            itemRender.visible = true;
            itemRender.rotX = 30;
            itemRender.rotY = 45;
            itemRender.rotZ = 0;
            itemRender.lightingswell = true;

            itemRenders.append(itemRender);
            
            Interface.LootMenu.slots[i].setText("x" + item.quantity);
			Interface.LootMenu.slots[i].top()
        } else {
            Interface.LootMenu.slots[i].setText("");
        }
    }
}

addEventHandler("GUI.onClick", function(self) {
    if(Player.gui != PLAYER_GUI.LOOTMENU)
        return;

    switch (self) {
        case Interface.LootMenu.leave:
            Interface.LootMenu.hide();
            break;
            
        case Interface.LootMenu.get:
            if (currentLootNpcId != null) {
                local packet = Packet();
                packet.writeUInt8(PacketId.Other);
                packet.writeUInt8(PacketOther.TakeAllLoot);
                packet.writeInt32(currentLootNpcId);
                packet.send(RELIABLE);
                
				
				getItems.play()
                Interface.LootMenu.hide();
            }
            break;
    }
});

addEventHandler("onFocus", function(currentId, previousId) {
    focusedNpcId = currentId;
});

addEventHandler("onLostFocus", function(type, id, name) {
    focusedNpcId = null;
});

addEventHandler("onKeyDown", function(key) {
    if (key == KEY_LCONTROL || key == MOUSE_BUTTONLEFT) {
        if (focusedNpcId == null) return;
        
        local currentTime = getTickCount();
        if (currentTime - lastLootTime < 2000 && lastLootNpcId == focusedNpcId) return;
        
        if (isPlayerDead(focusedNpcId) == true) {
            if (chatInputIsOpen()) return;
            if (isConsoleOpen()) return;
            
            local packet = Packet();
            packet.writeUInt8(PacketId.Other);
            packet.writeUInt8(PacketOther.LootBody);
            packet.writeInt32(focusedNpcId);
            packet.send(RELIABLE);
            
            lastLootTime = currentTime;
            lastLootNpcId = focusedNpcId;
        }
    }
});


addEventHandler("onPacket", function(packet) {
    local mainId = packet.readUInt8();
    
    if (mainId == PacketId.Other) {
        local subId = packet.readUInt8();
        
        if (subId == PacketOther.LootData) {
            local npcId = packet.readInt32();
            local npcName = packet.readString();
            
            local itemCount = packet.readUInt8();
            local lootItems = [];
            
            for (local i = 0; i < itemCount; i++) {
                local itemInstance = packet.readString();
                local quantity = packet.readUInt16();
                
                lootItems.append({
                    instance = itemInstance,
                    quantity = quantity
                });
            }
            

            Interface.LootMenu.show(npcId, npcName, lootItems);
        }
        else if (subId == PacketOther.Notification) {
            local message = packet.readString();
        }
    }
});


