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

setTimer(function() { AI_Update() }, 500, 0)

local function AI_HitNPC(pid, kid, desc) {
    if (kid != -1 && pid >= getMaxSlots()) {
        local npc_state = AI_GetNPCState(pid)
        if (npc_state) {
            npc_state.OnHitReceived(kid, desc)
        }
    }
}

addEventHandler("onPlayerDamage", AI_HitNPC)


addEventHandler("onPlayerRespawn", function(pid) {
    if (isNpc(pid)) {
        local npc_state = AI_GetNPCState(pid)
        if (npc_state) {
            npc_state.Reset()
            npc_state.Spawn()
        }
    }
})

addEventHandler("onPlayerDead", function(pid, killerid) {
    if (isNpc(pid)) {
        local npc_state = AI_GetNPCState(pid)
        if (npc_state) {
            local instance = getPlayerInstance(pid)
            local respawnTime = DEFAULT_NPC_RESPAWN_TIME
            if (instance == "PC_HERO" && "DYNAMIC_HUMAN" in npcRespawnTimes) {
                respawnTime = npcRespawnTimes["DYNAMIC_HUMAN"]
            }
            else if (instance in npcRespawnTimes) {
                respawnTime = npcRespawnTimes[instance]
            }
            local spawn_point = npc_state.spawn
            setTimer(function() {
                if (isPlayerConnected(pid)) {
                    npc_state.Reset()
                    npc_state.Spawn()
                    setPlayerWorld(pid, spawn_point.world)
                    setPlayerPosition(pid, spawn_point.x, spawn_point.y, spawn_point.z)
                    setPlayerAngle(pid, spawn_point.angle)
                    spawnPlayer(pid)
                }
            }, respawnTime, 1)
        }
    }
})


addEventHandler("onPacket", function(playerid, packet) {
    try {
        local packetCategory = packet.readUInt8();
        
        if (packetCategory == PacketId.Bot) {
            local packetType = packet.readUInt8();
            
            if (packetType == PacketBot.PlaySound) {
                local npcId = packet.readInt32();
                local soundName = packet.readString();
            }
        }
    } catch (e) {
        print("Error reading packet: " + e);
    }
});