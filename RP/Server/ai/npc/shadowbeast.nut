class AIShadowbeast extends AIMonster {
    instance = "SHADOWBEAST"
    attack_distance = 400
    target_distance = 1200
    chase_distance = 1000
    warn_time = 8000

    function Setup() {
        setPlayerName(this.id, "Shadowbeast")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}