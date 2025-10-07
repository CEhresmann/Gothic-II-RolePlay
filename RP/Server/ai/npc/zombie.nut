class AIZombie extends AIMonster {
    attack_distance = 250
    target_distance = 800
    chase_distance = 800
    warn_time = 3000

    function Setup() {
        setPlayerName(this.id, "Zombie")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}