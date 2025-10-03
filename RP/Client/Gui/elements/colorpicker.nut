local function rgbToHsv(r, g, b)
{
	r /= 255.0
	g /= 255.0
	b /= 255.0

	local v = max(r, g, b)
	local c = v - min(r, g, b)
	local s = v != 0 ? c / v : 0

	local h = 0
	if (c != 0)
	{
		if (v == r)
			h = (g - b) / c
		else if (v == g)
			h = 2 + (b - r) / c
		else if (v == b)
			h = 4 + (r - g) / c
	}

	if (h < 0)
		h += 6

	return {h = 60 * h, s = s, v = v}
}

local function hsvToRgb(h, s, v)
{
    local getColorComponent = function(n)
    {
        local k = (n + h / 60) % 6
        local r = (v - v * s * max(min(k, 4 - k, 1), 0)) * 255
        return round(r).tointeger()
    }

    return Color(getColorComponent(5), getColorComponent(3), getColorComponent(1))
}

class GUI.ColorPicker extends GUI.Texture
{
#public:
	indicator = null
	brightnessRange = null
	alphaRange = null

	constructor(arg = null)
	{
		indicator = GUI.Texture("indicator" in arg ? arg.indicator : null)
		indicator.parent = this

		brightnessRange = GUI.Range(arg.brightnessRange)
		brightnessRange.parent = this

		alphaRange = GUI.Range(arg.alphaRange)
		alphaRange.parent = this

		base.constructor(arg)

		if ("pickedColor" in arg)
			this.setPickedColor(arg.pickedColor)
		else
		{
			local positionPx = getPositionPx()
			local sizePx = getSizePx()

			setIndicatorPositionPx(positionPx.x + sizePx.width / 2, positionPx.y + sizePx.height / 2)
		}

		updateRangeCoords()

		this.bind(EventType.MouseDown, onMouseDown)
		this.bind(EventType.MouseDrag, onMouseDrag)

		brightnessRange.bind(EventType.Change, onChange)
		alphaRange.bind(EventType.Change, onChange)
	}

	function updateRangeCoords()
	{
		local positionPx = getPositionPx()
		local sizePx = getSizePx()

		brightnessRange.setPositionPx(positionPx.x, positionPx.y + sizePx.height + 10)
		brightnessRange.setSizePx(sizePx.width, brightnessRange.getSizePx().height)

		alphaRange.setPositionPx(positionPx.x + sizePx.width + 10, positionPx.y)
		alphaRange.setSizePx(alphaRange.getSizePx().width, sizePx.height)
	}

	function setIndicatorPositionPx(x, y)
	{
		local positionPx = getPositionPx()
		local sizePx = getSizePx()

		local indicatorSizePx = indicator.getSizePx()

		indicator.setPositionPx(
			clamp(x - indicatorSizePx.width / 2, positionPx.x - indicatorSizePx.width / 2, positionPx.x + sizePx.width - indicatorSizePx.width / 2),
			clamp(y - indicatorSizePx.height / 2, positionPx.y - indicatorSizePx.width / 2, positionPx.y + sizePx.height - indicatorSizePx.height / 2)
		)
	}

	function getPickedColor()
	{
		local positionPx = getPositionPx()
		local sizePx = getSizePx()

		local indicatorSizePx = indicator.getSizePx()
		local indicatorPositionPx = indicator.getPositionPx()

		indicatorPositionPx.x += indicatorSizePx.width / 2
		indicatorPositionPx.y += indicatorSizePx.height / 2

		local h = ((indicatorPositionPx.x - positionPx.x) / sizePx.width.tofloat()) * 360
		local s = (indicatorPositionPx.y - positionPx.y) / sizePx.height.tofloat()
		local v = brightnessRange.getValue() / brightnessRange.getMaximum().tofloat()

		local color = hsvToRgb(clamp(h, 0.0, 360.0), clamp(1.0 - s, 0.0, 1.0), v)
		color.a = alphaRange.getValue()

		return color
	}

	function setPickedColor(color)
	{
		local positionPx = getPositionPx()
		local sizePx = getSizePx()

		local hsv = rgbToHsv(color.r, color.g, color.b)

		local x = positionPx.x + sizePx.width * (hsv.h / 360.0)
		local y = positionPx.y + sizePx.height * (1.0 - hsv.s)

		setIndicatorPositionPx(x, y)

		brightnessRange.setValue(brightnessRange.getMaximum() * hsv.v)
		alphaRange.setValue(color.a)
	}

	function setPositionPx(x, y)
	{
		local positionPx = getPositionPx()
		base.setPositionPx(x, y)

		local offsetXPx = x - positionPx.x
		local offsetYPx = y - positionPx.y

		local indicatorPositionPx = indicator.getPositionPx()
		indicator.setPositionPx(indicatorPositionPx.x + offsetXPx, indicatorPositionPx.y + offsetYPx)

		local brightnessRangePositionPx = brightnessRange.getPositionPx()
		brightnessRange.setPositionPx(brightnessRangePositionPx.x + offsetXPx, brightnessRangePositionPx.y + offsetYPx)

		local alphaRangePositionPx = alphaRange.getPositionPx()
		alphaRange.setPositionPx(alphaRangePositionPx.x + offsetXPx, alphaRangePositionPx.y + offsetYPx)
	}

	function setSizePx(width, height)
	{
		local pickedColor = getPickedColor()

		local sizePx = getSizePx()
		base.setSizePx(width, height)

		updateRangeCoords()
		setPickedColor(pickedColor)
	}

	function setVisible(visible)
	{
		base.setVisible(visible)
		indicator.setVisible(visible)

		brightnessRange.setVisible(visible)
		alphaRange.setVisible(visible)
	}

	function top()
	{
		base.top()
		indicator.top()

		brightnessRange.top()
		alphaRange.top()
	}

	function onMouseDown(self, btn)
	{
		local cursorPositionPx = getCursorPositionPx()
		self.setIndicatorPositionPx(cursorPositionPx.x, cursorPositionPx.y)

		self.call(EventType.Change)
		callEvent("GUI.onChange", self)
	}

	function onMouseDrag(self, x, y)
	{
		self.setIndicatorPositionPx(x, y)

		self.call(EventType.Change)
		callEvent("GUI.onChange", self)
	}

	function onChange(self)
	{
		self.parent.call(EventType.Change)
		callEvent("GUI.onChange", self.parent)
	}
}