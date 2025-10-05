enum LEVEL {
    NONE = 0,
    MOD = 1,
    ADMIN = 2
}

class Admins_account extends ORM.Model </ table="admins_account" /> {
    </ primary_key = true, auto_increment = true />
    id = -1
    </ type = "VARCHAR(255)", unique = true, not_null = true />
    uid = ""
    </ type = "INTEGER", not_null = true />
    rank = 0
}

local Player = [];
local MaxPlayers = getMaxSlots();

for (local i = 0; i < MaxPlayers; ++i) {
    Player.push({
        rank = 0,
        godmode = false,
        isBot = false,
        safeFromBots = false 
    });
}

function getPlayerData(pid) {
    if (pid < 0 || pid >= MaxPlayers || !isPlayerConnected(pid)) {
        return null;
    }
    return Player[pid];
}

local function isPotentialBot(pid) {
    local uid = getPlayerUID(pid);
    if (!uid || uid == "" || uid == "0") {
        return true;
    }
    local name = getPlayerName(pid);
    if (name.find("Bot") != null || name.find("BOT") != null ||
        name.find("[BOT]") != null || name.find("(BOT)") != null) {
        return true;
    }
    return false;
}

function checkPermission(pid, level) {
    if (Player[pid].rank >= level)
        return true;
    SendSystemMessage(pid, "Nie masz uprawnieñ do u¿ycia tej komendy!", {r=255,g=0,b=0});
    return false;
}

local function syncGodModeWithClient(pid, enabled) {
    if (!isPlayerConnected(pid)) return;

    local packet = Packet();
    packet.writeUInt8(PacketId.Admin);
    packet.writeUInt8(PacketAdmin.GodMode);
    packet.writeBool(enabled);
    packet.send(pid, RELIABLE_ORDERED);
}

local function syncAdminData(pid) {
    local playerData = getPlayerData(pid);
    if (!playerData) return;

    if (playerData.rank >= LEVEL.ADMIN && playerData.godmode) {
        syncGodModeWithClient(pid, true);
    }
}

local function cmd_acp(pid, params) {
    SendSystemMessage(pid, "-=========== ACP (Panel Administracji) ===========-", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/login - Zaloguj siê na swoje konto admina/moda na podstawie UID.", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/color id r g b - Zmieñ kolor gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/name id nickname - Zmieñ pseudonim gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/kick id powód - Wyrzuæ gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/pos nazwa - Zapisz pozycjê do pliku", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/ros - Zapisz pozycjê ziela do pliku", {r=0,g=255,b=0});
	SendSystemMessage(pid, "/mos - Zapisz pozycjê moba do pliku", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/ban id minuty powód - Zbanuj gracza (minuty = 0 = na zawsze)", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/tp from_id to_id - Teleportuj gracza do innego gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/tpall to_id - Teleportuj wszystkich graczy do gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/giveitem id instancja iloœæ - Daj przedmiot graczowi", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/removeitem id instancja iloœæ - Zabierz przedmiot graczowi", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/str id wartoœæ - Ustaw si³ê gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/dex id wartoœæ - Ustaw zrêcznoœæ gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/heal id - Ulecz gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/mana id - Uzupe³nij manê gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/setmaxhp id maxHP - Ustaw maksymalne HP gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/setmaxmana id maxMana - Ustaw maksymaln¹ manê gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/setweaponskill id skillId procenty - Ustaw umiejêtnoœæ broni (0=1H,1=2H,2=BOW,3=CBOW)", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/time godzina minuta - Ustaw czas serwera", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/kill id - Zabij gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/instance id instancja - Zmieñ instancjê gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/admin_awans idFrakcji idKlasy idGracza - Awansuj gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/report id powód - Zg³oœ gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/invisible - Prze³¹cz niewidzialnoœæ", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/godmode - W³¹cz/wy³¹cz tryb nieunicestwialny", {r=0,g=255,b=0});
	SendSystemMessage(pid, "/botimmunity - W³¹cz/wy³¹cz immunitet na ataki botów", {r=0,g=255,b=0});
}

local function cmd_login(pid, params) {
    local playerUID = getPlayerUID(pid);
    if (!playerUID) {
        SendSystemMessage(pid, "Nie uda³o siê pobraæ twojego unikalnego ID (UID).", {r=255,g=0,b=0});
        return;
    }

    try {
        local account = Admins_account.findOne(@(q) q.where("uid", "=", playerUID));
        if (account) {
            if (account.rank >= LEVEL.MOD) {
                Player[pid].rank = account.rank;
                local rankName = (account.rank == LEVEL.ADMIN) ? "Administratora" : "Moderatora";
                SendSystemMessage(pid, "Zalogowano pomyœlnie jako " + rankName + ".", {r=255,g=255,b=0});
                if (account.rank == LEVEL.ADMIN)
                    setPlayerColor(pid, CFG.AdminColor.r, CFG.AdminColor.g, CFG.AdminColor.b);
                else if (account.rank == LEVEL.MOD)
                    setPlayerColor(pid, CFG.ModColor.r, CFG.ModColor.g, CFG.ModColor.b);
                syncAdminData(pid);
            } else {
                SendSystemMessage(pid, "Twoje konto nie ma wystarczaj¹cych uprawnieñ.", {r=255,g=0,b=0});
            }
        } else {
            SendSystemMessage(pid, "Twoje konto nie zosta³o znalezione w systemie administracji.", {r=255,g=0,b=0});
        }
    } catch (e) {
        SendSystemMessage(pid, "Wyst¹pi³ b³¹d bazy danych podczas logowania. Skontaktuj siê z w³aœcicielem serwera.", {r=255,g=0,b=0});
        serverLog("ACP B³¹d Logowania dla " + getPlayerName(pid) + " (UID: " + playerUID + "): " + e);
    }
}

local function cmd_godmode(pid, params) {
    if (!checkPermission(pid, LEVEL.ADMIN)) return;

    local args = sscanf("d", params);
    local targetId = pid;
    local targetName = getPlayerName(pid);

    if (args && args[0] != pid) {
        targetId = args[0];
        if (!isPlayerConnected(targetId)) {
            SendSystemMessage(pid, "Gracz o ID " + targetId + " nie jest pod³¹czony!", {r=255,g=0,b=0});
            return;
        }
        targetName = getPlayerName(targetId);
    }

    local targetData = getPlayerData(targetId);
    if (!targetData) {
        SendSystemMessage(pid, "B³¹d: Nie mo¿na pobraæ danych gracza!", {r=255,g=0,b=0});
        return;
    }

    targetData.godmode = !targetData.godmode;

    if (targetData.godmode) {
        SendSystemMessage(pid, "GodMode W£¥CZONY dla " + targetName + "!", {r=0,g=255,b=0});
        if (targetId != pid) {
            SendSystemMessage(targetId, "GodMode W£¥CZONY! Jesteœ teraz nietykalny.", {r=0,g=255,b=0});
        }
    } else {
        SendSystemMessage(pid, "GodMode WY£¥CZONY dla " + targetName + "!", {r=255,g=0,b=0});
        if (targetId != pid) {
            SendSystemMessage(targetId, "GodMode WY£¥CZONY! Mo¿esz teraz otrzymywaæ obra¿enia.", {r=255,g=0,b=0});
        }
    }

    syncGodModeWithClient(targetId, targetData.godmode);
}

function isPlayerSafeFromBots(pid) {
    local playerData = getPlayerData(pid);
    return (playerData && playerData.safeFromBots == true);
}

local function cmd_botimmunity(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;

    local args = sscanf("d", params);
    if (!args) {
        SendSystemMessage(pid, "U¿ycie: /botimmunity id_gracza", {r=255,g=0,b=0});
        return;
    }

    local targetId = args[0];
    local targetData = getPlayerData(targetId);
    
    if (!targetData || !isPlayerConnected(targetId)) {
        SendSystemMessage(pid, "Gracz o ID " + targetId + " nie jest pod³¹czony!", {r=255,g=0,b=0});
        return;
    }

    targetData.safeFromBots = !targetData.safeFromBots;

    if (targetData.safeFromBots) {
        SendSystemMessage(pid, "Immunitet na boty W£¥CZONY dla " + getPlayerName(targetId) + "!", {r=0,g=255,b=0});
        SendSystemMessage(targetId, "Administrator w³¹czy³ ci immunitet na boty! Agresywne boty nie bêd¹ ciê atakowaæ.", {r=0,g=255,b=0});
    } else {
        SendSystemMessage(pid, "Immunitet na boty WY£¥CZONY dla " + getPlayerName(targetId) + "!", {r=255,g=0,b=0});
        SendSystemMessage(targetId, "Administrator wy³¹czy³ ci immunitet na boty! Boty mog¹ ciê teraz atakowaæ.", {r=255,g=0,b=0});
    }
}

local function onPlayerDamage(pid, kid, DamageDesc) {
    local victimData = getPlayerData(pid);
    if (victimData && victimData.godmode) {
        DamageDesc.damage = 0;
        return true;
    }
    return false;
}













/*################ BOT FOLLOW ###############*/


local function cmd_follow(pid, params) {
    if (!checkPermission(pid, LEVEL.ADMIN)) return;

    local args = sscanf("dd", params);
    if (!args) {
        SendSystemMessage(pid, "U¿ycie: /follow id_bota id_gracza", {r=255,g=0,b=0});
        SendSystemMessage(pid, "Przyk³ad: /follow 37 0 - bot o ID 37 bêdzie pod¹¿a³ za graczem o ID 0", {r=255,g=0,b=0});
        return;
    }

    local botId = args[0];
    local targetId = args[1];
    
    // SprawdŸ czy bot istnieje i jest NPC
    if (!isPlayerConnected(botId) || !isNpc(botId)) {
        SendSystemMessage(pid, "ID " + botId + " nie jest poprawnym botem (NPC)!", {r=255,g=0,b=0});
        return;
    }

    if (!isPlayerConnected(targetId)) {
        SendSystemMessage(pid, "Gracz o ID " + targetId + " nie jest pod³¹czony!", {r=255,g=0,b=0});
        return;
    }

    if (botId == targetId) {
        SendSystemMessage(pid, "Bot nie mo¿e pod¹¿aæ za samym sob¹!", {r=255,g=0,b=0});
        return;
    }

    // ZnajdŸ AI bota
    local npc_state = AI_GetNPCState(botId);
    if (!npc_state) {
        SendSystemMessage(pid, "B³¹d: Nie znaleziono AI dla bota o ID " + botId + "!", {r=255,g=0,b=0});
        return;
    }

    // SprawdŸ czy bot ju¿ pod¹¿a za tym graczem
    if (npc_state.follow_mode && npc_state.follow_target == targetId) {
        SendSystemMessage(pid, "Bot " + getPlayerName(botId) + " ju¿ pod¹¿a za " + getPlayerName(targetId), {r=255,g=255,b=0});
        return;
    }

    // W³¹cz pod¹¿anie - TERAZ U¯YWAMY ISTNIEJ¥CYCH PÓL
    npc_state.follow_mode = true;
    npc_state.follow_target = targetId;
    npc_state.last_follow_check = 0;

    SendSystemMessage(pid, "Bot " + getPlayerName(botId) + " zaczyna pod¹¿aæ za " + getPlayerName(targetId), {r=0,g=255,b=0});
    
    // Powiadom gracza
    SendSystemMessage(targetId, "Bot " + getPlayerName(botId) + " zaczyna za tob¹ pod¹¿aæ!", {r=255,g=255,b=0});
}





local function cmd_stopfollow(pid, params) {
    if (!checkPermission(pid, LEVEL.ADMIN)) return;

    local args = sscanf("d", params);
    if (!args) {
        SendSystemMessage(pid, "U¿ycie: /stopfollow id_bota", {r=255,g=0,b=0});
        return;
    }

    local botId = args[0];
    
    // SprawdŸ czy bot istnieje i jest NPC
    if (!isPlayerConnected(botId) || !isNpc(botId)) {
        SendSystemMessage(pid, "ID " + botId + " nie jest poprawnym botem (NPC)!", {r=255,g=0,b=0});
        return;
    }

    // ZnajdŸ AI bota
    local npc_state = AI_GetNPCState(botId);
    if (!npc_state) {
        SendSystemMessage(pid, "B³¹d: Nie znaleziono AI dla bota o ID " + botId + "!", {r=255,g=0,b=0});
        return;
    }
    
    // SprawdŸ czy bot w ogóle pod¹¿a
    if (!npc_state.follow_mode) {
        SendSystemMessage(pid, "Bot " + getPlayerName(botId) + " nie pod¹¿a za nikim!", {r=255,g=0,b=0});
        return;
    }

    local oldTarget = npc_state.follow_target;
    
    // Wy³¹cz pod¹¿anie u¿ywaj¹c funkcji StopFollowing
    if ("StopFollowing" in npc_state) {
        npc_state.StopFollowing();
    } else {
        // Fallback dla botów które nie maj¹ StopFollowing
        npc_state.follow_mode = false;
        npc_state.follow_target = -1;
        npc_state.last_follow_check = 0;
        playAni(npc_state.id, "S_STAND");
    }

    SendSystemMessage(pid, "Bot " + getPlayerName(botId) + " przesta³ pod¹¿aæ", {r=255,g=0,b=0});
    
    // Powiadom poprzedni cel
    if (oldTarget != -1 && isPlayerConnected(oldTarget)) {
        SendSystemMessage(oldTarget, "Bot " + getPlayerName(botId) + " przesta³ za tob¹ pod¹¿aæ", {r=255,g=255,b=0});
    }
}






/*################ BOT FOLLOW ###############*/















local function cmd_pos(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;

    local args = sscanf("s", params);
    if (!args) {
        SendSystemMessage(pid, "U¿ycie: /pos nazwa", {r=255,g=0,b=0});
        return;
    }

    local id = args[0];
    local pos = getPlayerPosition(pid);
    local fileSave = file("pos.txt", "a");
    fileSave.write(id + " = " + pos.x + ", " + pos.y + ", "+pos.z + "\n");
    fileSave.close();
    SendSystemMessage(pid, "Pozycja zapisana jako "+id, {r=255,g=0,b=0});
}

local function cmd_ros(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;
    local pos = getPlayerPosition(pid);
    local fileSave = file("ros.txt", "a");
    fileSave.write("RegisterGroundItem(" + pos.x + ", " + pos.y + ", " + pos.z + "); \n");
    fileSave.close();

    SendSystemMessage(pid, "Pozycja ziela zapisana", {r=255,g=0,b=0});
}

local function cmd_mos(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;
	
	local args = sscanf("s", params);
    if (!args) {
        SendSystemMessage(pid, "U¿ycie: /mos instancja_moba", {r=255,g=0,b=0});
        return;
    }
	
	local instance = args[0];
    local pos = getPlayerPosition(pid);
	local angle = getPlayerAngle(pid);
    local fileSave = file("mos.txt", "a");
	fileSave.write("createMonster(\"" + instance + "\", " + pos.x + ", " + pos.y + ", " + pos.z + ", " + angle + "); \n");
    fileSave.close();

    SendSystemMessage(pid, "Mob " +instance+" ustawiony!", {r=0,g=255,b=0});
}

local function cmd_color(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;
    local args = sscanf("dddd", params);
    if (!args) {
        SendSystemMessage(pid, "U¿ycie: /color id r g b", {r=255,g=0,b=0});
        return;
    }

    local id = args[0];
    local r = args[1];
    local g = args[2];
    local b = args[3];

    if (!isPlayerConnected(id)) {
        SendSystemMessage(pid, "Nie mo¿esz zmieniæ koloru niepod³¹czonemu graczowi!", {r=255,g=0,b=0});
        return;
    }

    setPlayerColor(id, r, g, b);

    SendSystemMessage(pid, format("Zmieni³eœ kolor gracza %s na %d, %d, %d", getPlayerName(id), r, g, b), {r=r,g=g,b=b});
    SendSystemMessage(id, format("Twój kolor zosta³ zmieniony na %d, %d, %d przez %s", r, g, b, getPlayerName(pid)), {r=r,g=g,b=b});
}

local function cmd_name(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;

    local args = sscanf("ds", params);
    if (!args) {
        SendSystemMessage(pid, "U¿ycie: /name id pseudonim", {r=255,g=0,b=0});
        return;
    }

    local id = args[0];
    local name = args[1];
    if (!isPlayerConnected(id)) {
        SendSystemMessage(pid, "Nie mo¿esz zmieniæ pseudonimu niepod³¹czonemu graczowi!", {r=255,g=0,b=0});
        return;
    }

    setPlayerName(id, name);

    SendSystemMessage(pid, format("Zmieni³eœ pseudonim gracza %s na %s", getPlayerName(id), name), {r=0,g=255,b=0});
    SendSystemMessage(id, format("Twój pseudonim zosta³ zmieniony na %s przez %s", name, getPlayerName(pid)), {r=0,g=255,b=0});
}

local function cmd_kick(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("ds", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /kick id powód", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local reason = args[1];
        if (!isPlayerConnected(id)) {
            SendSystemMessage(pid, "Nie mo¿esz wyrzuciæ niepod³¹czonego gracza!", {r=255,g=0,b=0});
            return;
        }

        kick(id, reason);

        SendSystemMessage(null, format("%s zosta³ wyrzucony przez %s", getPlayerName(id), getPlayerName(pid)), {r=255,g=80,b=0});
        SendSystemMessage(null, format("Powód: %s", reason), {r=255,g=80,b=0});
    }
}

local function cmd_ban(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dds", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /ban id minuty powód", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local minutes = args[1];
        local reason = args[2];

        if (!isPlayerConnected(id)) {
            SendSystemMessage(pid, "Nie mo¿esz zbanowaæ niepod³¹czonego gracza!", {r=255,g=0,b=0});
            return;
        }

        ban(id, minutes, reason);
        if (minutes > 0) SendSystemMessage(null, format("%s zosta³ zbanowany na %d minut przez %s", getPlayerName(id), minutes, getPlayerName(pid)), {r=255,g=0,b=0});
        else SendSystemMessage(null, format("%s zosta³ ZBANOWANY NA ZAWSZE przez %s", getPlayerName(id), getPlayerName(pid)), {r=255,g=0,b=0});
        SendSystemMessage(null, format("Powód: %s", reason), {r=255,g=0,b=0});
    }
}

local function cmd_tp(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /tp from_id to_id", {r=255,g=0,b=0});
            return;
        }

        local from_id = args[0];
        local to_id = args[1];
        if (!isPlayerSpawned(from_id) || !isPlayerSpawned(to_id)) {
            SendSystemMessage(pid, "Nie mo¿esz teleportowaæ niepod³¹czonych lub niespawnionych graczy!", {r=255,g=0,b=0});
            return;
        }

        if (from_id == to_id) {
            SendSystemMessage(pid, "Nie mo¿esz teleportowaæ tego samego gracza!", {r=255,g=0,b=0});
            return;
        }

        local world = getPlayerWorld(to_id);
        if (world != getPlayerWorld(from_id))
            setPlayerWorld(from_id, world);
        local pos = getPlayerPosition(to_id);
        setPlayerPosition(from_id, pos.x, pos.y, pos.z);

        SendSystemMessage(pid, format("Teleportowano %s do %s", getPlayerName(from_id), getPlayerName(to_id)), {r=0,g=255,b=0});
        SendSystemMessage(from_id, format("Zosta³eœ teleportowany do %s przez %s", getPlayerName(to_id), getPlayerName(pid)), {r=0,g=255,b=0});
        SendSystemMessage(to_id, format("Do ciebie zosta³ teleportowany %s przez %s", getPlayerName(from_id), getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_tpall(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("d", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /tpall to_id", {r=255,g=0,b=0});
            return;
        }

        local to_id = args[0];
        if (!isPlayerSpawned(to_id)) {
            SendSystemMessage(pid, "Nie mo¿esz teleportowaæ do niepod³¹czonego lub niespawnionego gracza!", {r=255,g=0,b=0});
            return;
        }

        local world = getPlayerWorld(to_id);
        local pos = getPlayerPosition(to_id);
        local message = format("Zosta³eœ teleportowany do %s przez %s", getPlayerName(to_id), getPlayerName(pid));
        for (local i = 0; i < getMaxSlots(); ++i) {
            if (isPlayerConnected(i) && isPlayerSpawned(i)) {
                if (world != getPlayerWorld(i))
                    setPlayerWorld(i, world);
                SendSystemMessage(i, message, {r=0,g=255,b=0});
                setPlayerPosition(i, pos.x, pos.y, pos.z);
            }
        }

        SendSystemMessage(pid, format("Teleportowano wszystkich graczy do %s", getPlayerName(to_id)), {r=0,g=255,b=0});
    }
}

local function cmd_giveitem(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dsd", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /giveitem id instancja iloœæ", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local instance = args[1];
        local amount = args[2];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie mo¿esz daæ przedmiotu niepod³¹czonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (amount < 1) amount = 1;
        giveItem(id, instance, amount);
        SendSystemMessage(pid, format("Da³eœ przedmiot %s w iloœci: %d graczowi %s", instance, amount, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Otrzyma³eœ przedmiot %s w iloœci: %d od %s", instance, amount, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_str(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /str id wartoœæ", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local value = args[1];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie mo¿esz daæ si³y niepod³¹czonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (value < 0) value = 0;
        setPlayerStrength(id, value);
        SendSystemMessage(pid, format("Zmieni³eœ si³ê gracza %s na %d", getPlayerName(id), value), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja si³a zosta³a zmieniona na %d przez %s", value, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_dex(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /dex id wartoœæ", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local value = args[1];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie mo¿esz daæ zrêcznoœci niepod³¹czonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (value < 0) value = 0;
        setPlayerDexterity(id, value);
        SendSystemMessage(pid, format("Zmieni³eœ zrêcznoœæ gracza %s na %d", getPlayerName(id), value), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja zrêcznoœæ zosta³a zmieniona na %d przez %s", value, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_awans(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("ddd", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /admin_awans <id frakcji> <id klasy> <id gracza>", {r=255,g=0,b=0});
            return;
        }

        local id = args[2];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie mo¿esz daæ klasy niepod³¹czonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        local fraction_id = args[0];
        if(!Fraction.rawin(fraction_id)) {
            SendSystemMessage(pid, "Nie ma frakcji o podanym ID.", {r=255,g=0,b=0});
            foreach(_key, _fraction in Fraction)
                SendSystemMessage(pid, _key+" - "+_fraction.name, {r=255,g=0,b=0});
            return;
        }

        local fraction = Fraction[fraction_id];
        local class_id = args[1];
        if(!fraction.classes.rawin(class_id)) {
            SendSystemMessage(pid, "Nie ma klasy we frakcji o podanym ID.", {r=255,g=0,b=0});
            foreach(_key, _class in fraction.classes)
                SendSystemMessage(pid, _key+" - "+_class.name, {r=255,g=0,b=0});
            return;
        }

        setClassPlayer(id, fraction_id, class_id);
        SendSystemMessage(pid, format("Da³eœ klasê %s graczowi %s", fraction.classes[class_id].name, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Otrzyma³eœ klasê %s od %s", fraction.classes[class_id].name, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_heal(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local basicArgs = sscanf("d", params);
        if (!basicArgs) {
            SendSystemMessage(pid, "U¿ycie: /heal id [wartoœæ]", {r=255,g=0,b=0});
            return;
        }

        local id = basicArgs[0];

        local fullArgs = sscanf("dd", params);
        local value = (fullArgs && fullArgs.len() > 1) ? fullArgs[1] : null;
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie mo¿esz leczyæ niepod³¹czonego lub niespawnionego gracza!", {r=255,g=0,b=0});
            return;
        }

        if (value == null || value <= 0) {
            setPlayerHealth(id, getPlayerMaxHealth(id));
        } else {
            setPlayerHealth(id, value);
        }

        SendSystemMessage(pid, format("Uleczy³eœ gracza %s", getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Zosta³eœ uleczony przez %s", getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_mana(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local basicArgs = sscanf("d", params);
        if (!basicArgs) {
            SendSystemMessage(pid, "U¿ycie: /mana id [wartoœæ]", {r=255,g=0,b=0});
            return;
        }

        local id = basicArgs[0];

        local fullArgs = sscanf("dd", params);
        local value = (fullArgs && fullArgs.len() > 1) ? fullArgs[1] : null;
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie mo¿esz uzupe³niæ many niepod³¹czonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (value == null || value <= 0) {
            setPlayerMana(id, getPlayerMaxMana(id));
        } else {
            setPlayerMana(id, value);
        }

        SendSystemMessage(pid, format("Zmieni³eœ manê graczowi %s", getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja mana zosta³a zmieniona przez %s", getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_instance(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("ds", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /instance id instancja (przyk³ad WILK)", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie mo¿esz zmieniæ instancji temu graczowi!", {r=255,g=0,b=0});
            return;
        }

        setPlayerInstance(id, args[1]);
        SendSystemMessage(pid, format("Zmieni³eœ instancjê gracza %s na %s", getPlayerName(id), args[1]), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja instancja zosta³a zmieniona na %s przez %s", args[1], getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_kill(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("d", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /kill <id>", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie mo¿esz zabiæ niepod³¹czonego lub niespawnionego gracza!", {r=255,g=0,b=0});
            return;
        }

        setPlayerHealth(id, 0);
        SendSystemMessage(id, "Zosta³eœ zabity przez "+getPlayerName(pid), {r=255,g=0,b=0});
        SendSystemMessage(pid, "Zabi³eœ gracza "+getPlayerName(id), {r=255,g=0,b=0});
    }
}

local function cmd_time(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /time godzina minuta", {r=255,g=0,b=0});
            return;
        }

        local hour = args[0];
        local min = args[1];
        if (hour > 23) hour = 23;
        else if (hour < 0) hour = 0;
        if (min > 59) min = 59;
        else if (min < 0) min = 0;

        setTime(hour, min);
        SendSystemMessage(null, format("%s zmieni³ czas na %02d:%02d", getPlayerName(pid), hour, min), {r=0,g=255,b=0});
    }
}

function cmd_report(pid, params){
    local args = sscanf("ds", params)
    if(!args){
        SendSystemMessage(pid, "U¿yj: /report <id> <tekst>", {r=0,g=255,b=0});
        return;
    };
    if(!isPlayerConnected(args[0])){
        SendSystemMessage(pid, "Nie ma osoby o tym ID", {r=0,g=255,b=0});
        return;
    };
    for(local i = 0; i < getMaxSlots(); i++ ){
        if(isPlayerConnected(i)){
            if(Player[i].rank >= LEVEL.MOD)
                SendSystemMessage(i, "Zg³oszenie od: "+getPlayerName(pid) + "(( "+pid+" )) na "+getPlayerName(args[0])+" (( "+args[0]+" )) powód: "+args[1], {r=250,g=230,b=0});
        };
    };
    SendSystemMessage(pid, "Zg³oszenie wys³ane pomyœlnie!", {r=0,g=255,b=0});
};

function cmd_invisible(pid, params){
    if(checkPermission(pid, LEVEL.MOD)){
        if(getPlayerInvisible(pid)){
            setPlayerInvisible(pid, false);
            SendSystemMessage(pid, "Niewidzialnoœæ wy³¹czona", {r=250,g=0,b=0});
        }
        else{
            setPlayerInvisible(pid, true);
            SendSystemMessage(pid, "Niewidzialnoœæ w³¹czona", {r=250,g=0,b=0});
        }
    }
}

local function cmd_setweaponskill(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("ddd", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /setweaponskill id skillId procenty", {r=255,g=0,b=0});
            SendSystemMessage(pid, "SkillId: 0=1H, 1=2H, 2=BOW, 3=CBOW", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local skillId = args[1];
        local percentage = args[2];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie mo¿esz ustawiæ umiejêtnoœci broni niepod³¹czonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (percentage < 0) percentage = 0;
        if (percentage > 100) percentage = 100;

        setPlayerSkillWeapon(id, skillId, percentage);
        SendSystemMessage(pid, format("Ustawi³eœ umiejêtnoœæ broni %d na %d%% dla %s", skillId, percentage, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja umiejêtnoœæ broni %d zosta³a ustawiona na %d%% przez %s", skillId, percentage, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_setmaxmana(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /setmaxmana id maxMana", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local maxMana = args[1];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie mo¿esz ustawiæ maksymalnej many niepod³¹czonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (maxMana < 0) maxMana = 0;

        setPlayerMaxMana(id, maxMana);
        SendSystemMessage(pid, format("Ustawi³eœ maksymaln¹ manê na %d dla %s", maxMana, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja maksymalna mana zosta³a ustawiona na %d przez %s", maxMana, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_setmaxhp(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /setmaxhp id maxHP", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local maxHP = args[1];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie mo¿esz ustawiæ maksymalnego HP niepod³¹czonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (maxHP < 0) maxHP = 0;

        setPlayerMaxHealth(id, maxHP);
        SendSystemMessage(pid, format("Ustawi³eœ maksymalne HP na %d dla %s", maxHP, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoje maksymalne HP zosta³o ustawione na %d przez %s", maxHP, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_removeitem(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dsd", params);
        if (!args) {
            SendSystemMessage(pid, "U¿ycie: /removeitem id instancja iloœæ", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local instance = args[1];
        local amount = args[2];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie mo¿esz zabraæ przedmiotu niepod³¹czonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (amount < 1) amount = 1;

        removeItem(id, instance, amount);
        SendSystemMessage(pid, format("Zabra³eœ przedmiot %s w iloœci: %d graczowi %s", instance, amount, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Zabrano ci przedmiot %s w iloœci: %d przez %s", instance, amount, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

// Synchronizuj godmode gdy gracz siê respawnuje
local function onPlayerSpawn(pid) {
    if (Player[pid].rank >= LEVEL.ADMIN && Player[pid].godmode) {
        syncGodModeWithClient(pid, true);
    }
}

local function playerDisconnect(pid, reason) {
    Player[pid].rank = 0;
    Player[pid].godmode = false;
    Player[pid].safeFromBots = false;
}


addEventHandler("onPlayerDisconnect", playerDisconnect);
addEventHandler("onPlayerDamage", onPlayerDamage);
addEventHandler("onPlayerSpawn", onPlayerSpawn);

local function cmdHandler(pid, cmd, params) {
    switch (cmd) {
    case "acp":
        cmd_acp(pid, params);
        break;
    case "login":
        cmd_login(pid, params);
        break;
    case "color":
        cmd_color(pid, params);
        break;
    case "name":
        cmd_name(pid, params);
        break;
    case "kick":
        cmd_kick(pid, params);
        break;
    case "ban":
        cmd_ban(pid, params);
        break;
    case "tp":
        cmd_tp(pid, params);
        break;
    case "tpall":
        cmd_tpall(pid, params);
        break;
    case "giveitem":
        cmd_giveitem(pid, params);
        break;
    case "removeitem":
        cmd_removeitem(pid, params);
        break;
    case "str":
        cmd_str(pid, params);
        break;
    case "dex":
        cmd_dex(pid, params);
        break;
    case "instance":
        cmd_instance(pid, params);
        break;
    case "heal":
        cmd_heal(pid, params);
        break;
    case "mana":
        cmd_mana(pid, params);
        break;
    case "kill":
        cmd_kill(pid, params);
        break;
    case "time":
        cmd_time(pid, params);
        break;
    case "pos":
        cmd_pos(pid, params);
        break;
    case "ros":
        cmd_ros(pid, params);
        break;
	case "mos":
        cmd_mos(pid, params);
        break;
    case "admin_awans":
        cmd_awans(pid, params);
        break;
    case "report":
        cmd_report(pid, params);
        break;
    case "invisible":
        cmd_invisible(pid, params);
        break;
    case "godmode":
        cmd_godmode(pid, params);
        break;
	case "botimmunity":
        cmd_botimmunity(pid, params);
        break;
    case "setweaponskill":
        cmd_setweaponskill(pid, params);
        break;
    case "setmaxmana":
        cmd_setmaxmana(pid, params);
        break;
    case "setmaxhp":
        cmd_setmaxhp(pid, params);
        break;
	case "follow":
        cmd_follow(pid, params);
        break;
    case "stopfollow":
        cmd_stopfollow(pid, params);
        break;
    }
}

addEventHandler("onPlayerCommand", cmdHandler);