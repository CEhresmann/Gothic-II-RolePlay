
const WEAPONMODE_NONE = 0
const WEAPONMODE_FIST = 1
const WEAPONMODE_1HS = 2
const WEAPONMODE_2HS = 3
const WEAPONMODE_BOW = 4
const WEAPONMODE_CBOW = 5
const WEAPONMODE_MAG = 6


function AI_GetDistancePlayers(from, to) {
    local from_pos = getPlayerPosition(from)
    local to_pos = getPlayerPosition(to)

    return getDistance3d(from_pos.x, from_pos.y, from_pos.z, to_pos.x, to_pos.y, to_pos.z)
}


function AI_GetAngleToPlayer(from, to) {
    local from_pos = getPlayerPosition(from)
    local to_pos = getPlayerPosition(to)

    return getVectorAngle(from_pos.x, from_pos.z, to_pos.x, to_pos.z)
}

function AI_TurnToPlayer(from, to) {
    local from_pos = getPlayerPosition(from)
    local to_pos = getPlayerPosition(to)

    setPlayerAngle(from, getVectorAngle(from_pos.x, from_pos.z, to_pos.x, to_pos.z), true)
}

function AI_WaitForAction(npc_id, action_id) {
    return action_id != -1 && !isNpcActionFinished(npc_id, action_id)
}

function AI_Warn(npc_state, ts) {
    if (npc_state.warn_time == 0) {
        return false
    }

    if (npc_state.warn_start == 0) {
        npc_state.warn_start = ts
    }

    if ((ts - npc_state.warn_start) < npc_state.warn_time) {
        playAni(npc_state.id, "T_WARN")
        return true
    }

    return false    
}

function AI_CollectNearestTarget(npc_state) {
    local streamed = getStreamedPlayersByPlayer(npc_state.id)
    local from_pos = getPlayerPosition(npc_state.id)

    local nearest_playerid = -1
    local nearest_distance = 999999

    foreach (pid in streamed) {
        if (isPlayerDead(pid)) {
            continue
        }

        if (isPlayerSafeFromBots(pid)) {
            continue
        }

        local to_pos = getPlayerPosition(pid)
        local distance = getDistance3d(from_pos.x, from_pos.y, from_pos.z, to_pos.x, to_pos.y, to_pos.z)

        if (distance < nearest_distance && distance <= npc_state.target_distance) {
            nearest_playerid = pid
            nearest_distance = distance
        }
    }

    return nearest_playerid
}