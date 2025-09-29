class AIScavenger extends AIMonster {
    instance = "SCAVENGER"
    attack_distance = 300
    target_distance = 1200
    chase_distance = 1000
	respawn_time = 30000
    warn_time = 3000

    function Setup() {
        setPlayerName(this.id, "Scavenger")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}