class AIBase {
    id = -1
    spawn = null
    instance = null

    respawn_time = 10000
    death_time = 0
	
    follow_mode = false
    follow_target = -1
    follow_distance = 200.0
    last_follow_check = 0

    wait_until = 0
    wait_for_action_id = -1

    constructor(npc_id) {
        this.id = npc_id
        respawn_time = 10000
    }

    function Reset() {
        this.wait_until = 0
        this.wait_for_action_id = -1
        this.follow_mode = false
        this.follow_target = -1
        this.last_follow_check = 0
        
        if (!AI_WaitForAction(this.id, this.wait_for_action_id)) {
            playAni(this.id, "S_STAND");
            this.wait_for_action_id = -1;
        }
    }

    function Create(instance = null) {
        instance = instance || this.instance

        local npc_id = createNpc("NPC", instance)
        if (npc_id == -1) {
            return null
        }

        local state = this(npc_id)
        state.instance = instance
        state.Setup()
        
        return state
    }

    function Update(ts) {
    }

    function Setup() {
    }

    function Spawn() {
    }

    function OnHitReceived(kid, desc) {
    }
	
    function FollowRoutine(ts) {
        if (!this.follow_mode || this.follow_target == -1) {
            return false;
        }

        if (!isPlayerConnected(this.follow_target) || isPlayerDead(this.follow_target)) {
            this.StopFollowing();
            return false;
        }

        if (ts - this.last_follow_check < 200) {
            return true;
        }
        this.last_follow_check = ts;

        local distance = AI_GetDistancePlayers(this.id, this.follow_target);
        
        local targetWeaponMode = getPlayerWeaponMode(this.follow_target);
        local currentBotWeaponMode = getPlayerWeaponMode(this.id);
        
        if (("can_fight_back" in this) && this.can_fight_back && ("weapon_mode" in this) && this.weapon_mode != null && this.weapon_mode != WEAPONMODE_NONE) {
            if (targetWeaponMode != WEAPONMODE_NONE && currentBotWeaponMode == WEAPONMODE_NONE) {
                drawWeapon(this.id, this.weapon_mode);
            } else if (targetWeaponMode == WEAPONMODE_NONE && currentBotWeaponMode != WEAPONMODE_NONE) {
                removeWeapon(this.id);
            }
        }
        
        if (distance > this.follow_distance + 50) {
            AI_TurnToPlayer(this.id, this.follow_target);
            
            if (!AI_WaitForAction(this.id, this.wait_for_action_id) && (this.wait_until - ts) <= 0) {
                local animName = "S_FISTRUNL";
                
                local currentWeaponMode = getPlayerWeaponMode(this.id);
                if (currentWeaponMode != WEAPONMODE_NONE) {
                    switch (currentWeaponMode) {
                        case WEAPONMODE_FIST: animName = "S_FISTRUNL"; break;
                        case WEAPONMODE_1HS: animName = "S_1HRUNL"; break;
                        case WEAPONMODE_2HS: animName = "S_2HRUNL"; break;
                        case WEAPONMODE_BOW: animName = "S_BOWRUNL"; break;
                        case WEAPONMODE_CBOW: animName = "S_CBOWRUNL"; break;
                        case WEAPONMODE_MAG: animName = "S_MAGRUNL"; break;
                        default: animName = "S_FISTRUNL"; break;
                    }
                }
                
                playAni(this.id, animName);
                this.wait_until = ts + 1000;
            }
        } else {
            if (!AI_WaitForAction(this.id, this.wait_for_action_id)) {
                playAni(this.id, "S_STAND");
                this.wait_until = ts + 2000;
                
                if (rand() % 100 == 0) {
                    AI_TurnToPlayer(this.id, this.follow_target);
                }
            }
        }
        
        return true;
    }
	
    function StopFollowing() {
        this.follow_mode = false;
        this.follow_target = -1;
        this.last_follow_check = 0;
        this.wait_until = 0;
        
        if (!AI_WaitForAction(this.id, this.wait_for_action_id)) {
            playAni(this.id, "S_STAND");
            this.wait_for_action_id = -1;
        }
        
        this.ResetBotAfterFollow();
    }
    
    function ResetBotAfterFollow() {
        // Do nothing in base class
    }
}