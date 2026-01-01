
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
    SendSystemMessage(pid, "Nie masz uprawnień do użycia tej komendy!", {r=255,g=0,b=0});
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
    SendSystemMessage(pid, "/login - Zaloguj się na swoje konto admina/moda na podstawie UID.", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/color id r g b - Zmień kolor gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/name id nickname - Zmień pseudonim gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/kick id powód - Wyrzuć gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/pos nazwa - Zapisz pozycję do pliku", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/ros - Zapisz pozycję ziela do pliku", {r=0,g=255,b=0});
	SendSystemMessage(pid, "/mos - Zapisz pozycję moba do pliku", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/ban id minuty powód - Zbanuj gracza (minuty = 0 = na zawsze)", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/tp from_id to_id - Teleportuj gracza do innego gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/tpall to_id - Teleportuj wszystkich graczy do gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/giveitem id instancja ilość - Daj przedmiot graczowi", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/removeitem id instancja ilość - Zabierz przedmiot graczowi", {r=0,g=255,b=0});
	SendSystemMessage(pid, "/setlp id wartość - Ustaw LP gracza", {r=0,g=255,b=0});
	SendSystemMessage(pid, "/addlp id wartość - Dodaj LP graczowi", {r=0,g=255,b=0});
	SendSystemMessage(pid, "/getlp id - Sprawdź LP gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/str id wartość - Ustaw siłę gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/dex id wartość - Ustaw zręczność gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/heal id - Ulecz gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/mana id - Uzupełnij manę gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/setmaxhp id maxHP - Ustaw maksymalne HP gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/setmaxmana id maxMana - Ustaw maksymalną manę gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/setweaponskill id skillId procenty - Ustaw umiejętność broni (0=1H,1=2H,2=BOW,3=CBOW)", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/time godzina minuta - Ustaw czas serwera", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/kill id - Zabij gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/instance id instancja - Zmień instancję gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/admin_awans idFrakcji idKlasy idGracza - Awansuj gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/report id powód - Zgłoś gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/invisible - Przełącz niewidzialność", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/godmode - Włącz/wyłącz tryb nieunicestwialny", {r=0,g=255,b=0});
	SendSystemMessage(pid, "/botimmunity - Włącz/wyłącz immunitet na ataki botów", {r=0,g=255,b=0});
}

local function cmd_login(pid, params) {
    local playerUID = getPlayerUID(pid);
    if (!playerUID) {
        SendSystemMessage(pid, "Nie udało się pobrać twojego unikalnego ID (UID).", {r=255,g=0,b=0});
        return;
    }

    try {
        local account = Admins_account.findOne(@(q) q.where("uid", "=", playerUID));
        if (account) {
            if (account.rank >= LEVEL.MOD) {
                Player[pid].rank = account.rank;
                local rankName = (account.rank == LEVEL.ADMIN) ? "Administratora" : "Moderatora";
                SendSystemMessage(pid, "Zalogowano pomyślnie jako " + rankName + ".", {r=255,g=255,b=0});
                if (account.rank == LEVEL.ADMIN)
                    setPlayerColor(pid, CFG.AdminColor.r, CFG.AdminColor.g, CFG.AdminColor.b);
                else if (account.rank == LEVEL.MOD)
                    setPlayerColor(pid, CFG.ModColor.r, CFG.ModColor.g, CFG.ModColor.b);
                syncAdminData(pid);
            } else {
                SendSystemMessage(pid, "Twoje konto nie ma wystarczających uprawnień.", {r=255,g=0,b=0});
            }
        } else {
            SendSystemMessage(pid, "Twoje konto nie zostało znalezione w systemie administracji.", {r=255,g=0,b=0});
        }
    } catch (e) {
        SendSystemMessage(pid, "Wystąpił błąd bazy danych podczas logowania. Skontaktuj się z właścicielem serwera.", {r=255,g=0,b=0});
        serverLog("ACP Błąd Logowania dla " + getPlayerName(pid) + " (UID: " + playerUID + "): " + e);
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
            SendSystemMessage(pid, "Gracz o ID " + targetId + " nie jest podłączony!", {r=255,g=0,b=0});
            return;
        }
        targetName = getPlayerName(targetId);
    }

    local targetData = getPlayerData(targetId);
    if (!targetData) {
        SendSystemMessage(pid, "Błąd: Nie można pobrać danych gracza!", {r=255,g=0,b=0});
        return;
    }

    targetData.godmode = !targetData.godmode;

    if (targetData.godmode) {
        SendSystemMessage(pid, "GodMode WŁĄCZONY dla " + targetName + "!", {r=0,g=255,b=0});
        if (targetId != pid) {
            SendSystemMessage(targetId, "GodMode WŁĄCZONY! Jesteś teraz nietykalny.", {r=0,g=255,b=0});
        }
    } else {
        SendSystemMessage(pid, "GodMode WYŁĄCZONY dla " + targetName + "!", {r=255,g=0,b=0});
        if (targetId != pid) {
            SendSystemMessage(targetId, "GodMode WYŁĄCZONY! Możesz teraz otrzymywać obrażenia.", {r=255,g=0,b=0});
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
        SendSystemMessage(pid, "Użycie: /botimmunity id_gracza", {r=255,g=0,b=0});
        return;
    }

    local targetId = args[0];
    local targetData = getPlayerData(targetId);
    
    if (!targetData || !isPlayerConnected(targetId)) {
        SendSystemMessage(pid, "Gracz o ID " + targetId + " nie jest podłączony!", {r=255,g=0,b=0});
        return;
    }

    targetData.safeFromBots = !targetData.safeFromBots;

    if (targetData.safeFromBots) {
        SendSystemMessage(pid, "Immunitet na boty WŁĄCZONY dla " + getPlayerName(targetId) + "!", {r=0,g=255,b=0});
        SendSystemMessage(targetId, "Administrator włączył ci immunitet na boty! Agresywne boty nie będą cię atakować.", {r=0,g=255,b=0});
    } else {
        SendSystemMessage(pid, "Immunitet na boty WYŁĄCZONY dla " + getPlayerName(targetId) + "!", {r=255,g=0,b=0});
        SendSystemMessage(targetId, "Administrator wyłączył ci immunitet na boty! Boty mogą cię teraz atakować.", {r=255,g=0,b=0});
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
        SendSystemMessage(pid, "Użycie: /follow id_bota id_gracza", {r=255,g=0,b=0});
        SendSystemMessage(pid, "Przykład: /follow 37 0 - bot o ID 37 będzie podążał za graczem o ID 0", {r=255,g=0,b=0});
        return;
    }

    local botId = args[0];
    local targetId = args[1];
    
    if (!isPlayerConnected(botId) || !isNpc(botId)) {
        SendSystemMessage(pid, "ID " + botId + " nie jest poprawnym botem (NPC)!", {r=255,g=0,b=0});
        return;
    }

    if (!isPlayerConnected(targetId)) {
        SendSystemMessage(pid, "Gracz o ID " + targetId + " nie jest podłączony!", {r=255,g=0,b=0});
        return;
    }

    if (botId == targetId) {
        SendSystemMessage(pid, "Bot nie może podążać za samym sobą!", {r=255,g=0,b=0});
        return;
    }

    local npc_state = AI_GetNPCState(botId);
    if (!npc_state) {
        SendSystemMessage(pid, "Błąd: Nie znaleziono AI dla bota o ID " + botId + "!", {r=255,g=0,b=0});
        return;
    }

    if (npc_state.follow_mode && npc_state.follow_target == targetId) {
        SendSystemMessage(pid, "Bot " + getPlayerName(botId) + " już podąża za " + getPlayerName(targetId), {r=255,g=255,b=0});
        return;
    }

    npc_state.follow_mode = true;
    npc_state.follow_target = targetId;
    npc_state.last_follow_check = 0;

    SendSystemMessage(pid, "Bot " + getPlayerName(botId) + " zaczyna podążać za " + getPlayerName(targetId), {r=0,g=255,b=0});
    
    SendSystemMessage(targetId, "Bot " + getPlayerName(botId) + " zaczyna za tobą podążać!", {r=255,g=255,b=0});
}





local function cmd_stopfollow(pid, params) {
    if (!checkPermission(pid, LEVEL.ADMIN)) return;

    local args = sscanf("d", params);
    if (!args) {
        SendSystemMessage(pid, "Użycie: /stopfollow id_bota", {r=255,g=0,b=0});
        return;
    }

    local botId = args[0];
    
    if (!isPlayerConnected(botId) || !isNpc(botId)) {
        SendSystemMessage(pid, "ID " + botId + " nie jest poprawnym botem (NPC)!", {r=255,g=0,b=0});
        return;
    }

    local npc_state = AI_GetNPCState(botId);
    if (!npc_state) {
        SendSystemMessage(pid, "Błąd: Nie znaleziono AI dla bota o ID " + botId + "!", {r=255,g=0,b=0});
        return;
    }
    
    if (!npc_state.follow_mode) {
        SendSystemMessage(pid, "Bot " + getPlayerName(botId) + " nie podąża za nikim!", {r=255,g=0,b=0});
        return;
    }

    local oldTarget = npc_state.follow_target;
    
    if ("StopFollowing" in npc_state) {
        npc_state.StopFollowing();
    } else {
        npc_state.follow_mode = false;
        npc_state.follow_target = -1;
        npc_state.last_follow_check = 0;
        playAni(npc_state.id, "S_STAND");
    }

    SendSystemMessage(pid, "Bot " + getPlayerName(botId) + " przestał podążać", {r=255,g=0,b=0});
    
    if (oldTarget != -1 && isPlayerConnected(oldTarget)) {
        SendSystemMessage(oldTarget, "Bot " + getPlayerName(botId) + " przestał za tobą podążać", {r=255,g=255,b=0});
    }
}






/*################ BOT FOLLOW ###############*/













local function cmd_pos(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;

    local args = sscanf("s", params);
    if (!args) {
        SendSystemMessage(pid, "Użycie: /pos nazwa", {r=255,g=0,b=0});
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
        SendSystemMessage(pid, "Użycie: /mos instancja_moba", {r=255,g=0,b=0});
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
        SendSystemMessage(pid, "Użycie: /color id r g b", {r=255,g=0,b=0});
        return;
    }

    local id = args[0];
    local r = args[1];
    local g = args[2];
    local b = args[3];

    if (!isPlayerConnected(id)) {
        SendSystemMessage(pid, "Nie możesz zmienić koloru niepodłączonemu graczowi!", {r=255,g=0,b=0});
        return;
    }

    setPlayerColor(id, r, g, b);

    SendSystemMessage(pid, format("Zmieniłeś kolor gracza %s na %d, %d, %d", getPlayerName(id), r, g, b), {r=r,g=g,b=b});
    SendSystemMessage(id, format("Twój kolor został zmieniony na %d, %d, %d przez %s", r, g, b, getPlayerName(pid)), {r=r,g=g,b=b});
}

local function cmd_name(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;

    local args = sscanf("ds", params);
    if (!args) {
        SendSystemMessage(pid, "Użycie: /name id pseudonim", {r=255,g=0,b=0});
        return;
    }

    local id = args[0];
    local name = args[1];
    if (!isPlayerConnected(id)) {
        SendSystemMessage(pid, "Nie możesz zmienić pseudonimu niepodłączonemu graczowi!", {r=255,g=0,b=0});
        return;
    }

    setPlayerName(id, name);

    SendSystemMessage(pid, format("Zmieniłeś pseudonim gracza %s na %s", getPlayerName(id), name), {r=0,g=255,b=0});
    SendSystemMessage(id, format("Twój pseudonim został zmieniony na %s przez %s", name, getPlayerName(pid)), {r=0,g=255,b=0});
}

local function cmd_kick(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("ds", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /kick id powód", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local reason = args[1];
        if (!isPlayerConnected(id)) {
            SendSystemMessage(pid, "Nie możesz wyrzucić niepodłączonego gracza!", {r=255,g=0,b=0});
            return;
        }

        kick(id, reason);

        SendSystemMessage(null, format("%s został wyrzucony przez %s", getPlayerName(id), getPlayerName(pid)), {r=255,g=80,b=0});
        SendSystemMessage(null, format("Powód: %s", reason), {r=255,g=80,b=0});
    }
}

local function cmd_ban(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dds", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /ban id minuty powód", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local minutes = args[1];
        local reason = args[2];

        if (!isPlayerConnected(id)) {
            SendSystemMessage(pid, "Nie możesz zbanować niepodłączonego gracza!", {r=255,g=0,b=0});
            return;
        }

        ban(id, minutes, reason);
        if (minutes > 0) SendSystemMessage(null, format("%s został zbanowany na %d minut przez %s", getPlayerName(id), minutes, getPlayerName(pid)), {r=255,g=0,b=0});
        else SendSystemMessage(null, format("%s został ZBANOWANY NA ZAWSZE przez %s", getPlayerName(id), getPlayerName(pid)), {r=255,g=0,b=0});
        SendSystemMessage(null, format("Powód: %s", reason), {r=255,g=0,b=0});
    }
}

local function cmd_tp(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /tp from_id to_id", {r=255,g=0,b=0});
            return;
        }

        local from_id = args[0];
        local to_id = args[1];
        if (!isPlayerSpawned(from_id) || !isPlayerSpawned(to_id)) {
            SendSystemMessage(pid, "Nie możesz teleportować niepodłączonych lub niespawnionych graczy!", {r=255,g=0,b=0});
            return;
        }

        if (from_id == to_id) {
            SendSystemMessage(pid, "Nie możesz teleportować tego samego gracza!", {r=255,g=0,b=0});
            return;
        }

        local world = getPlayerWorld(to_id);
        if (world != getPlayerWorld(from_id))
            setPlayerWorld(from_id, world);
        local pos = getPlayerPosition(to_id);
        setPlayerPosition(from_id, pos.x, pos.y, pos.z);

        SendSystemMessage(pid, format("Teleportowano %s do %s", getPlayerName(from_id), getPlayerName(to_id)), {r=0,g=255,b=0});
        SendSystemMessage(from_id, format("Zostałeś teleportowany do %s przez %s", getPlayerName(to_id), getPlayerName(pid)), {r=0,g=255,b=0});
        SendSystemMessage(to_id, format("Do ciebie został teleportowany %s przez %s", getPlayerName(from_id), getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_tpall(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("d", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /tpall to_id", {r=255,g=0,b=0});
            return;
        }

        local to_id = args[0];
        if (!isPlayerSpawned(to_id)) {
            SendSystemMessage(pid, "Nie możesz teleportować do niepodłączonego lub niespawnionego gracza!", {r=255,g=0,b=0});
            return;
        }

        local world = getPlayerWorld(to_id);
        local pos = getPlayerPosition(to_id);
        local message = format("Zostałeś teleportowany do %s przez %s", getPlayerName(to_id), getPlayerName(pid));
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
            SendSystemMessage(pid, "Użycie: /giveitem id instancja ilość", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local instance = args[1];
        local amount = args[2];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz dać przedmiotu niepodłączonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (amount < 1) amount = 1;
        giveItem(id, instance, amount);
        SendSystemMessage(pid, format("Dałeś przedmiot %s w ilości: %d graczowi %s", instance, amount, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Otrzymałeś przedmiot %s w ilości: %d od %s", instance, amount, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_setck(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /setck id wartość (0 - normal, 1 - CK)", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local ckValue = args[1];
        
        if (ckValue != 0 && ckValue != 1) {
            SendSystemMessage(pid, "Wartość CK musi być 0 (normal) lub 1 (CK)", {r=255,g=0,b=0});
            return;
        }

        if (!isPlayerConnected(id)) {
            SendSystemMessage(pid, "Gracz nie jest online! Użyj /setofflineck dla graczy offline.", {r=255,g=0,b=0});
            return;
        }

        local playerName = getPlayerName(id);
        local account = PlayerAccount.findOne(@(q) q.where("name", "=", playerName));
        
        if (!account) {
            SendSystemMessage(pid, "Gracz nie został znaleziony w bazie danych!", {r=255,g=0,b=0});
            return;
        }

        account.CK = ckValue;
        account.save();

        if (ckValue == 1) {
            kick(id, "Twoja postać zginęła!");
            SendSystemMessage(pid, format("Ustawiono CK = 1 dla gracza %s i wyrzucono z serwera.", playerName), {r=0,g=255,b=0});
        } else {
            SendSystemMessage(pid, format("Ustawiono CK = 0 dla gracza %s. Konto odblokowane.", playerName), {r=0,g=255,b=0});
        }
    }
}

local function cmd_setofflineck(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("sd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /setofflineck 'nick' wartość (0 - normal, 1 - CK)", {r=255,g=0,b=0});
            return;
        }

        local playerName = args[0];
        local ckValue = args[1];
        
        if (ckValue != 0 && ckValue != 1) {
            SendSystemMessage(pid, "Wartość CK musi być 0 (normal) lub 1 (CK)", {r=255,g=0,b=0});
            return;
        }

        local isOnline = false;
        local onlinePlayerId = -1;
        
        for (local i = 0; i < getMaxSlots(); i++) {
            if (isPlayerConnected(i) && getPlayerName(i) == playerName) {
                isOnline = true;
                onlinePlayerId = i;
                break;
            }
        }

        if (isOnline) {
            SendSystemMessage(pid, format("Gracz %s jest online! Użyj /setck %d %d", playerName, onlinePlayerId, ckValue), {r=255,g=0,b=0});
            return;
        }

        local account = PlayerAccount.findOne(@(q) q.where("name", "=", playerName));
        
        if (!account) {
            SendSystemMessage(pid, format("Gracz '%s' nie został znaleziony w bazie danych!", playerName), {r=255,g=0,b=0});
            return;
        }

        account.CK = ckValue;
        account.save();

        if (ckValue == 1) {
            SendSystemMessage(pid, format("Ustawiono CK = 1 dla gracza %s. Gracz nie będzie mógł się zalogować.", playerName), {r=0,g=255,b=0});
        } else {
            SendSystemMessage(pid, format("Ustawiono CK = 0 dla gracza %s. Gracz może się normalnie logować.", playerName), {r=0,g=255,b=0});
        }
    }
}


local function cmd_setlp(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /setlp id wartość", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local value = args[1];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz ustawić punktów nauki niepodłączonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (value < 0) value = 0;
		setPlayerLearningPoints(id, value);
        SendSystemMessage(pid, format("Zmieniłeś punkty nauki gracza %s na %d", getPlayerName(id), value), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoje punkty nauki zostały zmienione na %d przez %s", value, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_getlp(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("d", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /getlp id", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz sprawdzić punktów nauki niepodłączonego lub niespawnionego gracza!", {r=255,g=0,b=0});
            return;
        }

		local value = getPlayerLearningPoints(id);
        SendSystemMessage(pid, format("Punkty nauki gracza %s wynoszą: %d", getPlayerName(id), value), {r=0,g=255,b=0});
    }
}

local function cmd_addlp(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /addlp id wartość", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local value = args[1];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz dać punktów nauki niepodłączonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (value < 0) value = 0;
		addPlayerLearningPoints(id, value);
		local newValue = getPlayerLearningPoints(id);
        SendSystemMessage(pid, format("Dałeś punkty nauki graczowi %s ilość: %d obecna ilość: %d", getPlayerName(id), value, newValue), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Otrzymałeś %d punktów nauki! przez %s, obecna ilość to: %d", value, getPlayerName(pid), newValue), {r=0,g=255,b=0});
    }
}

local function cmd_setproffesion(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("ddd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /setproffesion id typ_id wartość  (TYP ID: 0-Myśliwy, 1-Łuczarz, 2-Kowal, 3-Płatnerz, 4-Alchemik, 5-Kucharz)", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
		local professionType = args[1];
        local value = args[2];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz ustawić profesji niepodłączonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (value < 0) value = 0;
		setPlayerProfessionLevel(id, professionType, value)
        SendSystemMessage(pid, format("Zmieniłeś profesje %d gracza %s na %d", professionType, getPlayerName(id), value), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja profesja %d została zmieniona na %d przez %s", professionType, value, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_getproffesion(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /getproffesion id typ (0-Myśliwy, 1-Łuczarz, 2-Kowal, 3-Płatnerz, 4-Alchemik, 5-Kucharz)", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
		local professionType = args[1];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz sprawdzić profesji niepodłączonego lub niespawnionego gracza!", {r=255,g=0,b=0});
            return;
        }

		local value = getPlayerProfessionLevel(id, professionType)
        SendSystemMessage(pid, format("Profesja gracza %s wynosi: %d", getPlayerName(id), value), {r=0,g=255,b=0});
    }
}


local function cmd_str(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /str id wartość", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local value = args[1];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz dać siły niepodłączonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (value < 0) value = 0;
        setPlayerStrength(id, value);
        SendSystemMessage(pid, format("Zmieniłeś siłę gracza %s na %d", getPlayerName(id), value), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja siła została zmieniona na %d przez %s", value, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_dex(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /dex id wartość", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local value = args[1];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz dać zręczności niepodłączonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (value < 0) value = 0;
        setPlayerDexterity(id, value);
        SendSystemMessage(pid, format("Zmieniłeś zręczność gracza %s na %d", getPlayerName(id), value), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja zręczność została zmieniona na %d przez %s", value, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_awans(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("ddd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /admin_awans <id frakcji> <id klasy> <id gracza>", {r=255,g=0,b=0});
            return;
        }

        local id = args[2];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz dać klasy niepodłączonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
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
        SendSystemMessage(pid, format("Dałeś klasę %s graczowi %s", fraction.classes[class_id].name, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Otrzymałeś klasę %s od %s", fraction.classes[class_id].name, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_heal(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local basicArgs = sscanf("d", params);
        if (!basicArgs) {
            SendSystemMessage(pid, "Użycie: /heal id [wartość]", {r=255,g=0,b=0});
            return;
        }

        local id = basicArgs[0];

        local fullArgs = sscanf("dd", params);
        local value = (fullArgs && fullArgs.len() > 1) ? fullArgs[1] : null;
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz leczyć niepodłączonego lub niespawnionego gracza!", {r=255,g=0,b=0});
            return;
        }

        if (value == null || value <= 0) {
            setPlayerHealth(id, getPlayerMaxHealth(id));
        } else {
            setPlayerHealth(id, value);
        }

        SendSystemMessage(pid, format("Uleczyłeś gracza %s", getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Zostałeś uleczony przez %s", getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_mana(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local basicArgs = sscanf("d", params);
        if (!basicArgs) {
            SendSystemMessage(pid, "Użycie: /mana id [wartość]", {r=255,g=0,b=0});
            return;
        }

        local id = basicArgs[0];

        local fullArgs = sscanf("dd", params);
        local value = (fullArgs && fullArgs.len() > 1) ? fullArgs[1] : null;
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz uzupełnić many niepodłączonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (value == null || value <= 0) {
            setPlayerMana(id, getPlayerMaxMana(id));
        } else {
            setPlayerMana(id, value);
        }

        SendSystemMessage(pid, format("Zmieniłeś manę graczowi %s", getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja mana została zmieniona przez %s", getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_instance(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("ds", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /instance id instancja (przykład WILK)", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz zmienić instancji temu graczowi!", {r=255,g=0,b=0});
            return;
        }

        setPlayerInstance(id, args[1]);
        SendSystemMessage(pid, format("Zmieniłeś instancję gracza %s na %s", getPlayerName(id), args[1]), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja instancja została zmieniona na %s przez %s", args[1], getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_kill(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("d", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /kill <id>", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz zabić niepodłączonego lub niespawnionego gracza!", {r=255,g=0,b=0});
            return;
        }

        setPlayerHealth(id, 0);
        SendSystemMessage(id, "Zostałeś zabity przez "+getPlayerName(pid), {r=255,g=0,b=0});
        SendSystemMessage(pid, "Zabiłeś gracza "+getPlayerName(id), {r=255,g=0,b=0});
    }
}

local function cmd_time(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /time godzina minuta", {r=255,g=0,b=0});
            return;
        }

        local hour = args[0];
        local min = args[1];
        if (hour > 23) hour = 23;
        else if (hour < 0) hour = 0;
        if (min > 59) min = 59;
        else if (min < 0) min = 0;

        setTime(hour, min);
        SendSystemMessage(null, format("%s zmienił czas na %02d:%02d", getPlayerName(pid), hour, min), {r=0,g=255,b=0});
    }
}

function cmd_report(pid, params){
    local args = sscanf("ds", params)
    if(!args){
        SendSystemMessage(pid, "Użyj: /report <id> <tekst>", {r=0,g=255,b=0});
        return;
    };
    if(!isPlayerConnected(args[0])){
        SendSystemMessage(pid, "Nie ma osoby o tym ID", {r=0,g=255,b=0});
        return;
    };
    for(local i = 0; i < getMaxSlots(); i++ ){
        if(isPlayerConnected(i)){
            if(Player[i].rank >= LEVEL.MOD)
                SendSystemMessage(i, "Zgłoszenie od: "+getPlayerName(pid) + "(( "+pid+" )) na "+getPlayerName(args[0])+" (( "+args[0]+" )) powód: "+args[1], {r=250,g=230,b=0});
        };
    };
    SendSystemMessage(pid, "Zgłoszenie wysłane pomyślnie!", {r=0,g=255,b=0});
};

function cmd_invisible(pid, params){
    if(checkPermission(pid, LEVEL.MOD)){
        if(getPlayerInvisible(pid)){
            setPlayerInvisible(pid, false);
            SendSystemMessage(pid, "Niewidzialność wyłączona", {r=250,g=0,b=0});
        }
        else{
            setPlayerInvisible(pid, true);
            SendSystemMessage(pid, "Niewidzialność włączona", {r=250,g=0,b=0});
        }
    }
}

local function cmd_setweaponskill(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("ddd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /setweaponskill id skillId procenty", {r=255,g=0,b=0});
            SendSystemMessage(pid, "SkillId: 0=1H, 1=2H, 2=BOW, 3=CBOW", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local skillId = args[1];
        local percentage = args[2];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz ustawić umiejętności broni niepodłączonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (percentage < 0) percentage = 0;
        if (percentage > 100) percentage = 100;

        setPlayerSkillWeapon(id, skillId, percentage);
        SendSystemMessage(pid, format("Ustawiłeś umiejętność broni %d na %d%% dla %s", skillId, percentage, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja umiejętność broni %d została ustawiona na %d%% przez %s", skillId, percentage, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_setmaxmana(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /setmaxmana id maxMana", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local maxMana = args[1];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz ustawić maksymalnej many niepodłączonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (maxMana < 0) maxMana = 0;

        setPlayerMaxMana(id, maxMana);
        SendSystemMessage(pid, format("Ustawiłeś maksymalną manę na %d dla %s", maxMana, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoja maksymalna mana została ustawiona na %d przez %s", maxMana, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_setmaxhp(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /setmaxhp id maxHP", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local maxHP = args[1];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz ustawić maksymalnego HP niepodłączonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (maxHP < 0) maxHP = 0;

        setPlayerMaxHealth(id, maxHP);
        SendSystemMessage(pid, format("Ustawiłeś maksymalne HP na %d dla %s", maxHP, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Twoje maksymalne HP zostało ustawione na %d przez %s", maxHP, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_removeitem(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dsd", params);
        if (!args) {
            SendSystemMessage(pid, "Użycie: /removeitem id instancja ilość", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local instance = args[1];
        local amount = args[2];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "Nie możesz zabrać przedmiotu niepodłączonemu lub niespawnionemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (amount < 1) amount = 1;

        removeItem(id, instance, amount);
        SendSystemMessage(pid, format("Zabrałeś przedmiot %s w ilości: %d graczowi %s", instance, amount, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Zabrano ci przedmiot %s w ilości: %d przez %s", instance, amount, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

// Synchronizuj godmode gdy gracz się respawnuje
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
	case "setlp":
        cmd_setlp(pid, params);
        break;	
	case "getlp":
        cmd_getlp(pid, params);
        break;	
	case "addlp":
        cmd_addlp(pid, params);
        break;
	case "setproffesion":
        cmd_setproffesion(pid, params);
        break;	
	case "getproffesion":
        cmd_getproffesion(pid, params);
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
	case "setck":
        cmd_setck(pid, params);
        break;
	case "setofflineck":
        cmd_setofflineck(pid, params);
        break;
    }
}

addEventHandler("onPlayerCommand", cmdHandler);