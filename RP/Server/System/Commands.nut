/*
	ChangeLog:
	Added Command PM ~ Blaszunia
	Animation chat adjust ~ Blaszunia


*/
Commands <- {};

function Commands::globalChat(pid, params){
    if (!checkPermission(pid, LEVEL.MOD)) return;

	local args = sscanf("s", params);
	if (!args)
	{
		sendMessageToPlayer(pid, 255, 255, 255, _L(pid, "System Type: %s", "/g <text>"));
		return;
	}
    local message = args[0];
    message = getPlayerName(pid) +" (GLOBALNY): "+message;
    StringLib.distanceChat(pid, {r = 0, g = 255, b = 0}, -1, message);
}


function Commands::shoutChat(pid, params){
	local args = sscanf("s", params);
	if (!args)
	{
		sendMessageToPlayer(pid, 255, 255, 255, _L(pid, "System Type: %s", "/k <text>"));
		return;
	}
    local message = args[0];
    message = getPlayerName(pid) + "" + CFG.Shout.Prefix + message + CFG.Shout.Sufix;
    StringLib.distanceChat(pid, CFG.Shout.Color, CFG.Shout.Distance, message);
}

function Commands::whisperChat(pid, params){
	local args = sscanf("s", params);
	if (!args)
	{
		sendMessageToPlayer(pid, 255, 255, 255, _L(pid, "System Type: %s", "/sz <text>"));
		return;
	}
    local message = args[0];
    message = getPlayerName(pid) + "" + CFG.Whisper.Prefix + message + CFG.Whisper.Sufix;
    StringLib.distanceChat(pid, CFG.Whisper.Color, CFG.Whisper.Distance, message);
}

function Commands::outOfCharacterChat(pid, params){
	local args = sscanf("s", params);
	if (!args)
	{
		sendMessageToPlayer(pid, 255, 255, 255, _L(pid, "System Type: %s", "/b <text>"));
		return;
	}
    local message = args[0];
    message = getPlayerName(pid) + "" + CFG.OutOfCharacter.Prefix + message + CFG.OutOfCharacter.Sufix;
    StringLib.distanceChat(pid, CFG.OutOfCharacter.Color, CFG.OutOfCharacter.Distance, message);
}

function Commands::inCharacterChat(pid, params){
	local args = sscanf("s", params);
	if (!args)
	{
		sendMessageToPlayer(pid, 255, 255, 255, _L(pid, "System Type: %s", "/ja <text>"));
		return;
	}
    local message = args[0];
    message = getPlayerName(pid) + "" + CFG.InCharacter.Prefix + message + CFG.InCharacter.Sufix;
    StringLib.distanceChat(pid, CFG.InCharacter.Color, CFG.InCharacter.Distance, message);
}

function Commands::environmentChat(pid, params){
	local args = sscanf("s", params);
	if (!args)
	{
		sendMessageToPlayer(pid, 255, 255, 255, _L(pid, "System Type: %s", "/do <text>"));
		return;
	}
    local message = args[0];
    message = CFG.Environment.Prefix + message + CFG.Environment.Sufix + " ("+getPlayerName(pid) + ")";
    StringLib.distanceChat(pid, CFG.Environment.Color, CFG.Environment.Distance, message);
}

function Commands::animations(pid, params){
	local args = sscanf("d", params);
	if (!args)
	{
		sendMessageToPlayer(pid, 255, 255, 255, _L(pid, "System Type: %s", "/anim <id>"));
		return;
	}

    local id = args[0];
    if(id > (CFG.Anims.len()-1))
    {
        sendMessageToPlayer(pid, 255, 255, 255, "System: max id = " +(CFG.Anims.len()-1));
        return;
    }

    playAni(pid, CFG.Anims[id].inst);

    if(!CFG.ShowAnimatiotChat)
        return;

    local message = _L(pid, " do animation ") + _L(pid, CFG.Anims[id].name);
    message = getPlayerName(pid) + "" + CFG.InCharacter.Prefix + message + CFG.InCharacter.Sufix;
    StringLib.distanceChat(pid, CFG.InCharacter.Color, CFG.InCharacter.Distance, message);
}

function Commands::setDescription(pid, params) {
	local args = sscanf("s", params);
	if (!args)
	{
		sendMessageToPlayer(pid, 255, 255, 255, _L(pid, "System Type: %s", "/opis <text>"));
		return;
	}

    setPlayerDescription(pid, args[0]);
    sendMessageToPlayer(pid, 255, 255, 255, _L(pid, "You set description on") + " "+args[0]);
}

function Commands::randomCommand(pid, params) {
	local args = sscanf("d", params);
	if (!args)
	{
		sendMessageToPlayer(pid, 255, 255, 255, _L(pid, "System Type: %s", "/kosci <amount of throws>"));
		return;
	}
    local amount = args[0];
	if(amount <= 0 || amount > 100)
		amount = 1;

	local throws = "";
	for(local i = 0; i < amount; i++)
	{
		local throwBone = (rand() % 6) + 1;
		throws = throws + throwBone + ", ";
	}

	throws = throws.slice(0, -2);
    local message = getPlayerName(pid) + CFG.InCharacter.Prefix + _L(pid, "Throw") + " " + throws + CFG.InCharacter.Sufix;
    StringLib.distanceChat(pid, CFG.InCharacter.Color, CFG.InCharacter.Distance, message);
}

function Commands::privateMessage(pid, params){
	local args = sscanf("ds", params);
	if(!args){
		sendMessageToPlayer(pid, 0,255,0,"Use: /pm or /pw <id> <message>");
		return;
	};
	if(!isPlayerConnected(args[0])){
		sendMessageToPlayer(pid,0,255,0,"No online person with this id");
		return;
	};

	sendMessageToPlayer(pid,CFG.PM_OUT.Color.r,CFG.PM_OUT.Color.g,CFG.PM_OUT.Color.b, "(PM) "+getPlayerName(args[0])+"("+args[0]+")"+ " "+CFG.PM_OUT.message+" "+args[1]); //out
	sendMessageToPlayer(args[0],CFG.PM_IN.Color.r,CFG.PM_IN.Color.g,CFG.PM_IN.Color.b, "(PM) "+getPlayerName(pid)+"("+pid+")"+ " "+CFG.PM_IN.message+" "+args[1]); //in 
}


addEventHandler("onInit", function() {
    addCommand("g", Commands.globalChat)
    addCommand("k", Commands.shoutChat)
    addCommand("krzyk", Commands.shoutChat)
    addCommand("sz", Commands.whisperChat)
    addCommand("szept", Commands.whisperChat)
    addCommand("ja", Commands.inCharacterChat)
    addCommand("me", Commands.inCharacterChat)
    addCommand("do", Commands.environmentChat)
    addCommand("b", Commands.outOfCharacterChat)
    addCommand("ooc", Commands.outOfCharacterChat)
    addCommand("anim", Commands.animations)
    addCommand("opis", Commands.setDescription);
    addCommand("kosci", Commands.randomCommand);
	addCommand("pm", Commands.privateMessage);
	addCommand("pw", Commands.privateMessage);
	
	
})