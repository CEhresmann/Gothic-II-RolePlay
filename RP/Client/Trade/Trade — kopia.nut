Interface.TradingMenu <- {
    window = GUI.Window({
        positionPx = {x = 0.01 * Resolution.x, y = 0.01 * Resolution.y},
        sizePx = {width = 0.98 * Resolution.x, height = 0.98 * Resolution.y},
        file = "MENU_INGAME.TGA",
        color = {a = 255}
    }),

    "show" : function() {
        Interface.baseInterface(true, PLAYER_GUI.TRADINGMENU);
        this.window.setVisible(true);
        setCursorVisible(true);
		
		local topictext = "Handel z "+getPlayerName(0);
        this.Topic.setText(topictext);
        this.Topic.setRelativePositionPx((0.98 * Resolution.x - textWidthPx(topictext)) / 3.5, this.Topic.getRelativePositionPx().y);
        
        this.myTradeItems.clear();
        this.reservedItems.clear();
        
        this.refreshPlayerItems();
        this.refreshTradeItems();
    },

	"hide" : function() {
		Interface.baseInterface(false);
		this.window.setVisible(false);
		setCursorVisible(false);
		
		if ("myItemsSlots" in this) {
			foreach (slot in this.myItemsSlots) {
				if (slot) slot.setVisible(false);
			}
		}
		if ("myItemRenders" in this) {
			foreach (render in this.myItemRenders) {
				if (render) render.visible = false;
			}
		}
		if ("myItemTexts" in this) {
			foreach (text in this.myItemTexts) {
				if (text) text.setVisible(false);
			}
		}
		
		this.hideTradeElements();
		this.hideItemTooltip();
		
		this.currentScrollPosition = 0;
		this.currentMyTradeScrollPosition = 0;
		this.currentHisTradeScrollPosition = 0;
	},
	
	"hideTradeElements" : function() {
		if ("myTradeItemsSlots" in this) {
			foreach (slot in this.myTradeItemsSlots) {
				if (slot) slot.setVisible(false);
			}
		}
		if ("myTradeItemRenders" in this) {
			foreach (render in this.myTradeItemRenders) {
				if (render) render.visible = false;
			}
		}
		if ("myTradeItemTexts" in this) {
			foreach (text in this.myTradeItemTexts) {
				if (text) text.setVisible(false);
			}
		}
		
		if ("hisTradeItemsSlots" in this) {
			foreach (slot in this.hisTradeItemsSlots) {
				if (slot) slot.setVisible(false);
			}
		}
		if ("hisTradeItemRenders" in this) {
			foreach (render in this.hisTradeItemRenders) {
				if (render) render.visible = false;
			}
		}
		if ("hisTradeItemTexts" in this) {
			foreach (text in this.hisTradeItemTexts) {
				if (text) text.setVisible(false);
			}
		}
	},
    
    "showItemTooltip" : function(itemName, itemInstance) {
        this.hideItemTooltip();
        
        local cursorPos = getCursorPositionPx();
        
        this.itemTooltipBackground <- GUI.Texture({
            positionPx = {x = cursorPos.x + 10, y = cursorPos.y + 10},
            sizePx = {width = 200, height = 40},
            file = "BLACK.TGA",
            color = {a = 255},
            collection = Interface.TradingMenu.window
        });
        
        this.itemTooltipText <- GUI.Draw({
            positionPx = {x = cursorPos.x + 20, y = cursorPos.y + 20},
            text = itemName,
            font = "FONT_OLD_10_WHITE_HI.TGA",
            align = Align.Left,
            collection = Interface.TradingMenu.window
        });
        
        this.itemTooltipBackground.setVisible(true);
        this.itemTooltipText.setVisible(true);
    },
    
    "hideItemTooltip" : function() {
        if ("itemTooltipBackground" in this && this.itemTooltipBackground) {
            this.itemTooltipBackground.setVisible(false);
        }
        if ("itemTooltipText" in this && this.itemTooltipText) {
            this.itemTooltipText.setVisible(false);
        }
    },
    
    "myTradeItems" : [],
    "hisTradeItems" : [],
    "reservedItems" : [],
    
    "getAvailableAmount" : function(itemInstance) {
        local playerItems = getEq();
        foreach (item in playerItems) {
            if (item.instance == itemInstance) {
                return item.amount;
            }
        }
        return 0;
    },
    
    "getReservedAmount" : function(itemInstance) {
        local reserved = 0;
        foreach (reservedItem in this.reservedItems) {
            if (reservedItem.instance == itemInstance) {
                reserved += reservedItem.amount;
            }
        }
        return reserved;
    },
    
    "addItemToTrade" : function(itemIndex, amount = 1) {
        local playerItems = getEq();
        if (itemIndex < 0 || itemIndex >= playerItems.len()) {
            return false;
        }
        
        local item = playerItems[itemIndex];
        
        local availableAmount = this.getAvailableAmount(item.instance);
        local reservedAmount = this.getReservedAmount(item.instance);
        local actuallyAvailable = availableAmount - reservedAmount;
        
        if (amount <= 0 || amount > actuallyAvailable) {
            return false;
        }
        
        local existingIndex = -1;
        foreach (i, tradeItem in this.myTradeItems) {
            if (tradeItem.instance == item.instance) {
                existingIndex = i;
                break;
            }
        }
        
        if (existingIndex >= 0) {
            this.myTradeItems[existingIndex].amount += amount;
        } else {
            local tradeItem = {
                name = item.name,
                instance = item.instance,
                amount = amount,
                originalIndex = itemIndex
            };
            this.myTradeItems.append(tradeItem);
        }
        
        this.reserveItem(item.instance, amount);
        
        this.refreshPlayerItems();
        this.refreshTradeItems();
        
        return true;
    },
    
    "reserveItem" : function(itemInstance, amount) {
        local existingIndex = -1;
        foreach (i, reservedItem in this.reservedItems) {
            if (reservedItem.instance == itemInstance) {
                existingIndex = i;
                break;
            }
        }
        
        if (existingIndex >= 0) {
            this.reservedItems[existingIndex].amount += amount;
        } else {
            local reservedItem = {
                instance = itemInstance,
                amount = amount
            };
            this.reservedItems.append(reservedItem);
        }
    },
    
    "unreserveItem" : function(itemInstance, amount) {
        foreach (i, reservedItem in this.reservedItems) {
            if (reservedItem.instance == itemInstance) {
                if (amount >= reservedItem.amount) {
                    this.reservedItems.remove(i);
                } else {
                    reservedItem.amount -= amount;
                }
                break;
            }
        }
    },
    
    "removeItemFromTrade" : function(tradeIndex, amount = null) {
        if (tradeIndex < 0 || tradeIndex >= this.myTradeItems.len()) {
            return false;
        }
        
        local tradeItem = this.myTradeItems[tradeIndex];
        
        if (amount == null || amount >= tradeItem.amount) {
            this.unreserveItem(tradeItem.instance, tradeItem.amount);
            this.myTradeItems.remove(tradeIndex);
        } else {
            tradeItem.amount -= amount;
            this.unreserveItem(tradeItem.instance, amount);
        }
        
        this.refreshPlayerItems();
        this.refreshTradeItems();
        
        return true;
    },
    
	"refreshPlayerItems" : function() {
		if (!("myItemsSlots" in this)) {
			this.myItemsSlots <- [];
		}
		if (!("myItemRenders" in this)) {
			this.myItemRenders <- [];
		}
		if (!("myItemTexts" in this)) {
			this.myItemTexts <- [];
		}
		if (!("currentScrollPosition" in this)) {
			this.currentScrollPosition <- 0;
		}
		
		foreach (slot in this.myItemsSlots) {
			if (slot) slot.setVisible(false);
		}
		foreach (render in this.myItemRenders) {
			if (render) render.visible = false;
		}
		foreach (text in this.myItemTexts) {
			if (text) text.setVisible(false);
		}
		
		this.myItemsSlots.clear();
		this.myItemRenders.clear();
		this.myItemTexts.clear();
		
		local playerItems = getEq();
		
		if (playerItems.len() == 0) {
			if (this.myItemsScrollbar) {
				this.myItemsScrollbar.setVisible(false);
			}
			return;
		}
		
		local myItemsPos = this.myItems.getPositionPx();
		local myItemsSize = this.myItems.getSizePx();
		
		local slotsPerRow = 5;
		local slotWidthPx = 0.05 * Resolution.x;
		local slotHeightPx = 0.08 * Resolution.y;
		local horizontalSpacingPx = 0.01 * Resolution.x;
		local verticalSpacingPx = 0.01 * Resolution.y;
		
		local baseXPx = myItemsPos.x + (0.03 * Resolution.x);
		local baseYPx = myItemsPos.y + (0.05 * Resolution.y);
		
		local availableHeightPx = myItemsSize.height - (0.05 * Resolution.y);
		local maxVisibleRows = floor(availableHeightPx / (slotHeightPx + verticalSpacingPx)).tointeger();
		local totalRows = ceil(playerItems.len() / slotsPerRow.tofloat()).tointeger();
		
		if (this.myItemsScrollbar && this.myItemsScrollbar.range) {
			if (totalRows > maxVisibleRows) {
				this.myItemsScrollbar.setVisible(true);
				this.myItemsScrollbar.range.setMinimum(0);
				this.myItemsScrollbar.range.setMaximum(totalRows - maxVisibleRows);
				this.myItemsScrollbar.range.setStep(1);
				this.myItemsScrollbar.range.setValue(this.currentScrollPosition);
				
				if (!("scrollbarBound" in this) || !this.scrollbarBound) {
					this.myItemsScrollbar.range.bind(EventType.Change, function(self) {
						Interface.TradingMenu.currentScrollPosition = self.getValue();
						Interface.TradingMenu.refreshPlayerItems();
					});
					this.scrollbarBound <- true;
				}
			} else {
				this.myItemsScrollbar.setVisible(false);
				this.currentScrollPosition = 0;
			}
		}
		
		for (local i = 0; i < playerItems.len(); i++) {
			local row = floor(i / slotsPerRow).tointeger();
			local col = i % slotsPerRow;
			
			if (row < this.currentScrollPosition || row >= this.currentScrollPosition + maxVisibleRows) {
				continue;
			}
			
			local visibleRow = row - this.currentScrollPosition;
			local slotXPx = baseXPx + col * (slotWidthPx + horizontalSpacingPx);
			local slotYPx = baseYPx + visibleRow * (slotHeightPx + verticalSpacingPx);
			
			if (slotYPx + slotHeightPx > myItemsPos.y + myItemsSize.height) {
				continue;
			}
			
			local item = playerItems[i];
			local reservedAmount = this.getReservedAmount(item.instance);
			local availableAmount = item.amount - reservedAmount;
			
			local slot = GUI.Button({
				positionPx = {x = slotXPx, y = slotYPx},
				sizePx = {width = slotWidthPx, height = slotHeightPx},
				file = "MENU_INGAME.TGA",
				draw = {text = ""},
				collection = Interface.TradingMenu.window
			});
			
			slot.setVisible(true);
			
			if (availableAmount <= 0) {
				slot.setColor({r = 100, g = 100, b = 100, a = 200});
			} else {
				slot.setColor({r = 255, g = 255, b = 255, a = 255});
			}
			
			if (availableAmount > 0) {
				slot.bind(EventType.Click, function(item, index, availAmount) {
					return function(element) {
						local amount = Interface.TradingMenu.input.getValue();
						if (amount <= 0) amount = 1;
						
						if (amount > availAmount) {
							amount = availAmount;
						}
						
						Interface.TradingMenu.addItemToTrade(index, amount);
					}
				}(item, i, availableAmount));
			} else {
				slot.setColor({r = 150, g = 150, b = 150, a = 200});
			}
			
			slot.bind(EventType.MouseDown, function(item, index) {
				return function(element, button) {
					if (button == MOUSE_BUTTONRIGHT) {
						Interface.TradingMenu.showItemTooltip(item.name, item.instance);
					}
				}
			}(item, i));
			
			local slotPos = slot.getPosition();
            local slotSize = slot.getSize();
			
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
			
			local textXPx = slotXPx + slotWidthPx / 2;
			local textYPx = slotYPx + slotHeightPx - 0.015 * Resolution.y;
			
			local amountText = GUI.Draw({
				positionPx = {x = textXPx, y = textYPx},
				text = "x" + item.amount + (reservedAmount > 0 ? " (-" + reservedAmount + ")" : ""),
				font = availableAmount > 0 ? "FONT_OLD_10_WHITE_HI.TGA" : "FONT_OLD_10_GREY_HI.TGA",
				align = Align.Center,
				collection = Interface.TradingMenu.window
			});
			amountText.setVisible(true);
			
			this.myItemsSlots.append(slot);
			this.myItemRenders.append(itemRender);
			this.myItemTexts.append(amountText);
		}
	},
    
    "refreshTradeItems" : function() {
        this.refreshMyTradeItems();
        this.refreshHisTradeItems();
    },
    
    "refreshMyTradeItems" : function() {
        if (!("myTradeItemsSlots" in this)) {
            this.myTradeItemsSlots <- [];
        }
        if (!("myTradeItemRenders" in this)) {
            this.myTradeItemRenders <- [];
        }
        if (!("myTradeItemTexts" in this)) {
            this.myTradeItemTexts <- [];
        }
        if (!("currentMyTradeScrollPosition" in this)) {
            this.currentMyTradeScrollPosition <- 0;
        }
        
        foreach (slot in this.myTradeItemsSlots) {
            if (slot) slot.setVisible(false);
        }
        foreach (render in this.myTradeItemRenders) {
            if (render) render.visible = false;
        }
        foreach (text in this.myTradeItemTexts) {
            if (text) text.setVisible(false);
        }
        
        this.myTradeItemsSlots.clear();
        this.myTradeItemRenders.clear();
        this.myTradeItemTexts.clear();
        
        if (this.myTradeItems.len() == 0) {
            if (this.mytradeItemsScrollbar) {
                this.mytradeItemsScrollbar.setVisible(false);
            }
            return;
        }
        
        local myTradePos = this.mytradeItems.getPositionPx();
        local myTradeSize = this.mytradeItems.getSizePx();
        
        local slotsPerRow = 3;
        local slotWidthPx = 0.07 * Resolution.x;
        local slotHeightPx = 0.09 * Resolution.y;
        local horizontalSpacingPx = 0.01 * Resolution.x;
        local verticalSpacingPx = 0.01 * Resolution.y;
        
        local baseXPx = myTradePos.x + (0.01 * Resolution.x);
        local baseYPx = myTradePos.y + (0.05 * Resolution.y);
        
        local availableHeightPx = myTradeSize.height - (0.05 * Resolution.y);
        local maxVisibleRows = floor(availableHeightPx / (slotHeightPx + verticalSpacingPx)).tointeger();
        local totalRows = ceil(this.myTradeItems.len() / slotsPerRow.tofloat()).tointeger();
        
        if (this.mytradeItemsScrollbar && this.mytradeItemsScrollbar.range) {
            if (totalRows > maxVisibleRows) {
                this.mytradeItemsScrollbar.setVisible(true);
                this.mytradeItemsScrollbar.range.setMinimum(0);
                this.mytradeItemsScrollbar.range.setMaximum(totalRows - maxVisibleRows);
                this.mytradeItemsScrollbar.range.setStep(1);
                this.mytradeItemsScrollbar.range.setValue(this.currentMyTradeScrollPosition);
                
                if (!("myTradeScrollbarBound" in this) || !this.myTradeScrollbarBound) {
                    this.mytradeItemsScrollbar.range.bind(EventType.Change, function(self) {
                        Interface.TradingMenu.currentMyTradeScrollPosition = self.getValue();
                        Interface.TradingMenu.refreshMyTradeItems();
                    });
                    this.myTradeScrollbarBound <- true;
                }
            } else {
                this.mytradeItemsScrollbar.setVisible(false);
                this.currentMyTradeScrollPosition = 0;
            }
        }
        
        for (local i = 0; i < this.myTradeItems.len(); i++) {
            local row = floor(i / slotsPerRow).tointeger();
            local col = i % slotsPerRow;
            
            if (row < this.currentMyTradeScrollPosition || row >= this.currentMyTradeScrollPosition + maxVisibleRows) {
                continue;
            }
            
            local visibleRow = row - this.currentMyTradeScrollPosition;
            local slotXPx = baseXPx + col * (slotWidthPx + horizontalSpacingPx);
            local slotYPx = baseYPx + visibleRow * (slotHeightPx + verticalSpacingPx);
            
            if (slotYPx + slotHeightPx > myTradePos.y + myTradeSize.height) {
                continue;
            }
            
            local slot = GUI.Button({
                positionPx = {x = slotXPx, y = slotYPx},
                sizePx = {width = slotWidthPx, height = slotHeightPx},
                file = "MENU_INGAME.TGA",
                draw = {text = ""},
                collection = Interface.TradingMenu.window
            });
            
            slot.setVisible(true);
            
            slot.bind(EventType.Click, function(tradeItem, index) {
                return function(element) {
                    Interface.TradingMenu.removeItemFromTrade(index);
                }
            }(this.myTradeItems[i], i));
            
            slot.bind(EventType.MouseDown, function(tradeItem, index) {
                return function(element, button) {
                    if (button == MOUSE_BUTTONRIGHT) {
                        Interface.TradingMenu.showItemTooltip(tradeItem.name, tradeItem.instance);
                    }
                }
            }(this.myTradeItems[i], i));
            
            local slotPos = slot.getPosition();
            local slotSize = slot.getSize();
            
            local itemRender = ItemRender(
                slotPos.x,
                slotPos.y,
                slotSize.width,
                slotSize.height,
                this.myTradeItems[i].instance
            );
            
            itemRender.visible = true;
            itemRender.rotX = 30;
            itemRender.rotY = 45;
            itemRender.rotZ = 0;
            itemRender.lightingswell = true;
            
            local textXPx = slotXPx + slotWidthPx / 2;
            local textYPx = slotYPx + slotHeightPx - 0.015 * Resolution.y;
            
            local amountText = GUI.Draw({
                positionPx = {x = textXPx, y = textYPx},
                text = "x" + this.myTradeItems[i].amount,
                font = "FONT_OLD_10_WHITE_HI.TGA",
                align = Align.Center,
                collection = Interface.TradingMenu.window
            });
            amountText.setVisible(true);
            
            this.myTradeItemsSlots.append(slot);
            this.myTradeItemRenders.append(itemRender);
            this.myTradeItemTexts.append(amountText);
        }
    },
    
    "refreshHisTradeItems" : function() {
        if (!("hisTradeItemsSlots" in this)) {
            this.hisTradeItemsSlots <- [];
        }
        if (!("hisTradeItemRenders" in this)) {
            this.hisTradeItemRenders <- [];
        }
        if (!("hisTradeItemTexts" in this)) {
            this.hisTradeItemTexts <- [];
        }
        
        foreach (slot in this.hisTradeItemsSlots) {
            if (slot) slot.setVisible(false);
        }
        foreach (render in this.hisTradeItemRenders) {
            if (render) render.visible = false;
        }
        foreach (text in this.hisTradeItemTexts) {
            if (text) text.setVisible(false);
        }
        
        this.hisTradeItemsSlots.clear();
        this.hisTradeItemRenders.clear();
        this.hisTradeItemTexts.clear();
    },
    
    myItemsSlots = null,
    myItemRenders = null,
    myItemTexts = null,
    myTradeItemsSlots = null,
    myTradeItemRenders = null,
    myTradeItemTexts = null,
    hisTradeItemsSlots = null,
    hisTradeItemRenders = null,
    hisTradeItemTexts = null,
    currentScrollPosition = 0,
    currentMyTradeScrollPosition = 0,
    currentHisTradeScrollPosition = 0,
    scrollbarBound = false,
    myTradeScrollbarBound = false,
    itemTooltipBackground = null,
    itemTooltipText = null
};

Interface.TradingMenu.myItemsSlots <- [];
Interface.TradingMenu.myItemRenders <- [];
Interface.TradingMenu.myItemTexts <- [];
Interface.TradingMenu.myTradeItemsSlots <- [];
Interface.TradingMenu.myTradeItemRenders <- [];
Interface.TradingMenu.myTradeItemTexts <- [];
Interface.TradingMenu.hisTradeItemsSlots <- [];
Interface.TradingMenu.hisTradeItemRenders <- [];
Interface.TradingMenu.hisTradeItemTexts <- [];
Interface.TradingMenu.reservedItems <- [];

Interface.TradingMenu.window.setColor({r = 255, g = 0, b = 0, a = 255});

Interface.TradingMenu.Topic <- GUI.Draw({
    relativePositionPx = {x = 0.0 * Resolution.x, y = 0.85 * Resolution.y},
    text = "Interakcja z ",
    collection = Interface.TradingMenu.window
});

Interface.TradingMenu.input <- GUI.NumberInput({
    relativePositionPx = {x = 0.10 * Resolution.x, y = 0.89 * Resolution.y},
    sizePx = {width = 0.15 * Resolution.x, height = 0.04 * Resolution.y},
    font = "FONT_OLD_20_WHITE_HI.TGA",
    file = "BLACK.TGA",
    color = {a = 200},
    align = Align.Center,
    placeholder = "Iloœæ",
    paddingPx = 2,
    collection = Interface.TradingMenu.window
});

Interface.TradingMenu.accept <- GUI.Button({
    relativePositionPx = {x = 0.26 * Resolution.x, y = 0.89 * Resolution.y},
    sizePx = {width = 0.10 * Resolution.x, height = 0.04 * Resolution.y},
    file = "MENU_INGAME.TGA",
	color = {a = 255},
    draw = {text = "Akceptuj"},
    collection = Interface.TradingMenu.window
});

Interface.TradingMenu.leave <- GUI.Button({
    relativePositionPx = {x = 0.36 * Resolution.x, y = 0.89 * Resolution.y},
    sizePx = {width = 0.10 * Resolution.x, height = 0.04 * Resolution.y},
    file = "MENU_INGAME.TGA",
	color = {a = 255},
    draw = {text = "Odmów"},
    collection = Interface.TradingMenu.window
});

Interface.TradingMenu.myItems <- GUI.Window({
    positionPx = {x = 0.6 * Resolution.x, y = 0.1 * Resolution.y},
    sizePx = {width = 0.35 * Resolution.x, height = 0.85 * Resolution.y},
    file = "MENU_INGAME.TGA",
    color = {a = 255},
    topBar = {
        offsetPx = {x = 10, y = 20},
        align = Align.Center,
        draw = { text = "Moje Przedmioty:" }
    },
    collection = Interface.TradingMenu.window
});

Interface.TradingMenu.myItemsScrollbar <- GUI.ScrollBar({
    relativePositionPx = {x = 0.33 * Resolution.x, y = 0.025 * Resolution.y},
    sizePx = {width = 0.01 * Resolution.x, height = 0.8 * Resolution.y},
    range = {
        file = "MENU_INGAME.TGA",
        indicator = {file = "BAR_MISC.TGA"},
        orientation = Orientation.Vertical
    },
    increaseButton = {file = "U.TGA"},
    decreaseButton = {file = "O.TGA"},
    collection = Interface.TradingMenu.myItems
});

if (Interface.TradingMenu.myItemsScrollbar && Interface.TradingMenu.myItemsScrollbar.range) {
    Interface.TradingMenu.myItemsScrollbar.range.setMinimum(0);
    Interface.TradingMenu.myItemsScrollbar.range.setMaximum(0);
    Interface.TradingMenu.myItemsScrollbar.range.setStep(1);
    Interface.TradingMenu.myItemsScrollbar.range.setValue(0);
}

Interface.TradingMenu.mytradeItems <- GUI.Window({
    positionPx = {x = 0.305 * Resolution.x, y = 0.05 * Resolution.y},
    sizePx = {width = 0.265 * Resolution.x, height = 0.80 * Resolution.y},
    file = "MENU_INGAME.TGA",
    color = {a = 255},
    topBar = {
        offsetPx = {x = 10, y = 20},
        align = Align.Center,
        draw = { text = "Ty" }
    },
    collection = Interface.TradingMenu.window
});

Interface.TradingMenu.mytradeItemsScrollbar <- GUI.ScrollBar({
    relativePositionPx = {x = 0.245 * Resolution.x, y = 0.025 * Resolution.y},
    sizePx = {width = 0.01 * Resolution.x, height = 0.75 * Resolution.y},
    range = {
        file = "MENU_INGAME.TGA",
        indicator = {file = "BAR_MISC.TGA"},
        orientation = Orientation.Vertical
    },
    increaseButton = {file = "U.TGA"},
    decreaseButton = {file = "O.TGA"},
    collection = Interface.TradingMenu.mytradeItems
});

if (Interface.TradingMenu.mytradeItemsScrollbar && Interface.TradingMenu.mytradeItemsScrollbar.range) {
    Interface.TradingMenu.mytradeItemsScrollbar.range.setMinimum(0);
    Interface.TradingMenu.mytradeItemsScrollbar.range.setMaximum(0);
    Interface.TradingMenu.mytradeItemsScrollbar.range.setStep(1);
    Interface.TradingMenu.mytradeItemsScrollbar.range.setValue(0);
}

Interface.TradingMenu.histradeItems <- GUI.Window({
    positionPx = {x = 0.047 * Resolution.x, y = 0.05 * Resolution.y},
    sizePx = {width = 0.265 * Resolution.x, height = 0.80 * Resolution.y},
    file = "MENU_INGAME.TGA",
    color = {a = 255},
    topBar = {
        offsetPx = {x = 10, y = 20},
        align = Align.Center,
        draw = { text = "Nickname" }
    },
    collection = Interface.TradingMenu.window
});

Interface.TradingMenu.histradeItemsScrollbar <- GUI.ScrollBar({
    relativePositionPx = {x = 0.009 * Resolution.x, y = 0.025 * Resolution.y},
    sizePx = {width = 0.01 * Resolution.x, height = 0.75 * Resolution.y},
    range = {
        file = "MENU_INGAME.TGA",
        indicator = {file = "BAR_MISC.TGA"},
        orientation = Orientation.Vertical
    },
    increaseButton = {file = "U.TGA"},
    decreaseButton = {file = "O.TGA"},
    collection = Interface.TradingMenu.histradeItems
});

if (Interface.TradingMenu.histradeItemsScrollbar && Interface.TradingMenu.histradeItemsScrollbar.range) {
    Interface.TradingMenu.histradeItemsScrollbar.range.setMinimum(0);
    Interface.TradingMenu.histradeItemsScrollbar.range.setMaximum(0);
    Interface.TradingMenu.histradeItemsScrollbar.range.setStep(1);
    Interface.TradingMenu.histradeItemsScrollbar.range.setValue(0);
}

Interface.TradingMenu.leave.bind(EventType.Click, function(element) {
    Interface.TradingMenu.hide();
});

Interface.TradingMenu.window.bind(EventType.Click, function(element) {
    Interface.TradingMenu.hideItemTooltip();
});

Interface.TradingMenu.window.bind(EventType.MouseDown, function(element, button) {
    if (button == MOUSE_BUTTONRIGHT) {
        Interface.TradingMenu.hideItemTooltip();
    }
});

setUnloadCallback(function() {
    Interface.TradingMenu.hide();
});

setReloadCallback(function() {
    Interface.TradingMenu.show();
});