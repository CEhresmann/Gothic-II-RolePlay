local text = "Counter: "
local counter = 0

local function printCounterText()
{
	++counter
	print(text + counter)
}

local timer_id = -1

local function onReload()
{
	// create a new timer that will be executed infinitely with one second delay
	// try changing the arguments passed to this function
	timer_id = setTimer(printCounterText, 1000, 0)
}

// register reload callback that will be called:
// - when scripts get initialized for the first time
// - when you introduce changes to this file and save it in your editor
setReloadCallback(onReload)

local function onUnload()
{
	// kill the old timer
	killTimer(timer_id)
}

// register unload callback that will be called:
// - before the current script is about to be unloaded
//
// use it to clean up the global things that won't be destroyed
// automatically while reloading the script
setUnloadCallback(onUnload)