class AIOrcWarriorRoam extends AIHumanoid {
    instance = "ORCWARRIOR_ROAM"
    attack_distance = 250
    target_distance = 1000
    chase_distance = 500
    warn_time = 3000
    weapon_mode = WEAPONMODE_2HS

    function Setup() {
        setPlayerName(this.id, "Orc")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIOrcShamanSit extends AIHumanoid {
    instance = "ORCSHAMAN_SIT"
    attack_distance = 1000
    target_distance = 1000
    chase_distance = 0
    weapon_mode = WEAPONMODE_MAG

    function Setup() {
        setPlayerName(this.id, "Orc Shaman")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
        setPlayerMaxMana(this.id, 1000)
        setPlayerMana(this.id, 1000)
        setPlayerTalent(this.id, TALENT_MAGE, 6)
        equipItem(this.id, "ITSC_INSTANTFIREBALL", 0)
    }
}