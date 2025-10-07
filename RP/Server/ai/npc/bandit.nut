class AIHumanBanditMelee extends AIHumanoid {
    attack_distance = 200
    target_distance = 1000
    chase_distance = 500
    weapon_mode = WEAPONMODE_1HS

    function Setup() {
        setPlayerName(this.id, "Bandit")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIHumanBanditRanged extends AIHumanoid {
    attack_distance = 950
    target_distance = 1000
    chase_distance = 500
    weapon_mode = WEAPONMODE_BOW

    function Setup() {
        setPlayerName(this.id, "Bandit")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}