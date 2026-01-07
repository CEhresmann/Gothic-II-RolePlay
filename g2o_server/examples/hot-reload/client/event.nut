local function onCommand(cmd, arg)
{
	// try introducing new commands while server is running
	// by saving this file in your text editor

	switch (cmd)
	{
		case "client-hello":
			Chat.print(255, 255, 255, "Client says: World!")
			break
	}
}

local function onReload()
{
	// bind the function to onCommand event
	addEventHandler("onCommand", onCommand)
}

// register reload callback that will be called:
// - when scripts get initialized for the first time
// - when you introduce changes to this file and save it in your editor
setReloadCallback(onReload)

local function onUnload()
{
	// unbind the function from onCommand event
	removeEventHandler("onCommand", onCommand)
}

// register unload callback that will be called:
// - before the current script is about to be unloaded
//
// use it to clean up the global things that won't be destroyed
// automatically while reloading the script
setUnloadCallback(onUnload)