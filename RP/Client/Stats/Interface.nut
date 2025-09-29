disableLogicalKey(GAME_SCREEN_STATUS, true);

Interface.StatsMenu <- {
    window = GUI.Window({
        positionPx = {x = 0.12 * Resolution.x, y = 0.18 * Resolution.y},
        sizePx = {width = 0.75 * Resolution.x, height = 0.60 * Resolution.y},
        file = "LETTERS.TGA",
        color = {a = 255}
    }),

    currentCategory = "skills", // Domyœlna kategoria
    selectedSkill = null, // Aktualnie wybrany skill do ulepszenia

    "show" : function() {
        local topicplayername = getPlayerName(heroId);
        this.Topic.setText(topicplayername);
        this.Topic.setRelativePositionPx((0.75 * Resolution.x - textWidthPx(topicplayername)) / 2, this.Topic.getRelativePositionPx().y);
        
        // Aktualizuj wyœwietlane informacje
        this.updateDisplay();
        
        Interface.baseInterface(true, PLAYER_GUI.STATSMENU);
        window.setVisible(true);
        
        // Ukryj okno ulepszania przy otwarciu
        this.Upgrade.setVisible(false);
    },

    "hide" : function() {
        Interface.baseInterface(false);
        window.setVisible(false);
    },

    "toggle" : function() {
        if(Player.gui == -1) {
            show();
            return;
        }

        if(Player.gui == PLAYER_GUI.STATSMENU)
            hide();
    },
    
    "updateDisplay" : function() {
        // Ukryj wszystkie kategorie
        this.CatSkills.setVisible(false);
        // Tutaj dodaj inne kategorie gdy je stworzysz
        
        // Poka¿ odpowiedni¹ kategoriê
        if (this.currentCategory == "skills") {
            this.CatSkills.setVisible(true);
            this.updateSkillsDisplay();
        }
        // Tutaj dodaj inne warunki dla innych kategorii
    },
    
    "updateSkillsDisplay" : function() {
        // Aktualizuj wartoœci statystyk
        this.HP.setText("Zdrowie: "+getPlayerHealth(heroId)+"/"+getPlayerMaxHealth(heroId));
        this.Mana.setText("Mana: "+getPlayerMana(heroId)+"/"+getPlayerMaxMana(heroId));
        this.Str.setText("Si³a: "+getPlayerStrength(heroId));
        this.Dex.setText("Zrêcznoœæ: "+getPlayerDexterity(heroId));
        this.oneH.setText("1H: "+getPlayerSkillWeapon(heroId, WEAPON_1H)+"%");
        this.twoH.setText("2H: "+getPlayerSkillWeapon(heroId, WEAPON_2H)+"%");
        this.bow.setText("£uk: "+getPlayerSkillWeapon(heroId, WEAPON_BOW)+"%");
        this.cbow.setText("Kusza: "+getPlayerSkillWeapon(heroId, WEAPON_CBOW)+"%");
        this.mage.setText("Kr¹g: "+getPlayerTalent(heroId, TALENT_MAGE));
        
        // Aktualizuj punkty nauki
        this.PN.setText("Punkty Nauki: "/* + getPlayerLearningPoints(heroId)*/); // Zak³adam, ¿e taka funkcja istnieje
    },
    
    "showUpgradeWindow" : function(skillName, cost) {
        this.selectedSkill = skillName;
        this.UpgradeText.setText("Ulepszyæ " + skillName + "?\nKoszt: " + cost + "PN");
        this.Upgrade.setVisible(true);
    },
    
    "hideUpgradeWindow" : function() {
        this.Upgrade.setVisible(false);
        this.selectedSkill = null;
    },
    
    "upgradeSkill" : function() {
        if (this.selectedSkill == null) return;
        
        // Tutaj dodaj logikê ulepszania skilla
        // SprawdŸ czy gracz ma wystarczaj¹co punktów nauki
        // Jeœli tak, to ulepsz skill i odejmij punkty
        
        // Przyk³adowa implementacja:
        local currentPoints = /*getPlayerLearningPoints(heroId);*/3;
        local cost = 1; // Koszt ulepszenia
        
        if (currentPoints >= cost) {
            // Ulepsz skill - tutaj potrzebujesz funkcji do ulepszania konkretnych statystyk
            // Np. upgradePlayerSkill(heroId, this.selectedSkill);
            
            // Odejmij punkty nauki
            //setPlayerLearningPoints(heroId, currentPoints - cost);
			print("upgrade");
            
            // Aktualizuj wyœwietlane wartoœci
            this.updateSkillsDisplay();
            
            // Ukryj okno ulepszania
            this.hideUpgradeWindow();
        } else {
            // Komunikat o braku punktów
            print("Nie masz wystarczaj¹co punktów nauki!");
        }
    }
};

//Interface.StatsMenu.window.setColor({r = 0, g = 0, b = 0, a = 255});

Interface.StatsMenu.Topic <- GUI.Draw({
    relativePositionPx = {x = 0.0 * Resolution.x, y = 0.03 * Resolution.y},
    text = "Nickname",
    collection = Interface.StatsMenu.window
});

Interface.StatsMenu.leave <- GUI.Button({
    relativePositionPx = {x = 0.6 * Resolution.x, y = 0.5 * Resolution.y},
    sizePx = {width = 0.10 * Resolution.x, height = 0.04 * Resolution.y},
    file = "INV_TITEL.TGA",
    draw = {text = "WyjdŸ"},
    collection = Interface.StatsMenu.window
});

Interface.StatsMenu.PN <- GUI.Draw({
    relativePositionPx = {x = 0.22 * Resolution.x, y = 0.49 * Resolution.y},
    text = "Punkty Nauki: 0",
    collection = Interface.StatsMenu.window
});
Interface.StatsMenu.PN.setScale(1.3, 1.3);

/* ********** CATEGORIES ********** */

Interface.StatsMenu.Cat <- GUI.Window({
        relativePositionPx = {x = 0.04 * Resolution.x, y = 0.045 * Resolution.y},
        sizePx = {width = 0.14 * Resolution.x, height = 0.5 * Resolution.y},
        file = "MENU_INGAME.TGA",
        color = {a = 255},
        collection = Interface.StatsMenu.window
    });

Interface.StatsMenu.skills <- GUI.Button({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.04 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.04 * Resolution.y},
    file = "INV_SLOT_FOCUS.TGA",
    draw = {text = "Umiejêtnoœci"},
    collection = Interface.StatsMenu.Cat
});

Interface.StatsMenu.proffesion <- GUI.Button({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.09 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.04 * Resolution.y},
    file = "INV_SLOT_FOCUS.TGA",
    draw = {text = "Profesje"},
    collection = Interface.StatsMenu.Cat
});

/* ********** SKILLS ********** */

Interface.StatsMenu.CatSkills <- GUI.Window({
        relativePositionPx = {x = 0.2 * Resolution.x, y = 0.06 * Resolution.y},
        sizePx = {width = 0.5 * Resolution.x, height = 0.4 * Resolution.y},
        file = "LETTERS.TGA",
        color = {a = 255},
        collection = Interface.StatsMenu.window
    });
Interface.StatsMenu.CatSkills.setColor({r = 0, g = 0, b = 0, a = 255});

Interface.StatsMenu.HP <- GUI.Button({
    relativePositionPx = {x = 0.35 * Resolution.x, y = 0.03 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y},
    draw = {text = "Zdrowie: "+getPlayerHealth(heroId)+"/"+getPlayerMaxHealth(heroId)},
    align = Align.Left,
    collection = Interface.StatsMenu.CatSkills
});

Interface.StatsMenu.Mana <- GUI.Button({
    relativePositionPx = {x = 0.35 * Resolution.x, y = 0.06 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y},
    draw = {text = "Mana: "+getPlayerMana(heroId)+"/"+getPlayerMaxMana(heroId)},
    align = Align.Left,
    collection = Interface.StatsMenu.CatSkills
});

Interface.StatsMenu.Str <- GUI.Button({
    relativePositionPx = {x = 0.04 * Resolution.x, y = 0.03 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y},
    draw = {text = "Si³a: "+getPlayerStrength(heroId)},
    align = Align.Left,
    collection = Interface.StatsMenu.CatSkills
});

Interface.StatsMenu.Dex <- GUI.Button({
    relativePositionPx = {x = 0.04 * Resolution.x, y = 0.06 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y},
    draw = {text = "Zrêcznoœæ: "+getPlayerDexterity(heroId)},
    align = Align.Left,
    collection = Interface.StatsMenu.CatSkills
});

Interface.StatsMenu.oneH <- GUI.Button({
    relativePositionPx = {x = 0.04 * Resolution.x, y = 0.14 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y},
    draw = {text = "1H: "+getPlayerSkillWeapon(heroId, WEAPON_1H)+"%"},
    align = Align.Left,
    collection = Interface.StatsMenu.CatSkills
});

Interface.StatsMenu.twoH <- GUI.Button({
    relativePositionPx = {x = 0.04 * Resolution.x, y = 0.17 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y},
    draw = {text = "2H: "+getPlayerSkillWeapon(heroId, WEAPON_2H)+"%"},
    align = Align.Left,
    collection = Interface.StatsMenu.CatSkills
});

Interface.StatsMenu.bow <- GUI.Button({
    relativePositionPx = {x = 0.04 * Resolution.x, y = 0.20 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y},
    draw = {text = "£uk: "+getPlayerSkillWeapon(heroId, WEAPON_BOW)+"%"},
    align = Align.Left,
    collection = Interface.StatsMenu.CatSkills
});

Interface.StatsMenu.cbow <- GUI.Button({
    relativePositionPx = {x = 0.04 * Resolution.x, y = 0.23 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y},
    draw = {text = "Kusza: "+getPlayerSkillWeapon(heroId, WEAPON_CBOW)+"%"},
    align = Align.Left,
    collection = Interface.StatsMenu.CatSkills
});

Interface.StatsMenu.mage <- GUI.Button({
    relativePositionPx = {x = 0.35 * Resolution.x, y = 0.14 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y},
    draw = {text = "Kr¹g: "+getPlayerTalent(heroId, TALENT_MAGE)},
    align = Align.Left,
    collection = Interface.StatsMenu.CatSkills
});

/* ********** BINDS ********** */

/* ********** UPGRADE WINDOW ********** */
Interface.StatsMenu.Upgrade <- GUI.Window({
        relativePositionPx = {x = 0.35 * Resolution.x, y = 0.2 * Resolution.y},
        sizePx = {width = 0.2 * Resolution.x, height = 0.15 * Resolution.y},
        file = "LETTERS.TGA",
        color = {a = 230},
        collection = Interface.StatsMenu.window
    });
Interface.StatsMenu.Upgrade.top();
Interface.StatsMenu.Upgrade.setVisible(false); // Ukryte na start

Interface.StatsMenu.UpgradeText <- GUI.Draw({
    relativePositionPx = {x = 0.07 * Resolution.x, y = 0.01 * Resolution.y},
    text = "Ulepszyæ?\nKoszt: 1PN",
    collection = Interface.StatsMenu.Upgrade
});

Interface.StatsMenu.accept <- GUI.Button({
    relativePositionPx = {x = 0.05 * Resolution.x, y = 0.06 * Resolution.y},
    sizePx = {width = 0.10 * Resolution.x, height = 0.03 * Resolution.y},
    file = "MENU_INGAME.TGA",
    draw = {text = "Tak"},
    collection = Interface.StatsMenu.Upgrade
});

Interface.StatsMenu.cancel <- GUI.Button({
    relativePositionPx = {x = 0.05 * Resolution.x, y = 0.095 * Resolution.y},
    sizePx = {width = 0.10 * Resolution.x, height = 0.03 * Resolution.y},
    file = "MENU_INGAME.TGA",
    draw = {text = "Nie"},
    collection = Interface.StatsMenu.Upgrade
});
/* ********** UPGRADE WINDOW ********** */

// Bindy dla przycisków kategorii
Interface.StatsMenu.skills.bind(EventType.Click, function(element) {
    Interface.StatsMenu.currentCategory = "skills";
    Interface.StatsMenu.updateDisplay();
});

Interface.StatsMenu.proffesion.bind(EventType.Click, function(element) {
    Interface.StatsMenu.currentCategory = "proffesion";
    Interface.StatsMenu.updateDisplay();
    // Tutaj dodaj kod dla kategorii profesji gdy j¹ zaimplementujesz
});

// Bindy dla przycisków statystyk (ulepszanie)
Interface.StatsMenu.HP.bind(EventType.Click, function(element) {
    Interface.StatsMenu.showUpgradeWindow("Zdrowie", 1);
});

Interface.StatsMenu.Mana.bind(EventType.Click, function(element) {
    Interface.StatsMenu.showUpgradeWindow("Mana", 1);
});

Interface.StatsMenu.Str.bind(EventType.Click, function(element) {
    Interface.StatsMenu.showUpgradeWindow("Si³a", 1);
});

Interface.StatsMenu.Dex.bind(EventType.Click, function(element) {
    Interface.StatsMenu.showUpgradeWindow("Zrêcznoœæ", 1);
});

Interface.StatsMenu.oneH.bind(EventType.Click, function(element) {
    Interface.StatsMenu.showUpgradeWindow("Broñ jednorêczna", 1);
});

Interface.StatsMenu.twoH.bind(EventType.Click, function(element) {
    Interface.StatsMenu.showUpgradeWindow("Broñ dwurêczna", 1);
});

Interface.StatsMenu.bow.bind(EventType.Click, function(element) {
    Interface.StatsMenu.showUpgradeWindow("£uk", 1);
});

Interface.StatsMenu.cbow.bind(EventType.Click, function(element) {
    Interface.StatsMenu.showUpgradeWindow("Kusza", 1);
});

Interface.StatsMenu.mage.bind(EventType.Click, function(element) {
    Interface.StatsMenu.showUpgradeWindow("Magia", 1);
});

// Bindy dla okna ulepszania
Interface.StatsMenu.accept.bind(EventType.Click, function(element) {
    Interface.StatsMenu.upgradeSkill();
});

Interface.StatsMenu.cancel.bind(EventType.Click, function(element) {
    Interface.StatsMenu.hideUpgradeWindow();
});

Interface.StatsMenu.leave.bind(EventType.Click, function(element) {
    Interface.StatsMenu.hide();
});

addEventHandler("onKeyDown", function(key) {
    if (chatInputIsOpen())
        return

    if (isConsoleOpen())
        return

    if(key == KEY_B)
        Interface.StatsMenu.toggle();
});

setUnloadCallback(function() {
    Interface.StatsMenu.hide();
});

setReloadCallback(function() {
    Interface.StatsMenu.show();
});