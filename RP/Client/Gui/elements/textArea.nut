local ref = {
	activeTextArea = null
}

local Line = class
{
#public
	id = 0
	parent = null
	metadata = null

#private:
	_text = ""

	_start = 0
	_offsetXPx = 0
	_widthPx = 0

	constructor(arg)
	{
		id = "id" in arg ? arg.id : id
		parent = arg.parent
		metadata = "metadata" in arg ? arg.metadata : {}

		_text = "text" in arg ? arg.text : _text

		_start = "start" in arg ? arg.start : _start
		_widthPx = "widthPx" in arg ? arg.widthPx : _widthPx
		_offsetXPx = "offsetXPx" in arg ? arg.offsetXPx : _offsetXPx
	}

	function getVisibleLine()
	{
		local scrollbar = parent.scrollbar
		local value = scrollbar ? scrollbar.range.getValue() : 0

		if (id >= value && (id < parent.visibleLines.len() + value))
			return parent.visibleLines[id - value]

		return null
	}

	function restoreText()
	{
		local visibleLine = getVisibleLine()
		if (visibleLine)
			visibleLine.setText(_text.len() ? _text : " ")
	}

	function getText()
	{
		return _text
	}

	function setText(text)
	{
		_text = text
		restoreText()
	}

	function getOffsetPx()
	{
		return _offsetXPx
	}
}

local VisibleLine = class extends GUI.Label
{
#public
	id = -1

	constructor(id, arg)
	{
		this.id = id
		base.constructor(arg)
	}
}

local GUITextAreaClasses = classes(GUI.Sprite, GUI.Margin, GUI.Alignment)
class GUI.TextArea extends GUITextAreaClasses
{
#public:
	visibleLines = null
	lines = null
	scrollbar = null

#private:
	// Properties
	_text = ""
	_maxLetters = -1
	_font = "FONT_OLD_10_WHITE_HI.TGA"
	_lineHeightPx = 30
	_separator = " "
	_scale = 1.0
	_selector = "|"
	_linesColor = null
	_scrollbarVisibilityMode = ScrollbarVisibilityMode.Needed
	_isReadOnly = false

	// Work
	_maxWidthPx = 0
	_cursor = 0
	_curLineId = 0

	constructor(arg)
	{
		visibleLines = []
		lines = []

		GUI.Sprite.constructor.call(this, arg)
		GUI.Margin.constructor.call(this, arg)
		_alignment = "align" in arg ? arg.align : Align.Left

		_text = "text" in arg ? arg.text : _text
		_maxLetters = "maxLetters" in arg ? arg.maxLetters : _maxLetters
		_font = "font" in arg ? arg.font : _font

		if ("lineHeightPx" in arg)
			_lineHeightPx = arg.lineHeightPx
		else if ("lineHeight" in arg)
			_lineHeightPx = nay(arg.lineHeight)
		else
		{
			local oldFont = textGetFont()
			textSetFont(_font)
			_lineHeightPx = letterHeightPx()
			textSetFont(oldFont)
		}

		_separator = "separator" in arg ? arg.separator : _separator
		_scale = "scale" in arg ? arg.scale : _scale
		_selector = "selector" in arg ? arg.selector : _selector

		_linesColor = Color(255, 255, 255, 255)
		if ("linesColor" in arg)
			setLinesColor(arg.linesColor)

		_isReadOnly = "isReadOnly" in arg ? arg.isReadOnly : _isReadOnly

		if ("scrollbar" in arg)
		{
			_scrollbarVisibilityMode = "scrollbarVisibilityMode" in arg ? arg.scrollbarVisibilityMode : _scrollbarVisibilityMode
			arg.scrollbar.keysEnabled <- _isReadOnly // Block scrollbar keyboard navigation and use them for input.
			scrollbar = GUI.ScrollBar(arg.scrollbar)

			scrollbar.parent = this
			scrollbar.range.setMaximum(0)
			scrollbar.range.bind(EventType.Change, function(self) {
				self.parent.parent._refreshLines()
			})


			if (scrollbar.getSizePx().width == 0)
				scrollbar.setSizePx(SCROLLBAR_SIZE, 0)

			_updateScrollbarView()
		}

		lines.push(Line({ parent = this }))
		this.bind(EventType.Click, function(self) {
			self.onClick()
		})

		_updateVisibleLines()
	}

	function setVisible(visible)
	{
		GUI.Sprite.setVisible.call(this, visible)

		foreach (visibleLine in visibleLines)
			visibleLine.setVisible(visible)

		_updateScrollbarVisibility()
	}

	function setActive(active)
	{
		if (ref.activeTextArea && ref.activeTextArea != this)
			ref.activeTextArea.lines[ref.activeTextArea._curLineId].restoreText()

		if (active)
		{
			if (_isReadOnly)
				return

			if (ref.activeTextArea == this)
				return

			if (!visible)
				setVisible(true)

			ref.activeTextArea = this
			_updateCurLineText()
		}
		else if (ref.activeTextArea == this)
		{
			ref.activeTextArea = null
			_updateCurLineText()
		}
	}

	function setDisabled(disabled)
	{
		GUI.Sprite.setDisabled.call(this, disabled)

		foreach (visibleLine in visibleLines)
			visibleLine.setDisabled(disabled)

		if (scrollbar)
			scrollbar.setDisabled(disabled)
	}

	function top()
	{
		GUI.Sprite.top.call(this)

		foreach (visibleLine in visibleLines)
			visibleLine.top()

		if (scrollbar)
			scrollbar.top()
	}

	function setPositionPx(x, y)
	{
		local positionPx = getPositionPx()
		local offsetXPx = x - positionPx.x
		local offsetYPx = y - positionPx.y

		GUI.Sprite.setPositionPx.call(this, x, y)

		foreach (visibleLine in visibleLines)
		{
			local linePositionPx = visibleLine.getPositionPx()
			visibleLine.setPositionPx(linePositionPx.x + offsetXPx, linePositionPx.y + offsetYPx)
		}

		if (scrollbar)
		{
			local scrollbarPositionPx = scrollbar.getPositionPx()
			scrollbar.setPositionPx(scrollbarPositionPx.x + offsetXPx, scrollbarPositionPx.y + offsetYPx)
		}
	}

	function setSizePx(width, height)
	{
		GUI.Sprite.setSizePx.call(this, width, height)
		_updateVisibleLines()

		if (scrollbar)
			_updateScrollbarView()
	}

	function setMarginPx(top, right, bottom, left)
	{
		GUI.Margin.setMarginPx.call(this, top, right, bottom, left)
		_updateVisibleLines()
	}

	function setAlignment(alignment)
	{
		GUI.Alignment.setAlignment.call(this, alignment)

		local marginPx = getMarginPx()
		local sizePx = getSizePx()
		local positionPx = getPositionPx()

		foreach (line in lines)
		{
			switch (alignment)
			{
				case Align.Left:
					line._offsetXPx = marginPx.left
					break

				case Align.Center:
					line._offsetXPx = marginPx.left + ((sizePx.width - marginPx.right) - line._widthPx) / 2
					break

				case Align.Right:
					line._offsetXPx = sizePx.width - line._widthPx - marginPx.right
					break
			}

			local visibleLine = line.getVisibleLine()
			if (visibleLine)
				visibleLine.setPositionPx(positionPx.x + line._offsetXPx, visibleLine.getPositionPx().y)
		}
	}

	function getText()
	{
		return _text
	}

	function setText(text)
	{
		if ((_maxLetters != -1) && (text.len() > _maxLetters))
			text = text.slice(0, _maxLetters)

		// Recalculate text from beginning.
		_cursor = 0
		_curLineId = 0

		_reloadText(text, true, false)
		_text = text

		_updateCurLineText()
	}

	function getMaxLetters()
	{
		return _maxLetters
	}

	function setMaxLetters(maxLetters)
	{
		_maxLetters = maxLetters

		if (_text.len() > _maxLetters)
			setText(_text.slice(0, maxLetters))
	}

	function getFont()
	{
		return _fonts
	}

	function setFont(font)
	{
		_font = font.toupper()

		foreach (visibleLine in visibleLines)
			visibleLine.setFont(_font)

		setText(_text)
	}

	function setLineHeightPx(lineHeight)
	{
		_lineHeightPx = lineHeight
		_updateVisibleLines()
	}

	function getLineHeightPx()
	{
		return _lineHeightPx
	}

	function getLineHeight()
	{
		return anx(_lineHeightPx)
	}

	function setLineHeight(spacing)
	{
		setLineHeightPx(nax(spacing))
	}

	function getSeparator()
	{
		return _separator
	}

	function setSeparator(separator)
	{
		_separator = separator
		setText(_text)
	}

	function getScale()
	{
		return _scale
	}

	function setScale(scale)
	{
		_scale = scale

		foreach (visibleLine in visibleLines)
			visibleLine.setScale(_scale, _scale)
	}

	function getSelector()
	{
		return _selector
	}

	function setSelector(selector)
	{
		_selector = selector
		_updateCurLineText()
	}

	function getLinesColor()
	{
		return clone _linesColor
	}

	function setLinesColor(color)
	{
		local isColorInstance = typeof color == "Color"
		if (isColorInstance || "r" in color)
			_linesColor.r = color.r

		if (isColorInstance || "g" in color)
			_linesColor.g = color.g

		if (isColorInstance || "b" in color)
			_linesColor.b = color.b

		if (isColorInstance || "a" in color)
			_linesColor.a = color.a

		foreach (visibleLine in visibleLines)
			visibleLine.setColor(clone _linesColor)
	}

	function getScrollbarVisibilityMode()
	{
		return _scrollbarVisibilityMode
	}

	function setScrollbarVisibilityMode(visibilityMode)
	{
		_scrollbarVisibilityMode = visibilityMode
		_updateScrollbarVisibility()
	}

	function isReadOnly()
	{
		return _isReadOnly
	}

	function setReadOnly(isReadOnly)
	{
		_isReadOnly = isReadOnly

		if (scrollbar)
			scrollbar.keysEnabled = _isReadOnly

	}

	function getMaxScrollbarValue()
	{
		local difference = lines.len() - visibleLines.len()
		return difference > 0 ? difference : 0
	}

	function _updateScrollbarValues(value, max)
	{
		scrollbar.range._value = value
		scrollbar.range._maximum = max
		scrollbar.range.updateIndicatorPosition()
	}

	function _updateScrollbarView()
	{
		local sizePx = getSizePx()
		local positionPx = getPositionPx()
		local widthPx = scrollbar.getSizePx().width

		scrollbar.setPositionPx((positionPx.x + sizePx.width - widthPx), positionPx.y)
		scrollbar.setSizePx(widthPx, sizePx.height)
	}

	function _updateScrollbarVisibility()
	{
		if (!scrollbar)
			return

		local visible = getVisible()
		switch (_scrollbarVisibilityMode)
		{
			case ScrollbarVisibilityMode.Always:
				scrollbar.setVisible(visible)
				break

			case ScrollbarVisibilityMode.Needed:
				scrollbar.setVisible(visible && visibleLines.len() < lines.len())
				break

			case ScrollbarVisibilityMode.Never:
				scrollbar.setVisible(false)
				break
		}
	}

	function _isScrollbarUsed()
	{
		return scrollbar != null && lines.len() > visibleLines.len()
	}

	function _updateVisibleLines()
	{
		local sizePx = getSizePx()
		local oldLinesCount = visibleLines.len()
		local marginPx = getMarginPx()

		local newLinesCount = (sizePx.height - marginPx.top - marginPx.bottom) / _lineHeightPx
		_maxWidthPx = (sizePx.width - marginPx.left - marginPx.right)

		local positionPx = getPositionPx()
		local lineYPx = positionPx.y + marginPx.top
		local disabled = getDisabled()
		local visible = getVisible()

		local line_onClick = function(self) {
			self.parent.onClick()
		}

		for (local i = 0, end = (oldLinesCount > newLinesCount) ? oldLinesCount : newLinesCount; i < end; ++i)
		{
			local visibleLine
			// In scope, just update data line.
			if ((i < oldLinesCount) && (i < newLinesCount))
				visibleLine = visibleLines[i]
			// Add new visible line.
			else if (i < newLinesCount)
			{
				visibleLine = VisibleLine(i, { parent = this, text = " " })
				visibleLine.bind(EventType.Click, line_onClick)
				visibleLines.push(visibleLine)
			}
			// Remove old visible line.
			else if (i > newLinesCount)
				visibleLines.remove(visibleLines[i])

			// Update visible line if it exists.
			if (visibleLine)
			{
				visibleLine.setPositionPx(0, lineYPx + (i * _lineHeightPx))
				visibleLine.setScale(_scale, _scale)
				visibleLine.setFont(_font)
				visibleLine.setColor(clone _linesColor)

				visibleLine.setVisible(visible)
				visibleLine.setDisabled(disabled)
			}
		}

		setText(_text)
	}

	function _updateCurLineText()
	{
		local curLine = lines[_curLineId]
		local visibleLine = curLine.getVisibleLine()

		if (!visibleLine)
			return

		if (ref.activeTextArea != this)
		{
			curLine.restoreText()
			return
		}

		local offset = _cursor - curLine._start
		local text = curLine.getText()

		local newText = text.slice(0, offset) + _selector + text.slice(offset)
		visibleLine.setText(newText.len() ? newText : " ")
	}

	function _refreshLines()
	{
		if (!scrollbar)
			return

		local positionPx = getPositionPx()
		local positionYPx = positionPx.y + getMarginPx().top
		local sValue = scrollbar.range.getValue()
		local linesCount = lines.len()

		foreach (i, visibleLine in visibleLines)
		{
			local id = i + sValue
			if (id == _curLineId)
				continue

			// Clear unused lines.
			if (i >= linesCount)
			{
				if (visibleLine.getText() != " ")
					visibleLine.setText(" ")
				continue
			}

			local line = lines[id]
			local text = line.getText()

			visibleLine.setText(text.len() ? text : " ")
			visibleLine.setPositionPx(positionPx.x + line.getOffsetPx(), positionYPx + (i * _lineHeightPx))
		}

		_updateCurLineText()
	}

	function _reloadText(newText, updateTooLongText, updateScrollbarValue)
	{
		local oldFont = textGetFont()
		textSetFont(_font)

		local startLineId = _curLineId

		local curSeparatorId = -1
		local curSeparatorWidthPx = 0
		local curSeparatorText = ""

		local updateLines = [{ start = lines[startLineId]._start, text = "", widthPx = 0 }]
		local updateLineId = 0
		local updateLine = updateLines[updateLineId]

		local visibleLinesCount = visibleLines.len()

		// Loop trough text from curLine start.
		for (local letterId = updateLine.start, textLen = newText.len(); letterId < textLen; ++letterId)
		{
			local letterAscii = newText[letterId]
			if (letterAscii == '\n')
			{
				++updateLineId

				updateLines.push({ start = letterId + 1, text = "", widthPx = 0 })
				updateLine = updateLines[updateLineId]
				continue
			}

			local letter = rawstring(letterAscii.tochar())
			local letterWidthPx = (textWidthPx(letter) * _scale).tointeger()

			if (_separator != "")
			{
				// Remember separators position for the future calculations.
				if (letter == _separator)
				{
					curSeparatorId = letterId
					curSeparatorWidthPx = 0
					curSeparatorText = ""
				}
				// Getting text and its width from the separator.
				else if (curSeparatorId >= updateLine.start)
				{
					curSeparatorWidthPx += letterWidthPx
					curSeparatorText += letter
				}
			}

			// Add a character that fits and continue.
			if ((updateLine.widthPx + letterWidthPx) <= _maxWidthPx)
			{
				updateLine.text += letter
				updateLine.widthPx += letterWidthPx
				continue
			}

			// Calculating id for the data line.
			local lineId = updateLineId + startLineId
			if (_cursor >= updateLine.start)
				_curLineId = lineId

			if (!scrollbar && ((lineId + 1) >= visibleLinesCount))
			{
				if (!updateTooLongText)
					return false
				else
					break
			}

			// Move to new line.
			++updateLineId

			updateLines.push({ start = letterId, text = letter, widthPx = letterWidthPx })
			updateLine = updateLines[updateLineId]

			// Special (like Maciek z Klanu) behaviour for _separator != null.
			if (_separator != "")
			{
				// Skip the separator if the line starts with it.
				if (letter == _separator)
				{
					updateLine.start = letterId + 1
					updateLine.text = ""
					updateLine.widthPx = 0
					continue
				}

				// Move word after separator from previous line to new one.
				local prevLine = updateLines[updateLineId - 1]
				if (curSeparatorId > prevLine.start)
				{
					prevLine.text = prevLine.text.slice(0, prevLine.text.len() - (letterId - curSeparatorId))
					prevLine.widthPx -= curSeparatorWidthPx

					updateLine.start = curSeparatorId + 1
					updateLine.text = curSeparatorText
					updateLine.widthPx = curSeparatorWidthPx
				}
			}
		}

		// Update curLineId if cursor is behind the last lines start.
		if (_cursor >= updateLine.start)
			_curLineId = startLineId + updateLines.len() - 1

		textSetFont(oldFont)

		local oldLinesCount = lines.len()
		local newLinesCount = startLineId + updateLines.len()

		local newSMax = scrollbar ? (newLinesCount - visibleLinesCount) : 0
		newSMax = (newSMax < 0) ? 0 : newSMax

		local updateSVisibility = false
		local newSValue = 0
		local isSValueChanged = false

		if (scrollbar)
		{
			local oldSMax = scrollbar.range.getMaximum()
			local oldSValue = scrollbar.range.getValue()
			newSValue = (oldSValue > newSMax) ? newSMax : oldSValue

			// For _addLeter and _removeLetter.
			if (updateScrollbarValue)
			{
				local isIdTooSmall = _curLineId < newSValue
				local isIdTooBig = _curLineId >= (newSValue + visibleLinesCount)

				// CurLine is not in scope.
				if (isIdTooSmall || isIdTooBig)
				{
					local linesOffset = newLinesCount - oldLinesCount

					// Update scrollbar value with offset.
					if (linesOffset != 0)
						newSValue += linesOffset
					// CurLine should be first.
					else if (isIdTooSmall)
						newSValue = _curLineId
					// CurLine should be last.
					else if (isIdTooBig)
						newSValue = _curLineId - visibleLinesCount + 1

					newSValue = newSValue > 0 ? newSValue : 0
				}
			}

			isSValueChanged = newSValue != oldSValue
			_updateScrollbarValues(newSValue, newSMax)
			updateSVisibility = newSMax != oldSMax
		}

		// Update data and visible lines.
		// Update data and visible lines.
		local sizePx = getSizePx()
		local positionPx = getPositionPx()
		local marginPx = getMarginPx()
		local alignment = getAlignment()

		for (local i = startLineId, end = (oldLinesCount > newLinesCount ? oldLinesCount : newLinesCount); i < end; ++i)
		{
			local updateIdx = i - startLineId
			local line

			// Add new line.
			if (i >= oldLinesCount)
			{
				line = Line({ id = i, parent = this })
				lines.push(line)
			}
			// Remove old line.
			else if (i >= newLinesCount)
				lines.remove(lines.len() - 1)
			// Update line.
			else
				line = lines[i]

			if (line)
			{
				local updateLine = updateLines[updateIdx]

				line._start = updateLine.start
				line._text = updateLine.text
				line._widthPx = updateLine.widthPx

				switch (alignment)
				{
					case Align.Left:
						line._offsetXPx = marginPx.left
						break

					case Align.Center:
						line._offsetXPx = marginPx.left + ((sizePx.width - marginPx.right) - line._widthPx) / 2
						break

					case Align.Right:
						line._offsetXPx = sizePx.width - line._widthPx - marginPx.right
						break
				}
			}

			// Update visible line.
			if (!isSValueChanged && ((i >= newSValue) && (i < (newSValue + visibleLinesCount))))
			{
				local visibleLine = visibleLines[i - newSValue]
				if (!line)
					visibleLine.setText(" ")
				else
				{
					visibleLine.setText(line._text)
					visibleLine.setPositionPx(positionPx.x + line._offsetXPx, visibleLine.getPositionPx().y)
				}
			}
		}

		if (updateSVisibility)
			_updateScrollbarVisibility()

		// Need to refresh all lines.
		if (isSValueChanged)
			_refreshLines()

		return true
	}

	function _addLetter(letter)
	{
		if (!letter)
			return

		local oldFont = textGetFont()
		textSetFont(_font)

		local letterWidthPx = textWidthPx(letter)
		textSetFont(oldFont)

		// Skip unseen letters in Gothics font. For example: [] or *. These have width = 1 px.
		if (letterWidthPx <= 1)
			return

		if ((_maxLetters != -1) && (_text.len() >= _maxLetters))
			return

		local oldCursorId = _cursor
		local oldLineId = _curLineId
		local newText = _text.slice(0, _cursor) + letter + _text.slice(_cursor)
		++_cursor

		// Letter can't fit, undo changes.
		if (_reloadText(newText, false, true))
		{
			_text = newText
			_updateCurLineText()
		}
		else
		{
			_cursor = oldCursorId
			_curLineId = oldLineId
		}
	}

	function _removeLetter()
	{
		if (_text.len() == 0)
			return

		if (_cursor == 0)
			return

		// Cursor is at lines start, move line backward for proper update.
		if (lines[_curLineId]._start == _cursor)
			--_curLineId

		local newText = _text.slice(0, _cursor - 1) + _text.slice(_cursor)
		--_cursor

		_reloadText(newText, false, true)
		_text = newText
		_updateCurLineText()
	}

	function _goLeft()
	{
		if (_cursor == 0)
			return

		--_cursor

		// Move line backward.
		local oldLine = lines[_curLineId]
		if (_cursor < oldLine._start)
		{
			--_curLineId

			if (_isScrollbarUsed())
			{
				local value = scrollbar.range.getValue()

				// Previous line is unseen, need to refresh all lines.
				if (value == _curLineId + 1)
					scrollbar.range.setValue(value - 1)
				else
					oldLine.restoreText()
			}
			else
				oldLine.restoreText()
		}

		_updateCurLineText()
	}

	function _goToPrevWord()
	{
		if (_cursor == 0)
			return

		local i = _cursor - 1

		// Pass separators.
		while (i > 0 && rawstring(_text[i].tochar()) == _separator)
			--i

		// Pass letters until first separator.
		while (i > 0 && rawstring(_text[i - 1].tochar()) != _separator)
			--i

		if (_cursor != i)
		{
			local curLine = lines[_curLineId]
			_cursor = i

			// Update curLineId if changed.
			while (_curLineId > 0)
			{
				if (lines[_curLineId]._start <= _cursor)
					break

				--_curLineId
			}

			// New line is unseen, refresh all lines.
			local visibleLinesCount = visibleLines.len()
			if (_isScrollbarUsed() && (_curLineId < scrollbar.range.getValue()))
				scrollbar.range.setValue(_curLineId)
			else
			{
				curLine.restoreText()
				_updateCurLineText()
			}
		}
	}

	function _goRight()
	{
		if (_cursor == _text.len())
			return

		++_cursor

		// Move line forward.
		local oldLine = lines[_curLineId]
		if (_cursor > (oldLine._start + oldLine.getText().len()))
		{
			++_curLineId

			if (_isScrollbarUsed())
			{
				local value = scrollbar.range.getValue()

				// Next line is unseen, need to refresh all lines.
				if ((visibleLines.len() + value) == _curLineId)
					scrollbar.range.setValue(value + 1)
				else
					oldLine.restoreText()
			}
			else
				oldLine.restoreText()
		}

		_updateCurLineText()
	}

	function _goToNextWord()
	{
		local textLen = _text.len()
		if (_cursor == textLen)
			return

		local i = _cursor + 1

		// Pass letters until first separator.
		while (i < textLen && rawstring(_text[i].tochar()) != _separator)
			++i

		// Pass separators.
		while (i < textLen && rawstring(_text[i].tochar()) == _separator)
			++i

		if (_cursor != i)
		{
			local curLine = lines[_curLineId]
			_cursor = i

			// Update curLineId if changed.
			local linesCount = lines.len()
			while ((_curLineId + 1) < linesCount && _cursor >= lines[_curLineId + 1]._start)
				++_curLineId

			// New line is unseen, refresh all lines.
			local visibleLinesCount = visibleLines.len()
			if (_isScrollbarUsed() && (_curLineId >= scrollbar.range.getValue() + visibleLinesCount))
				scrollbar.range.setValue(_curLineId - visibleLinesCount + 1)
			else
			{
				curLine.restoreText()
				_updateCurLineText()
			}
		}
	}

	function _goVertically(direction)
	{
		local newLineid = _curLineId + direction
		if (newLineid < 0 || newLineid >= lines.len())
			return

		local newLine = lines[newLineid]

		// Empty line.
		if (newLine._start == -1)
			return

		local newId = 0
		local newWidthPx = 0
		local newText = newLine.getText()
		local newLen = newText.len()

		local prevLine = lines[_curLineId]
		local prevId = prevLine._start
		local prevWidthPx = 0

		local oldFont = textGetFont()
		textSetFont(_font)

		while (true)
		{
			// Get width from start to the cursor.
			if (prevId < _cursor)
			{
				prevWidthPx += textWidthPx(rawstring(_text[prevId].tochar()))
				++prevId
			}
			// Getting cursors width is completed.
			// Check if the width of the newline is greater than or equal to the width of the cursor.
			else
			{
				_cursor = newLine._start + (_cursor - prevLine._start)
				break
			}

			// Get new lines width.
			if (newId < newLen)
			{
				newWidthPx += textWidthPx(rawstring(newText[newId].tochar()))
				++newId
			}
			// Getting new lines width is completed.
			// Check if the width of the cursor is lower than or equal to the width of new line.
			else if (newWidthPx <= prevWidthPx)
			{
				_cursor = newLine._start + newId
				break
			}

			if ((prevId >= _cursor) && (newId >= newLen))
			{
				_cursor = newLine._start + newId
				break
			}
		}

		_curLineId = newLineid

		// If new line is unseen, update scrollbars value.
		if (scrollbar)
		{
			local oldSValue = scrollbar.range.getValue()
			local newSValue = oldSValue
			local visibleLinesCount = visibleLines.len()

			if (_curLineId < newSValue)
				newSValue = _curLineId
			else if (_curLineId >= (newSValue + visibleLinesCount))
				newSValue = _curLineId - visibleLinesCount + 1

			newSValue = newSValue > 0 ? newSValue : 0

			if (oldSValue != newSValue)
				scrollbar.range.setValue(newSValue)
			else
			{
				prevLine.restoreText()
				_updateCurLineText()
			}
		}
		else
		{
			prevLine.restoreText()
			_updateCurLineText()
		}

		textSetFont(oldFont)
	}

	function _goToBegin()
	{
		local prevLineId = _curLineId

		_cursor = 0
		_curLineId = 0

		if (_isScrollbarUsed() && scrollbar.range.getValue() != 0)
			scrollbar.range.setValue(0)
		else
		{
			if (prevLineId != _curLineId)
				lines[prevLineId].restoreText()

			_updateCurLineText()
		}
	}

	function _goToEnd()
	{
		local prevLineId = _curLineId

		_cursor = _text.len()
		_curLineId = lines.len() - 1

		if (_isScrollbarUsed() && (scrollbar.range.getMaximum() != scrollbar.range.getValue()))
			scrollbar.range.setValue(scrollbar.range.getMaximum())
		else
		{
			if (prevLineId != _curLineId)
				lines[prevLineId].restoreText()

			_updateCurLineText()
		}
	}

	function _moveCursorByClick()
	{
		local cPosPx = getCursorPositionPx()
		local positionPx = getPositionPx()
		local sizePx = getSizePx()
		local marginPx = getMarginPx()

		// You clicked outside the Y area.
		if ((cPosPx.y < (positionPx.y + marginPx.top)) || (cPosPx.y > (positionPx.y + sizePx.height - marginPx.bottom)))
			return

		// You clicked outside the X area.
		if ((cPosPx.x < (positionPx.x + marginPx.left)) || (cPosPx.x > (positionPx.x + sizePx.width - marginPx.right)))
			return

		local visibleLineId = (cPosPx.y - positionPx.y - marginPx.top) / _lineHeightPx
		if ((visibleLineId + 1) > visibleLines.len())
			return

		local visibleLine = visibleLines[visibleLineId]
		local newLineId = _isScrollbarUsed() ? (visibleLine.id + scrollbar.range.getValue()) : visibleLine.id
		if (newLineId >= lines.len())
			return

		local newLine = lines[newLineId]
		if (newLine._start == -1)
			return

		// Clear old line.
		if (newLine != _curLineId)
		{
			lines[_curLineId].restoreText()
			_curLineId = newLineId
		}

		// Update cursors value.
		local oldFont = textGetFont()
		textSetFont(_font)

		local lineWidth = positionPx.x + marginPx.left
		local text = newLine.getText()

		local i = 0
		for (local end = text.len(); i < end; ++i)
		{
			if (lineWidth >= cPosPx.x)
				break

			lineWidth += textWidthPx(rawstring(text[i].tochar()))  * _scale
		}

		textSetFont(oldFont)

		_cursor = newLine._start + i
		_updateCurLineText()
	}

	function onClick()
	{
		if (!_isReadOnly)
		{
			if (ref.activeTextArea != this)
				setActive(true)
		}

		if (!ref.activeTextArea)
			return

		ref.activeTextArea._moveCursorByClick()
	}

	static function getActiveTextArea()
	{
		return ref.activeTextArea
	}

	static function onKeyInput(key, letter)
	{
		if (!ref.activeTextArea)
			return

		if (letter == '\b')
			ref.activeTextArea._removeLetter()
		else if (letter >= 32)
			ref.activeTextArea._addLetter(letter.tochar())
	}

	static function onKeyDown(key)
	{
		if (!ref.activeTextArea)
			return

		switch (key)
		{
			case KEY_LEFT:
			{
				if (isKeyPressed(KEY_LCONTROL) || isKeyPressed(KEY_RCONTROL))
					ref.activeTextArea._goToPrevWord()
				else
					ref.activeTextArea._goLeft()
				break
			}

			case KEY_RIGHT:
			{
				if (isKeyPressed(KEY_LCONTROL) || isKeyPressed(KEY_RCONTROL))
					ref.activeTextArea._goToNextWord()
				else
					ref.activeTextArea._goRight()
				break
			}

			case KEY_UP:
				ref.activeTextArea._goVertically(-1)
				break

			case KEY_DOWN:
				ref.activeTextArea._goVertically(1)
				break

			case KEY_HOME:
				ref.activeTextArea._goToBegin()
				break

			case KEY_END:
				ref.activeTextArea._goToEnd()
				break

			// case KEY_RETURN:
				// ref.activeTextArea._addLetter("\n")
				// break

			case KEY_DELETE:
				ref.activeTextArea.setText("")
				break
		}
	}

	static function onMouseDown(button)
	{
		if (!isCursorVisible())
			return

		local elementPointedByCursor = GUI.Event.getElementPointedByCursor()
		if (elementPointedByCursor == ref.activeTextArea)
			return

		if (elementPointedByCursor && (elementPointedByCursor.parent == ref.activeTextArea))
			return

		if (ref.activeTextArea && !ref.activeTextArea._isReadOnly)
			ref.activeTextArea.setActive(false)
	}
}

addEventHandler("onKeyInput", GUI.TextArea.onKeyInput)
addEventHandler("onKeyDown", GUI.TextArea.onKeyDown)
addEventHandler("onMouseDown", GUI.TextArea.onMouseDown)