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
    
    was_attacked = false
    last_attacker_id = -1
    is_fleeing = false
    flee_check_timer = 0
    combat_state = 0
    idle_sound_timer = 0
    next_idle_sound_time = 0
    last_sound_time = 0

    attack_sounds = null
    help_sounds = null
    idle_sounds = null

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
        
        this.attack_sounds = ::CFG.NPCSounds.attack_sounds;
        this.help_sounds = ::CFG.NPCSounds.help_sounds;
        this.idle_sounds = ::CFG.NPCSounds.idle_sounds;
        
        this.sound_time_offset = (npc_id * 257 + 113) % 1000000;
        this.individual_delay = (npc_id * 73) % 5000;
        this.sound_chance = 60 + (npc_id % 40);
        
        this.Reset();
    }

    function SetConfig(cfg, callback = null) {
        this.config = cfg;
        this.customCallback = callback;
        
        if ("visual" in cfg) {
            this.visual = cfg.visual;
        }
        if ("name" in cfg) {
            this.npc_name = cfg.name;
        }
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
                    } catch (e) {
                        print("Failed to set visual: " + e);
                    }
                }
            }, 100, 1, this.id, this.config.visual);
        }
        
        if (this.customCallback != null) {
            setTimer(function(npc, callback) {
                if (isPlayerConnected(npc.id)) {
                    callback(npc);
                }
            }, 500, 1, this, this.customCallback);
        }
    }

    function Spawn() {
        setPlayerInstance(this.id, this.instance);
        this.Reset();
        this.ApplyConfig();
    }

    function Reset() {
        base.Reset();
        this.was_attacked = false;
        this.last_attacker_id = -1;
        this.is_fleeing = false;
        this.wait_until = 0;
        this.flee_check_timer = 0;
        this.combat_state = 0;
        this.idle_sound_timer = 0;
        this.next_idle_sound_time = this.GetRandomIdleSoundTime();
        this.last_sound_time = 0;
        
        this.idle_sound_timer = this.sound_time_offset + this.individual_delay;
        
        if (getPlayerWeaponMode(this.id) != WEAPONMODE_NONE) {
            this.RemoveWeapon();
        }
    }

    function GetRandomIdleSoundTime() {
        return 1500000 + rand() % 4500000 + this.individual_delay;
    }

    function Update(ts) {
        if (isPlayerDead(this.id)) return;
        
        if (this.is_fleeing) {
            this.FleeBehavior(ts);
        } 
        else if (this.was_attacked && this.can_fight_back) {
            if (!this.ValidateEnemy()) {
                this.enemy_id = this.CollectDefenseTarget();
            }

            if (this.enemy_id != -1) {
                if (this.combat_state != 1) {
                    this.combat_state = 1;
                    local randomSound = this.attack_sounds[rand() % this.attack_sounds.len()];
                    this.PlaySoundForPlayer(this.last_attacker_id, randomSound);
                }
                this.AttackRoutine(ts);
            } else {
                this.IdleBehavior(ts);
            }
        } else {
            this.IdleBehavior(ts);
            if (this.idle_speech) {
                this.HandleIdleSounds(ts);
            }
        }
    }

    function HandleIdleSounds(ts) {
        if (this.combat_state == 0) {
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
        foreach (playerid in streamed) {
            this.PlaySoundForPlayer(playerid, soundName);
        }
    }

    function CollectDefenseTarget() {
        if (this.last_attacker_id != -1 &&
            isPlayerConnected(this.last_attacker_id) &&
            !isPlayerDead(this.last_attacker_id)) {

            local distance = AI_GetDistancePlayers(this.id, this.last_attacker_id);
            if (distance <= this.chase_distance) {
                return this.last_attacker_id;
            }
        }
        return -1;
    }

    function IdleBehavior(ts) {
        if (getPlayerWeaponMode(this.id) != WEAPONMODE_NONE) {
            this.RemoveWeapon();
        }
        
        if (this.can_wander && !AI_WaitForAction(this.id, this.wait_for_action_id)) {
            local chance = rand() % 100;
            if (chance < this.wander_chance) {
                this.Wander();
            } else if (chance > 100 - this.idle_chance) {
                this.PlayIdleAnimation();
            }
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
            if (distance < 300) {
                this.ContinueFleeing();
            } else {
                this.StopFleeing();
            }
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
        local idleAnis = ["T_LOOKAROUND", "T_HEAD_TURN", "S_RUNL_2_STAND"];
        playAni(this.id, idleAnis[rand() % idleAnis.len()]);
    }

    function OnHitReceived(kid, desc) {
        if (this.last_attacker_id == kid && this.is_fleeing) {
            return;
        }

        this.was_attacked = true;
        this.last_attacker_id = kid;

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
        if (!isPlayerConnected(attackerId) || isPlayerDead(attackerId)) {
            return;
        }
        
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
        } catch (e) {
        }
    }

    function OnFocusChange(from, to) {
        if (to == -1 && this.was_attacked) {
            this.StopFleeing();
        }
        base.OnFocusChange(from, to);
    }

    function OnSpawn() {}
}