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

for (local i = 0; i < getMaxSlots(); ++i)
    Player.push({rank = 0});

function checkPermission(pid, level) {
    if (Player[pid].rank >= level)
        return true;

    SendSystemMessage(pid, "Nie masz uprawnień do użycia tej komendy!", {r=255,g=0,b=0});
    return false;
}

local function cmd_acp(pid, params) {
    SendSystemMessage(pid, "-=========== ACP (Panel Administracji) ===========-", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/login - Zaloguj się na swoje konto admina/moda na podstawie UID.", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/color id r g b - Zmień kolor gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/name id nickname - Zmień pseudonim gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/kick id powód - Wyrzuć gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/pos nazwa - Zapisz pozycję do pliku", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/ros - Zapisz pozycję ziela do pliku", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/ban id minuty powód - Zbanuj gracza (minuty = 0 = na zawsze)", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/tp from_id to_id - Teleportuj gracza do innego gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/tpall to_id - Teleportuj wszystkich graczy do gracza", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/giveitem id instancja ilość - Daj przedmiot graczowi", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/removeitem id instancja ilość - Zabierz przedmiot graczowi", {r=0,g=255,b=0});
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
        SendSystemMessage(pid, "Nie możesz zmienić koloru niepołączonemu graczowi!", {r=255,g=0,b=0});
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
        SendSystemMessage(pid, "Nie możesz zmienić pseudonimu niepołączonemu graczowi!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz wyrzucić niepołączonego gracza!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz zbanować niepołączonego gracza!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz teleportować niepołączonych lub niespawniętych graczy!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz teleportować do niepołączonego lub niespawniętego gracza!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz dać przedmiotu niepołączonemu lub niespawniętemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (amount < 1) amount = 1;
        giveItem(id, instance, amount);

        SendSystemMessage(pid, format("Dałeś przedmiot %s w ilości: %d graczowi %s", instance, amount, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Otrzymałeś przedmiot %s w ilości: %d od %s", instance, amount, getPlayerName(pid)), {r=0,g=255,b=0});
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
            SendSystemMessage(pid, "Nie możesz dać siły niepołączonemu lub niespawniętemu graczowi!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz dać zręczności niepołączonemu lub niespawniętemu graczowi!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz dać klasy niepołączonemu lub niespawniętemu graczowi!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz leczyć niepołączonego lub niespawniętego gracza!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz uzupełnić many niepołączonemu lub niespawniętemu graczowi!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz zabić niepołączonego lub niespawniętego gracza!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz ustawić umiejętności broni niepołączonemu lub niespawniętemu graczowi!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz ustawić maksymalnej many niepołączonemu lub niespawniętemu graczowi!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz ustawić maksymalnego HP niepołączonemu lub niespawniętemu graczowi!", {r=255,g=0,b=0});
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
            SendSystemMessage(pid, "Nie możesz zabrać przedmiotu niepołączonemu lub niespawniętemu graczowi!", {r=255,g=0,b=0});
            return;
        }

        if (amount < 1) amount = 1;

        removeItem(id, instance, amount);

        SendSystemMessage(pid, format("Zabrałeś przedmiot %s w ilości: %d graczowi %s", instance, amount, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Zabrano ci przedmiot %s w ilości: %d przez %s", instance, amount, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function playerDisconnect(pid, reason) {
    Player[pid].rank = 0;
}

addEventHandler("onPlayerDisconnect", playerDisconnect);

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
    case "time":
        cmd_time(pid, params);
        break;
    case "kill":
        cmd_kill(pid, params);
        break;
    case "pos":
        cmd_pos(pid, params);
        break;
    case "ros":
        cmd_ros(pid, params);
        break;
    case "admin_awans":
        cmd_awans(pid, params);
        break;
    case "report":
        cmd_report(pid, params);
        break;
    case "raport":
        cmd_report(pid, params);
        break;
    case "invisible":
        cmd_invisible(pid, params);
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
    }
}

addEventHandler("onPlayerCommand", cmdHandler);