class AIBase {
    id = -1
    spawn = null
    instance = null

	respawn_time = 10000
    death_time = 0

    // AI vars
    wait_until = 0
    wait_for_action_id = -1

    constructor(npc_id) {
        this.id = npc_id
		respawn_time = 10000
    }

    function Reset() {
        this.wait_until = 0
        this.wait_for_action_id = -1
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
        // Triggered every AI update tick
    }

    function Setup() {
        // Triggered only once while creating NPC
    }

    function Spawn() {
        // Triggered after NPC respawn
    }

    function OnHitReceived(kid, desc) {
        // Triggered when NPC receives damage
    }
}