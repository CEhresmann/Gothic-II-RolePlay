local text = "Counter: "
local counter = 0

local label = Label(220, 7600, "")

local function updateLabelText()
{
	++counter
	label.text = text + counter
}

local timer_id = -1

local function onReload()
{
	// update label text and show it
	updateLabelText()
	label.visible = true

	// create a new timer that will be executed infinitely with one second delay
	// try changing the arguments passed to this function
	timer_id = setTimer(updateLabelText, 1000, 0)
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