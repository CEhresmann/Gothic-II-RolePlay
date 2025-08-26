
CFG <- {
    Hostname = "Open Roleplay 2.0"
    Version = "2.0.0",

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

    AdminPassword = "test123"
    ModPassword = "test123"

    WhiteList = [
    ]

    ModSerial = [
    ]

    AdminSerial = [
    ]

    Shout = { Distance = 3000, Color = {r = 199, g = 22, b = 22}, Prefix = " krzyk: ", Sufix = "" }
    Whisper = { Distance = 660, Color = {r = 155, g = 199, b = 155}, Prefix = " szept: ", Sufix = "" }
    OutOfCharacter = { Distance = 1300, Color = {r = 155, g = 2, b = 168}, Prefix = " ((", Sufix = "))"}
    InCharacter = { Distance = 1300, Color = {r = 197, g = 115, b = 50}, Prefix = " (ME) ", Sufix = "" }
    Environment = { Distance = 1300, Color = {r = 52, g = 224, b = 101}, Prefix = "", Sufix = "" }
	PM_OUT = {Color = {r = 255, g = 255, b = 0}, message = ">>"}
	PM_IN = {Color = {r = 255, g = 255, b = 128}, message = "<<"}
	
    DefaultPosition = {x = 0.9, y = 21.12, z = 23.25, angle = 41}
    DefaultColor = {r = 255, g = 255, b = 255}
    AdminColor = {r = 200, g = 0, b = 0}
    ModColor = {r = 0, g = 200, b = 0}

    MapShowOthers = false
    MapShowYourself = true

    WorldBuilder = true
    WorldBuilderTrueBuilding = false
    WorldBuilderPassword = "test123"

    BotEyeVision = true,
    BotUseWaypoints = true,
    BotWaypointMap = "NEWWORLD",

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
