local ref = {
	activeInput = null
}

local keyDelayFirst = getKeyDelayFirst(KEY_DELAY_GAME)
local keyDelayRate = getKeyDelayRate(KEY_DELAY_GAME)

class GUI.Input extends GUI.Button
{
	// Variables for configuration:
	_placeholder = ""
	_placeholderColor = null
	_textColor = null

	_paddingPx = 0

	_text = ""
	_value = "" // Read-only

	_selector = "|"
	_maxLetters = 1000

	// Variables for input operation:
	_offsetPos = 0
	_curPos = 0

	_textWidthPx = 0
	_maxTextWidthPx = 0
	_visibleText = ""

	_lastValue = ""

	constructor(arg = null)
	{
		if (!("label" in arg))
			arg.label <- {}

		if ("paddingPx" in arg)
			_paddingPx = arg.paddingPx
		else if("padding" in arg)
			_paddingPx = nax(arg.padding)

		base.constructor(arg)
		_placeholder = "placeholder" in arg ? arg.placeholder : _placeholder

		_placeholderColor = Color(180, 180, 180, 255)
		if ("placeholderColor" in arg)
			setPlaceholderColor(arg.placeholderColor)

		_textColor = label.getColor()
		if ("textColor" in arg)
			setTextColor(arg.textColor)

		_text = "text" in arg ? arg.text : _text
		_value = "value" in arg ? arg.value : _value

		_selector = "selector" in arg ? arg.selector : _selector
		_maxLetters = "maxLetters" in arg ? arg.maxLetters : _maxLetters

		_updateTextMaxWidthPx()
		_updateValue('=', _text)

		_lastValue = _value

		this.bind(EventType.Click, onClick.bindenv(this))
		this.bind(EventType.KeyInput, onKeyInput.bindenv(this))
		this.bind(EventType.KeyDown, onKeyDown.bindenv(this))
	}

	function alignLabel()
	{
		local positionPx = getPositionPx()
		local sizePx = getSizePx()
		local sizeLabelPx = label.getSizePx()

		switch(_alignment)
		{
			case Align.Left:
				label.setPositionPx(positionPx.x + _paddingPx, positionPx.y + sizePx.height / 2 - sizeLabelPx.height / 2)
				break

			case Align.Center:
				label.setPositionPx(positionPx.x + sizePx.width / 2 - sizeLabelPx.width / 2, positionPx.y + sizePx.height / 2 - sizeLabelPx.height / 2)
				break

			case Align.Right:
				label.setPositionPx(positionPx.x + sizePx.width - (sizeLabelPx.width + _paddingPx), positionPx.y + sizePx.height / 2 - sizeLabelPx.height / 2)
				break
		}
	}

	function setVisible(visible)
	{
		if (!visible && isActive())
			setActive(false)

		base.setVisible(visible)
	}

	function setDisabled(disabled)
	{
		if (isActive())
			setActive(false)

		base.setDisabled(disabled)
	}

	function getText()
	{
		return _text
	}

	function setText(text)
	{
		if (typeof text != "string")
			text = rawstring(text)

		if (text.len() > _maxLetters)
			text = text.slice(0, _maxLetters)

		_text = text
		_updateTextFromLen()
		_updateValue('=', text)
	}

	function setSizePx(x, y)
	{
		base.setSizePx(x, y)
		_updateTextMaxWidthPx()
	}

	function setPaddingPx(padding)
	{
		_paddingPx = padding
		_updateTextMaxWidthPx()
	}

	function isActive()
	{
		return ref.activeInput == this
	}

	function setActive(active)
	{
		ref.activeInput = active ? this : null
		_updateLabelText()

		setKeyDelayFirst(active ? getKeyDelayFirst(KEY_DELAY_SYSTEM) : keyDelayFirst)
		setKeyDelayRate(active ? getKeyDelayRate(KEY_DELAY_SYSTEM) : keyDelayRate)

		if (active)
			_lastValue = _value
		else if (_lastValue != _value)
		{
			this.call(EventType.Change)
			callEvent("GUI.onChange", this)
		}
	}

	static function getActiveInput()
	{
		return ref.activeInput
	}

	function getValue()
	{
		return _value
	}

	function getSelector()
	{
		return _selector
	}

	function setSelector(selector)
	{
		_selector = selector
		_updateLabelText()
	}

	function getMaxLetters()
	{
		return _maxLetters
	}

	function setMaxLetters(maxLetters)
	{
		_maxLetters = maxLetters
		setText(_text)
	}

	function setPlaceholder(placeholder)
	{
		_placeholder = placeholder
		_updateLabelText()
	}

	function getPlaceholderColor()
	{
		return clone _placeholderColor
	}

	function setPlaceholderColor(color)
	{
		local isColorInstance = typeof color == "Color"

		if (isColorInstance || "r" in color)
			_placeholderColor.r = color.r

		if (isColorInstance || "g" in color)
			_placeholderColor.g = color.g

		if (isColorInstance || "b" in color)
			_placeholderColor.b = color.b

		if (isColorInstance || "a" in color)
			_placeholderColor.a = color.a

		_updateLabelText()
	}

	function getTextColor()
	{
		return clone _textColor
	}

	function setTextColor(color)
	{
		local isColorInstance = typeof color == "Color"

		if (isColorInstance || "r" in color)
			_textColor.r = color.r

		if (isColorInstance || "g" in color)
			_textColor.g = color.g

		if (isColorInstance || "b" in color)
			_textColor.b = color.b

		if (isColorInstance || "a" in color)
			_textColor.a = color.a

		_updateLabelText()
	}

	function _isWhitespaceCharacter(code)
	{
		return (code >= 0 && code <= 32) || code == 127
	}

	function _isWordBreakCharacter(code)
	{
		return (code >= 33 && code <= 47)
			|| (code >= 58 && code <= 64)
			|| (code >= 91 && code <= 96)
			|| (code >= 123 && code <= 126)
	}

	function _isWordCharacter(code)
	{
		// Special characters, treat them as word part characters
		if (code == '_'
		|| 	code == '\'')
			return true

		return !_isWordBreakCharacter(code) && !_isWhitespaceCharacter(code)
	}

	function _addText(text)
	{
		local _textLen = _text.len()
		if (_textLen == _maxLetters)
			return

		local textLen = text.len()
		if (_textLen + textLen > _maxLetters)
			text = text.slice(0, _maxLetters - _textLen)

		local isSelectorAtEnd = _isSelectorAtEnd()
		local textPos = _offsetPos + _curPos

		_textWidthPx += _getTextWidthPx(text)
		_text = _text.slice(0, textPos) + text + _text.slice(textPos)

		if (!_isTextCutted())
		{
			_updateVisibleText(isSelectorAtEnd ? _visibleText + text : _visibleText.slice(0, _curPos) + text + _visibleText.slice(_curPos))
			_curPos += textLen
		}
		else
		{
			if (isSelectorAtEnd)
			{
				_offsetPos += textLen
				_updateVisibleTextFromEnd()
			}
			else
			{
				_curPos += textLen
				_updateVisibleTextFromStart()
			}
		}

		_updateValue('+', text)
		_updateLabelText()
	}

	function _removeLetterBefore()
	{
		local textPos = _offsetPos + _curPos
		if (textPos == 0)
			return

		local visibleTextLen = _visibleText.len()
		local curIndex = textPos - 1

		local removedLetter = _text[curIndex].tochar()

		_textWidthPx -= _getTextWidthPx(removedLetter)
		_text = _text.slice(0, curIndex) + _text.slice(textPos)

		if (!_isTextCutted())
		{
			_updateVisibleText(_text)
			_curPos = _text.len() - (visibleTextLen - _curPos)
			_offsetPos = 0
		}
		else if (_offsetPos == 0)
		{
			if (_curPos > 0)
				--_curPos

			_updateVisibleTextFromStart()
		}
		else if (_offsetPos > 0)
			_updateVisibleTextAfterRemove()

		_updateValue('-', removedLetter)
		_updateLabelText()
	}

	function _removeLetterAfter()
	{
		local curIndex = _offsetPos + _curPos
		if (curIndex == _text.len())
			return

		local removedLetter = _text[curIndex].tochar()

		_textWidthPx -= _getTextWidthPx(removedLetter)
		_text = _text.slice(0, curIndex) + _text.slice(curIndex + 1)

		if (!_isTextCutted())
		{
			_updateVisibleText(_text)
			_offsetPos = 0
		}
		else if (_offsetPos == 0)
			_updateVisibleTextFromStart()
		else if (_offsetPos > 0)
			_updateVisibleTextAfterRemove()

		_updateValue('-', removedLetter)
		_updateLabelText()
	}

	function _goLeft(moveToWord)
	{
		local textPos = _offsetPos + _curPos
		if (textPos == 0)
			return

		_curPos -= moveToWord ? textPos - _getWordIdxLeft(textPos - 1) : 1

		if (_curPos < 0)
		{
			_offsetPos = _offsetPos + _curPos
			_curPos = 0

			_updateVisibleTextFromStart()
		}

		_updateLabelText()
	}

	function _goRight(moveToWord)
	{
		local textPos = _offsetPos + _curPos
		if (textPos == _text.len())
			return

		_curPos += moveToWord ? _getWordIdxRight(textPos) - textPos : 1

		local visibleTextLen = _visibleText.len()
		if (_curPos > visibleTextLen)
		{
			local count = _curPos - visibleTextLen

			_offsetPos = _offsetPos + count
			_curPos = visibleTextLen

			_updateVisibleTextFromEnd()
		}

		_updateLabelText()
	}

	function _goToBegin()
	{
		_curPos = 0
		_offsetPos = 0
		_updateVisibleTextFromStart()
		_updateLabelText()
	}

	function _goToEnd()
	{
		_updateTextFromLen()
	}

	function _getTextWidthPx(text)
	{
		local oldFont = textGetFont()
		textSetFont(label.getFont())

		local widthPx = textWidthPx(text)
		textSetFont(oldFont)

		return widthPx
	}

	function _isTextCutted()
	{
		return _textWidthPx > _maxTextWidthPx
	}

	function _isSelectorAtEnd()
	{
		return _curPos == _visibleText.len()
	}

	function _updateLabelText()
	{
		local isActive = isActive()
		if (_text == "")
		{
			label.setColor(_placeholderColor)
			base.setText(isActive ? _selector + _placeholder : _placeholder)
		}
		else
		{
			label.setColor(_textColor)
			base.setText(isActive ? _visibleText.slice(0, _curPos) + _selector + _visibleText.slice(_curPos) : _visibleText)
		}
	}

	function _updateValue(opcode, value)
	{
		_value = _text
	}

	function _getViewFromStart(begin, end, widthPx = 0)
	{
		local text = ""

		local i = begin
		while (i < end)
		{
			local letter = _text[i].tochar()
			local letterWidthPx = textWidthPx(letter)

			if (widthPx + letterWidthPx >= _maxTextWidthPx)
				break

			widthPx += letterWidthPx
			text += letter

			++i
		}

		return {text = text, widthPx = widthPx, idx = i}
	}

	function _getViewFromEnd(begin, end, widthPx = 0)
	{
		local text = ""

		local i = begin
		while (i >= end)
		{
			local letter = _text[i].tochar()
			local letterWidthPx = textWidthPx(letter)

			if (widthPx + letterWidthPx >= _maxTextWidthPx)
				break

			widthPx += letterWidthPx
			text = letter + text

			--i
		}

		return {text = text, widthPx = widthPx, idx = i}
	}

	function _getWordIdxLeft(begin)
	{
		local i = begin
		local previousCharacterType = _isWordCharacter(_text[i])

		while(i >= 0)
		{
			local currentCharacterType = _isWordCharacter(_text[i])
			if (previousCharacterType != currentCharacterType)
				break

			--i
		}

		return i + 1
	}

	function _getWordIdxRight(begin)
	{
		local i = begin
		local end = _text.len()

		local previousCharacterType = _isWordCharacter(_text[i])

		while(i < end)
		{
			local currentCharacterType = _isWordCharacter(_text[i])
			if (previousCharacterType != currentCharacterType)
				break

			++i
		}

		return i
	}

	function _updateVisibleText(text)
	{
		_visibleText = text
	}

	function _updateVisibleTextFromStart()
	{
		local oldFont = textGetFont()

		textSetFont(label.getFont())
		_updateVisibleText(_getViewFromStart(_offsetPos, _text.len()).text)
		textSetFont(oldFont)
	}

	function _updateVisibleTextFromEnd()
	{
		local oldFont = textGetFont()
		textSetFont(label.getFont())

		local view = _getViewFromEnd(_offsetPos + _curPos - 1, 0)

		_updateVisibleText(view.text)
		_curPos = _visibleText.len()
		_offsetPos = view.idx + 1

		textSetFont(oldFont)
	}

	function _updateVisibleTextAfterRemove()
	{
		local oldFont = textGetFont()
		textSetFont(label.getFont())

		local oldVisibleTextLen = _visibleText.len()
		local startIndex = _offsetPos + _curPos - 1

		local suffixView = _getViewFromStart(startIndex,  _offsetPos + oldVisibleTextLen - 1)
		local prefixView = _getViewFromEnd(startIndex - 1, 0, suffixView.widthPx)

		_updateVisibleText(prefixView.text + suffixView.text)
		local newVisibleTextLen = _visibleText.len()

		_curPos = newVisibleTextLen - (oldVisibleTextLen - _curPos)
		_offsetPos = prefixView.idx + 1

		textSetFont(oldFont)
	}

	function _updateTextFromLen()
	{
		local oldFont = textGetFont()
		textSetFont(label.getFont())

		local textLen =  _text.len()

		_updateVisibleText(_getViewFromEnd(textLen - 1, 0).text)
		local visibleTextLen = _visibleText.len()

		_curPos = visibleTextLen
		_offsetPos = textLen - visibleTextLen

		_updateLabelText()
		textSetFont(oldFont)
	}

	function _updateTextMaxWidthPx()
	{
		_maxTextWidthPx = getSizePx().width - _paddingPx * 2
		_updateTextFromLen()
	}

	function onClick(self)
	{
		if (ref.activeInput != this)
			setActive(true)

		local cursorPos = getCursorPositionPx().x
		local labelPos = label.getPositionPx().x

		local newPos = cursorPos - labelPos
		if (newPos < 0)
			newPos = 0

		local visibleLen = _visibleText.len()
		local i = 0

		if (newPos < label.getSizePx().width)
		{
			local oldFont = textGetFont()
			textSetFont(label.getFont())

			for (local curWidth = 0; i < visibleLen && curWidth < newPos; ++i)
				curWidth += textWidthPx(_visibleText[i].tochar())

			if (i > visibleLen)
				i = visibleLen

			textSetFont(oldFont)
		}
		else
			i = visibleLen

		if (i != _curPos)
		{
			_curPos = i
			_updateLabelText()
		}
	}

	function onKeyInput(self, key, letter)
	{
		if (self != ref.activeInput)
			return

		if (letter >= 32 && letter != 127)
			_addText(letter.tochar())
	}

	function onKeyDown(self, key)
	{
		if (self != ref.activeInput)
			return

		cancelEvent()

		local ctrlPressed = isKeyPressed(KEY_LCONTROL) || isKeyPressed(KEY_RCONTROL)

		switch (key)
		{
			case KEY_HOME:
				_goToBegin()
				break

			case KEY_END:
				_goToEnd()
				break

			case KEY_LEFT:
				_goLeft(ctrlPressed)
				break

			case KEY_RIGHT:
				_goRight(ctrlPressed)
				break

			case KEY_BACK:
				_removeLetterBefore()

				ref.activeInput.call(EventType.KeyInput, key, '\b')
				callEvent("GUI.onKeyInput", ref.activeInput, key, '\b')
				break

			case KEY_DELETE:
				_removeLetterAfter()

				ref.activeInput.call(EventType.KeyInput, key, 0x7F)
				callEvent("GUI.onKeyInput", ref.activeInput, key, 0x7F)
				break
		}
	}

	static function onMouseDown(button)
	{
		if (!isCursorVisible())
			return

		local elementPointedByCursor = GUI.Event.getElementPointedByCursor()
		if (elementPointedByCursor == ref.activeInput)
			return

		if (ref.activeInput)
			ref.activeInput.setActive(false)
	}

	static function onPaste(text)
	{
		if (!ref.activeInput)
			return

		ref.activeInput._addText(text)
	}
}

addEventHandler("onMouseDown", GUI.Input.onMouseDown)
addEventHandler("onPaste", GUI.Input.onPaste)