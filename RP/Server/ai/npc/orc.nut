class AIOrcWarriorRoam extends AIHumanoid {
    instance = "ORCWARRIOR_REST"
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
		equipItem(this.id, "ItMw_2h_OrcAxe_02", 0)
    }
}

class AIOrcWarriorHarad extends AIHumanoid {
    instance = "ORCWARRIOR_HARAD"
    attack_distance = 250
    target_distance = 1000
    chase_distance = 500
    warn_time = 3000
    weapon_mode = WEAPONMODE_2HS

    function Setup() {
        setPlayerName(this.id, "Orc Harad")
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance)
    }
}

class AIOrcEliteRest extends AIHumanoid {
    instance = "ORCELITE_REST"
    attack_distance = 250
    target_distance = 1000
    chase_distance = 500
    warn_time = 3000
    weapon_mode = WEAPONMODE_2HS

    function Setup() {
        setPlayerName(this.id, "Orc Elite")
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