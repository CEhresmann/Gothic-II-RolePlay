class GUI.DataElement
{
#public:
	parent = null
	metadata = null

#private:
	_text = null
	_value = null
	_color = null
	_labelColor = null
	_file = ""
	_font = "FONT_OLD_10_WHITE_HI.TGA"
	_isDisabled = false

	constructor(parent, arg)
	{
		this.parent = parent
		metadata = "metadata" in arg ? arg.metadata : {}

		_value = "value" in arg ? arg.value : _value
		_text = ("text" in arg) ? rawstring(arg.text) : ((_value != null) ? rawstring(_value) : "")
		_color = Color(255, 255, 255, 255)
		_labelColor = Color(255, 255, 255, 255)
		_file = "file" in arg ? arg.file : _file
		_font = "font" in arg ? arg.font : _font
		_isDisabled = "disabled" in arg ? arg.disabled : _isDisabled

		setColor("color" in arg ? arg.color : _color)
		setLabelColor("labelColor" in arg ? arg.labelColor : _labelColor)
	}

	function getVisibleElement()
	{
		throw "You must override GUI.DataElement.getVisibleElement in child class!"
	}

	function getText()
	{
		return _text
	}

	function setText(text)
	{
		_text = rawstring(text)

		local visibleElement = getVisibleElement()
		if (visibleElement)
			visibleElement.setText(_text)
	}

	function getValue()
	{
		return _value
	}

	function setValue(value, updateText = true)
	{
		_value = value

		if (updateText)
			setText(value != null ? value : "")
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

		local visibleElement = getVisibleElement()
		if (visibleElement)
			visibleElement.setColor(color)
	}

	function getLabelColor()
	{
		return clone _labelColor
	}

	function setLabelColor(color)
	{
		local isColorInstance = typeof color == "Color"

		if (isColorInstance || "r" in color)
			_labelColor.r = color.r

		if (isColorInstance || "g" in color)
			_labelColor.g = color.g

		if (isColorInstance || "b" in color)
			_labelColor.b = color.b

		if (isColorInstance || "a" in color)
			_labelColor.a = color.a

		local visibleElement = getVisibleElement()
		if (visibleElement)
			visibleElement.label.setColor(color)
	}

	function getFile()
	{
		return _file
	}

	function setFile(file)
	{
		_file = file

		local visibleElement = getVisibleElement()
		if (visibleElement)
			visibleElement.setFile(file)
	}

	function getFont()
	{
		return _font
	}

	function setFont(font)
	{
		_font = font

		local visibleElement = getVisibleElement()
		if (visibleElement)
			visibleElement.setFont(font)
	}

	function getDisabled()
	{
		return _isDisabled
	}

	function setDisabled(disabled)
	{
		_isDisabled = disabled

		local visibleElement = getVisibleElement()
		if (visibleElement)
			visibleElement.setDisabled(disabled)
	}
}