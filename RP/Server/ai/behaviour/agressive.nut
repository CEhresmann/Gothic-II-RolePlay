class AIAgressive extends AIBase {
    enemy_id = null
    collect_target = null
    weapon_mode = null

    attack_distance = 300
    target_distance = 1000
    chase_distance = 1000
    warn_time = 0

    max_distance = 0
    warn_start = 0

    constructor(npc_id) {
        base.constructor(npc_id);
        this.enemy_id = -1;
        this.collect_target = AI_CollectNearestTarget;
        if (this.weapon_mode == null) {
            this.weapon_mode = null;
        }
        this.max_distance = this.target_distance;
        this.warn_start = 0;
    }

    function Reset() {
        base.Reset();
        this.warn_start = 0;
        this.max_distance = this.target_distance;
        this.enemy_id = -1;
    }

    function ValidateEnemy() {
        if (this.enemy_id != -1) {
            if (!isPlayerConnected(this.enemy_id) || isPlayerDead(this.enemy_id)) {
                this.enemy_id = -1;
                return false;
            }

            local distance = AI_GetDistancePlayers(this.id, this.enemy_id);
            return distance <= this.max_distance;
        }

        return false;
    }

    function Update(ts) {
        if (isPlayerDead(this.id)) {
            return;
        }

        if (this.FollowRoutine(ts)) {
            return;
        }

        if (!this.ValidateEnemy() && this.collect_target) {
            local last_enemy_id = this.enemy_id;
            this.enemy_id = this.collect_target(this);

            if (last_enemy_id != this.enemy_id) {
                this.OnFocusChange(last_enemy_id, this.enemy_id);
            }
        }

        if (this.enemy_id != -1) {
            this.AttackRoutine(ts);
        } else {
            this.DailyRoutine(ts);
        }
    }

    function AttackRoutine(ts) {
    }

    function DailyRoutine(ts) {
    }

    function OnFocusChange(from, to) {
    }
    
    function ResetBotAfterFollow() {
        this.warn_start = 0;
        this.max_distance = this.target_distance;
        this.enemy_id = -1;
        playAni(this.id, "S_STAND");
    }
	
    function SetFollowTarget(targetId, distance = 200.0) {
        if (!isPlayerConnected(targetId)) return false;
        
        this.follow_mode = true;
        this.follow_target = targetId;
        this.follow_distance = distance;
        this.last_follow_check = 0;
        
        return true;
    }
}