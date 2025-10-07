class AITroll extends AIMonster {
    instance = "TROLL"
    attack_distance = 400
    target_distance = 1200
    chase_distance = 1000
    warn_time = 5000

    function Setup() {
        setPlayerName(this.id, "Troll")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIBlackTroll extends AIMonster {
    instance = "TROLL_BLACK"
    attack_distance = 400
    target_distance = 1200
    chase_distance = 1000
    warn_time = 5000

    function Setup() {
        setPlayerName(this.id, "Black Troll")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}