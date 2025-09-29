class AIYoungGiantbug extends AIMonster {
    instance = "YGIANT_BUG"
    attack_distance = 300
    target_distance = 1200
    chase_distance = 1000
    warn_time = 3000

    function Setup() {
        setPlayerName(this.id, "Young Giant Bug")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIGiantbug extends AIMonster {
    instance = "GIANT_BUG"
    attack_distance = 300
    target_distance = 1200
    chase_distance = 1000
    warn_time = 3000

    function Setup() {
        setPlayerName(this.id, "Giant Bug")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}