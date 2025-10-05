class AIWaran extends AIMonster {
    instance = "WARAN"
    attack_distance = 350
    target_distance = 1200
    chase_distance = 1000
    warn_time = 5000

    function Setup() {
        setPlayerName(this.id, "Waran")
    }


    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIFireWaran extends AIMonster {
    instance = "FIREWARAN"
    attack_distance = 350
    target_distance = 1200
    chase_distance = 1000
    warn_time = 5000

    function Setup() {
        setPlayerName(this.id, "Fire Waran")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}