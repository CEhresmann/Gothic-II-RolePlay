class ServerLogs extends ORM.Model </ table="server_logs" /> {
    </ primary_key = true, auto_increment = true />
    id = -1
    
    </ type = "VARCHAR(255)", not_null = true />
    player_name = ""
    
    </ type = "VARCHAR(255)", not_null = true />
    player_uid = ""
    
    </ type = "TEXT", not_null = true />
    message = ""
    
    </ type = "TIMESTAMP" not_null = true />
    timestamp = 0
    
    </ type = "VARCHAR(20)" />
    type = ""
}

local function logServerAction(pid, message, messageType = "chat") {
    try {
        if (!isDatabaseConnected()) return;
        
        local playerName = getPlayerName(pid);
        local playerUID = getPlayerUID(pid);
        
        local serverLog = ServerLogs();
        serverLog.player_name = playerName;
        serverLog.player_uid = playerUID;
        serverLog.message = message;
		serverLog.timestamp = 0;
        serverLog.type = messageType;
        
        serverLog.insert();
    } catch (e) {
        serverLog("[SERVER-LOG-ERROR] Failed to save action from " + getPlayerName(pid) + ": " + e);
    }
}

addEventHandler("onPlayerMessage", function(pid, message) {
    logServerAction(pid, message, "chat");
});

addEventHandler("onPlayerCommand", function(pid, command, params) {
    local fullCommand = "/" + command;
    if (params != "" && params != null) {
        fullCommand += " " + params;
    }
    logServerAction(pid, fullCommand, "command");
});

addEventHandler("onPlayerTakeItem", function(pid, item) {
    logServerAction(pid, "Picked up " + item.amount + "x " + item.instance, "other");
})

addEventHandler("onPlayerDropItem", function(pid, item) {
    logServerAction(pid, "Dropped " + item.amount + "x " + item.instance, "other");
})

addEventHandler("onPlayerDead", function(pid, killerid) {
	local killername = getPlayerName(killerid);
	local deadname = getPlayerName(pid);
    logServerAction(pid, deadname + " Killed by " + killername, "other");
})