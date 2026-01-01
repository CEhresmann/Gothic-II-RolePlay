local window = GUI.Window({
	positionPx = {x = 0, y = 0}
	sizePx = {width = 400, height = 80}
	file = "MENU_INGAME.TGA"
})


local chooseLangLabel = GUI.Label({
	positionPx = {x = 20, y = 20}
	text = "choose your language:"
	collection = window
})

local greetingsLabel = GUI.Label({
	positionPx = {x = 180, y = 50}
	text = "Witaj"
	collection = window
})

local langDropDownList = GUI.DropDownList({
	positionPx = {x = 240, y = 20}
	sizePx = {width = 120, height = 20}
	marginPx = [20]
	maxHeightPx = 500
	file = "MENU_INGAME.TGA"
	label = {text = "DropDownList"}
	list = {file = "MENU_INGAME.TGA"}
	scrollbar = {
		range = {
			file = "MENU_INGAME.TGA"
			indicator = {file = "BAR_MISC.TGA"}
		}
		increaseButton = {file = "U.TGA"}
		decreaseButton = {file = "O.TGA"}
	},

	rows = [
		{text = "English"}
		{text = "Polish"}
		{text = "Russian"}
		{text = "German"}
	]

	selectedIndex = 1
	collection = window
})

addEventHandler("onInit", function()
{
	window.setVisible(true)
})

langDropDownList.bind(EventType.Change, function(self)
{
	switch (self.getSelectedIndex())
	{
		case 0:
			greetingsLabel.setText("Hello")
			break

		case 1:
			greetingsLabel.setText("Witaj")
			break
		
		case 2:
			greetingsLabel.setText("Privet")
			break

		case 3:
			greetingsLabel.setText("Hallo")
			break
	}
})