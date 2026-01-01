disableLogicalKey(GAME_SCREEN_STATUS, true);

Interface.StatsMenu <- {
    window = GUI.Window({
        positionPx = {x = 0.12 * Resolution.x, y = 0.18 * Resolution.y},
        sizePx = {width = 0.75 * Resolution.x, height = 0.60 * Resolution.y},
        file = "LETTERS.TGA",
        color = {a = 255}
    }),

    currentCategory = "skills",
    selectedSkill = null,
    selectedProfession = null,
    learningPoints = 0,
    
    playerStats = {
        health = 0, maxHealth = 0, mana = 0, maxMana = 0,
        strength = 0, dexterity = 0, oneHanded = 0, twoHanded = 0,
        bow = 0, crossbow = 0, magicCircle = 0
    },

    playerProfessions = array(ProfessionType.COUNT, 0),

	"show" : function() {
		local topicplayername = getPlayerName(heroId);
		this.Topic.setText(topicplayername);
		this.Topic.setRelativePositionPx((this.window.getSizePx().width - textWidthPx(topicplayername)) / 2, this.Topic.getRelativePositionPx().y);
		
		this.requestStatsUpdate();
		
		Interface.baseInterface(true, PLAYER_GUI.STATSMENU);
		this.window.setVisible(true);
		this.Upgrade.setVisible(false);
        this.updateDisplay();
	},

    "hide" : function() {
        Interface.baseInterface(false);
        this.window.setVisible(false);
    },

    "toggle" : function() {
        if(Player.gui == -1) {
            this.show();
            return;
        }

        if(Player.gui == PLAYER_GUI.STATSMENU)
            this.hide();
    },
    
    "updateDisplay" : function() {
        this.CatSkills.setVisible(this.currentCategory == "skills");
        this.CatProfessions.setVisible(this.currentCategory == "professions");
        
        if (Player.gui == PLAYER_GUI.STATSMENU) {
            if (this.currentCategory == "skills") {
                this.updateSkillsDisplay();
            } else if (this.currentCategory == "professions") {
                this.updateProfessionsDisplay();
            }
        }
    },
    
    "updateSkillsDisplay" : function() {
        this.HP.setText("Zdrowie: " + this.playerStats.health + "/" + this.playerStats.maxHealth);
        this.Mana.setText("Mana: " + this.playerStats.mana + "/" + this.playerStats.maxMana);
        this.Str.setText("Siła: " + this.playerStats.strength);
        this.Dex.setText("Zręczność: " + this.playerStats.dexterity);
        this.oneH.setText("1H: " + this.playerStats.oneHanded + "%");
        this.twoH.setText("2H: " + this.playerStats.twoHanded + "%");
        this.bow.setText("Łuk: " + this.playerStats.bow + "%");
        this.cbow.setText("Kusza: " + this.playerStats.crossbow + "%");
        this.mage.setText("Krąg: " + this.playerStats.magicCircle);
        this.PN.setText("Punkty Nauki: " + this.learningPoints);
    },
    
	"updateProfessionsDisplay" : function() {
		for (local i = 0; i < ProfessionType.COUNT; i++) {
			local professionName = "prof" + i;
			if (professionName in this) {
				local level = this.playerProfessions[i];
				local maxLevel = PROFESSION_CONFIG.MaxLevel;
				local displayText = PROFESSION_CONFIG.Names[i] + ": " + level + "/" + maxLevel;
				this[professionName].setText(displayText);
			}
		}
	},
    
    "requestStatsUpdate" : function() {
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.RequestStatsUpdate);
        packet.send(RELIABLE_ORDERED);
    },
    
    "setLearningPoints" : function(points) {
        this.learningPoints = points;
        this.PN.setText("Punkty Nauki: " + this.learningPoints);
    },
    
    "setPlayerStats" : function(stats) {
        this.playerStats = stats;
        this.updateSkillsDisplay();
    },
    
	"setPlayerProfessions" : function(professions) {
		this.playerProfessions = professions;
		if (this.currentCategory == "professions") {
			this.updateProfessionsDisplay();
		}
	},
    
    "requestUpgradeCost" : function(skillName, skillType) {
        this.selectedSkill = {name = skillName, type = skillType};
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.RequestSkillCost);
        packet.writeUInt8(skillType);
        packet.send(RELIABLE_ORDERED);
    },

    "requestProfessionUpgrade" : function(professionType) {
        this.selectedProfession = { type = professionType, name = PROFESSION_CONFIG.Names[professionType] };
        
        if (this.playerProfessions[professionType] >= PROFESSION_CONFIG.MaxLevel) {
            addNotification(heroId, "Osiągnąłeś maksymalny poziom tej profesji!");
            return;
        }

        local packet = Packet();
        packet.writeUInt8(PacketId.Player);
        packet.writeUInt8(PacketPlayer.RequestProfessionCost);
        packet.writeUInt8(professionType);
        packet.send(RELIABLE_ORDERED);
    },

    "showUpgradeWindow" : function(itemName, cost) {
        if (cost < 0) return;
        local nameText = "Ulepszyć " + itemName + "?";
        this.UpgradeText.setText(nameText);
        this.UpgradeText.setRelativePositionPx((this.Upgrade.getSizePx().width - textWidthPx(nameText)) / 2, this.UpgradeText.getRelativePositionPx().y);
        
        local costText = "Koszt: " + cost + "PN";
        this.UpgradeCostText.setText(costText);
        this.UpgradeCostText.setRelativePositionPx((this.Upgrade.getSizePx().width - textWidthPx(costText)) / 2, this.UpgradeCostText.getRelativePositionPx().y);
        
        this.Upgrade.setVisible(true);
    },
    
    "hideUpgradeWindow" : function() {
        this.Upgrade.setVisible(false);
        this.selectedSkill = null;
        this.selectedProfession = null;
    },
    
    "confirmUpgrade" : function() {
        local packet = Packet();
        packet.writeUInt8(PacketId.Player);

        if (this.selectedSkill != null) {
            packet.writeUInt8(PacketPlayer.UpgradeSkill);
            packet.writeUInt8(this.selectedSkill.type);
        } else if (this.selectedProfession != null) {
            packet.writeUInt8(PacketPlayer.UpgradeProfession);
            packet.writeUInt8(this.selectedProfession.type);
        }
        packet.send(RELIABLE_ORDERED);
        this.hideUpgradeWindow();
    }
};

Interface.StatsMenu.Topic <- GUI.Label({
    relativePositionPx = {x = 0, y = 0.03 * Resolution.y},
    text = "Nickname",
    collection = Interface.StatsMenu.window
});

Interface.StatsMenu.leave <- GUI.Button({
    relativePositionPx = {x = 0.6 * Resolution.x, y = 0.5 * Resolution.y},
    sizePx = {width = 0.10 * Resolution.x, height = 0.04 * Resolution.y},
    file = "INV_TITEL.TGA",
    label = {text = "Wyjdź"},
    collection = Interface.StatsMenu.window
});

Interface.StatsMenu.PN <- GUI.Label({
    relativePositionPx = {x = 0.22 * Resolution.x, y = 0.49 * Resolution.y},
    text = "Punkty Nauki: 0",
    collection = Interface.StatsMenu.window
});
Interface.StatsMenu.PN.setScale(1.3, 1.3);

Interface.StatsMenu.Cat <- GUI.Window({
    relativePositionPx = {x = 0.04 * Resolution.x, y = 0.08 * Resolution.y},
    sizePx = {width = 0.14 * Resolution.x, height = 0.46 * Resolution.y},
    file = "MENU_INGAME.TGA",
    color = {a = 255},
    collection = Interface.StatsMenu.window
});

Interface.StatsMenu.skills <- GUI.Button({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.04 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.04 * Resolution.y},
    file = "INV_SLOT_FOCUS.TGA",
    label = {text = "Umiejętności"},
    collection = Interface.StatsMenu.Cat
});

Interface.StatsMenu.proffesion <- GUI.Button({
    relativePositionPx = {x = 0.01 * Resolution.x, y = 0.09 * Resolution.y},
    sizePx = {width = 0.12 * Resolution.x, height = 0.04 * Resolution.y},
    file = "INV_SLOT_FOCUS.TGA",
    label = {text = "Profesje"},
    collection = Interface.StatsMenu.Cat
});

Interface.StatsMenu.CatSkills <- GUI.Window({
    relativePositionPx = {x = 0.2 * Resolution.x, y = 0.08 * Resolution.y},
    sizePx = {width = 0.5 * Resolution.x, height = 0.4 * Resolution.y},
    file = "LETTERS.TGA",
    color = {r = 0, g = 0, b = 0, a = 200},
    collection = Interface.StatsMenu.window
});

Interface.StatsMenu.HP <- GUI.Button({ relativePositionPx = {x = 0.35 * Resolution.x, y = 0.03 * Resolution.y}, sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y}, label = {text = ""}, align = Align.Left, collection = Interface.StatsMenu.CatSkills });
Interface.StatsMenu.Mana <- GUI.Button({ relativePositionPx = {x = 0.35 * Resolution.x, y = 0.06 * Resolution.y}, sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y}, label = {text = ""}, align = Align.Left, collection = Interface.StatsMenu.CatSkills });
Interface.StatsMenu.Str <- GUI.Button({ relativePositionPx = {x = 0.04 * Resolution.x, y = 0.03 * Resolution.y}, sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y}, label = {text = ""}, align = Align.Left, collection = Interface.StatsMenu.CatSkills });
Interface.StatsMenu.Dex <- GUI.Button({ relativePositionPx = {x = 0.04 * Resolution.x, y = 0.06 * Resolution.y}, sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y}, label = {text = ""}, align = Align.Left, collection = Interface.StatsMenu.CatSkills });
Interface.StatsMenu.oneH <- GUI.Button({ relativePositionPx = {x = 0.04 * Resolution.x, y = 0.14 * Resolution.y}, sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y}, label = {text = ""}, align = Align.Left, collection = Interface.StatsMenu.CatSkills });
Interface.StatsMenu.twoH <- GUI.Button({ relativePositionPx = {x = 0.04 * Resolution.x, y = 0.17 * Resolution.y}, sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y}, label = {text = ""}, align = Align.Left, collection = Interface.StatsMenu.CatSkills });
Interface.StatsMenu.bow <- GUI.Button({ relativePositionPx = {x = 0.04 * Resolution.x, y = 0.20 * Resolution.y}, sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y}, label = {text = ""}, align = Align.Left, collection = Interface.StatsMenu.CatSkills });
Interface.StatsMenu.cbow <- GUI.Button({ relativePositionPx = {x = 0.04 * Resolution.x, y = 0.23 * Resolution.y}, sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y}, label = {text = ""}, align = Align.Left, collection = Interface.StatsMenu.CatSkills });
Interface.StatsMenu.mage <- GUI.Button({ relativePositionPx = {x = 0.35 * Resolution.x, y = 0.14 * Resolution.y}, sizePx = {width = 0.12 * Resolution.x, height = 0.03 * Resolution.y}, label = {text = ""}, align = Align.Left, collection = Interface.StatsMenu.CatSkills });

Interface.StatsMenu.CatProfessions <- GUI.Window({
    relativePositionPx = {x = 0.2 * Resolution.x, y = 0.08 * Resolution.y},
    sizePx = {width = 0.5 * Resolution.x, height = 0.4 * Resolution.y},
    file = "LETTERS.TGA",
    color = {r = 0, g = 0, b = 0, a = 200},
    collection = Interface.StatsMenu.window,
});

local professionY = 0.03;
for (local i = 0; i < ProfessionType.COUNT; i++) {
    Interface.StatsMenu["prof" + i] <- GUI.Button({
        relativePositionPx = {x = 0.04 * Resolution.x, y = professionY * Resolution.y},
        sizePx = {width = 0.42 * Resolution.x, height = 0.04 * Resolution.y},
        label = {text = ""},
        align = Align.Left,
        collection = Interface.StatsMenu.CatProfessions
    });
    professionY += 0.05;
}

Interface.StatsMenu.Upgrade <- GUI.Window({
    relativePositionPx = {x = 0.275 * Resolution.x, y = 0.2 * Resolution.y},
    sizePx = {width = 0.2 * Resolution.x, height = 0.15 * Resolution.y},
    file = "LETTERS.TGA",
    color = {a = 230},
    collection = Interface.StatsMenu.window,
});
Interface.StatsMenu.Upgrade.top();

Interface.StatsMenu.UpgradeText <- GUI.Label({ relativePositionPx = {x = 0, y = 0.02 * Resolution.y}, text = "", collection = Interface.StatsMenu.Upgrade });
Interface.StatsMenu.UpgradeCostText <- GUI.Label({ relativePositionPx = {x = 0, y = 0.04 * Resolution.y}, text = "", collection = Interface.StatsMenu.Upgrade });
Interface.StatsMenu.accept <- GUI.Button({ relativePositionPx = {x = 0.05 * Resolution.x, y = 0.07 * Resolution.y}, sizePx = {width = 0.10 * Resolution.x, height = 0.03 * Resolution.y}, file = "MENU_INGAME.TGA", label = {text = "Tak"}, collection = Interface.StatsMenu.Upgrade });
Interface.StatsMenu.cancel <- GUI.Button({ relativePositionPx = {x = 0.05 * Resolution.x, y = 0.105 * Resolution.y}, sizePx = {width = 0.10 * Resolution.x, height = 0.03 * Resolution.y}, file = "MENU_INGAME.TGA", label = {text = "Nie"}, collection = Interface.StatsMenu.Upgrade });

Interface.StatsMenu.skills.bind(EventType.Click, function(element) { Interface.StatsMenu.currentCategory = "skills"; Interface.StatsMenu.updateDisplay(); });
Interface.StatsMenu.proffesion.bind(EventType.Click, function(element) { Interface.StatsMenu.currentCategory = "professions"; Interface.StatsMenu.updateDisplay(); });
Interface.StatsMenu.HP.bind(EventType.Click, function(element) { Interface.StatsMenu.requestUpgradeCost("Zdrowie", SkillType.Health); });
Interface.StatsMenu.Mana.bind(EventType.Click, function(element) { Interface.StatsMenu.requestUpgradeCost("Mana", SkillType.Mana); });
Interface.StatsMenu.Str.bind(EventType.Click, function(element) { Interface.StatsMenu.requestUpgradeCost("Siła", SkillType.Strength); });
Interface.StatsMenu.Dex.bind(EventType.Click, function(element) { Interface.StatsMenu.requestUpgradeCost("Zręczność", SkillType.Dexterity); });
Interface.StatsMenu.oneH.bind(EventType.Click, function(element) { Interface.StatsMenu.requestUpgradeCost("Broń jednoręczna", SkillType.OneHanded); });
Interface.StatsMenu.twoH.bind(EventType.Click, function(element) { Interface.StatsMenu.requestUpgradeCost("Broń dwuręczna", SkillType.TwoHanded); });
Interface.StatsMenu.bow.bind(EventType.Click, function(element) { Interface.StatsMenu.requestUpgradeCost("Łuk", SkillType.Bow); });
Interface.StatsMenu.cbow.bind(EventType.Click, function(element) { Interface.StatsMenu.requestUpgradeCost("Kusza", SkillType.Crossbow); });
Interface.StatsMenu.mage.bind(EventType.Click, function(element) { Interface.StatsMenu.requestUpgradeCost("Magia", SkillType.MagicCircle); });

for (local i = 0; i < ProfessionType.COUNT; i++) {
    (function(profIndex) {
        Interface.StatsMenu["prof" + profIndex].bind(EventType.Click, function(element) {
            Interface.StatsMenu.requestProfessionUpgrade(profIndex);
        });
    })(i);
}

Interface.StatsMenu.accept.bind(EventType.Click, function(element) { Interface.StatsMenu.confirmUpgrade(); });
Interface.StatsMenu.cancel.bind(EventType.Click, function(element) { Interface.StatsMenu.hideUpgradeWindow(); });
Interface.StatsMenu.leave.bind(EventType.Click, function(element) { Interface.StatsMenu.hide(); });

addEventHandler("onPacket", function(packet) {
    local packetId = packet.readUInt8();
    
    if (packetId == PacketId.Player) {
        local playerPacketType = packet.readUInt8();
        
        switch(playerPacketType) {
            case PacketPlayer.UpdateStats:
                local stats = {
                    health = packet.readInt32(), maxHealth = packet.readInt32(),
                    mana = packet.readInt32(), maxMana = packet.readInt32(),
                    strength = packet.readInt32(), dexterity = packet.readInt32(),
                    oneHanded = packet.readInt32(), twoHanded = packet.readInt32(),
                    bow = packet.readInt32(), crossbow = packet.readInt32(),
                    magicCircle = packet.readInt32()
                };
                local learningPoints = packet.readInt32();
                Interface.StatsMenu.setPlayerStats(stats);
                Interface.StatsMenu.setLearningPoints(learningPoints);
                break;
            
            case PacketPlayer.UpdateSkillCost:
                local skillType = packet.readUInt8();
                local cost = packet.readInt32();
                if (Interface.StatsMenu.selectedSkill != null && Interface.StatsMenu.selectedSkill.type == skillType) {
                     Interface.StatsMenu.showUpgradeWindow(Interface.StatsMenu.selectedSkill.name, cost);
                }
                break;
            
            case PacketPlayer.UpdateProfessionCost:
                local profType = packet.readUInt8();
                local profCost = packet.readInt32();
                if (Interface.StatsMenu.selectedProfession != null && Interface.StatsMenu.selectedProfession.type == profType) {
                    local currentLevel = Interface.StatsMenu.playerProfessions[profType];
                    local name = Interface.StatsMenu.selectedProfession.name + " (poziom " + (currentLevel + 1) + ")";
                    Interface.StatsMenu.showUpgradeWindow(name, profCost);
                }
                break;
                
            case PacketPlayer.UpdateProfessions:
                local professions = [];
                for (local i = 0; i < ProfessionType.COUNT; i++) {
                    professions.push(packet.readInt32());
                }
                Interface.StatsMenu.setPlayerProfessions(professions);
                break;
        }
    }
});

addEventHandler("onKeyDown", function(key) {
    if (chatInputIsOpen() || isConsoleOpen()) return;
    if(key == KEY_B) Interface.StatsMenu.toggle();
});

