local function get_wm_name(wm) {
    switch (wm) {
    case WEAPONMODE_FIST: return "FIST"
    case WEAPONMODE_1HS: return "1H"
    case WEAPONMODE_2HS: return "2H"
    case WEAPONMODE_BOW: return "BOW"
    case WEAPONMODE_CBOW: return "CBOW"
    case WEAPONMODE_MAG: return "MAG"
    }

    return ""
}

class AIHumanoid extends AIAgressive {
    constructor(npc_id) {
        base.constructor(npc_id);
    }

    function AttackMove(ts) {
        if (this.weapon_mode >= WEAPONMODE_1HS && this.weapon_mode <= WEAPONMODE_2HS) {
            npcAttackMelee(this.id, this.enemy_id, random(ATTACK_FORWARD, ATTACK_RIGHT), -1, true)
        } else if (this.weapon_mode >= WEAPONMODE_BOW && this.weapon_mode <= WEAPONMODE_CBOW) {
            npcAttackRanged(this.id, this.enemy_id, true)
            this.wait_for_action_id = getNpcLastActionId(this.id)
        } else if (this.weapon_mode == WEAPONMODE_MAG) {
            npcSpellCast(this.id, this.enemy_id, true)
            this.wait_for_action_id = getNpcLastActionId(this.id)
        } else {
            npcAttackMelee(this.id, this.enemy_id, 0, -1, true)
        }
    }

    function ParadeMove(wm_name) {
        local action = rand() % 3

        switch (action) {
        case 0: playAni(this.id, "T_" + wm_name + "PARADEJUMPB"); break
        case 1: playAni(this.id, "T_" + wm_name + "RUNSTRAFEL"); break
        case 2: playAni(this.id, "T_" + wm_name + "RUNSTRAFER"); break
        }
    }

    function EnsureWeapon() {
        if (getPlayerWeaponMode(this.id) == WEAPONMODE_NONE) {
            if (this.weapon_mode == WEAPONMODE_MAG) {
                readySpell(this.id, 0, 0)
            } else {
                drawWeapon(this.id, this.weapon_mode)
            }

            this.wait_for_action_id = getNpcLastActionId(this.id)
            return false
        }

        return true
    }

    function RemoveWeapon() {
        local weapon_mode = getPlayerWeaponMode(this.id)
        if (weapon_mode != WEAPONMODE_NONE) {
            removeWeapon(this.id)
        }
    }

    function StartHitCombo(wm_name, ts) {
        if (this.weapon_mode <= WEAPONMODE_2HS) {
            local change_action = rand() % 100
            if (change_action > 70) {
                this.ParadeMove(wm_name)
            } else {
                this.AttackMove(ts)
            }
        } else {
            this.AttackMove(ts)
        }
    }

    function AttackRoutine(ts) {
        AI_TurnToPlayer(this.id, this.enemy_id)
        if ((this.wait_until - ts) > 0 || AI_WaitForAction(this.id, this.wait_for_action_id)) {
            return
        }

        this.wait_for_action_id = -1
        if (!this.EnsureWeapon()) {
            return
        }
        local distance = AI_GetDistancePlayers(this.id, this.enemy_id)
        local wm_name = get_wm_name(this.weapon_mode)

        if (distance > this.attack_distance) {
            if (!AI_Warn(this, ts)) {
                // Warn finished, run to enemy
                playAni(this.id, "S_" + wm_name + "RUNL")
            }
        } else {
            this.StartHitCombo(wm_name, ts)
        }
    }

    function OnFocusChange(from, to) {
        if (to == -1) {
            playAni(this.id, "S_RUN")

            this.RemoveWeapon()
            this.Reset()
        }
    }

    function OnHitReceived(kid, desc) {
        local change_action = rand() % 100
        if (change_action > 70) {
            this.ParadeMove(get_wm_name(this.weapon_mode))
            this.wait_for_action_id = getNpcLastActionId(this.id)
        }

        // Change target if killer is closer
        if (this.enemy_id != kid) {
            local enemy_distance = AI_GetDistancePlayers(this.id, this.enemy_id)
            local killer_distance = AI_GetDistancePlayers(this.id, kid)

            if (killer_distance < enemy_distance) {
                this.enemy_id = kid
            }
        }
    }
}