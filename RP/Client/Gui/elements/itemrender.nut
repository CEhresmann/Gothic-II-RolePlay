local GUIItemRenderClasses = classes(ItemRender, GUI.Base, GUI.Event)
class GUI.ItemRender extends GUIItemRenderClasses
{
	constructor(arg = null)
	{
		ItemRender.constructor.call(this, 0, 0, 0, 0, "")
		GUI.Base.constructor.call(this, arg)
		GUI.Event.constructor.call(this, arg)

		if ("sizePx" in arg)
			ItemRender.setSizePx.call(this, arg.sizePx.width, arg.sizePx.height)
		else if("size" in arg)
			ItemRender.setSize.call(this, arg.size.width, arg.size.height)

		if ("positionPx" in arg)
			ItemRender.setPositionPx.call(this, arg.positionPx.x, arg.positionPx.y)
		else if("position" in arg)
			ItemRender.setPosition.call(this, arg.position.x, arg.position.y)
		else if ("relativePositionPx" in arg)
		{
			local collectionPositionPx = collection.getPositionPx()
			ItemRender.setPositionPx.call(this, collectionPositionPx.x + arg.relativePositionPx.x, collectionPositionPx.y + arg.relativePositionPx.y)
		}
		else if ("relativePosition" in arg)
		{
			local collectionPosition = collection.getPosition()
			ItemRender.setPosition.call(this, collectionPosition.x + arg.relativePosition.x, collectionPosition.y + arg.relativePosition.y)
		}

		instance = "instance" in arg ? arg.instance : ""
	}

	function getPosition()
	{
		return GUI.Base.getPosition.call(this)
	}

	function setPosition(x, y)
	{
		GUI.Base.setPosition.call(this, x, y)
	}

	function getSize()
	{
		return GUI.Base.getSize.call(this)
	}

	function setSize(x, y)
	{
		GUI.Base.setSize.call(this, x, y)
	}

	function top()
	{
		GUI.Event.top.call(this)
		ItemRender.top.call(this)
	}

	function getVisible()
	{
		return this.visible
	}

	function setVisible(visible)
	{
		GUI.Event.setVisible.call(this, visible)
		GUI.Base.setVisible.call(this, visible)
		this.visible = visible
	}

	function setDisabled(disabled)
	{
		GUI.Event.setDisabled.call(this, disabled)
		GUI.Base.setDisabled.call(this, disabled)
	}

	function setRotation(rotX, rotY, rotZ)
	{
		this.rotX = rotX
		this.rotY = rotY
		this.rotZ = rotZ
	}

	function getRotation()
	{
		return	{
			rotX = this.rotX,
			rotY = this.rotY,
			rotZ = this.rotZ,
		}
	}

	function setZbias(zbias)
	{
		this.zbias = zbias
	}

	function getZbias()	{
		return this.zbias
	}

	function setLightingswell(lightingswell)
	{
		this.lightingswell = lightingswell
	}

	function getLightingswell()
	{
		return this.lightingswell
	}

	function setVisual(visual)
	{
		this.visual = visual
	}

	function getVisual()
	{
		return this.visual
	}

	function setInstance(instance)
	{
		this.instance = instance
	}

	function getInstance()
	{
		return this.instance
	}
}