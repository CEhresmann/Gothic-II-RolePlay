class AIYoungWolf extends AIMonster {
    instance = "YWOLF"
    attack_distance = 300
    target_distance = 1200
    chase_distance = 1000
    warn_time = 3000

    function Setup() {
        setPlayerName(this.id, "Young Wolf")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIWolf extends AIMonster {
    instance = "WOLF"
    attack_distance = 300
    target_distance = 1200
    chase_distance = 1000
    warn_time = 3000

    function Setup() {
        setPlayerName(this.id, "Wolf")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
        setPlayerStrength(this.id, 30)
    }
}