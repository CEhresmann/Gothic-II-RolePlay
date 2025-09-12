class AIYoungGobboGreen extends AIMonster {
    instance = "YGOBBO_GREEN"
    attack_distance = 300
    target_distance = 1000
    chase_distance = 600
    warn_time = 3000
    weapon_mode = WEAPONMODE_1HS

    function Setup() {
        setPlayerName(this.id, "Young Gobbo Green")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIGobboGreen extends AIMonster {
    instance = "GOBBO_GREEN"
    attack_distance = 300
    target_distance = 1000
    chase_distance = 600
    warn_time = 3000
    weapon_mode = WEAPONMODE_1HS

    function Setup() {
        setPlayerName(this.id, "Gobbo Green")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIGobboBlack extends AIMonster {
    instance = "GOBBO_BLACK"
    attack_distance = 300
    target_distance = 1000
    chase_distance = 600
    warn_time = 3000
    weapon_mode = WEAPONMODE_1HS

    function Setup() {
        setPlayerName(this.id, "Gobbo Black")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIGobboWarrior extends AIMonster {
    instance = "GOBBO_WARRIOR"
    attack_distance = 300
    target_distance = 1000
    chase_distance = 600
    warn_time = 3000
    weapon_mode = WEAPONMODE_1HS

    function Setup() {
        setPlayerName(this.id, "Gobbo Warrior")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIGobboSkeleton extends AIMonster {
    instance = "GOBBO_SKELETON"
    attack_distance = 300
    target_distance = 1000
    chase_distance = 600
    warn_time = 3000
    weapon_mode = WEAPONMODE_1HS

    function Setup() {
        setPlayerName(this.id, "Gobbo Skeleton")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}