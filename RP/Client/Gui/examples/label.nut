local label = GUI.Label({
	position = {x = 1000, y = 1000}
	text = "[#F60005]E[#aadd20]x[#aaffff]a[#ed00ef]m[#ff7800]p[#2900ff]l[#F60005]e [#50cc29]T[#cc298a]e[#F60005]x[#50cc29]t"
	font = "FONT_OLD_20_WHITE_HI.TGA"
})

local label2 = GUI.Label({
	position = {x = 1000, y = 1250}
	text = "HOVER me"
})

local function label_onMouseIn(self)
{
	self.setColor({r = 255, g = 0, b = 0})
}

local function label_onMouseOut(self)
{
	self.setText("[#F60005]E[#aadd20]x[#aaffff]a[#ed00ef]m[#ff7800]p[#2900ff]l[#F60005]e [#50cc29]T[#cc298a]e[#F60005]x[#50cc29]t")
}

local function label2_onMouseIn(self)
{
	self.setText("[#FFFFFF]HOVE[#FF0000]RED")
}

local function label2_onMouseOut(self)
{
	self.setText("HOVER me")
}

addEventHandler("onInit",function()
{
	label.bind(EventType.MouseIn, label_onMouseIn)
	label.bind(EventType.MouseOut, label_onMouseOut)

	label2.bind(EventType.MouseIn, label2_onMouseIn)
	label2.bind(EventType.MouseOut, label2_onMouseOut)

	label.setVisible(true)
	label2.setVisible(true)
	setCursorVisible(true)
})
