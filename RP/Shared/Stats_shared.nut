SKILL_CONFIG <- {
    Limits = {
        Health = 200,
        Mana = 150,
        Strength = 100,
        Dexterity = 100,
        WeaponSkill = 100,
        MagicCircle = 6
    },
    Development = {
        Attributes = {
            Thresholds = [
                { threshold = 10, cost = 1 },
                { threshold = 20, cost = 2 },
                { threshold = 30, cost = 3 },
                { threshold = 40, cost = 4 },
                { threshold = 50, cost = 5 },
                { threshold = 60, cost = 6 },
                { threshold = 70, cost = 7 },
                { threshold = 80, cost = 8 },
                { threshold = 90, cost = 9 },
                { threshold = 100, cost = 10 }
            ]
        },
        WeaponSkills = {
            Thresholds = [
                { threshold = 30, cost = 1 },
                { threshold = 60, cost = 2 },
                { threshold = 100, cost = 3 }
            ]
        },
        Vitals = {
            Value = 1,
            Thresholds = [
                { threshold = 100, cost = 1 },
                { threshold = 150, cost = 2 },
                { threshold = 200, cost = 3 }
            ]
        },
        Magic = {
            CircleCosts = {
                "2" : 25, "3" : 30, "4" : 35, "5" : 40, "6" : 50
            }
        }
    }
}

PROFESSION_CONFIG <- {
    UpgradeCosts = {
        [ProfessionType.Hunter] = [10, 20, 30, 40, 50],
        [ProfessionType.Archer] = [10, 20, 30, 40, 50],
        [ProfessionType.Blacksmith] = [15, 25, 35, 45, 55],
        [ProfessionType.Armorer] = [15, 25, 35, 45, 55],
        [ProfessionType.Alchemist] = [20, 30, 40, 50, 60],
        [ProfessionType.Cook] = [10, 15, 20, 25, 30]
    },
    MaxLevel = 5,
    Names = {
        [ProfessionType.Hunter] = "Łowca",
        [ProfessionType.Archer] = "Łucznik",
        [ProfessionType.Blacksmith] = "Kowal",
        [ProfessionType.Armorer] = "Płatnerz",
        [ProfessionType.Alchemist] = "Alchemik",
        [ProfessionType.Cook] = "Kucharz"
    },
    Descriptions = {
        [ProfessionType.Hunter] = "Specjalista w tropieniu i polowaniach",
        [ProfessionType.Archer] = "Mistrz strzelania z łuku",
        [ProfessionType.Blacksmith] = "Tworzy i naprawia broń",
        [ProfessionType.Armorer] = "Wytwarza i naprawia zbroje",
        [ProfessionType.Alchemist] = "Przygotowuje mikstury i eliksiry",
        [ProfessionType.Cook] = "Przyrządza pożywne posiłki"
    }
}
