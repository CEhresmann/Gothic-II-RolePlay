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

    SendSystemMessage(pid, "You don't have permission to use this command!", {r=255,g=0,b=0});
    return false;
}

local function cmd_acp(pid, params) {
    SendSystemMessage(pid, "-=========== ACP ===========-", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/login - Login to your admin/mod account based on your UID.", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/color id r g b - Change player color", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/name id nickname - Change player nickname", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/kick id reason - Kick player", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/pos name - Save position to file", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/ros - Save herb position to file", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/ban id minutes reason - Ban player (minutes = 0 = forever)", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/tp from_id to_id - Teleport player to other player", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/tpall to_id - Teleport players to other player", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/giveitem id instance amount - Give item to player", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/removeitem id instance amount - Remove item from player", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/str id value - Set player strength", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/dex id value - Set player dexterity", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/heal id - Heal player", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/mana id - Change player mana to full", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/setmaxhp id maxHP - Set player max HP", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/setmaxmana id maxMana - Set player max mana", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/setweaponskill id skillId percentage - Set weapon skill (0=1H,1=2H,2=BOW,3=CBOW)", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/time hour minute - Set server time", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/kill id - Kill player", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/instance id instance - Change player instance", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/admin_awans fractionId classId playerId - Promote player", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/report id reason - Report player", {r=0,g=255,b=0});
    SendSystemMessage(pid, "/invisible - Toggle invisibility", {r=0,g=255,b=0});
}

local function cmd_login(pid, params) {
    local playerUID = getPlayerUID(pid);
    if (!playerUID) {
        SendSystemMessage(pid, "Could not retrieve your unique ID.", {r=255,g=0,b=0});
        return;
    }

    try {
        local account = Admins_account.findOne(@(q) q.where("uid", "=", playerUID));
        if (account) {
            if (account.rank >= LEVEL.MOD) {
                Player[pid].rank = account.rank;
                local rankName = (account.rank == LEVEL.ADMIN) ? "Admin" : "Mod";
                SendSystemMessage(pid, "Logged in successfully as " + rankName + ".", {r=255,g=255,b=0});

                if (account.rank == LEVEL.ADMIN)
                    setPlayerColor(pid, CFG.AdminColor.r, CFG.AdminColor.g, CFG.AdminColor.b);
                else if (account.rank == LEVEL.MOD)
                    setPlayerColor(pid, CFG.ModColor.r, CFG.ModColor.g, CFG.ModColor.b);
            } else {
                SendSystemMessage(pid, "Your account does not have sufficient permissions.", {r=255,g=0,b=0});
            }
        } else {
            SendSystemMessage(pid, "Your account was not found in the administration system.", {r=255,g=0,b=0});
        }
    } catch (e) {
        SendSystemMessage(pid, "A database error occurred during login. Please contact the server owner.", {r=255,g=0,b=0});
        serverLog("ACP Login Error for " + getPlayerName(pid) + " (UID: " + playerUID + "): " + e);
    }
}

local function cmd_pos(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;

    local args = sscanf("s", params);
    if (!args) {
        SendSystemMessage(pid, "Usage: /pos name", {r=255,g=0,b=0});
        return;
    }

    local id = args[0];
    local pos = getPlayerPosition(pid);
    local fileSave = file("pos.txt", "a");
    fileSave.write(id + " = " + pos.x + ", " + pos.y + ", "+pos.z + "\n");
    fileSave.close();

    SendSystemMessage(pid, "Pos saved "+id, {r=255,g=0,b=0});
}

local function cmd_ros(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;
    
    local pos = getPlayerPosition(pid);
    local fileSave = file("ros.txt", "a");
    fileSave.write("RegisterGroundItem(" + pos.x + ", " + pos.y + ", " + pos.z + "); \n");
    fileSave.close();

    SendSystemMessage(pid, "Herb saved", {r=255,g=0,b=0});
}

local function cmd_color(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;

    local args = sscanf("dddd", params);
    if (!args) {
        SendSystemMessage(pid, "Usage: /color id r g b", {r=255,g=0,b=0});
        return;
    }

    local id = args[0];
    local r = args[1];
    local g = args[2];
    local b = args[3];

    if (!isPlayerConnected(id)) {
        SendSystemMessage(pid, "You cannot change color of unconnected player!", {r=255,g=0,b=0});
        return;
    }

    setPlayerColor(id, r, g, b);

    SendSystemMessage(pid, format("You changed color of %s to %d, %d, %d", getPlayerName(id), r, g, b), {r=r,g=g,b=b});
    SendSystemMessage(id, format("Your color was changed to %d, %d, %d by %s", r, g, b, getPlayerName(pid)), {r=r,g=g,b=b});
}

local function cmd_name(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;

    local args = sscanf("ds", params);
    if (!args) {
        SendSystemMessage(pid, "Usage: /name id nickname", {r=255,g=0,b=0});
        return;
    }

    local id = args[0];
    local name = args[1];

    if (!isPlayerConnected(id)) {
        SendSystemMessage(pid, "You cannot change nickname of unconnected player!", {r=255,g=0,b=0});
        return;
    }

    setPlayerName(id, name);

    SendSystemMessage(pid, format("You changed nickname of %s to %s", getPlayerName(id), name), {r=0,g=255,b=0});
    SendSystemMessage(id, format("Your nickname was changed to %s by %s", name, getPlayerName(pid)), {r=0,g=255,b=0});
}

local function cmd_kick(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("ds", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /kick id reason", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local reason = args[1];

        if (!isPlayerConnected(id)) {
            SendSystemMessage(pid, "You cannot kick unconnected player!", {r=255,g=0,b=0});
            return;
        }

        kick(id, reason);

        SendSystemMessage(null, format("%s has been kicked by %s", getPlayerName(id), getPlayerName(pid)), {r=255,g=80,b=0});
        SendSystemMessage(null, format("Reason: %s", reason), {r=255,g=80,b=0});
    }
}

local function cmd_ban(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dds", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /ban id minutes reason", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local minutes = args[1];
        local reason = args[2];

        if (!isPlayerConnected(id)) {
            SendSystemMessage(pid, "You cannot ban unconnected player!", {r=255,g=0,b=0});
            return;
        }

        ban(id, minutes, reason);

        if (minutes > 0) SendSystemMessage(null, format("%s has been banned for %d minutes by %s", getPlayerName(id), minutes, getPlayerName(pid)), {r=255,g=0,b=0});
        else SendSystemMessage(null, format("%s has been banned FOREVER by %s", getPlayerName(id), getPlayerName(pid)), {r=255,g=0,b=0});
        SendSystemMessage(null, format("Reason: %s", reason), {r=255,g=0,b=0});
    }
}

local function cmd_tp(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /tp from_id to_id", {r=255,g=0,b=0});
            return;
        }

        local from_id = args[0];
        local to_id = args[1];

        if (!isPlayerSpawned(from_id) || !isPlayerSpawned(to_id)) {
            SendSystemMessage(pid, "You cannot teleport unconnected or unspawned players!", {r=255,g=0,b=0});
            return;
        }

        if (from_id == to_id) {
            SendSystemMessage(pid, "You cannot teleport the same player!", {r=255,g=0,b=0});
            return;
        }

        local world = getPlayerWorld(to_id);
        if (world != getPlayerWorld(from_id))
            setPlayerWorld(from_id, world);

        local pos = getPlayerPosition(to_id);
        setPlayerPosition(from_id, pos.x, pos.y, pos.z);

        SendSystemMessage(pid, format("Teleported %s to %s", getPlayerName(from_id), getPlayerName(to_id)), {r=0,g=255,b=0});
        SendSystemMessage(from_id, format("You were teleported to %s by %s", getPlayerName(to_id), getPlayerName(pid)), {r=0,g=255,b=0});
        SendSystemMessage(to_id, format("To you has been teleported %s by %s", getPlayerName(from_id), getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_tpall(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("d", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /tpall to_id", {r=255,g=0,b=0});
            return;
        }

        local to_id = args[0];
        if (!isPlayerSpawned(to_id)) {
            SendSystemMessage(pid, "You cannot teleport to unconnected or unspawned player!", {r=255,g=0,b=0});
            return;
        }

        local world = getPlayerWorld(to_id);
        local pos = getPlayerPosition(to_id);
        local message = format("You were teleported to %s by %s", getPlayerName(to_id), getPlayerName(pid));

        for (local i = 0; i < getMaxSlots(); ++i) {
            if (isPlayerConnected(i) && isPlayerSpawned(i)) {
                if (world != getPlayerWorld(i))
                    setPlayerWorld(i, world);

                SendSystemMessage(i, message, {r=0,g=255,b=0});
                setPlayerPosition(i, pos.x, pos.y, pos.z);
            }
        }

        SendSystemMessage(pid, format("Teleported players %s", getPlayerName(to_id)), {r=0,g=255,b=0});
    }
}

local function cmd_giveitem(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dsd", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /giveitem id instance amount", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local instance = args[1];
        local amount = args[2];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "You cannot give item to unconnected or unspawned player!", {r=255,g=0,b=0});
            return;
        }

        if (amount < 1) amount = 1;
        giveItem(id, instance, amount);

        SendSystemMessage(pid, format("You gave item %s amount: %d to %s", instance, amount, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Received item %s amount: %d from %s", instance, amount, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_str(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /str id value", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local value = args[1];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "You cannot give strength to unconnected or unspawned player!", {r=255,g=0,b=0});
            return;
        }

        if (value < 0) value = 0;
        setPlayerStrength(id, value);

        SendSystemMessage(pid, format("You changed %s strength to %d", getPlayerName(id), value), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Strength was changed to %d by %s", value, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_dex(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /dex id value", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local value = args[1];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "You cannot give dexterity to unconnected or unspawned player!", {r=255,g=0,b=0});
            return;
        }

        if (value < 0) value = 0;
        setPlayerDexterity(id, value);

        SendSystemMessage(pid, format("You changed %s dexterity to %d", getPlayerName(id), value), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Dexterity was changed to %d by %s", value, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_awans(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("ddd", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /admin_awans <id fraction> <id class> <id player>", {r=255,g=0,b=0});
            return;
        }

        local id = args[2];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "You cannot give class too unconnected or unspawned player!", {r=255,g=0,b=0});
            return;
        }

        local fraction_id = args[0];

        if(!Fraction.rawin(fraction_id)) {
            SendSystemMessage(pid, "There's no fraction on given id.", {r=255,g=0,b=0});
            foreach(_key, _fraction in Fraction)
                SendSystemMessage(pid, _key+" - "+_fraction.name, {r=255,g=0,b=0});
            return;
        }

        local fraction = Fraction[fraction_id];
        local class_id = args[1];

        if(!fraction.classes.rawin(class_id)) {
            SendSystemMessage(pid, "There's no class in fraction on given id.", {r=255,g=0,b=0});
            foreach(_key, _class in fraction.classes)
                SendSystemMessage(pid, _key+" - "+_class.name, {r=255,g=0,b=0});
            return;
        }

        setClassPlayer(id, fraction_id, class_id);

        SendSystemMessage(pid, format("You gave class %s to %s", fraction.classes[class_id].name, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("You get class %s from %s", fraction.classes[class_id].name, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_heal(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local basicArgs = sscanf("d", params);
        if (!basicArgs) {
            SendSystemMessage(pid, "Usage: /heal id [value]", {r=255,g=0,b=0});
            return;
        }

        local id = basicArgs[0];
        
        local fullArgs = sscanf("dd", params);
        local value = (fullArgs && fullArgs.len() > 1) ? fullArgs[1] : null;
        
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "You cannot heal unconnected or unspawned player!", {r=255,g=0,b=0});
            return;
        }

        if (value == null || value <= 0) {
            setPlayerHealth(id, getPlayerMaxHealth(id));
        } else {
            setPlayerHealth(id, value);
        }

        SendSystemMessage(pid, format("You healed %s", getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("You were healed by %s", getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_mana(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local basicArgs = sscanf("d", params);
        if (!basicArgs) {
            SendSystemMessage(pid, "Usage: /mana id [value]", {r=255,g=0,b=0});
            return;
        }

        local id = basicArgs[0];
        
        local fullArgs = sscanf("dd", params);
        local value = (fullArgs && fullArgs.len() > 1) ? fullArgs[1] : null;
        
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "You cannot heal unconnected or unspawned player!", {r=255,g=0,b=0});
            return;
        }

        if (value == null || value <= 0) {
            setPlayerMana(id, getPlayerMaxMana(id));
        } else {
            setPlayerMana(id, value);
        }

        SendSystemMessage(pid, format("You changed mana %s", getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("You were mana healed by %s", getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_instance(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("ds", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /instance id instance (example WOLF)", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "You cannot change instance of this player!", {r=255,g=0,b=0});
            return;
        }

        setPlayerInstance(id, args[1]);

        SendSystemMessage(pid, format("You change instance %s to %s", getPlayerName(id), args[1]), {r=0,g=255,b=0});
        SendSystemMessage(id, format("You were changed for %s by %s", args[1], getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_kill(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("d", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /kill <id>", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "You cannot make dead unconnected or unspawned player!", {r=255,g=0,b=0});
            return;
        }

        setPlayerHealth(id, 0);
        SendSystemMessage(id, "You have been killed by "+getPlayerName(pid), {r=255,g=0,b=0});
        SendSystemMessage(pid, "You killed "+getPlayerName(id), {r=255,g=0,b=0});
    }
}

local function cmd_time(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /time hour min", {r=255,g=0,b=0});
            return;
        }

        local hour = args[0];
        local min = args[1];

        if (hour > 23) hour = 23;
        else if (hour < 0) hour = 0;

        if (min > 59) min = 59;
        else if (min < 0) min = 0;

        setTime(hour, min);
        SendSystemMessage(null, format("%s changed time to %02d:%02d", getPlayerName(pid), hour, min), {r=0,g=255,b=0});
    }
}

function cmd_report(pid, params){
    local args = sscanf("ds", params)
    if(!args){
        SendSystemMessage(pid, "Use: /report <id> <text>", {r=0,g=255,b=0});
        return;
    };
    if(!isPlayerConnected(args[0])){
        SendSystemMessage(pid, "No person with this ID", {r=0,g=255,b=0});
        return;
    };
    for(local i = 0; i < getMaxSlots(); i++ ){
        if(isPlayerConnected(i)){
            if(Player[i].rank >= LEVEL.MOD)
                SendSystemMessage(i, "Report from: "+getPlayerName(pid) + "(( "+pid+" )) on "+getPlayerName(args[0])+" (( "+args[0]+" )) reason: "+args[1], {r=250,g=230,b=0});
        };
    };
    SendSystemMessage(pid, "Report successfully send!", {r=0,g=255,b=0});
};

function cmd_invisible(pid, params){
    if(checkPermission(pid, LEVEL.MOD)){
        if(getPlayerInvisible(pid)){
            setPlayerInvisible(pid, false);
            SendSystemMessage(pid, "Invisible off", {r=250,g=0,b=0});
        }
        else{
            setPlayerInvisible(pid, true);
            SendSystemMessage(pid, "Invisible on", {r=250,g=0,b=0});
        }
    }
}

local function cmd_setweaponskill(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("ddd", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /setweaponskill id skillId percentage", {r=255,g=0,b=0});
            SendSystemMessage(pid, "SkillId: 0=1H, 1=2H, 2=BOW, 3=CBOW", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local skillId = args[1];
        local percentage = args[2];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "You cannot set weapon skill for unconnected or unspawned player!", {r=255,g=0,b=0});
            return;
        }

        if (percentage < 0) percentage = 0;
        if (percentage > 100) percentage = 100;

        setPlayerSkillWeapon(id, skillId, percentage);

        SendSystemMessage(pid, format("You set weapon skill %d to %d%% for %s", skillId, percentage, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Your weapon skill %d was set to %d%% by %s", skillId, percentage, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_setmaxmana(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /setmaxmana id maxMana", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local maxMana = args[1];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "You cannot set max mana for unconnected or unspawned player!", {r=255,g=0,b=0});
            return;
        }

        if (maxMana < 0) maxMana = 0;

        setPlayerMaxMana(id, maxMana);

        SendSystemMessage(pid, format("You set max mana to %d for %s", maxMana, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Your max mana was set to %d by %s", maxMana, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_setmaxhp(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /setmaxhp id maxHP", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local maxHP = args[1];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "You cannot set max HP for unconnected or unspawned player!", {r=255,g=0,b=0});
            return;
        }

        if (maxHP < 0) maxHP = 0;

        setPlayerMaxHealth(id, maxHP);

        SendSystemMessage(pid, format("You set max HP to %d for %s", maxHP, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Your max HP was set to %d by %s", maxHP, getPlayerName(pid)), {r=0,g=255,b=0});
    }
}

local function cmd_removeitem(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dsd", params);
        if (!args) {
            SendSystemMessage(pid, "Usage: /removeitem id instance amount", {r=255,g=0,b=0});
            return;
        }

        local id = args[0];
        local instance = args[1];
        local amount = args[2];

        if (!isPlayerSpawned(id)) {
            SendSystemMessage(pid, "You cannot remove item from unconnected or unspawned player!", {r=255,g=0,b=0});
            return;
        }

        if (amount < 1) amount = 1;

        removeItem(id, instance, amount);

        SendSystemMessage(pid, format("You removed item %s amount: %d from %s", instance, amount, getPlayerName(id)), {r=0,g=255,b=0});
        SendSystemMessage(id, format("Removed item %s amount: %d by %s", instance, amount, getPlayerName(pid)), {r=0,g=255,b=0});
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