addEventHandler("onPlayerMessage", function(pid, msg)
{
	sendPlayerMessageToAll(pid, 255, 255, 255, msg)
})