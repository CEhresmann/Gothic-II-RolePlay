local GUILabelClasses = classes(GUI.Base, GUI.Event)
class GUI.Label extends GUILabelClasses
{
#private:
	_positionPx = null
	_sizePx = null

	_scale = null

	_lineSizePx = 0

	_text = ""
	_richText = ""
	_font = "FONT_OLD_10_WHITE_HI.TGA"

	_color = null

	_labels = null
	_labelsCount = 1

	constructor(arg = null)
	{
		GUI.Base.constructor.call(this, arg)
		GUI.Event.constructor.call(this, arg)

		_labels = [Label(0, 0, "")]
		_sizePx = {width = 0.0, height = 0.0}
		_scale = "scale" in arg ? {width = arg.scale.width, height = arg.scale.height} : {width = 1.0, height = 1.0}
		_font = "font" in arg ? arg.font : _font

		_color = Color(255, 255, 255, 255)
		if ("color" in arg)
			setColor(arg.color)

		updateLineSize()

		if ("positionPx" in arg)
			_positionPx = {x = arg.positionPx.x, y = arg.positionPx.y}
		else if("position" in arg)
			_positionPx = {x = nax(arg.position.x), y = nay(arg.position.y)}
		else if ("relativePositionPx" in arg)
		{
			local collectionPositionPx = collection.getPositionPx()
			_positionPx = {x = collectionPositionPx.x + arg.relativePositionPx.x, y = collectionPositionPx.y + arg.relativePositionPx.y}
		}
		else if ("relativePosition" in arg)
		{
			local collectionPositionPx = collection.getPositionPx()
			_positionPx = {x = collectionPositionPx.x + nax(arg.relativePosition.x), y = collectionPositionPx.y + nay(arg.relativePosition.y)}
		}
		else
			_positionPx = {x = 0, y = 0}

		setText("text" in arg ? arg.text : "", "colorParserEnabled" in arg ? arg.colorParserEnabled : true)
	}

	function updateLineSize()
	{
		local oldFont = textGetFont()

		textSetFont(_font)
		_lineSizePx = letterHeightPx()
		textSetFont(oldFont)
	}

	function setVisible(visible)
	{
		GUI.Event.setVisible.call(this, visible)
		GUI.Base.setVisible.call(this, visible)

		for (local i = 0; i != _labelsCount; ++i)
			_labels[i].visible = visible
	}

	function setDisabled(disabled)
	{
		GUI.Event.setDisabled.call(this, disabled)
		GUI.Base.setDisabled.call(this, disabled)
	}

	function getPositionPx()
	{
		return _positionPx
	}

	function setPositionPx(x, y)
	{
		local offsetXPx = x - _positionPx.x
		local offsetYPx = y - _positionPx.y

		_positionPx.x = x
		_positionPx.y = y

		for (local i = 0; i != _labelsCount; ++i)
		{
			local label = _labels[i]
			local labelPositionPx = label.getPositionPx()

			label.setPositionPx(labelPositionPx.x + offsetXPx, labelPositionPx.y + offsetYPx)
		}
	}

	function getSizePx()
	{
		return _sizePx
	}

	function getLineSizePx()
	{
		return _lineSizePx * _scale.height
	}

	function setLineSizePx(lineSize)
	{
		_lineSizePx = lineSize

		setText(getText())
	}

	function getLineSize()
	{
		return any(getLineSizePx())
	}

	function setLineSize(lineSize)
	{
		setLineSizePx(any(lineSize))
	}

	function getLinesCount()
	{
		return getSizePx().height / getLineSizePx()
	}

	function top()
	{
		GUI.Event.top.call(this)

		for (local i = 0; i != _labelsCount; ++i)
			_labels[i].top()
	}

	function parse(text, colorParserEnabled = true)
	{
		local info = []

		local expression = "\\n"
		expression += (colorParserEnabled) ? "|\\[#[0-9_a-f_A-F]{6,}\\]" : ""

		local regex = regexp(expression)

		local currentPosition = 0
		local currentColor = _color

		_text = ""

		local result = null
		while (result = regex.search(text, currentPosition))
		{
			local isEOLFound = (result.end - result.begin == 1)
			local endPosition = (isEOLFound) ? result.end - 1 : result.begin

			local slicedText = text.slice(currentPosition, endPosition)

			if (slicedText != "" || isEOLFound)
			{
				info.push({text = slicedText, color = currentColor, newLine = isEOLFound})
				_text += slicedText
			}

			currentPosition = result.end
			currentColor = (isEOLFound) ? currentColor : hexToRgb(text.slice(result.begin + 2, result.end - 1))
		}

		local slicedText = text.slice(currentPosition, text.len())

		_text += slicedText
		info.push({text = slicedText, color = currentColor, newLine = false})

		if (info.len())
			return info

		return null
	}

	function getText()
	{
		return _text
	}

	function getRichText()
	{
		return _richText
	}

	function setText(text, colorParserEnabled = true)
	{
		if (typeof text != "string")
			text = rawstring(text)

		_richText = text

		if (text == "")
		{
			foreach (label in _labels)
				label.text = ""

			_sizePx.width = 0
			_sizePx.height = getLineSizePx()

			_labelsCount = 0
			_text = ""

			return
		}

		local lineHeightPx = getLineSizePx()
		local lineWidthPx = 0

		local positionPxX = _positionPx.x
		local positionPxY = _positionPx.y

		local widthPx = 0
		local heightPx = lineHeightPx

		local i = 0
		foreach (info in parse(text, colorParserEnabled))
		{
			local label = null

			if (info.text != "")
			{
				if (_labels.len() <= i)
					_labels.push(Label(0, 0, ""))

				label = _labels[i]

				label.setPositionPx(positionPxX, positionPxY)
				label.setScale(_scale.width, _scale.height)

				label.color.set(info.color.r, info.color.g, info.color.b, _color.a)

				label.font = _font
				label.text = info.text

				label.visible = _visible

				++i
			}

			if (info.newLine)
			{
				if (label)
					lineWidthPx += label.widthPx

				if (lineWidthPx > widthPx)
					widthPx = lineWidthPx

				lineWidthPx = 0
				heightPx += lineHeightPx

				positionPxX = _positionPx.x
				positionPxY += lineHeightPx
			}
			else if (label)
			{
				positionPxX += label.widthPx
				lineWidthPx += label.widthPx
			}
		}

		local lineWidthPx = positionPxX - _positionPx.x
		if (lineWidthPx > widthPx)
			widthPx = lineWidthPx

		_sizePx.width = widthPx
		_sizePx.height = heightPx

		_labelsCount = i

		for (local i = _labels.len() - 1; i >= _labelsCount; --i)
			_labels[i].visible = false
	}

	function getFont()
	{
		return _font
	}

	function setFont(font)
	{
		if (font == _font)
			return

		_font = font

		updateLineSize()

		setText(getText())
	}

	function getColor()
	{
		return clone _color
	}

	function setColor(color)
	{
		local isColorInstance = typeof color == "Color"

		if (isColorInstance || "r" in color)
			_color.r = color.r

		if (isColorInstance || "g" in color)
			_color.g = color.g

		if (isColorInstance || "b" in color)
			_color.b = color.b

		if (isColorInstance || "a" in color)
			_color.a = color.a

		for (local i = 0; i != _labelsCount; ++i)
			_labels[i].color.set(_color.r, _color.g, _color.b)
	}

	function getScale()
	{
		return _scale
	}

	function setScale(width, height)
	{
		_scale.width = width
		_scale.height = height

		setText(getRichText())
	}
}