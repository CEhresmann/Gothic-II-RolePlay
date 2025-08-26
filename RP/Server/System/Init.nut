
addEvent("onBotDeath");
addEvent("onPlayerLoggIn");
addEvent("onPlayerPositionChange");
addEvent("onTick");
addEvent("onMinute");
addEvent("onSecond");
addEvent("onGameTimeEvent");
addEvent("onObjectInteraction");

addEventHandler("onInit", function() {
	print("----=========----SERVER----============----");
	print("RolePlay open source loaded. Version: "+ CFG.Version);
	print("Hostname "+CFG.Hostname);
	print("Max players "+CFG.MaxSlots);
	print("----=========----SPAWN-----============----");
	print("Bots " + BotIntegration.Bots.len());
	print("Herbs "+getRegisteredGroundItems().len());
	print("Fractions "+Fraction.len());
	print("----=========----CONFIG----============----");
	print("User save system: file");
	print("Map show others: "+CFG.MapShowOthers);
	print("Map show yourself: "+CFG.MapShowYourself);
	print("World builder on: "+CFG.WorldBuilder);
	print("World builder true building on: "+CFG.WorldBuilderTrueBuilding);
	print("World builder password: "+CFG.WorldBuilderPassword);
	print("Default language: "+CFG.DefaultLanguage);
	print("Switch language: "+CFG.LanguageSwitcher);
	print("Currency: "+CFG.Currency);
	print("AdminPassword: "+CFG.AdminPassword);
	print("ModPassword: "+CFG.ModPassword);
	print("----=====================----");
})

addEventHandler("onPlayerMessage", function(pid, message)
{
    message = getPlayerName(pid) + " mówi: "+message;
    StringLib.distanceChat(pid, {r = 255, g = 255, b = 255}, 1300, message);
});

addEventHandler("onPlayerJoin", function(pid) {
	checkWhiteList(pid);

	setPlayerName(pid, "Niezalogowany "+pid)
	setPlayerColor(pid, CFG.DefaultColor.r, CFG.DefaultColor.g, CFG.DefaultColor.b)

	if(CFG.MaxSlots == getMaxSlots())
		return;

	if(getPlayersCount() >= CFG.MaxSlots) {
		kick(pid, "Maks graczy na serwerze "+CFG.MaxSlots)
	}
})

addEventHandler("onGameTimeEvent", function(tag) {

})

function checkWhiteList(pid)
{
	if(CFG.WhiteList.len() == 0)
		return;

	if(CFG.WhiteList.find(getPlayerName(pid)) == null)
	{
		kick(pid, "Nie znaleziono twojego nicku na whitelist.");
		return;
	}
}