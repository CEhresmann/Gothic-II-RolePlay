local sprite = GUI.Sprite({
	position = {x = 0, y = 0}
	size = {width = 2048, height = 2048}
	file = "INV_TITEL.TGA"
	scaling = true
})

local animSprite = GUI.Sprite({
	position = {x = 2048, y = 4096}
	size = {width = 4096, height = 4096}
	file = "OWODWFALL_HITSURFACE_A0.TGA"
	scaling = true
	beginFrame = 0
	endFrame = 14
	FPS = 10
})

addEventHandler("onInit", function()
{
	sprite.setVisible(true)
	animSprite.setVisible(true)

	setCursorVisible(true)
})

sprite.bind(EventType.MouseIn, function(self)
{
	self.setColor({r = 255, g = 255, b = 0})
	animSprite.stop()
})

sprite.bind(EventType.MouseOut, function(self)
{
	self.setColor({r = 255, g = 255, b = 255})
	animSprite.play()
})

sprite.bind(EventType.MouseDown, function(self, btn)
{
	self.setColor(0, 255, 0)
})

sprite.bind(EventType.MouseUp, function(self, btn)
{
	if (self.isMouseAt())
		self.setColor({r = 255, g = 255, b = 0})
	else
		self.setColor({r = 255, g = 255, b = 255})
})
