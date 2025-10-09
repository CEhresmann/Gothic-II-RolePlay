local attached = []
local states = {}
local npcs = {}

class AISpawnPoint {
    x = 0
    y = 0
    z = 0
    angle = 0
    world = null
}

npcClasses <- {
	//Humans
	DYNAMIC_HUMAN = AIDynamicHuman,

	
    // Sheep
    SHEEP = AISheep,
    HAMMEL = AIHammel,
    
    // Skeleton
    SKELETON = AISkeleton,
    SKELETONMAGE = AISkeletonMage,
    LESSER_SKELETON = AILesserSkeleton,
    SKELETON_LORD = AISkeletonLord,
    
    // Monster
    SCAVENGER = AIScavenger,
    SHADOWBEAST = AIShadowbeast,
    SNAPPER = AISnapper,
    TROLL = AITroll,
    TROLL_BLACK = AIBlackTroll,
    WARAN = AIWaran,
    FIREWARAN = AIFireWaran,
    WARG = AIWarg,
    YWOLF = AIYoungWolf,
    WOLF = AIWolf,
    
    // Zombie
    ZOMBIE = AIZombie,
    
    // Bandit
    BANDIT_MELEE = AIHumanBanditMelee,
    BANDIT_RANGED = AIHumanBanditRanged,
    
    // Bloodfly
    YBLOODFLY = AIYoungBloodfly,
    BLOODFLY = AIBloodfly,
    
    // Giant
    YGIANT_BUG = AIYoungGiantbug,
    GIANT_BUG = AIGiantbug,
    YGIANT_RAT = AIYoungGiantRat,
    GIANT_RAT = AIGiantRat,
    
    // Gobbo
    YGOBBO_GREEN = AIYoungGobboGreen,
    GOBBO_GREEN = AIGobboGreen,
    GOBBO_BLACK = AIGobboBlack,
    GOBBO_WARRIOR = AIGobboWarrior,
    GOBBO_SKELETON = AIGobboSkeleton,
	
	//ORC
	ORCWARRIOR_REST = AIOrcWarriorRoam,
    ORCSHAMAN_SIT = AIOrcShamanSit,
	ORCWARRIOR_HARAD = AIOrcWarriorHarad,
    ORCELITE_REST = AIOrcEliteRest,
    
    // Other
    KEILER = AIKeiler,
    LURKER = AILurker,
    MEATBUG = AIMeatbug,
    MINECRAWLER = AIMinecrawler,
    MINECRAWLERWARRIOR = AIMinecrawlerWarrior,
    MOLERAT = AIMolerat
}


function AI_GetNPCState(npc_id) {
    if (npc_id in states) {
        return states[npc_id]
    }
    return null
}

function AI_GetAttachedNPCs() {
    return npcs
}

function AI_SpawnNPC(npc_state, x, y, z, angle, world) {
    npcs[npc_state.id] <- npc_state  // Dodaj do g³ównej tablicy
    attached.push(npc_state)         // Zachowaj kompatybilnoœæ wsteczn¹
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
    
    return npc_state
}

function AI_RemoveNPC(npc_state) {
    if (npc_state.id in npcs) {
        delete npcs[npc_state.id]
    }
    if (npc_state.id in states) {
        destroyNpc(npc_state.id)
        delete states[npc_state.id]

        foreach (idx, state in attached) {
            if (state.id == npc_state.id) {
                attached.remove(idx)
                break
            }
        }
    }
}


function createMonster(npc, x, y, z, angle) {
    local npc_state
    
    if (typeof npc == "string") {
        local className = npc.toupper()
        if (className in npcClasses) {
            npc_state = npcClasses[className].Create()
        } else {
            npc_state = AISheep.Create()
            print("Warning: NPC class '" + className + "' not found, using Sheep instead")
        }
    } else {
        npc_state = npc
    }
    
    AI_SpawnNPC(npc_state, x, y, z, angle, CFG.BotsSpawnMap)
}

function createHuman(x, y, z, angle, config = {}, customCallback = null) {
    local npcInstance = AIDynamicHuman.Create("PC_HERO");
    if (npcInstance == null) {
        print("ERROR: Failed to create AIDynamicHuman instance");
        return null;
    }
    
    npcInstance.SetConfig(config, customCallback);
    
    if ("name" in config) npcInstance.name = config.name;
    if ("can_wander" in config) npcInstance.can_wander = config.can_wander;
    if ("idle_speech" in config) npcInstance.idle_speech = config.idle_speech;
    if ("can_fight_back" in config) npcInstance.can_fight_back = config.can_fight_back;
    if ("weapon_mode" in config) npcInstance.weapon_mode = config.weapon_mode;
    if ("attack_distance" in config) npcInstance.attack_distance = config.attack_distance;
    if ("weapon_warning" in config) npcInstance.enable_weapon_warning = config.weapon_warning;
    
    local spawnedNpc = AI_SpawnNPC(npcInstance, x, y, z, angle, CFG.BotsSpawnMap);
    if (spawnedNpc == null) {
        print("ERROR: Failed to spawn NPC");
        return null;
    }
    
    return spawnedNpc;
}