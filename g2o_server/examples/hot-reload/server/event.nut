local function onPlayerCommand(pid, cmd, arg)
{
	// try introducing new commands while server is running
	// by saving this file in your text editor

	switch (cmd)
	{
		case "server-hello":
			sendMessageToPlayer(pid, 255, 255, 255, "Server says: World!")
			break
	}
}

local function onReload()
{
	// bind the function to onCommand event
	addEventHandler("onPlayerCommand", onPlayerCommand)
}

// register reload callback that will be called:
// - when scripts get initialized for the first time
// - when you introduce changes to this file and save it in your editor
setReloadCallback(onReload)

local function onUnload()
{
	// unbind the function from onCommand event
	removeEventHandler("onPlayerCommand", onPlayerCommand)
}

// register unload callback that will be called:
// - before the current script is about to be unloaded
//
// use it to clean up the global things that won't be destroyed
// automatically while reloading the script
setUnloadCallback(onUnload)