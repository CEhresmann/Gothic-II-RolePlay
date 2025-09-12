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

    sendMessageToPlayer(pid, 255, 0, 0, "ACP: You don't have permission to use this command!");
    return false;
}

local function cmd_acp(pid, params) {
    sendMessageToPlayer(pid, 0, 255, 0, "-=========== ACP ===========-");
    sendMessageToPlayer(pid, 0, 255, 0, "/login - Login to your admin/mod account based on your UID.");
    sendMessageToPlayer(pid, 0, 255, 0, "/color id r g b - Change player color");
    sendMessageToPlayer(pid, 0, 255, 0, "/name id nickname - Change player nickname");
    sendMessageToPlayer(pid, 0, 255, 0, "/kick id reason - Kick player");
    sendMessageToPlayer(pid, 0, 255, 0, "/pos name - Save position to file");
    sendMessageToPlayer(pid, 0, 255, 0, "/ban id minutes reason - Ban player (minutes = 0 = forever)");
    sendMessageToPlayer(pid, 0, 255, 0, "/tp from_id to_id - Teleport player to other player");
    sendMessageToPlayer(pid, 0, 255, 0, "/tpall to_id - Teleport players to other player");
    sendMessageToPlayer(pid, 0, 255, 0, "/giveitem id instance amount - Give item to player");
    sendMessageToPlayer(pid, 0, 255, 0, "/removeitem id instance amount - Remove item from player");
    sendMessageToPlayer(pid, 0, 255, 0, "/str id value - Set player strength");
    sendMessageToPlayer(pid, 0, 255, 0, "/dex id value - Set player dexterity");
    sendMessageToPlayer(pid, 0, 255, 0, "/heal id - Heal player");
	sendMessageToPlayer(pid, 0, 255, 0, "/mana id - Change player mana to full");
    sendMessageToPlayer(pid, 0, 255, 0, "/setmaxhp id maxHP - Set player max HP");
    sendMessageToPlayer(pid, 0, 255, 0, "/setmaxmana id maxMana - Set player max mana");
    sendMessageToPlayer(pid, 0, 255, 0, "/setweaponskill id skillId percentage - Set weapon skill (0=1H,1=2H,2=BOW,3=CBOW)");
    sendMessageToPlayer(pid, 0, 255, 0, "/time hour minute - Set server time");
    sendMessageToPlayer(pid, 0, 255, 0, "/kill id - Kill player");
    sendMessageToPlayer(pid, 0, 255, 0, "/instance id instance - Change player instance");
    sendMessageToPlayer(pid, 0, 255, 0, "/show_grid id value - Show/hide grid");
    sendMessageToPlayer(pid, 0, 255, 0, "/bot_protection id value - Enable/disable bot protection");
    sendMessageToPlayer(pid, 0, 255, 0, "/admin_awans fractionId classId playerId - Promote player");
    sendMessageToPlayer(pid, 0, 255, 0, "/report id reason - Report player");
    sendMessageToPlayer(pid, 0, 255, 0, "/invisible - Toggle invisibility");
}

local function cmd_login(pid, params) {
    local playerUID = getPlayerUID(pid);
    if (!playerUID) {
        sendMessageToPlayer(pid, 255, 0, 0, "ACP: Could not retrieve your unique ID.");
        return;
    }

    try {
        local account = Admins_account.findOne(@(q) q.where("uid", "=", playerUID));
        if (account) {
            if (account.rank >= LEVEL.MOD) {
                Player[pid].rank = account.rank;
                local rankName = (account.rank == LEVEL.ADMIN) ? "Admin" : "Mod";
                sendMessageToPlayer(pid, 255, 255, 0, "ACP: Logged in successfully as " + rankName + ".");

                if (account.rank == LEVEL.ADMIN)
                    setPlayerColor(pid, CFG.AdminColor.r, CFG.AdminColor.g, CFG.AdminColor.b);
                else if (account.rank == LEVEL.MOD)
                    setPlayerColor(pid, CFG.ModColor.r, CFG.ModColor.g, CFG.ModColor.b);
            } else {
                sendMessageToPlayer(pid, 255, 0, 0, "ACP: Your account does not have sufficient permissions.");
            }
        } else {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Your account was not found in the administration system.");
        }
    } catch (e) {
        sendMessageToPlayer(pid, 255, 0, 0, "ACP: A database error occurred during login. Please contact the server owner.");
        serverLog("ACP Login Error for " + getPlayerName(pid) + " (UID: " + playerUID + "): " + e);
    }
}

local function cmd_pos(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;

    local args = sscanf("s", params);
    if (!args) {
        sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /pos name");
        return;
    }

    local id = args[0];
    local pos = getPlayerPosition(pid);
    local fileSave = file("pos.txt", "a");
    fileSave.write(id + " = " + pos.x + ", " + pos.y + ", "+pos.z + "\n");
    fileSave.close();

    sendMessageToPlayer(pid, 255, 0, 0, "ACP: Pos saved "+id);
}

local function cmd_color(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;

    local args = sscanf("dddd", params);
    if (!args) {
        sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /color id r g b");
        return;
    }

    local id = args[0];
    local r = args[1];
    local g = args[2];
    local b = args[3];

    if (!isPlayerConnected(id)) {
        sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot change color of unconnected player!");
        return;
    }

    setPlayerColor(id, r, g, b);

    sendMessageToPlayer(pid, r, g, b, format("ACP: You changed color of %s to %d, %d, %d", getPlayerName(id), r, g, b));
    sendMessageToPlayer(id, r, g, b, format("Your color was changed to %d, %d, %d by %s", r, g, b, getPlayerName(pid)));
}

local function cmd_name(pid, params) {
    if (!checkPermission(pid, LEVEL.MOD)) return;

    local args = sscanf("ds", params);
    if (!args) {
        sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /name id nickname");
        return;
    }

    local id = args[0];
    local name = args[1];

    if (!isPlayerConnected(id)) {
        sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot change nickname of unconnected player!");
        return;
    }

    setPlayerName(id, name);

    sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You changed nickname of %s to %s", getPlayerName(id), name));
    sendMessageToPlayer(id, 0, 255, 0, format("Your nickname was changed to %s by %s", name, getPlayerName(pid)));
}

local function cmd_kick(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("ds", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /kick id reason");
            return;
        }

        local id = args[0];
        local reason = args[1];

        if (!isPlayerConnected(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot kick unconnected player!");
            return;
        }

        kick(id, reason);

        sendMessageToAll(255, 80, 0, format("ACP: %s has been kicked by %s", getPlayerName(id), getPlayerName(pid)));
        sendMessageToAll(255, 80, 0, format("Reason: %s", reason));
    }
}

local function cmd_ban(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dds", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /ban id minutes reason");
            return;
        }

        local id = args[0];
        local minutes = args[1];
        local reason = args[2];

        if (!isPlayerConnected(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot ban unconnected player!");
            return;
        }

        ban(id, minutes, reason);

        if (minutes > 0) sendMessageToAll(255, 0, 0, format("ACP: %s has been banned for %d minutes by %s", getPlayerName(id), minutes, getPlayerName(pid)));
        else sendMessageToAll(255, 0, 0, format("ACP: %s has been banned FOREVER by %s", getPlayerName(id), getPlayerName(pid)));
        sendMessageToAll(255, 0, 0, format("Reason: %s", reason));
    }
}

local function cmd_tp(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("dd", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /tp from_id to_id");
            return;
        }

        local from_id = args[0];
        local to_id = args[1];

        if (!isPlayerSpawned(from_id) || !isPlayerSpawned(to_id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot teleport unconnected or unspawned players!");
            return;
        }

        if (from_id == to_id) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot teleport the same player!");
            return;
        }

        local world = getPlayerWorld(to_id);
        if (world != getPlayerWorld(from_id))
            setPlayerWorld(from_id, world);

        local pos = getPlayerPosition(to_id);
        setPlayerPosition(from_id, pos.x, pos.y, pos.z);

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: Teleported %s to %s", getPlayerName(from_id), getPlayerName(to_id)));
        sendMessageToPlayer(from_id, 0, 255, 0, format("You were teleported to %s by %s", getPlayerName(to_id), getPlayerName(pid)));
        sendMessageToPlayer(to_id, 0, 255, 0, format("To you has been teleported %s by %s", getPlayerName(from_id), getPlayerName(pid)));
    }
}

local function cmd_tpall(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("d", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /tpall to_id");
            return;
        }

        local to_id = args[0];
        if (!isPlayerSpawned(to_id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot teleport to unconnected or unspawned player!");
            return;
        }

        local world = getPlayerWorld(to_id);
        local pos = getPlayerPosition(to_id);
        local message = format("You were teleported to %s by %s", getPlayerName(to_id), getPlayerName(pid));

        for (local i = 0; i < getMaxSlots(); ++i) {
            if (isPlayerConnected(i) && isPlayerSpawned(i)) {
                if (world != getPlayerWorld(i))
                    setPlayerWorld(i, world);

                sendMessageToPlayer(i, 0, 255, 0, message);
                setPlayerPosition(i, pos.x, pos.y, pos.z);
            }
        }

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: Teleported players %s", getPlayerName(to_id)));
    }
}

local function cmd_giveitem(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dsd", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /giveitem id instance amount");
            return;
        }

        local id = args[0];
        local instance = args[1];
        local amount = args[2];

        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot give item to unconnected or unspawned player!");
            return;
        }

        if (amount < 1) amount = 1;
        giveItem(id, instance, amount);

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You gave item %s amount: %d to %s", args[1], amount, getPlayerName(id)));
        sendMessageToPlayer(id, 0, 255, 0, format("Received item %s amount: %d from %s", args[1], amount, getPlayerName(pid)));
    }
}

local function cmd_str(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /str id value");
            return;
        }

        local id = args[0];
        local value = args[1];

        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot give strength to unconnected or unspawned player!");
            return;
        }

        if (value < 0) value = 0;
        setPlayerStrength(id, value);

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You changed %s strength to %d", getPlayerName(id), value));
        sendMessageToPlayer(id, 0, 255, 0, format("Strength was changed to %d by %s", value, getPlayerName(pid)));
    }
}

local function cmd_dex(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /dex id value");
            return;
        }

        local id = args[0];
        local value = args[1];

        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot give dexterity to unconnected or unspawned player!");
            return;
        }

        if (value < 0) value = 0;
        setPlayerDexterity(id, value);

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You changed %s dexterity to %d", getPlayerName(id), value));
        sendMessageToPlayer(id, 0, 255, 0, format("Dexterity was changed to %d by %s", value, getPlayerName(pid)));
    }
}

local function cmd_awans(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("ddd", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /admin_awans <id fraction> <id class> <id player>");
            return;
        }

        local id = args[2];
        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot give class too unconnected or unspawned player!");
            return;
        }

        local fraction_id = args[0];

        if(!Fraction.rawin(fraction_id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: There's no fraction on given id.");
            foreach(_key, _fraction in Fraction)
                sendMessageToPlayer(pid, 255, 0, 0, "ACP: "+_key+" - "+_fraction.name);
            return;
        }

        local fraction = Fraction[fraction_id];
        local class_id = args[1];

        if(!fraction.classes.rawin(class_id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: There's no class in fraction on given id.");
            foreach(_key, _class in fraction.classes)
                sendMessageToPlayer(pid, 255, 0, 0, "ACP: "+_key+" - "+_class.name);

            return;
        }

        setClassPlayer(id, fraction_id, class_id);

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You gave class %s to %s", fraction.classes[class_id].name, getPlayerName(id)));
        sendMessageToPlayer(id, 0, 255, 0, format("You get class %s from %s", fraction.classes[class_id].name, getPlayerName(pid)));
    }
}

local function cmd_heal(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("d", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /heal id");
            return;
        }

        local id = args[0];
        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot heal unconnected or unspawned player!");
            return;
        }

        setPlayerHealth(id, getPlayerMaxHealth(id));

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You healed %s", getPlayerName(id)));
        sendMessageToPlayer(id, 0, 255, 0, format("You were healed by %s", getPlayerName(pid)));
    }
}

local function cmd_mana(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("d", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /mana id");
            return;
        }

        local id = args[0];
        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot mana unconnected or unspawned player!");
            return;
        }

        setPlayerMana(id, getPlayerMaxMana(id));

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You change mana %s", getPlayerName(id)));
        sendMessageToPlayer(id, 0, 255, 0, format("You mana has changed by %s", getPlayerName(pid)));
    }
}

local function cmd_instance(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("ds", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /instance id instance example WOLF");
            return;
        }

        local id = args[0];
        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot change instance of this player!");
            return;
        }

        setPlayerInstance(id, args[1]);

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You change instance %s to %s", getPlayerName(id), args[1]));
        sendMessageToPlayer(id, 0, 255, 0, format("You were changed for %s by %s", args[1], getPlayerName(pid)));
    }
}

local function cmd_kill(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("d", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /kill <id>");
            return;
        }

        local id = args[0];

        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot make dead unconnected or unspawned player!");
            return;
        }

        setPlayerHealth(id, 0);
        sendMessageToPlayer(id, 255, 0, 0, "You have been killed by "+getPlayerName(pid))
        sendMessageToPlayer(pid, 255, 0, 0, "ACP: You killed "+getPlayerName(id));
    }
}

local function cmd_showgrid(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("dd", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /show_grid <id> <1 - 0>");
            return;
        }

        local id = args[0];
        local value = args[1];

        if(!(value in [1,0])) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Incorrect value.");
            return;
        }

        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot make dead unconnected or unspawned player!");
            return;
        }

        sendMessageToPlayer(pid, 255, 0, 0, "ACP: We change map grid for "+getPlayerName(id));
        sendMessageToPlayer(id, 255, 0, 0, "ACP: Get change map grid by "+getPlayerName(pid));

        local packet = Packet();
        packet.writeUInt8(PacketId.Admin);
        packet.writeUInt8(PacketAdmin.Grid);
        packet.writeInt16(args[1]);
        packet.send(id, RELIABLE_ORDERED);
        packet = null;
    }
}

local function cmd_botprotection(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("dd", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /bot_protection <id> <1 - 0>");
            return;
        }

        local id = args[0];
        local value = args[1];

        if(!(value in [1,0])) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Incorrect value.");
            return;
        }

        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot make dead unconnected or unspawned player!");
            return;
        }

        if(value == 1)
            Player[id].botProtection = true;
        else
            Player[id].botProtection = false;

        sendMessageToPlayer(pid, 255, 0, 0, "ACP: You changed bot protection for "+getPlayerName(id));
        sendMessageToPlayer(id, 255, 0, 0, "ACP: You get changed bot protection by "+getPlayerName(pid));
    }
}

local function cmd_time(pid, params) {
    if (checkPermission(pid, LEVEL.MOD)) {
        local args = sscanf("dd", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /time hour min");
            return;
        }

        local hour = args[0];
        local min = args[1];

        if (hour > 23) hour = 23;
        else if (hour < 0) hour = 0;

        if (min > 59) min = 59;
        else if (min < 0) min = 0;

        setTime(hour, min);
        sendMessageToAll(0, 255, 0, format("ACP: %s changed time to %02d:%02d", getPlayerName(pid), hour, min));
    }
}

function cmd_report(pid, params){
    local args = sscanf("ds", params)
    if(!args){
        sendMessageToPlayer(pid, 0,255,0,"Use: /report <id> <text>");
        return;
    };
    if(!isPlayerConnected(args[0])){
        sendMessageToPlayer(pid,0,255,0,"No person with this ID");
        return;
    };
    for(local i = 0; i < getMaxSlots(); i++ ){
        if(isPlayerConnected(i)){
            if(Player[i].rank >= LEVEL.MOD)
                sendMessageToPlayer(i,250,230,0,"Report from: "+getPlayerName(pid) + "(( "+pid+" )) on "+getPlayerName(args[0])+" (( "+args[0]+" )) reason: "+args[1]);
        };
    };
    sendMessageToPlayer(pid, 0,255,0,"Raport successfully send!");
};

function cmd_invisible(pid, params){
    if(checkPermission(pid, LEVEL.MOD)){
        if(getPlayerInvisible(pid)){
            setPlayerInvisible(pid, false);
            sendMessageToPlayer(pid, 250,0,0,"ACP: Invisible off");
        }
        else{
            setPlayerInvisible(pid, true);
            sendMessageToPlayer(pid, 250,0,0,"ACP: Invisible on");
        }
    }
}

local function cmd_setweaponskill(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("ddd", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /setweaponskill id skillId percentage");
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: SkillId: 0=1H, 1=2H, 2=BOW, 3=CBOW");
            return;
        }

        local id = args[0];
        local skillId = args[1];
        local percentage = args[2];

        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot set weapon skill for unconnected or unspawned player!");
            return;
        }

        if (percentage < 0) percentage = 0;
        if (percentage > 100) percentage = 100;

        setPlayerSkillWeapon(id, skillId, percentage);

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You set weapon skill %d to %d%% for %s", skillId, percentage, getPlayerName(id)));
        sendMessageToPlayer(id, 0, 255, 0, format("Your weapon skill %d was set to %d%% by %s", skillId, percentage, getPlayerName(pid)));
    }
}

local function cmd_setmaxmana(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /setmaxmana id maxMana");
            return;
        }

        local id = args[0];
        local maxMana = args[1];

        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot set max mana for unconnected or unspawned player!");
            return;
        }

        if (maxMana < 0) maxMana = 0;

        setPlayerMaxMana(id, maxMana);

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You set max mana to %d for %s", maxMana, getPlayerName(id)));
        sendMessageToPlayer(id, 0, 255, 0, format("Your max mana was set to %d by %s", maxMana, getPlayerName(pid)));
    }
}

local function cmd_setmaxhp(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dd", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /setmaxhp id maxHP");
            return;
        }

        local id = args[0];
        local maxHP = args[1];

        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot set max HP for unconnected or unspawned player!");
            return;
        }

        if (maxHP < 0) maxHP = 0;

        setPlayerMaxHealth(id, maxHP);

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You set max HP to %d for %s", maxHP, getPlayerName(id)));
        sendMessageToPlayer(id, 0, 255, 0, format("Your max HP was set to %d by %s", maxHP, getPlayerName(pid)));
    }
}

local function cmd_removeitem(pid, params) {
    if (checkPermission(pid, LEVEL.ADMIN)) {
        local args = sscanf("dsd", params);
        if (!args) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: Wpisz /removeitem id instance amount");
            return;
        }

        local id = args[0];
        local instance = args[1];
        local amount = args[2];

        if (!isPlayerSpawned(id)) {
            sendMessageToPlayer(pid, 255, 0, 0, "ACP: You cannot remove item from unconnected or unspawned player!");
            return;
        }

        if (amount < 1) amount = 1;

        removeItem(id, instance, amount);

        sendMessageToPlayer(pid, 0, 255, 0, format("ACP: You removed item %s amount: %d from %s", instance, amount, getPlayerName(id)));
        sendMessageToPlayer(id, 0, 255, 0, format("Removed item %s amount: %d by %s", instance, amount, getPlayerName(pid)));
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
    case "show_grid":
        cmd_showgrid(pid, params);
        break;
    case "bot_protection":
        cmd_botprotection(pid, params);
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