local focusDraw = Draw(0, 0, "RSHIFT - Interakcja");
local focusPlayer = -1;
Interface.InteractMenu <- {
    window = GUI.Window({
        positionPx = {x = 0.26 * Resolution.x, y = 0.75 * Resolution.y},
        sizePx = {width = 0.472 * Resolution.x, height = 0.12 * Resolution.y},
        file = "MENU_INGAME.TGA",
        color = {a = 255}
    }),
    "show" : function() {
        Interface.baseInterface(true, PLAYER_GUI.INTERACTPLAYERMENU);
        this.window.setVisible(true);
        setCursorVisible(true);
    },
    "hide" : function() {
        Interface.baseInterface(false);
        this.window.setVisible(false);
        setCursorVisible(false);
    }
};
Interface.InteractMenu.window.setColor({r = 255, g = 0, b = 0, a = 255});
Interface.InteractMenu.Topic <- GUI.Draw({
    relativePositionPx = {x = 0.0 * Resolution.x, y = 0.0 * Resolution.y},
    text = "Interakcja z ",
    collection = Interface.InteractMenu.window
});
Interface.InteractMenu.trade <- GUI.Button({
    relativePositionPx = {x = 0.02 * Resolution.x, y = 0.04 * Resolution.y},
    sizePx = {width = 0.10 * Resolution.x, height = 0.04 * Resolution.y},
    file = "MENU_INGAME.TGA",
    draw = {text = "Handluj"},
    collection = Interface.InteractMenu.window
});
Interface.InteractMenu.leave <- GUI.Button({
    relativePositionPx = {x = 0.35 * Resolution.x, y = 0.04 * Resolution.y},
    sizePx = {width = 0.10 * Resolution.x, height = 0.04 * Resolution.y},
    file = "MENU_INGAME.TGA",
    draw = {text = "Wróæ"},
    collection = Interface.InteractMenu.window
});
Interface.TradeRequestMenu <- {
    window = GUI.Window({
        positionPx = {x = 0.3 * Resolution.x, y = 0.4 * Resolution.y},
        sizePx = {width = 0.4 * Resolution.x, height = 0.2 * Resolution.y},
        file = "MENU_INGAME.TGA",
        color = {a = 255}
    }),
    "show" : function(traderName) {
        Interface.baseInterface(true, PLAYER_GUI.TRADEMENU);
        local topictradetext = "Proœba o handel"
        this.Topic.setText(topictradetext);
        this.Topic.setRelativePositionPx((0.4 * Resolution.x - textWidthPx(topictradetext)) / 2, this.Topic.getRelativePositionPx().y);
        local tradertext = traderName + " chce handlowaæ z Tob¹"
        this.Details.setText(tradertext);
        this.Details.setRelativePositionPx((0.4 * Resolution.x - textWidthPx(tradertext)) / 2, this.Details.getRelativePositionPx().y);
        this.window.setVisible(true);
        setCursorVisible(true);
    },
    "hide" : function() {
        Interface.baseInterface(false);
        this.window.setVisible(false);
        setCursorVisible(false);
    },
    traderId = -1
};
Interface.TradeRequestMenu.Topic <- GUI.Draw({
    relativePositionPx = {x = 0.0 * Resolution.x, y = 0.01 * Resolution.y},
    text = "Proœba o handel",
    collection = Interface.TradeRequestMenu.window
});
Interface.TradeRequestMenu.Details <- GUI.Draw({
    relativePositionPx = {x = 0.0 * Resolution.x, y = 0.06 * Resolution.y},
    text = "",
    collection = Interface.TradeRequestMenu.window
});
Interface.TradeRequestMenu.accept <- GUI.Button({
    relativePositionPx = {x = 0.05 * Resolution.x, y = 0.12 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.04 * Resolution.y},
    file = "MENU_INGAME.TGA",
    draw = {text = "Akceptuj"},
    collection = Interface.TradeRequestMenu.window
});
Interface.TradeRequestMenu.reject <- GUI.Button({
    relativePositionPx = {x = 0.23 * Resolution.x, y = 0.12 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.04 * Resolution.y},
    file = "MENU_INGAME.TGA",
    draw = {text = "Odmów"},
    collection = Interface.TradeRequestMenu.window
});
Interface.InteractMenu.leave.bind(EventType.Click, function(element) {
    Interface.InteractMenu.hide();
    showPlayerDialog();
});
Interface.InteractMenu.trade.bind(EventType.Click, function(element) {
    sendTradeRequest();
});
Interface.TradeRequestMenu.accept.bind(EventType.Click, function(element) {
    local traderId = Interface.TradeRequestMenu.traderId;
    if (traderId != -1) {
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.Trade);
        packet.writeUInt8(3);
        packet.writeInt32(traderId);
        packet.writeBool(true);
        packet.writeInt32(heroId);
        packet.send(RELIABLE);
    }
    Interface.TradeRequestMenu.hide();
    Interface.TradeRequestMenu.traderId = -1;
});
Interface.TradeRequestMenu.reject.bind(EventType.Click, function(element) {
    local traderId = Interface.TradeRequestMenu.traderId;
    if (traderId != -1) {
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.Trade);
        packet.writeUInt8(3);
        packet.writeInt32(traderId);
        packet.writeBool(false);
        packet.writeInt32(heroId);
        packet.send(RELIABLE);
    }
    Interface.TradeRequestMenu.hide();
    Interface.TradeRequestMenu.traderId = -1;
});


function sendTradeRequest() {
    if (focusPlayer == -1) return;
    local packet = Packet();
    packet.writeUInt8(PacketId.Player);
    packet.writeUInt8(PacketPlayer.Trade);
    packet.writeUInt8(1);
    packet.writeInt32(focusPlayer);
    packet.writeInt32(heroId);
    packet.send(RELIABLE);
    Interface.InteractMenu.hide();
}
addEventHandler("onPacket", function(packet) {
    local mainId = packet.readUInt8();
    if (mainId == PacketId.Player) {
        local subId = packet.readUInt8();
        if (subId == PacketPlayer.Trade) {
            local packetType = packet.readUInt8();
            switch (packetType) {
                case 1:
                    local targetId = packet.readInt32();
                    local traderId = packet.readInt32();
                    if (targetId == heroId) {
                        Interface.TradeRequestMenu.traderId = traderId;
                        Interface.TradeRequestMenu.show(getPlayerName(traderId));
                    }
                    break;
                case 2:
                    local targetId = packet.readInt32();
                    local accepted = packet.readBool();
                    local responderId = packet.readInt32();
                    break;
                case 9:
                    break;
            }
        }
    }
});
addEventHandler("onKeyDown", function(key) {
    if (key == KEY_RSHIFT && focusPlayer != -1 && isPlayerCreated(focusPlayer) && !isLocalNpc(focusPlayer) && getPlayerName(focusPlayer) != "null") {
        Interface.InteractMenu.show();
        hidePlayerDialog();
        local topictext = "Interakcja z " + getPlayerName(focusPlayer);
        Interface.InteractMenu.Topic.setText(topictext);
        Interface.InteractMenu.Topic.setRelativePositionPx((0.472 * Resolution.x - textWidthPx(topictext)) / 2, Interface.InteractMenu.Topic.getRelativePositionPx().y);
    }
});
function showPlayerDialog() {
    if (focusPlayer == -1 || !isPlayerCreated(focusPlayer) || isLocalNpc(focusPlayer) || getPlayerName(focusPlayer) == "null") return hidePlayerDialog();
    focusDraw.setPosition(4100 - focusDraw.width / 2, 7800);
    focusDraw.visible = true;
    focusDraw.top();
}
function hidePlayerDialog() {
    focusDraw.visible = false;
}
addEventHandler("onTakeFocus", function(type, id, name) {
    if (type != VOB_NPC) return;
    if (id >= getMaxSlots()) return;
    local heroWeaponMode = getPlayerWeaponMode(heroId);
    local targetWeaponMode = getPlayerWeaponMode(id);
    if (heroWeaponMode != WEAPONMODE_NONE || targetWeaponMode != WEAPONMODE_NONE)
        return;
    focusPlayer = id;
    showPlayerDialog();
});
addEventHandler("onLostFocus", function(type, id, name) {
    if (type != VOB_NPC) return;
    if (focusPlayer != -1 && id == focusPlayer) {
        focusPlayer = -1;
        hidePlayerDialog();
    }
});
addEventHandler("onPlayerChangeWeaponMode", function(playerid, oldWeaponMode, newWeaponMode) {
    if (playerid == heroId || playerid == focusPlayer) {
        if (newWeaponMode != WEAPONMODE_NONE) {
            hidePlayerDialog();
        }
        else if (focusPlayer != -1 && getPlayerWeaponMode(focusPlayer) == WEAPONMODE_NONE) {
            showPlayerDialog();
        }
    }
});
addEventHandler("onOpenInventory", function() {
    hidePlayerDialog();
    Interface.InteractMenu.hide();
    Interface.TradeRequestMenu.hide();
});
addEventHandler("onCloseInventory", function() {
    if (focusPlayer != -1)
        showPlayerDialog();
});

