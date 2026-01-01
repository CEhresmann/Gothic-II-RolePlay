local DataRow = class extends GUI.DataElement
{
#public:
	id = -1

	constructor(id, parent, arg)
	{
		this.id = id
		base.constructor(parent, arg)
	}

	function getVisibleElement()
	{
		local scrollValue = parent.scrollbar.range.getValue()
		if (id >= scrollValue && id < parent.visibleRows.len() + scrollValue)
			return parent.visibleRows[id - scrollValue]

		return null
	}
}

class GUI.ListVisibleRow extends GUI.Button
{
#public:
	id = -1

	constructor(id, parent)
	{
		base.constructor({label = {}})
		this.id = id
		this.parent = parent
	}

	function getDataRowId()
	{
		return id + parent.scrollbar.range.getValue()
	}

	function getDataRow()
	{
		if (id >= parent.rows.len())
			return null

		return parent.rows[getDataRowId()]
	}
}

local GUIListClasses = classes(GUI.Sprite, GUI.Margin, GUI.Alignment)
class GUI.List extends GUIListClasses
{
#public:
	rows = null
	visibleRows = null
	scrollbar = null

#private:
	_scrollbarVisibilityMode = ScrollbarVisibilityMode.Needed
	_rowHeightPx = 0
	_rowSpacingPx = 0

	_visibleRowsCount = 0

	constructor(arg = null)
	{
		_scrollbarVisibilityMode = "scrollbarVisibilityMode" in arg ? arg.scrollbarVisibilityMode : _scrollbarVisibilityMode
		GUI.Margin.constructor.call(this, arg)
		_alignment = "align" in arg ? arg.align : Align.Center

		rows = []
		visibleRows = []

		scrollbar = GUI.ScrollBar("scrollbar" in arg ? arg.scrollbar : null)
		scrollbar.parent = this
		scrollbar.range.setMaximum(0)
		scrollbar.range.bind(EventType.Change, function(self) {
			self.parent.parent.refresh()
		})

		if (scrollbar.getSizePx().width == 0)
			scrollbar.setSizePx(SCROLLBAR_SIZE, 0)

		if ("rowHeightPx" in arg)
			_rowHeightPx = arg.rowHeightPx
		else if ("rowHeight" in arg)
			_rowHeightPx = nay(arg.rowHeight)
		else
		{
			local oldFont = textGetFont()
			textSetFont("FONT_OLD_10_WHITE_HI.TGA")
			_rowHeightPx = letterHeightPx()
			textSetFont(oldFont)
		}

		if ("rowSpacingPx" in arg)
			_rowSpacingPx = arg.rowSpacingPx
		else if ("rowSpacing" in arg)
			_rowSpacingPx = nay(arg.rowSpacing)

		GUI.Sprite.constructor.call(this, arg)
		updateVisibleElements()
	}

	function setPositionPx(x, y)
	{
		local positionPx = getPositionPx()
		GUI.Sprite.setPositionPx.call(this, x, y)

		foreach (visibleRow in visibleRows)
		{
			local visibleRowPositionPx = visibleRow.getPositionPx()
			visibleRow.setPositionPx(visibleRowPositionPx.x, visibleRowPositionPx.y)
		}

		local scrollbarPositionPx = scrollbar.getPositionPx()
		scrollbar.setPositionPx(scrollbarPositionPx.x, scrollbarPositionPx.y)
	}

	function setSizePx(width, height)
	{
		GUI.Sprite.setSizePx.call(this, width, height)
		updateVisibleElements()
	}

	function setMarginPx(top, right, bottom, left)
	{
		GUI.Margin.setMarginPx.call(this, top, right, bottom, left)
		updateVisibleElements()
	}

	function setAlignment(alignment)
	{
		GUI.Alignment.setAlignment.call(this, alignment)

		foreach (visibleRow in visibleRows)
			visibleRow.setAlignment(alignment)
	}

	function getRowHeightPx()
	{
		return _rowHeightPx
	}

	function setRowHeightPx(rowHeight)
	{
		_rowHeightPx = rowHeight
		updateVisibleElements()
	}

	function getRowHeight()
	{
		return any(_rowHeightPx)
	}

	function setRowHeight(rowHeight)
	{
		setRowHeightPx(nay(rowHeight))
	}

	function getRowSpacingPx()
	{
		return _rowSpacingPx
	}

	function setRowSpacingPx(rowSpacing)
	{
		_rowSpacingPx = rowSpacing
		updateVisibleElements()
	}

	function getRowSpacing()
	{
		return any(_rowSpacingPx)
	}

	function setRowSpacing(rowSpacing)
	{
		setRowSpacingPx(nay(rowSpacing))
	}

	function getScrollbarVisibilityMode()
	{
		return _scrollbarVisibilityMode
	}

	function setScrollbarVisibilityMode(visibilityMode)
	{
		_scrollbarVisibilityMode = visibilityMode
		updateScrollbarVisibility()
	}

	function updateScrollbarVisibility()
	{
		local visible = getVisible()
		switch (_scrollbarVisibilityMode)
		{
			case ScrollbarVisibilityMode.Always:
				scrollbar.setVisible(visible)
				break

			case ScrollbarVisibilityMode.Needed:
				scrollbar.setVisible(visible && visibleRows.len() < rows.len())
				break

			case ScrollbarVisibilityMode.Never:
				scrollbar.setVisible(false)
				break
		}
	}

	function setVisible(toggle)
	{
		GUI.Sprite.setVisible.call(this, toggle)
		foreach (visibleRow in visibleRows)
			visibleRow.setVisible(toggle && visibleRow.getDataRow())

		updateScrollbarVisibility()
	}

	function setDisabled(disabled)
	{
		GUI.Sprite.setDisabled.call(this, disabled)
		foreach (visibleRow in visibleRows)
			visibleRow.setDisabled(disabled)

		scrollbar.setDisabled(disabled)
	}

	function insertRow(rowId, arg)
	{
		local visible = getVisible()
		if (_visibleRowsCount < visibleRows.len())
		{
			if (visible)
				visibleRows[_visibleRowsCount].setVisible(true)

			++_visibleRowsCount
		}

		local row = DataRow(rowId, this, arg)
		rows.insert(rowId, row)

		local max = getMaxScrollbarValue()
		if (max != 0)
		{
			scrollbar.range.setMaximum(max)

			if (!scrollbar.getVisible() && visible && _scrollbarVisibilityMode == ScrollbarVisibilityMode.Needed)
				scrollbar.setVisible(true)
		}

		if (rowId >= scrollbar.range.getValue() + visibleRows.len())
			return row

		local visibleRow = row.getVisibleElement()
		local begin = visibleRow ? visibleRow.id : 0

		for (local i = rowId + 1, end = rows.len(); i < end; ++i)
			++rows[i].id

		refresh(begin)
		return row
	}

	function addRow(arg)
	{
		return insertRow(rows.len(), arg)
	}

	function removeRow(rowId)
	{
		if (rows.len() <= visibleRows.len())
		{
			--_visibleRowsCount
			visibleRows[_visibleRowsCount].setVisible(false)
		}

		for (local i = rows.len() - 1; i > rowId; --i)
			--rows[i].id

		rows.remove(rowId)

		local oldMax = scrollbar.range.getMaximum()
		if (oldMax > 0)
		{
			scrollbar.range.setMaximum(getMaxScrollbarValue())

			if (scrollbar.range.getValue() != oldMax)
				refresh()
		}
		else
			refresh()

		if (oldMax == 1 && scrollbar.getVisible() && _scrollbarVisibilityMode == ScrollbarVisibilityMode.Needed)
			scrollbar.setVisible(false)
	}

	function clear()
	{
		rows.clear()

		local oldValue = scrollbar.range.getValue()
		scrollbar.range.setMaximum(0)

		if (scrollbar.getVisible() && _scrollbarVisibilityMode == ScrollbarVisibilityMode.Needed)
			scrollbar.setVisible(false)

		if (oldValue == 0)
			refresh()

		_visibleRowsCount = 0
	}

	function sort(func)
	{
		rows.sort(func)
		foreach (i, row in rows)
			row.id = i

		refresh()
	}

	function getMaxScrollbarValue()
	{
		local difference = rows.len() - visibleRows.len()
			return difference > 0 ? difference : 0
	}

	function updateVisibleElements()
	{
		local oldVisibleRowsLen = visibleRows.len()
		local sizePx = getSizePx()
		local marginPx = getMarginPx()
		local rowSpacePx = _rowHeightPx + _rowSpacingPx
		local rowsLen = rows.len()

		local visibleRowsLen = (_rowHeightPx > 0) ? ((sizePx.height - marginPx.top - marginPx.bottom + _rowSpacingPx) / rowSpacePx) : 0
		_visibleRowsCount = visibleRowsLen <= rowsLen ? visibleRowsLen : rowsLen

		// Insert visibleRows loop:
		local visible = getVisible()
		for (local i = oldVisibleRowsLen; i < visibleRowsLen; ++i)
		{
			local visibleRow = _createVisibleRow(i)
			visibleRow.setAlignment(_alignment)
			visibleRow.setVisible(visible)

			visibleRows.push(visibleRow)
		}

		//  Remove visibleRows loop:
		for (local i = oldVisibleRowsLen - 1; i >= visibleRowsLen; --i)
			visibleRows.remove(i)

		//  Update visible rows:
		local positionPx = getPositionPx()
		local newPositionXPx = positionPx.x + marginPx.left
		local newPositionYPx = positionPx.y + marginPx.top
		local width = sizePx.width - marginPx.left - marginPx.right
		foreach (visibleRow in visibleRows)
		{
			visibleRow.setPositionPx(newPositionXPx, newPositionYPx)
			visibleRow.setSizePx(width, _rowHeightPx)
			newPositionYPx += rowSpacePx
		}

		//  Update scrollbar and data:
		local scrollbarWidthPx = scrollbar.getSizePx().width
		scrollbar.setPositionPx((positionPx.x + sizePx.width - scrollbarWidthPx), positionPx.y)
		scrollbar.setSizePx(scrollbarWidthPx, sizePx.height)

		local newMax = getMaxScrollbarValue()
		if (newMax != scrollbar.range.getMaximum())
		{
			scrollbar.range.setMaximum(newMax)

			local scrollVisible = getVisible() && newMax != 0 && _scrollbarVisibilityMode == ScrollbarVisibilityMode.Needed
			if (scrollVisible != scrollbar.getVisible())
				scrollbar.setVisible(scrollVisible)
		}

		refresh()
	}

	function refresh(begin = 0)
	{
		local scrollbarValue = scrollbar.range.getValue()
		local maxRowsId = rows.len() - 1
		local disabled = getDisabled()

		for (local i = begin; i < _visibleRowsCount; ++i)
		{
			local visibleRow = visibleRows[i]
			if (maxRowsId < i)
			{
				visibleRow.setVisible(false)
				continue
			}

			local row = rows[i + scrollbarValue]
			local text = row.getText()

			if (visibleRow.getText() != text)
				visibleRow.setText(text != null ? text : "")

			visibleRow.setColor(row.getColor())
			visibleRow.label.setColor(row.getLabelColor())
			visibleRow.setFile(row.getFile())
			visibleRow.setFont(row.getFont())
			visibleRow.setDisabled(disabled || row.getDisabled())
		}
	}

	function _createVisibleRow(id) {
		return GUI.ListVisibleRow(id, this)
	}
}
