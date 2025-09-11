local initial_ts = getTickCount()

function AI_ElapsedMs() {
    return getTickCount() - initial_ts
}

local function AI_Update() {
    local current_ts = getTickCount() - initial_ts
    local npcs = AI_GetAttachedNPCs()

    foreach (state in npcs) {
        state.Update(current_ts)
    }

    // printf("AI: %d ms", getTickCount() - current_ts)
}

setTimer(AI_Update, 500, 0)

local function AI_HitNPC(pid, kid, desc) {
    if (kid != -1 && pid >= getMaxSlots()) {
        local npc_state = AI_GetNPCState(pid)
        if (npc_state) {
            npc_state.OnHitReceived(kid, desc)
        }
    }
}

addEventHandler("onPlayerDamage", AI_HitNPC)

local function AI_RespawnNPC(pid) {
    if (isNpc(pid)) {
        local npc_state = AI_GetNPCState(pid)
        if (npc_state) {
            npc_state.Reset()
            npc_state.Spawn()

            setPlayerWorld(npc_state.id, npc_state.spawn.world)
            setPlayerPosition(npc_state.id, npc_state.spawn.x, npc_state.spawn.y, npc_state.spawn.z)
            setPlayerAngle(npc_state.id, npc_state.spawn.angle)
            spawnPlayer(pid)
        }
    }
}

addEventHandler("onPlayerRespawn", AI_RespawnNPC)
