class AISkeleton extends AIHumanoid {
    instance = "SKELETON"
    attack_distance = 250
    target_distance = 1200
    chase_distance = 1000
    weapon_mode = WEAPONMODE_1HS

    function Setup() {
        setPlayerName(this.id, "Skeleton")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AISkeletonMage extends AIHumanoid {
    instance = "SKELETONMAGE"
    attack_distance = 1000
    target_distance = 1000
    chase_distance = 1000
    weapon_mode = WEAPONMODE_MAG

    function Setup() {
        setPlayerName(this.id, "Skeleton Mage")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
        setPlayerMaxMana(this.id, 1000)
        setPlayerMana(this.id, 1000)
        setPlayerTalent(this.id, TALENT_MAGE, 6)
        equipItem(this.id, "ITSC_ICECUBE", 0)
    }
}

class AILesserSkeleton extends AIHumanoid {
    instance = "LESSER_SKELETON"
    attack_distance = 250
    target_distance = 1200
    chase_distance = 1000
    weapon_mode = WEAPONMODE_1HS

    function Setup() {
        setPlayerName(this.id, "Lesser Skeleton")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AISkeletonLord extends AIHumanoid {
    instance = "SKELETON_LORD"
    attack_distance = 250
    target_distance = 1200
    chase_distance = 1000
    weapon_mode = WEAPONMODE_2HS

    function Setup() {
        setPlayerName(this.id, "Skeleton Lord")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}