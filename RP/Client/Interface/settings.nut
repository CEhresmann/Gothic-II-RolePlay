Interface.Settings <- {
    window = GUI.Window({
        positionPx = { x = 0.10 * Resolution.x, y = 0.30 * Resolution.y },
        sizePx = { width = 0.25 * Resolution.x, height = 0.50 * Resolution.y },
        file = "MENU_INGAME.TGA",
        color = { a = 180 }
    }),

    function show() {
        Interface.baseInterface(true, PLAYER_GUI.SETTINGS);
        window.setVisible(true);
    },

    function hide() {
        saveSettings();
        Interface.baseInterface(false);
        window.setVisible(false);
    }
};

Interface.Settings.window.setColor({r = 255, g = 0, b = 0});

local defaultMusicVolume = 80;
local defaultFOV = 100.0;

local ratios = [
    { name = "4:3", value = 0.75 },
    { name = "16:9", value = 0.5625 },
    { name = "16:10", value = 0.625 },
    { name = "21:9", value = 0.4286 },
    { name = "1:1", value = 1.0 }
];

local currentRatioIndex = 0;
local currentRatioName = ratios[0].name;
local currentRatioValue = ratios[0].value;

Interface.Settings.Topic <- GUI.Button({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.02 * Resolution.y},
    sizePx = {width = 0.23 * Resolution.x, height = 0.03 * Resolution.y},
    file = "MENU_INGAME.TGA",
    draw = {text = "Ustawienia"},
    collection = Interface.Settings.window
})
Interface.Settings.Topic.setColor({r = 255, g = 0, b = 0});

Interface.Settings.musicVolumeSlider <- GUI.Slider({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.12 * Resolution.y},
    sizePx = {width = 0.18 * Resolution.x, height = 0.03 * Resolution.y},
    file = "MENU_CHOICE_BACK.TGA",
    progress = { file = "BAR_MISC.TGA", color = {r = 255, g = 255, b = 255} },
    orientation = Orientation.Horizontal,
    minimum = 0.0,
    maximum = 100.0,
    value = Music.volume * 100,
    collection = Interface.Settings.window
})
Interface.Settings.musicVolumeSlider.setColor({r = 80, g = 80, b = 80});

Interface.Settings.musicVolumeReset <- GUI.Button({
    relativePositionPx = {x = 0.20 * Resolution.x, y = 0.12 * Resolution.y},
    sizePx = {width = 0.04 * Resolution.x, height = 0.03 * Resolution.y},
    file = "DLG_CONVERSATION.TGA",
    draw = {text = "R"},
    collection = Interface.Settings.window
})

Interface.Settings.musicVolumeLabel <- GUI.Draw({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.10 * Resolution.y},
    draw = {text = "G³oœnoœæ muzyki: " + (Music.volume * 100).tointeger() + "%"},
    collection = Interface.Settings.window
})

Interface.Settings.fovSlider <- GUI.Slider({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.20 * Resolution.y},
    sizePx = {width = 0.18 * Resolution.x, height = 0.03 * Resolution.y},
    file = "MENU_CHOICE_BACK.TGA",
    progress = { file = "BAR_MISC.TGA", color = {r = 255, g = 255, b = 255} },
    orientation = Orientation.Horizontal,
    minimum = 30.0,
    maximum = 150.0,
    value = 100.0,
    collection = Interface.Settings.window
})
Interface.Settings.fovSlider.setColor({r = 80, g = 80, b = 80});

Interface.Settings.fovReset <- GUI.Button({
    relativePositionPx = {x = 0.20 * Resolution.x, y = 0.20 * Resolution.y},
    sizePx = {width = 0.04 * Resolution.x, height = 0.03 * Resolution.y},
    file = "DLG_CONVERSATION.TGA",
    draw = {text = "R"},
    collection = Interface.Settings.window
})

Interface.Settings.fovLabel <- GUI.Draw({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.18 * Resolution.y},
    draw = {text = "FOV kamery: 75"},
    collection = Interface.Settings.window
})

Interface.Settings.ratioPrev <- GUI.Button({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.28 * Resolution.y},
    sizePx = {width = 0.04 * Resolution.x, height = 0.03 * Resolution.y},
    file = "DLG_CONVERSATION.TGA",
    draw = {text = "<"},
    collection = Interface.Settings.window
})

Interface.Settings.ratioNext <- GUI.Button({
    relativePositionPx = {x = 0.20 * Resolution.x, y = 0.28 * Resolution.y},
    sizePx = {width = 0.04 * Resolution.x, height = 0.03 * Resolution.y},
    file = "DLG_CONVERSATION.TGA",
    draw = {text = ">"},
    collection = Interface.Settings.window
})

Interface.Settings.ratioLabel <- GUI.Draw({
    relativePositionPx = {x = 0.095 * Resolution.x, y = 0.28 * Resolution.y},
    sizePx = {width = 0.13 * Resolution.x, height = 0.03 * Resolution.y},
    draw = {text = "Ratio: 4:3"},
    collection = Interface.Settings.window
})

function validateMusicVolume(value) {
    if (typeof value != "float" && typeof value != "integer") return defaultMusicVolume;
    if (value < 0.0 || value > 100.0) return defaultMusicVolume;
    return value.tofloat();
}

function validateFOV(value) {
    if (typeof value != "float" && typeof value != "integer") return defaultFOV;
    if (value < 30.0 || value > 150.0) return defaultFOV;
    return value.tofloat();
}

function validateRatioIndex(value) {
    if (typeof value != "integer") return 0;
    if (value < 0 || value >= ratios.len()) return 0;
    return value;
}

function calculateChecksum(musicVolume, fov, ratioIndex) {
    return ((musicVolume * 137 + fov * 211 + ratioIndex * 313) % 997).tointeger();
}

function saveSettings() {
    local musicVolume = Interface.Settings.musicVolumeSlider.getValue();
    local fov = Interface.Settings.fovSlider.getValue();
    local checksum = calculateChecksum(musicVolume, fov, currentRatioIndex);
    
    LocalStorage.setItem("musicVolume", musicVolume);
    LocalStorage.setItem("fov", fov);
    LocalStorage.setItem("ratioIndex", currentRatioIndex);
    LocalStorage.setItem("checksum", checksum);
}

function loadSettings() {
    local savedMusicVolume = LocalStorage.getItem("musicVolume");
    local savedFOV = LocalStorage.getItem("fov");
    local savedRatioIndex = LocalStorage.getItem("ratioIndex");
    local savedChecksum = LocalStorage.getItem("checksum");
    
    local validMusicVolume = validateMusicVolume(savedMusicVolume);
    local validFOV = validateFOV(savedFOV);
    local validRatioIndex = validateRatioIndex(savedRatioIndex);
    
    if (savedChecksum == null || savedChecksum != calculateChecksum(validMusicVolume, validFOV, validRatioIndex)) {
        validMusicVolume = defaultMusicVolume;
        validFOV = defaultFOV;
        validRatioIndex = 0;
    }
    
    Interface.Settings.musicVolumeSlider.setValue(validMusicVolume);
    Music.volume = validMusicVolume / 100.0;
    Interface.Settings.musicVolumeLabel.setText("G³oœnoœæ muzyki: " + validMusicVolume.tointeger() + "%");
    
    Interface.Settings.fovSlider.setValue(validFOV);
    applyFOV(validFOV);
    Interface.Settings.fovLabel.setText("FOV kamery: " + validFOV.tointeger());
    
    currentRatioIndex = validRatioIndex;
    local ratio = ratios[validRatioIndex];
    currentRatioName = ratio.name;
    currentRatioValue = ratio.value;
    Interface.Settings.ratioLabel.setText("Ratio: " + currentRatioName);
}

function onMusicVolumeChanged(self) {
    local value = Interface.Settings.musicVolumeSlider.getValue();
    Music.volume = value / 100.0;
    Interface.Settings.musicVolumeLabel.setText("G³oœnoœæ muzyki: " + value.tointeger() + "%");
    saveSettings();
}

function onFOVChanged(self) {
    local value = Interface.Settings.fovSlider.getValue();
    applyFOV(value);
    Interface.Settings.fovLabel.setText("FOV kamery: " + value.tointeger());
    saveSettings();
}

function applyFOV(fovValue) {
    Camera.setFOV(fovValue, fovValue * currentRatioValue);
}

function resetMusicVolume(self) {
    Interface.Settings.musicVolumeSlider.setValue(defaultMusicVolume);
    Music.volume = defaultMusicVolume / 100.0;
    Interface.Settings.musicVolumeLabel.setText("G³oœnoœæ muzyki: " + defaultMusicVolume.tointeger() + "%");
    saveSettings();
}

function resetFOV(self) {
    Interface.Settings.fovSlider.setValue(defaultFOV);
    applyFOV(defaultFOV);
    Interface.Settings.fovLabel.setText("FOV kamery: " + defaultFOV.tointeger());
    saveSettings();
}

function changeRatio(direction) {
    currentRatioIndex = (currentRatioIndex + direction) % ratios.len();
    if (currentRatioIndex < 0) currentRatioIndex = ratios.len() - 1;
    
    local ratio = ratios[currentRatioIndex];
    currentRatioName = ratio.name;
    currentRatioValue = ratio.value;
    Interface.Settings.ratioLabel.setText("Ratio: " + currentRatioName);
    
    local currentFOV = Interface.Settings.fovSlider.getValue();
    applyFOV(currentFOV);
    saveSettings();
}

function prevRatio(self) {
    changeRatio(-1);
}

function nextRatio(self) {
    changeRatio(1);
}

Interface.Settings.musicVolumeSlider.bind(EventType.Change, onMusicVolumeChanged);
Interface.Settings.fovSlider.bind(EventType.Change, onFOVChanged);
Interface.Settings.musicVolumeReset.bind(EventType.Click, resetMusicVolume);
Interface.Settings.fovReset.bind(EventType.Click, resetFOV);
Interface.Settings.ratioPrev.bind(EventType.Click, prevRatio);
Interface.Settings.ratioNext.bind(EventType.Click, nextRatio);

addEventHandler("onKeyDown", function(key) {
    if (key != KEY_ESCAPE) return;
    if (Player.gui != PLAYER_GUI.SETTINGS) return;
    Interface.Settings.hide();
})


addEventHandler("onPlayerLoggin", function(heroId) {
    loadSettings();
})