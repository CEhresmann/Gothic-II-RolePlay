class AIYoungGiantRat extends AIMonster {
    instance = "YGIANT_RAT"
    attack_distance = 300
    target_distance = 1200
    chase_distance = 1000
    warn_time = 3000

    function Setup() {
        setPlayerName(this.id, "Young Giant Rat")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIGiantRat extends AIMonster {
    instance = "GIANT_RAT"
    attack_distance = 300
    target_distance = 1200
    chase_distance = 1000
    warn_time = 3000

    function Setup() {
        setPlayerName(this.id, "Giant Rat")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}