class AIYoungBloodfly extends AIMonster {
    instance = "YBLOODFLY"
    attack_distance = 300
    target_distance = 1200
    chase_distance = 1000
    warn_time = 3000

    function Setup() {
        setPlayerName(this.id, "Young Bloodfly")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIBloodfly extends AIMonster {
    instance = "BLOODFLY"
    attack_distance = 300
    target_distance = 1200
    chase_distance = 1000
    warn_time = 3000

    function Setup() {
        setPlayerName(this.id, "Bloodfly")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}