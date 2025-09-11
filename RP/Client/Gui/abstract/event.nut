local getroottable = getroottable

local ref =
{
	pointedByCursor = null,
	draggedByCursor = null,
	focused = null,
	lastClicked = null
}

local doubleClickTimestamp = null
local currentEventType = -1

local oldResolution = getResolution()
local newResolution = getResolution()

class GUI.Event
{
	static _objects = []
	static _resolutionChangeListeners = []

#protected:
	_id = -1
	_events = null

#public:
	toolTip = null
	contextMenu = null

	constructor(arg = null)
	{
		_events = array(EventType.Max)
		toolTip = "toolTip" in arg ? arg.toolTip : toolTip
		contextMenu = "contextMenu" in arg ? arg.contextMenu : contextMenu
	}

    function addToArray()
    {
		_id = _objects.len()
        _objects.push(this.weakref())
    }

    function removeFromArray()
    {
        if (_id == -1)
            return

        _objects[_id] = null
        _id = -1
    }

	function top()
	{
		if (!getVisible())
			return

		local lastIdx = _objects.len() - 1
		local tmp = _objects[_id]

		for (local i = _id; i < lastIdx; ++i)
			_objects[i] = _objects[i + 1]

		_objects[lastIdx] = tmp
	}

	function bind(event_type, callback, priority = 9999)
	{
		if (event_type == EventType.ChangeResolution && _resolutionChangeListeners.find(this) == null)
			_resolutionChangeListeners.push(this.weakref())

		local event = _events[event_type] || {handlers = [], cancelled = false}
		_events[event_type] = event

		event.handlers.push({callback = callback, priority = priority, index = event.handlers.len(), cancelled = false})
		event.handlers.sort(function(a, b)
		{
			if (a.priority == b.priority)
				return a.index <=> b.index

			return a.priority <=> b.priority
		})
	}

	function unbind(event_type, callback)
	{
		if (event_type == EventType.ChangeResolution)
		{
			local resolutionChangeListenersIdx = _resolutionChangeListeners.find(this)
			if (resolutionChangeListenersIdx != null)
				_resolutionChangeListeners.remove(resolutionChangeListenersIdx)
		}

		local event = _events[event_type]
		if (event == null)
			return

		local idx = null

		foreach (i, handler in event.handlers)
		{
			if (handler.callback == callback)
			{
				idx = i
				break
			}
		}

		if (idx != null)
			event.handlers.remove(idx)
	}

	function call(event_type, ...)
	{
		local event = _events[event_type]
		if (event == null)
			return

		vargv.insert(0, getroottable())
		vargv.insert(1, this)

		currentEventType = event_type

		foreach (handler in event.handlers)
			handler.callback.acall(vargv)

		event.cancelled = false
		currentEventType = -1
	}

	function cancel()
	{
		if (currentEventType == -1)
			return

		_events[currentEventType].cancelled = true
	}

	function isCancelled()
	{
		if (currentEventType == -1)
			return false

		return _events[currentEventType].cancelled
	}

	function setVisible(visible)
	{
		if (getVisible() == visible)
			return

		if (!visible)
		{
			if (contextMenu && contextMenu.getActiveParent() == this)
				contextMenu.setVisible(false)

			if (this == ref.pointedByCursor)
				setElementPointedByCursor(null)

			if (this == ref.focused)
				setFocusedElement(null)


			removeFromArray()
		}
		else
		{
			addToArray()

			if (isCursorVisible() && checkIsMouseAt())
				setElementPointedByCursor(this)
		}
	}

	function setDisabled(disabled)
	{
		if (!disabled)
			return

		if (isFocused())
			setFocusedElement(null)

		if (contextMenu && contextMenu.getActiveParent() == this)
			contextMenu.setVisible(false)
	}

	function checkIsMouseAt()
	{
		if (!getVisible())
			return false

		if (getDisabled())
			return false

		local positionPx = getPositionPx()
		local sizePx = getSizePx()

		local cursorPositionPx = getCursorPositionPx()

		if (cursorPositionPx.x >= positionPx.x && cursorPositionPx.x <= positionPx.x + sizePx.width
		&& cursorPositionPx.y >= positionPx.y && cursorPositionPx.y <= positionPx.y + sizePx.height)
			return true

		return false
	}

	function isMouseAt()
	{
		return ref.pointedByCursor == this
	}

	function isFocused()
	{
		return ref.focused == this
	}

	static function findElementPointedByCursor()
	{
		for (local i = _objects.len() - 1; i >= 0; --i)
		{
			local object = _objects[i]

			if (object == null)
				continue

			if (object.checkIsMouseAt())
				return object
		}

		return null
	}

	static function getElementPointedByCursor()
	{
		return ref.pointedByCursor
	}

	static function setElementPointedByCursor(newElementPointedByCursor)
	{
		if (newElementPointedByCursor == ref.pointedByCursor)
			return

		if (ref.pointedByCursor)
		{
			ref.pointedByCursor.call(EventType.MouseOut)
			callEvent("GUI.onMouseOut", ref.pointedByCursor)
		}

		ref.pointedByCursor = (newElementPointedByCursor != null) ? newElementPointedByCursor.weakref() : null

		if (newElementPointedByCursor)
		{
			newElementPointedByCursor.call(EventType.MouseIn)
			callEvent("GUI.onMouseIn", newElementPointedByCursor)
		}
	}

	static function getFocusedElement()
	{
		return ref.focused
	}

	static function setFocusedElement(newFocusedElement)
	{
		if (newFocusedElement == ref.focused)
			return

		if (ref.focused)
		{
			ref.focused.call(EventType.LostFocus)
			callEvent("GUI.onLostFocus", ref.focused)
		}

		ref.focused = (newFocusedElement != null) ? newFocusedElement.weakref() : null

		if (newFocusedElement)
		{
			newFocusedElement.call(EventType.TakeFocus)
			callEvent("GUI.onTakeFocus", newFocusedElement)
		}
	}

    static function onRender()
    {
        local deletedObjectIndicies = []
		local deletedObjects = 0

		foreach (index, object in _objects)
        {
            if (object == null)
            {
                ++deletedObjects
                deletedObjectIndicies.push(index)
                continue
            }

            object._id = index - deletedObjects

            if (!object.getVisible())
                continue

            object.call(EventType.Render)
        }

        for (local i = deletedObjectIndicies.len() - 1; i >= 0; --i)
            _objects.remove(deletedObjectIndicies[i])
    }

	static function onChangeResolution()
	{
		oldResolution = newResolution
		newResolution = getResolution()

		local deletedObjectIndicies = []

		foreach (index, object in _resolutionChangeListeners)
        {
            if (object == null)
            {
                deletedObjectIndicies.push(index)
                continue
            }

            object.call(EventType.ChangeResolution, oldResolution, newResolution)
        }

        for (local i = deletedObjectIndicies.len() - 1; i >= 0; --i)
            _resolutionChangeListeners.remove(deletedObjectIndicies[i])
	}

	static function onKeyInput(key, letter)
	{
		if (!ref.focused)
			return

		// ignore whitespace characters
		if (letter < 32 || letter == 127)
			return

		ref.focused.call(EventType.KeyInput, key, letter)
		callEvent("GUI.onKeyInput", ref.focused, key, letter)
	}

	static function onKeyDown(key)
	{
		if (!ref.focused)
			return

		ref.focused.call(EventType.KeyDown, key)
		callEvent("GUI.onKeyDown", ref.focused, key)
	}

	static function onKeyUp(key)
	{
		if (!ref.focused)
			return

		ref.focused.call(EventType.KeyUp, key)
		callEvent("GUI.onKeyUp", ref.focused, key)
	}

	static function onKeyInput(key, letter)
	{
		if (!ref.focused)
			return

		// ignore whitespace characters
		if (letter < 32 || letter == 127)
			return

		ref.focused.call(EventType.KeyInput, key, letter)
		callEvent("GUI.onKeyInput", ref.focused, key, letter)
	}

	static function onKeyDown(key)
	{
		if (!ref.focused)
			return

		ref.focused.call(EventType.KeyDown, key)
		callEvent("GUI.onKeyDown", ref.focused, key)
	}

	static function onKeyUp(key)
	{
		if (!ref.focused)
			return

		ref.focused.call(EventType.KeyUp, key)
		callEvent("GUI.onKeyUp", ref.focused, key)
	}

	static function onMouseDown(button)
	{
		if (!isCursorVisible())
			return

		setFocusedElement(ref.pointedByCursor)

		if (button == MOUSE_BUTTONLEFT)
			ref.draggedByCursor = ref.pointedByCursor

		if (!ref.pointedByCursor)
			return

		ref.pointedByCursor.call(EventType.MouseDown, button)
		callEvent("GUI.onMouseDown", ref.pointedByCursor, button)
	}

	static function onMouseUp(button)
	{
		if (!isCursorVisible())
			return

		if (!ref.focused)
			return

		ref.focused.call(EventType.MouseUp, button)
		callEvent("GUI.onMouseUp", ref.focused, button)

		if (button == MOUSE_BUTTONLEFT)
		{
			ref.focused.call(EventType.Click)
			callEvent("GUI.onClick", ref.focused)

			local now = getTickCount()
			if (ref.lastClicked == ref.focused && now <= doubleClickTimestamp)
			{
				ref.lastClicked = null
				doubleClickTimestamp = null

				ref.focused.call(EventType.DoubleClick)
				callEvent("GUI.onDoubleClick", ref.focused)
			}
			else
			{
				ref.lastClicked = (ref.focused != null) ? ref.focused.weakref() : null
				doubleClickTimestamp = (ref.focused != null) ? now + DOUBLE_CLICK_TIME : null
			}

			ref.draggedByCursor = null
		}
	}

	static function onMouseMove(x, y)
	{
		if (!isCursorVisible())
			return

		setElementPointedByCursor(findElementPointedByCursor())

		local cursorPositionPx = getCursorPositionPx()

		if (ref.pointedByCursor)
			ref.pointedByCursor.call(EventType.MouseMove, cursorPositionPx.x, cursorPositionPx.y)

		if (ref.draggedByCursor)
			ref.draggedByCursor.call(EventType.MouseDrag, cursorPositionPx.x, cursorPositionPx.y)
	}

	static function onCursorShow()
	{
		setElementPointedByCursor(findElementPointedByCursor())
	}

	static function onCursorHide()
	{
		if (ref.focused)
		{
			for (local i = MOUSE_BUTTONLEFT; i <= MOUSE_BUTTONMID; ++i)
			{
				if (!isMouseBtnPressed(i))
					continue

				ref.focused.call(EventType.MouseUp, i)
				callEvent("GUI.onMouseUp", ref.focused, i)
			}
		}

		setElementPointedByCursor(null)
	}
}

addEventHandler("onRender", GUI.Event.onRender.bindenv(GUI.Event))
addEventHandler("onChangeResolution", GUI.Event.onChangeResolution.bindenv(GUI.Event))
addEventHandler("onKeyInput", GUI.Event.onKeyInput.bindenv(GUI.Event))
addEventHandler("onKeyDown", GUI.Event.onKeyDown.bindenv(GUI.Event))
addEventHandler("onKeyUp", GUI.Event.onKeyUp.bindenv(GUI.Event))
addEventHandler("onMouseDown", GUI.Event.onMouseDown.bindenv(GUI.Event))
addEventHandler("onMouseUp", GUI.Event.onMouseUp.bindenv(GUI.Event))
addEventHandler("onMouseMove", GUI.Event.onMouseMove.bindenv(GUI.Event))

local _setCursorVisible = setCursorVisible
function setCursorVisible(toggle)
{
	if (toggle != isCursorVisible())
	{
		if (toggle)
			GUI.Event.onCursorShow()
		else
			GUI.Event.onCursorHide()
	}

	_setCursorVisible(toggle)
}
