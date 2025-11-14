local function get_wm_name(wm) {
    switch (wm) {
    case WEAPONMODE_FIST: return "FIST"
    case WEAPONMODE_1HS: return "1H"
    case WEAPONMODE_2HS: return "2H"
    case WEAPONMODE_BOW: return "BOW"
    case WEAPONMODE_CBOW: return "CBOW"
    case WEAPONMODE_MAG: return "MAG"
    }
    return "FIST"
}

class AIDynamicHuman extends AIHumanoid {
    instance = "PC_HERO"
    
    name = "NPC"
    can_wander = false
    can_fight_back = false
    weapon_mode = WEAPONMODE_NONE
    wander_chance = 3
    idle_chance = 2
    flee_distance = 1000
    idle_speech = true
    enable_weapon_warning = true
    
    was_attacked = false
    last_attacker_id = -1
    is_fleeing = false
    flee_check_timer = 0
    combat_state = 0
    idle_sound_timer = 0
    next_idle_sound_time = 0
    last_sound_time = 0
    last_warning_time = 0
    is_warning = false
    warning_target = -1
    warning_end_time = 0
    warning_start_time = 0
    final_warning_sent = false

    attack_sounds = null
    help_sounds = null
    idle_sounds = null
    warning_sounds = null
    final_warning_sounds = null
	
    sound_time_offset = 0
    individual_delay = 0
    sound_chance = 70 

    config = {}
    customCallback = null
    visual = null
    npc_name = ""
    npc_instance = ""

    constructor(npc_id) {
        base.constructor(npc_id);
        this.attack_distance = 200;
        this.chase_distance = 500;
        
        this.attack_sounds = CFG.NPCSounds.attack_sounds;
        this.help_sounds = CFG.NPCSounds.help_sounds;
        this.idle_sounds = CFG.NPCSounds.idle_sounds;
        this.warning_sounds = CFG.NPCSounds.warning_sounds;
        this.final_warning_sounds = CFG.NPCSounds.final_warning_sounds;
        
        this.sound_time_offset = (npc_id * 257 + 113) % 1000000;
        this.individual_delay = (npc_id * 73) % 5000;
        this.sound_chance = 60 + (npc_id % 40);
        
        this.Reset();
    }

    function SetConfig(cfg, callback = null) {
        this.config = cfg;
        this.customCallback = callback;
        
        if ("visual" in cfg) this.visual = cfg.visual;
        if ("name" in cfg) this.npc_name = cfg.name;
        if ("weapon_warning" in cfg) this.enable_weapon_warning = cfg.weapon_warning;
    }

    function ApplyConfig() {
        if ("name" in this.config) {
            setPlayerName(this.id, this.config.name);
            this.name = this.config.name;
        }
        
        if ("visual" in this.config) {
            setTimer(function(id, visual) {
                if (isPlayerConnected(id)) {
                    try {
                        setPlayerVisual(id, visual.body, visual.bodyTex, visual.head, visual.headTex);
                    } catch (e) {}
                }
            }, 100, 1, this.id, this.config.visual);
        }
        
        if (this.customCallback != null) {
            setTimer(function(npc, callback) {
                if (isPlayerConnected(npc.id)) callback(npc);
            }, 500, 1, this, this.customCallback);
        }
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance);
        this.Reset();
        this.ApplyConfig();
    }

	function Reset() {
        this.wait_until = 0;
        this.wait_for_action_id = -1;
        this.follow_mode = false;
        this.follow_target = -1;
        this.last_follow_check = 0;
        
        this.was_attacked = false;
        this.last_attacker_id = -1;
        this.is_fleeing = false;
        this.flee_check_timer = 0;
        this.combat_state = 0;
        this.idle_sound_timer = 0;
        this.next_idle_sound_time = this.GetRandomIdleSoundTime();
        this.last_sound_time = 0;
        this.last_warning_time = 0;
        this.is_warning = false;
        this.warning_target = -1;
        this.warning_end_time = 0;
        this.warning_start_time = 0;
        this.final_warning_sent = false;
        
        this.idle_sound_timer = this.sound_time_offset + this.individual_delay;
        
        
        if (!AI_WaitForAction(this.id, this.wait_for_action_id)) {
            playAni(this.id, "S_STAND");
            this.wait_for_action_id = -1;
        }
    }
	
	function ValidateEnemy() {
		if (this.enemy_id != -1 && this.last_attacker_id != -1) {
			if (!isPlayerConnected(this.enemy_id) || isPlayerDead(this.enemy_id) ||
				!isPlayerConnected(this.last_attacker_id) || isPlayerDead(this.last_attacker_id)) {
				
				return false;
			}
			
			local distance = AI_GetDistancePlayers(this.id, this.enemy_id);
			return distance <= this.chase_distance;
		}
		return false;
	}

    function ResetBotAfterFollow() {
        this.Reset();
    }

    function GetRandomIdleSoundTime() {
        return 1500000 + rand() % 4500000 + this.individual_delay;
    }

    function Update(ts) {
		if (isPlayerDead(this.id)) return;
		
		if (this.FollowRoutine(ts)) {
			return;
		}
		
		if (this.is_warning) this.WarningBehavior(ts);
		else if (this.is_fleeing) this.FleeBehavior(ts);
		else if (this.was_attacked && this.can_fight_back) {
			
			local last_enemy_id_before_check = this.enemy_id;

			if (!this.ValidateEnemy()) {
				this.enemy_id = this.CollectDefenseTarget();
			}

			if (last_enemy_id_before_check != -1 && this.enemy_id == -1) {
				this.OnFocusChange(last_enemy_id_before_check, -1)
				this.ResetCombatState();
			}

			else if (last_enemy_id_before_check != this.enemy_id) {
				this.OnFocusChange(last_enemy_id_before_check, this.enemy_id);
			}


			if (this.enemy_id != -1) {
				if (this.combat_state != 1) {
					this.combat_state = 1;
					local randomSound = this.attack_sounds[rand() % this.attack_sounds.len()];
					this.PlaySoundForPlayer(this.last_attacker_id, randomSound);
				}
				this.AttackRoutine(ts);
			} else {
				if (last_enemy_id_before_check == -1) {
					this.ResetCombatState(); 
				}
				this.IdleBehavior(ts);
			}
		} else {
			if (this.can_fight_back && this.enable_weapon_warning) this.CheckForArmedPlayers();
			this.IdleBehavior(ts);
			if (this.idle_speech) this.HandleIdleSounds(ts);
		}
	}

	function ResetCombatState() {
		this.was_attacked = false;
		this.last_attacker_id = -1;
		this.enemy_id = -1;
		this.combat_state = 0;
		if (!AI_WaitForAction(this.id, this.wait_for_action_id)) {
			playAni(this.id, "S_STAND");
		}
	}

    function WarningBehavior(ts) {
        if (getTickCount() > this.warning_end_time) {
            this.StopWarning();
            return;
        }
        
        if (this.warning_target != -1 && isPlayerConnected(this.warning_target)) {
            local weaponMode = getPlayerWeaponMode(this.warning_target);
            
            if (weaponMode == WEAPONMODE_NONE) {
                this.StopWarning();
                return;
            }
            
            local myPos = getPlayerPosition(this.id);
            local targetPos = getPlayerPosition(this.warning_target);
            local angleToTarget = getVectorAngle(myPos.x, myPos.z, targetPos.x, targetPos.z);
            setPlayerAngle(this.id, angleToTarget);
            
            local currentTime = getTickCount();
            local elapsedTime = currentTime - this.warning_start_time;
            
            if (!this.final_warning_sent && elapsedTime > 15000) this.SendFinalWarning();
            if (elapsedTime > 20000) this.AttackWarningTarget();
        }
    }

    function SendFinalWarning() {
        if (this.warning_target != -1 && isPlayerConnected(this.warning_target) && this.final_warning_sounds.len() > 0) {
            local randomSound = this.final_warning_sounds[rand() % this.final_warning_sounds.len()];
            this.PlaySoundForPlayer(this.warning_target, randomSound);
            this.final_warning_sent = true;
        }
    }

    function AttackWarningTarget() {
        if (this.warning_target != -1 && isPlayerConnected(this.warning_target)) {
            local weaponMode = getPlayerWeaponMode(this.warning_target);
            if (weaponMode != WEAPONMODE_NONE) {
                this.was_attacked = true;
                this.last_attacker_id = this.warning_target;
                this.enemy_id = this.warning_target;
                this.combat_state = 1;
                
                if (this.attack_sounds.len() > 0) {
                    local randomSound = this.attack_sounds[rand() % this.attack_sounds.len()];
                    this.PlaySoundForPlayer(this.warning_target, randomSound);
                }
            }
            this.StopWarning();
        }
    }

    function StopWarning() {
        this.is_warning = false;
        this.warning_target = -1;
        this.final_warning_sent = false;
        
        if (!this.was_attacked && getPlayerWeaponMode(this.id) != WEAPONMODE_NONE) removeWeapon(this.id);
        
        this.idle_sound_timer = this.sound_time_offset;
        this.next_idle_sound_time = this.GetRandomIdleSoundTime();
    }

    function CheckForArmedPlayers() {
        local currentTime = getTickCount();
        if (currentTime - this.last_warning_time < 2000) return;
        
        this.last_warning_time = currentTime;
        
        local streamedPlayers = getStreamedPlayersByPlayer(this.id);
        local myPos = getPlayerPosition(this.id);
        
        foreach (playerid in streamedPlayers) {
            if (playerid != this.id && isPlayerConnected(playerid) && !isPlayerDead(playerid)) {
                local playerPos = getPlayerPosition(playerid);
                local distance = getDistance3d(myPos.x, myPos.y, myPos.z, playerPos.x, playerPos.y, playerPos.z);
                
                if (distance > 800) continue;
                
                local weaponMode = getPlayerWeaponMode(playerid);
                
                if (weaponMode != WEAPONMODE_NONE && !this.is_warning) {
                    this.StartWarning(playerid);
                    break;
                }
            }
        }
    }

    function StartWarning(playerid) {
        if (!isPlayerConnected(playerid) || isPlayerDead(playerid)) return;
        
        this.is_warning = true;
        this.warning_target = playerid;
        this.warning_start_time = getTickCount();
        this.warning_end_time = getTickCount() + 40000;
        this.final_warning_sent = false;
        
        if (this.can_fight_back && getPlayerWeaponMode(this.id) == WEAPONMODE_NONE) drawWeapon(this.id, this.weapon_mode);
        
        if (this.warning_sounds.len() > 0) {
            local randomSound = this.warning_sounds[rand() % this.warning_sounds.len()];
            this.PlaySoundForPlayer(playerid, randomSound);
            this.last_sound_time = getTickCount();
        }
    }

    function HandleIdleSounds(ts) {
        if (this.combat_state == 0 && !this.is_warning) {
            this.idle_sound_timer += ts;
            
            if (this.idle_sound_timer >= this.next_idle_sound_time) {
                local currentTime = getTickCount();
                
                if ((currentTime - this.last_sound_time) > 30000 &&
                    (currentTime % 17 == this.id % 17) && 
                    rand() % 100 < this.sound_chance) {
                    
                    this.PlayRandomIdleSound();
                    this.idle_sound_timer = 0;
                    this.next_idle_sound_time = this.GetRandomIdleSoundTime();
                    this.last_sound_time = currentTime;
                }
                else if (this.idle_sound_timer > this.next_idle_sound_time * 1.5) {
                    this.idle_sound_timer = 0;
                    this.next_idle_sound_time = this.GetRandomIdleSoundTime();
                }
            }
        }
    }

    function PlayRandomIdleSound() {
        if (this.idle_sounds.len() > 0) {
            local randomIndex = (getTickCount() + this.id) % this.idle_sounds.len();
            local randomSound = this.idle_sounds[randomIndex];
            this.PlaySoundForStream(randomSound);
        }
    }

    function PlaySoundForStream(soundName) {
        local streamed = getStreamedPlayersByPlayer(this.id);
        foreach (playerid in streamed) this.PlaySoundForPlayer(playerid, soundName);
    }

	function CollectDefenseTarget() {
		if (this.last_attacker_id != -1 &&
			isPlayerConnected(this.last_attacker_id) &&
			!isPlayerDead(this.last_attacker_id)) {

			local distance = AI_GetDistancePlayers(this.id, this.last_attacker_id);
			if (distance <= this.chase_distance) return this.last_attacker_id;
		}
		
		return -1;
	}

    function IdleBehavior(ts) {
        if (this.can_wander && !AI_WaitForAction(this.id, this.wait_for_action_id) && !this.is_warning) {
            local chance = rand() % 100;
            if (chance < this.wander_chance) this.Wander();
            else if (chance > 100 - this.idle_chance) this.PlayIdleAnimation();
        }
    }

    function FleeBehavior(ts) {
        if (this.last_attacker_id == -1 || !isPlayerConnected(this.last_attacker_id) || isPlayerDead(this.last_attacker_id)) {
            this.StopFleeing();
            return;
        }
        
        local distance = AI_GetDistancePlayers(this.id, this.last_attacker_id);
        if (distance > this.flee_distance) {
            this.StopFleeing();
            return;
        }
        
        if (getTickCount() > this.wait_until) {
            if (distance < 300) this.ContinueFleeing();
            else this.StopFleeing();
            return;
        }
        
        playAni(this.id, "S_RUN");
        
        this.flee_check_timer += ts;
        if (this.flee_check_timer > 2000) {
            this.flee_check_timer = 0;
            local currentAngle = getPlayerAngle(this.id);
            local newAngle = (currentAngle + 135 + rand() % 90 - 45) % 360;
            setPlayerAngle(this.id, newAngle);
        }
    }

    function StopFleeing() {
        this.is_fleeing = false;
        this.was_attacked = false;
        this.last_attacker_id = -1;
        this.flee_check_timer = 0;
        this.combat_state = 0;
        this.idle_sound_timer = this.sound_time_offset;
        this.next_idle_sound_time = this.GetRandomIdleSoundTime();
        playAni(this.id, "S_STAND");
    }

    function ContinueFleeing() {
        if (this.last_attacker_id != -1 && isPlayerConnected(this.last_attacker_id)) {
            local from_pos = getPlayerPosition(this.id);
            local to_pos = getPlayerPosition(this.last_attacker_id);
            local angleToAttacker = getVectorAngle(from_pos.x, from_pos.z, to_pos.x, to_pos.z);
            
            local fleeAngle = (angleToAttacker + 180) % 360;
            fleeAngle = (fleeAngle + rand() % 120 - 60) % 360;
            
            setPlayerAngle(this.id, fleeAngle);
            this.wait_until = getTickCount() + 1000 + rand() % 1000;
        }
    }

    function Wander() {
        local randomAngle = rand() % 360;
        setPlayerAngle(this.id, randomAngle);
        playAni(this.id, "S_RUNL");
        this.wait_until = getTickCount() + 1000 + rand() % 2000;
    }

    function PlayIdleAnimation() {
        local idleAnis = ["T_SEARCH", "S_LGUARD", "S_HGUARD"];
        playAni(this.id, idleAnis[rand() % idleAnis.len()]);
    }

    function OnHitReceived(kid, desc) {
        if (this.last_attacker_id == kid && this.is_fleeing) return;

        this.was_attacked = true;
        this.last_attacker_id = kid;

        if (this.is_warning) this.StopWarning();

        local currentTime = getTickCount();
        if ((currentTime - this.last_sound_time) > 3000) {
            
            if (this.can_fight_back) {
                if (this.enemy_id != kid) {
                    local last_enemy = this.enemy_id;
                    this.enemy_id = kid;
                    this.OnFocusChange(last_enemy, this.enemy_id);
                }
                
                if (this.combat_state != 1) {
                    this.combat_state = 1;
                    local randomSound = this.attack_sounds[rand() % this.attack_sounds.len()];
                    this.PlaySoundForPlayer(kid, randomSound);
                    this.last_sound_time = currentTime;
                }
                base.OnHitReceived(kid, desc);
            } else {
                if (this.combat_state != 2) {
                    this.combat_state = 2;
                    local randomSound = this.help_sounds[rand() % this.help_sounds.len()];
                    this.PlaySoundForPlayer(kid, randomSound);
                    this.last_sound_time = currentTime;
                }
                this.StartFleeing(kid);
            }
        }
    }

    function StartFleeing(attackerId) {
        if (!isPlayerConnected(attackerId) || isPlayerDead(attackerId)) return;
        
        this.is_fleeing = true;
        
        local from_pos = getPlayerPosition(this.id);
        local to_pos = getPlayerPosition(attackerId);
        local angleToAttacker = getVectorAngle(from_pos.x, from_pos.z, to_pos.x, to_pos.z);
        
        local fleeAngle = (angleToAttacker + 180) % 360;
        fleeAngle = (fleeAngle + rand() % 120 - 60) % 360;
        
        setPlayerAngle(this.id, fleeAngle);
        this.wait_until = getTickCount() + 1500 + rand() % 1500;
    }

    function PlaySoundForPlayer(playerid, soundName) {
        try {
            local packet = Packet();
            packet.writeUInt8(PacketId.Bot);
            packet.writeUInt8(PacketBot.PlaySound);
            packet.writeInt32(this.id);
            packet.writeString(soundName);
            packet.send(playerid, 0);
        } catch (e) {}
    }

    function OnFocusChange(from, to) {
        if (to == -1 && this.was_attacked) this.StopFleeing();
        base.OnFocusChange(from, to);
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
		
		if (this.can_fight_back && this.weapon_mode != null && this.weapon_mode != WEAPONMODE_NONE) {
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
		base.StopFollowing();
		
		this.wait_until = 0;
	}

    function SetFollowTarget(targetId, distance = 200.0) {
        if (!isPlayerConnected(targetId)) return false;
        
        this.follow_mode = true;
        this.follow_target = targetId;
        this.follow_distance = distance;
        this.last_follow_check = 0;
        
        return true;
    }

    function OnSpawn() {}
}

addEventHandler("onPlayerChangeWeaponMode", function(playerid, oldWeaponMode, newWeaponMode) {
    local npcs = null;
    
    if ("AI_Manager" in getroottable() && "npcs" in ::AI_Manager) npcs = ::AI_Manager.npcs;
    else if ("npcs" in getroottable()) npcs = ::npcs;
    else return;
    
    foreach (npcid, npc in npcs) {
        if (npc instanceof AIDynamicHuman && npc.can_fight_back && npc.enable_weapon_warning && isPlayerConnected(npcid)) {
            local distance = AI_GetDistancePlayers(npcid, playerid);
            
            if (distance < 800 && newWeaponMode != WEAPONMODE_NONE && !npc.is_warning) {
                if (rand() % 100 < 40) npc.StartWarning(playerid);
            }
        }
    }
});

