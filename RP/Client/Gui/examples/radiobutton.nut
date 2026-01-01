local descriptionLabel = GUI.Label({
	positionPx = {x = 10, y = 125}
	text = "Choose your gender:"
})

local maleRadioButton = GUI.RadioButton({
	positionPx = {x = 10, y = 147}
	sizePx = {width = 20, height = 15}
	file = "INV_SLOT_EQUIPPED_FOCUS.TGA"
	label = {text = "O"}
	group = "Gender"
})

local maleDescriptionLabel = GUI.Label({
	positionPx = {x = 35, y = 147}
	text = "Male"
}) 

local femaleRadioButton = GUI.RadioButton({
	positionPx = {x = 10, y = 169}
	sizePx = {width = 20, height = 15}
	file = "INV_SLOT_EQUIPPED_FOCUS.TGA"
	label = {text = "O"}
	group = "Gender"
})

local femaleDescriptionLabel = GUI.Label({
	positionPx = {x = 35, y = 169}
	text = "Female"
}) 

local soirefRadioButton = GUI.RadioButton({
	positionPx = {x = 10, y = 191}
	sizePx = {width = 20, height = 15}
	file = "INV_SLOT_EQUIPPED_FOCUS.TGA"
	label = {text = "O"}
	group = "Gender"
})

local soirefDescriptionLabel = GUI.Label({
	positionPx = {x = 35, y = 191}
	text = "Soiref"
}) 

addEventHandler("onInit",function()
{
	descriptionLabel.setVisible(true)

	maleRadioButton.setVisible(true)
	maleDescriptionLabel.setVisible(true)
	
	femaleRadioButton.setVisible(true)
	femaleDescriptionLabel.setVisible(true)
	
	soirefRadioButton.setVisible(true)
	soirefDescriptionLabel.setVisible(true)
	
	setCursorVisible(true)
})
