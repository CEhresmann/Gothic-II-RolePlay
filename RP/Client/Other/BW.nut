local timeToEndBw = CFG.RespawnTime;
local bwTimer = null;


Interface.BW <- {
    window = GUI.Window({
        positionPx = { x = 0.28 * Resolution.x, y = 0.30 * Resolution.y },
        sizePx = { width = 0.45 * Resolution.x, height = 0.20 * Resolution.y },
        file = "MENU_INGAME.TGA",
        color = { a = 180 }
    }),

    function show() {
        Interface.baseInterface(true, PLAYER_GUI.BW);
        window.setVisible(true);
        isBWActive = true;
        ShowChat(true);
		this.Topic.label.setText("Jesteœ nieprzytomny, obudzisz siê za:");
		Camera.movementEnabled = true;
    },

    function hide() {
        saveSettings();
        Interface.baseInterface(false);
        window.setVisible(false);
        isBWActive = false;
        
        if (bwTimer != null) {
            killTimer(bwTimer);
            bwTimer = null;
        }
    }
};

Interface.BW.window.setColor({r = 255, g = 0, b = 0});

Interface.BW.Topic <- GUI.Button({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.02 * Resolution.y},
    sizePx = {width = 0.43 * Resolution.x, height = 0.03 * Resolution.y},
    file = "MENU_INGAME.TGA",
    label = {text = "Jesteœ nieprzytomny, obudzisz siê za:"},
    collection = Interface.BW.window
})

Interface.BW.Topic.setColor({r = 255, g = 0, b = 0});

Interface.BW.TimerLabel <- GUI.Button({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.06 * Resolution.y},
    sizePx = {width = 0.43 * Resolution.x, height = 0.05 * Resolution.y},
    file = "MENU_INGAME.TGA",
    label = {text = "60 sekund"},
    collection = Interface.BW.window
})

Interface.BW.TimerLabel.setColor({r = 255, g = 255, b = 255});

Interface.BW.WakeUpButton <- GUI.Button({
    relativePositionPx = {x = 0.05 * Resolution.x, y = 0.12 * Resolution.y},
    sizePx = {width = 0.15 * Resolution.x, height = 0.04 * Resolution.y},
    file = "MENU_INGAME.TGA",
    label = {text = "WSTAÑ"},
    collection = Interface.BW.window,
})

Interface.BW.SleepButton <- GUI.Button({
    relativePositionPx = {x = 0.25 * Resolution.x, y = 0.12 * Resolution.y},
    sizePx = {width = 0.15 * Resolution.x, height = 0.04 * Resolution.y},
    file = "MENU_INGAME.TGA",
    label = {text = "ZAŒNIJ"},
    collection = Interface.BW.window,
})

Interface.BW.WakeUpButton.setColor({r = 0, g = 255, b = 0});
Interface.BW.SleepButton.setColor({r = 255, g = 165, b = 0});

function showChoiceButtons() {
    Interface.BW.WakeUpButton.setVisible(true);
    Interface.BW.SleepButton.setVisible(true);
    Interface.BW.TimerLabel.setVisible(false);
    Interface.BW.Topic.label.setText("Wybierz co chcesz zrobiæ:");
}

function hideChoiceButtons() {
    Interface.BW.WakeUpButton.setVisible(false);
    Interface.BW.SleepButton.setVisible(false);
    Interface.BW.TimerLabel.setVisible(true);
}

function bwCountdown() {
    if (!isBWActive) return;
    
    timeToEndBw--;
    updateBWTimerDisplay();
    
    if (timeToEndBw <= 0) {
        showChoiceButtons();
    }
}

function startBW(timeInSeconds) {
    timeToEndBw = timeInSeconds;
    Interface.BW.show();
    updateBWTimerDisplay();
    hideChoiceButtons();
    
    if (bwTimer != null) {
        killTimer(bwTimer);
        bwTimer = null;
    }
    
    bwTimer = setTimer(bwCountdown, 1000, timeInSeconds);
}

function updateBWTimerDisplay() {
    local minutes = timeToEndBw / 60;
    local seconds = timeToEndBw % 60;
    local displayText = format("%d:%02d", minutes, seconds);
    Interface.BW.TimerLabel.label.setText(displayText + " sekund");
}

function sendBWDecision(decision) {
    local packet = Packet();
    packet.writeUInt8(PacketId.Other);
    packet.writeUInt8(PacketOther.BW);
    packet.writeUInt8(4);
    packet.writeUInt8(decision);
    packet.send(RELIABLE_ORDERED);
}

function endBW() {
    if (bwTimer != null) {
        killTimer(bwTimer);
        bwTimer = null;
    }
    Interface.BW.hide();
}

addEventHandler("onPacket", function(packet) {
    local packetId = packet.readUInt8();
    
    if (packetId == PacketId.Other) {
        local subPacketId = packet.readUInt8();
        
        if (subPacketId == PacketOther.BW) {
            local notificationType = packet.readUInt8();
            
            if (notificationType == 1) {
                local bwTime = packet.readInt32();
                startBW(bwTime);
            }
            else if (notificationType == 2) {
                local newTime = packet.readInt32();
                timeToEndBw = newTime;
                updateBWTimerDisplay();
            }
            else if (notificationType == 3) {
                endBW();
            }
        }
    }
});

Interface.BW.WakeUpButton.bind(EventType.Click, function(element) {
    sendBWDecision(1);
});

Interface.BW.SleepButton.bind(EventType.Click, function(element) {
    sendBWDecision(2);
});

function forceEndBW() {
    endBW();
}

function updateBWTime(newTime) {
    timeToEndBw = newTime;
    updateBWTimerDisplay();
}

