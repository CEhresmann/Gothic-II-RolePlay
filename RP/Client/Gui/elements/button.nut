local GUIButtonClasses = classes(GUI.Sprite, GUI.Alignment, GUI.Offset)
class GUI.Button extends GUIButtonClasses
{
#public:
	label = null

	constructor(arg = null)
	{
		if ("label" in arg)
		{
			label = GUI.Label(arg.label)
			label.setDisabled(true)

			GUI.Offset.constructor.call(this, arg)
			_alignment = "align" in arg ? arg.align : Align.Center
		}

		GUI.Sprite.constructor.call(this, arg)
		if (label)
			alignLabel()
	}

	function setOffsetPx(x, y)
	{
		GUI.Offset.setOffsetPx.call(this, x, y)

		if (label)
			alignLabel()
	}

	function setAlignment(alignment)
	{
		GUI.Alignment.setAlignment.call(this, alignment)

		if (label)
			alignLabel()
	}

	function setVisible(visible)
	{
		GUI.Sprite.setVisible.call(this, visible)

		if (label)
			label.setVisible(visible)
	}

	function top()
	{
		GUI.Sprite.top.call(this)

		if (label)
			label.top()
	}

	function setPositionPx(x, y)
	{
		local positionPx = getPositionPx()
		GUI.Sprite.setPositionPx.call(this, x, y)

		if (label)
		{
			local offsetXPx = x - positionPx.x
			local offsetYPx = y - positionPx.y

			local labelPositionPx = label.getPositionPx()
			label.setPositionPx(labelPositionPx.x + offsetXPx, labelPositionPx.y + offsetYPx)
		}
	}

	function setSizePx(width, height)
	{
		GUI.Sprite.setSizePx.call(this, width, height)

		if (label)
			alignLabel()
	}

	function getText()
	{
		if (!label)
			return ""

		return label.getText()
	}

	function setText(text)
	{
		if (!label)
			return

		label.setText(text)
		alignLabel()
	}

	function getFont()
	{
		if (!label)
			return ""

		return label.getFont()
	}

	function setFont(font)
	{
		if (!label)
			return

		label.setFont(font)
		alignLabel()
	}

	function setScale(x, y)
	{
		if (!label)
			return

		label.setScale(x, y)
		alignLabel()
	}

	function alignLabel()
	{
		local positionPx = getPositionPx()
		local offsetPx = getOffsetPx()
		local sizePx = getSizePx()
		local labelSizePx = label.getSizePx()
		local labelPositionXPx = positionPx.x + offsetPx.x
		local labelPositionYPx = positionPx.y + offsetPx.y + (sizePx.height > 0 ? (sizePx.height - labelSizePx.height) / 2 : 0)

		switch (_alignment)
		{
			case Align.Left:
				label.setPositionPx(labelPositionXPx, labelPositionYPx)
				break

			case Align.Center:
				label.setPositionPx(labelPositionXPx + (sizePx.width - labelSizePx.width) / 2, labelPositionYPx)
				break

			case Align.Right:
				label.setPositionPx(labelPositionXPx + sizePx.width - labelSizePx.width, labelPositionYPx)
				break
		}		
	}
}