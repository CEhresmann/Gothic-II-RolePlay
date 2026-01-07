// try changing some of the values
// saving this file will cause it to be hot reloaded
local sprite = Sprite(2048, 2048, 4096, 4096, "MENU_INGAME.TGA")
local label = Label(0, 0, "Title text")

local function onReload()
{
	// set label font
	label.font = "FONT_OLD_20_WHITE.TGA"

	// center label
	local spritePosition = sprite.getPosition()
	local spriteSize = sprite.getSize()

	label.setPosition(spritePosition.x + (spriteSize.width - label.width) / 2, spritePosition.y + 400)

	// show UI elements
	sprite.visible = true
	label.visible = true
}

// register reload callback that will be called:
// - when scripts get initialized for the first time
// - when you introduce changes to this file and save it in your editor
setReloadCallback(onReload)