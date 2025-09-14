local attached = []
local states = {}

class AISpawnPoint {
    x = 0
    y = 0
    z = 0
    angle = 0
    world = null
}

function AI_GetNPCState(npc_id) {
    if (npc_id in states) {
        return states[npc_id]
    }

    return null
}

function AI_GetAttachedNPCs() {
    return attached
}

function AI_SpawnNPC(npc_state, x, y, z, angle, world) {
    attached.push(npc_state)
    states[npc_state.id] <- npc_state

    npc_state.spawn = AISpawnPoint()
    npc_state.spawn.x = x
    npc_state.spawn.y = y
    npc_state.spawn.z = z
    npc_state.spawn.angle = angle
    npc_state.spawn.world = world
    npc_state.Reset()
    npc_state.Spawn()

    setPlayerWorld(npc_state.id, world)
    setPlayerPosition(npc_state.id, x, y, z)
    setPlayerAngle(npc_state.id, angle)
    spawnPlayer(npc_state.id)
}

function AI_RemoveNPC(npc_state) {
    if (npc_id in states && states[npc_state.id]) {
        destroyNpc(npc_state.id)
        states[npc_state.id] = null

        foreach (idx, state in npcs) {
            if (state.id == npc_state.id) {
                npcs[idx] = npcs[npcs.len() - 1]
                npcs.pop()
            }
        }
    }
}