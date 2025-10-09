function initDiscord() {
    Discord.recreate(CFG.DiscordActivityID);
}

function updateDiscordActivity() {
    local serverName = getHostname();
    local playerNick = getPlayerName(heroId);
    local playersCount = getPlayersCount();
    local maxPlayers = getMaxSlots();

    if (playerNick != null && serverName != null) {
        DiscordRichPresence.details = "Gra jako: " + playerNick;
        DiscordRichPresence.state = "Online: " + playersCount + "/" + maxPlayers;
        
        DiscordRichPresence.largeImageKey = "or";
        DiscordRichPresence.largeImageText = "Gothic 2 Online";
        
        DiscordRichPresence.button1.active = true;
        DiscordRichPresence.button1.label = "Discord";
        DiscordRichPresence.button1.url = CFG.ServerDiscordLink;
        
        DiscordRichPresence.button2.active = true;
        DiscordRichPresence.button2.label = "Graj";
        DiscordRichPresence.button2.url = "g2o://"+CFG.ServerIPAdress+":"+CFG.ServerPort;
        
        DiscordRichPresence.startTimestamp = time().tostring();
        Discord.updatePresence();
    }
}

addEventHandler("onPlayerLoggin", function(heroId){
	initDiscord();
    setTimer(updateDiscordActivity, 2000, 1);
});