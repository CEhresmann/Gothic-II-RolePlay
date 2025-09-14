ChatConfig <- {
    maxLines = 13,
    chatAreaWidthPercent = 0.75,
    maxInputLines = 3,
    maxSentHistory = 20,
    lineSpacing = 2
};

CFG <- {
    Hostname = "Open Roleplay 2.0"
    Version = "2.0.5",

    Spawn = {x = 0, y = 0, z = 0, angle = 65}

    MaxSlots = getMaxSlots()
    DamageAnims = true
    TextWrap = true
    ShowAnimatiotChat = true

    Languages = {
        "en" : { layout = 0, package = "en", text = "English"}
        "pl" : { layout = 1, package = "pl", text = "Polski"}
        "ru" : { layout = 2, package = "ru", text = "Russia"}
        "de" : { layout = 3, package = "de", text = "Deutsch"}
    }
    DefaultLanguage = "pl",
    LanguageSwitcher = true

    Currency = "ITMI_GOLD"

    WhiteList = [
    ]
	
    DefaultPosition = {x = 0.9, y = 21.12, z = 23.25, angle = 41}
    DefaultColor = {r = 255, g = 255, b = 255}
    AdminColor = {r = 200, g = 0, b = 0}
    ModColor = {r = 0, g = 200, b = 0}

    MapShowOthers = false
    MapShowYourself = true

    WorldBuilder = true
    WorldBuilderTrueBuilding = true

    BotsSpawnMap = "NEWWORLD\\NEWWORLD.ZEN",
	BodyTexturesAmount = 12,
	HeadTexturesAmount = 162,

    FractionDescription = [
        [
            "No fraction.",
        ],
        [
            "",
            "",
            "",
        ]
    ]

    DefaultVisual = {
        Body = "Hum_Body_Naked0"
        Skin = 9
        Head = "Hum_Head_Pony"
        Face = 22
    }

	NPCSounds = {
        attack_sounds = [
            "SVM_6_DieMonster",
            "SVM_3_Guards", 
            "SVM_4_IGetYouStill",
            "SVM_4_LookingForTroubleAgain",
            "SVM_3_Alarm"
        ],
        
        help_sounds = [
            "SVM_3_Help",
            "SVM_3_Guards",
            "DIA_MIL_6_STANDARD_06_01", 
            "SVM_1_SpareMe"
        ],
        
        idle_sounds = [
            "SVM_1_Smalltalk11",
            "SVM_1_Smalltalk20",
            "SVM_1_Smalltalk25",
            "SVM_1_Smalltalk07",
            "SVM_1_Smalltalk15",
            "SVM_1_Smalltalk30",
            "SVM_10_Smalltalk05",
            "SVM_10_Smalltalk12"
        ]
    }

    GroundItems = [
        ["ITPL_HEALTH_HERB_01", 1, 15, 60], // instance, amount, chance, respawnTime (minutes)
        ["ITPL_HEALTH_HERB_02", 1, 10, 120],
        ["ITPL_HEALTH_HERB_03", 1, 5, 180],
        ["ITPL_MANA_HERB_01", 1, 15, 60],
        ["ITPL_MANA_HERB_02", 1, 10, 120],
        ["ITPL_MANA_HERB_03", 1, 5, 180],
        ["ITPL_FORESTBERRY", 1, 15, 30],
        ["ITPL_PLANEBERRY", 1, 5, 120],
        ["ITPL_BEET", 1, 5, 90],
        ["ITPL_BLUEPLANT", 1, 5, 120],
    ]

    Anims = [
        {
            name = "Sit",
            inst = "T_STAND_2_SIT"
        },
        {
            name = "Search",
            inst = "T_SEARCH"
        },
        {
            name = "Sleep",
            inst = "T_STAND_2_SLEEPGROUND"
        },
        {
            name = "Arms chill",
            inst = "S_LGUARD"
        },
        {
            name = "Arms guard",
            inst = "S_HGUARD"
        },
        {
            name = "Pee",
            inst = "T_STAND_2_PEE"
        },
        {
            name = "Training",
            inst = "T_1HSFREE"
        },
        {
            name = "Watching melee",
            inst = "T_1HSINSPECT"
        },
        {
            name = "Pray",
            inst = "S_PRAY"
        }
    ]
};


// Tabela czasów respawnu w MILISEKUNDACH
npcRespawnTimes <- {
	DYNAMIC_HUMAN = 15000,


    SHEEP = 15000,
    HAMMEL = 900000,
    

    SKELETON = 1200000,
    SKELETONMAGE = 1500000,
    LESSER_SKELETON = 1080000,
    SKELETON_LORD = 1800000,
    

    SCAVENGER = 1080000,
    SHADOWBEAST = 2700000,
    SNAPPER = 1320000,
    TROLL = 1800000,
    TROLL_BLACK = 2100000,
    WARAN = 1500000,
    FIREWARAN = 1680000,
    WARG = 1200000,
    YWOLF = 900000,
    WOLF = 1200000,
    

    ZOMBIE = 1500000,
    

    BANDIT_MELEE = 1200000,
    BANDIT_RANGED = 1320000,
    

    YBLOODFLY = 720000,
    BLOODFLY = 900000,
    

    YGIANT_BUG = 1500000,
    GIANT_BUG = 2100000,
    YGIANT_RAT = 1200000,
    GIANT_RAT = 1800000,
    

    YGOBBO_GREEN = 900000,
    GOBBO_GREEN = 1200000,
    GOBBO_BLACK = 1500000,
    GOBBO_WARRIOR = 1680000,
    GOBBO_SKELETON = 1800000,
    

    KEILER = 1200000,
    LURKER = 1500000,
    MEATBUG = 720000,
    MINECRAWLER = 1800000,
    MINECRAWLERWARRIOR = 2100000,
    MOLERAT = 900000
}
const DEFAULT_NPC_RESPAWN_TIME = 900000

//Tabela lootu itemów z mobków
LootMobItems <- {
    "Sheep": [
        {item = "ItAt_SheepFur", quantity = 1},
        {item = "ItFoMuttonRaw", quantity = 2}
    ],
    "Wolf": [
        {item = "ItAt_WolfFur", quantity = 1},
        {item = "ItFoMeatRaw", quantity = 2}
    ],
	"BLOODFLY": [
        {item = "ItAt_Sting", quantity = 1},
        {item = "ItAt_Wing", quantity = 2}
    ],
	"GIANT_RAT": [
        {item = "ItFoMuttonRaw", quantity = 1}
    ]
	"LURKER": [
        {item = "ItAt_LurkerSkin", quantity = 1},
        {item = "ItAt_LurkerClaw", quantity = 2}
    ],
	"KEILER": [
        {item = "ItAt_Addon_KeilerFur", quantity = 1},
        {item = "ItAt_LurkerClaw", quantity = 2}
    ],
	"MEATBUG": [
        {item = "ItAt_Meatbugflesh", quantity = 1}
    ],
	"BLATTCRAWLER": [
        {item = "ItAt_Addon_BCKopf", quantity = 1},
        {item = "ItAt_CrawlerMandibles", quantity = 1}
    ],
	"MOLERAT": [
        {item = "ItAt_Addon_BCKopf", quantity = 1},
        {item = "ItAt_CrawlerMandibles", quantity = 1}
    ],
	"SCAVENGER": [
        {item = "ItFoMuttonRaw", quantity = 2}
    ],
	"SHADOWBEAST": [
        {item = "ItAt_ShadowFur", quantity = 1},
        {item = "ItFoMuttonRaw", quantity = 2}
    ],
	"TROLL": [
        {item = "ItAt_TrollFur", quantity = 1},
        {item = "ItFoMuttonRaw", quantity = 4},
		{item = "ItAt_TrollTooth", quantity = 1}
    ],
	"WARG": [
        {item = "ItAt_WargFur", quantity = 1},
        {item = "ItFoMuttonRaw", quantity = 2}
    ],
	"WOLF": [
        {item = "ItAt_WolfFur", quantity = 1},
        {item = "ItFoMuttonRaw", quantity = 1},
		{item = "ItAt_Claw", quantity = 2},
		{item = "ItAt_Teeth", quantity = 1}
    ],
};