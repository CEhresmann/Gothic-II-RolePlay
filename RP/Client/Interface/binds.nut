Interface.Binds <- {
    window = GUI.Window({
        positionPx = { x = 0.28 * Resolution.x, y = 0.30 * Resolution.y },
        sizePx = { width = 0.45 * Resolution.x, height = 0.50 * Resolution.y },
        file = "MENU_INGAME.TGA",
        color = { a = 180 }
    }),

    function show() {
        Interface.baseInterface(true, PLAYER_GUI.BINDS);
        window.setVisible(true);
    },

    function hide() {
        saveSettings();
        Interface.baseInterface(false);
        window.setVisible(false);
    }
};

Interface.Binds.window.setColor({r = 255, g = 0, b = 0});


Interface.Binds.Topic <- GUI.Button({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.02 * Resolution.y},
    sizePx = {width = 0.43 * Resolution.x, height = 0.03 * Resolution.y},
    file = "MENU_INGAME.TGA",
    label = {text = "Klawiszologia"},
    collection = Interface.Binds.window
})
Interface.Binds.Topic.setColor({r = 255, g = 0, b = 0});


Interface.Binds.InfoLabel <- GUI.Label({
    relativePositionPx = {x = 0.02 * Resolution.x, y = 0.07 * Resolution.y},
    sizePx = {width = 0.31 * Resolution.x, height = 0.40 * Resolution.y},
    text = "[#FFFFFF]F3[#AAAAAA] - Ukrywa/pokazuje całe GUI.\n\n[#FFFFFF]F10[#AAAAAA] - Pokazuje/ukrywa okno animacji.\n\n[#FFFFFF]T[#AAAAAA] - Otwiera/zamyka czat.\n\n[#FFFFFF]V[#AAAAAA] - Zmienia aktualną kategorię czatu.\n\n[#FFFFFF]B[#AAAAAA] - Otwiera okno statystyk postaci.\n\n[#FFFFFF]LCTRL/LPM[#AAAAAA] - Lootuje przedmioty z martwego moba.\n\n[#FFFFFF]LCTRL/LPM[#AAAAAA] - Otwiera okno craftingu voba.\n\n[#FFFFFF]LCTRL + SCROLL[#AAAAAA] - Przewija historię wiadomości na czacie.",
    font = "FONT_OLD_10_WHITE_HI.TGA",
    collection = Interface.Binds.window
})


addEventHandler("onKeyDown", function(key) {
    if (key != KEY_ESCAPE) return;
    if (Player.gui != PLAYER_GUI.BINDS) return;
    Interface.Binds.hide();
})
