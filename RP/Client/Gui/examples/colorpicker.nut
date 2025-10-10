local colorPicker = GUI.ColorPicker({
	positionPx = {x = 75, y = 100}
	sizePx = {width = 255, height = 255}
	file = "HSV.TGA"

	indicator = {
		positionPx = {x = 125, y = 150}
		sizePx = {width = 12, height = 12}
		file = "CIRCLE.TGA"
		color = Color(0, 0, 0)
	}

	brightnessRange = {
		sizePx = {width = 0, height = 12}
		marginPx = {top = -2, bottom = -2}
		file = "GRAYSCALE_HORIZONTAL.TGA"
		indicator = {file = "SLIDER_HORIZONTAL.TGA"}
		indicatorSizePx = 7
		minimum = 0
		maximum = 255
		value = 255
		step = 1
		orientation = Orientation.Horizontal
	}

	alphaRange = {
		sizePx = {width = 12, height = 0}
		marginPx = {left = -2, right = -2}
		file = "GRAYSCALE_VERTICAL.TGA"
		indicator = {file = "SLIDER_VERTICAL.TGA"}
		indicatorSizePx = 7
		minimum = 255
		maximum = 0
		value = 255
		step = 1
		orientation = Orientation.Vertical
	}
})

local square = GUI.Sprite({
	positionPx = {x = 30, y = 100}
	sizePx = {width = 30, height = 30}
	color = colorPicker.getPickedColor()
	file = "WHITE.TGA"
})

square.bind(EventType.Click, function(self)
{
	colorPicker.setVisible(!colorPicker.getVisible())
})

colorPicker.bind(EventType.Change, function(self)
{
	local pickedColor = colorPicker.getPickedColor()
	square.color.set(pickedColor.r, pickedColor.g, pickedColor.b)
})

addEventHandler("onInit", function()
{
	square.setVisible(true)
	setCursorVisible(true)
})