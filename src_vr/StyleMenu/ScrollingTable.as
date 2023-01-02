import skyui.components.list.ScrollingList;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;


class ScrollingTable extends MultiColumnScrollingList
{
	public function ScrollingTable()
	{
		super();
	}

	public function onLoad(): Void
	{
		super.onLoad();
	}
	
	public function get paddedEntries(): Number
	{
		var difference: Number = getListEnumSize() % columnCount;
		if(difference > 0) {
			return columnCount - difference;
		}
		return 0;
	}
	
	// @override MultiColumnScrollingList
	public function UpdateList(): Void
	{
		// Prepare clips
		setClipCount(_maxListIndex);

		var xStart = background._x + leftBorder;
		var yStart = background._y + topBorder;
		var h = 0;
		var w = 0;
		var lastColumnIndex = columnCount - 1;
		var columnWidth = (background._width - leftBorder - rightBorder - (columnCount-1) * columnSpacing) / columnCount;

		// Clear clipIndex for everything before the selected list part
		for (var i = 0; i < getListEnumSize() && i < _scrollPosition ; i++)
			getListEnumEntry(i).clipIndex = undefined;

		_listIndex = 0;
		
		// Display the selected part of the list
		for (var i = _scrollPosition; i < getListEnumSize() + paddedEntries && _listIndex < _maxListIndex; i++) {
			var entryClip = getClipByIndex(_listIndex);
			var entryItem = getListEnumEntry(i);

			entryClip.itemIndex = entryItem.itemIndex;
			entryItem.clipIndex = _listIndex;
			
			entryClip.width = columnWidth;
			entryClip.setEntry(entryItem, listState);

			entryClip._x = xStart + w;
			entryClip._y = yStart + h;
			entryClip._visible = true;

			if (i % columnCount == lastColumnIndex) {
				w = 0;
				h = h + entryHeight;
			} else {
				w = w + columnWidth + columnSpacing;
			}

			++_listIndex;
		}
		
		// Clear clipIndex for everything after the selected list part
		for (var i = _scrollPosition + _listIndex; i < getListEnumSize(); i++)
			getListEnumEntry(i).clipIndex = undefined;
		
		// Select entry under the cursor for mouse-driven navigation
		if (isMouseDrivenNav)
			for (var e = Mouse.getTopMostEntity(); e != undefined; e = e._parent)
				if (e._parent == this && e._visible && e.itemIndex != undefined)
					doSetSelectedIndex(e.itemIndex, SELECT_MOUSE);
					
		var bShowSeparators = _listIndex > 0;
		for (var i=0; i<_separators.length; i++)
			_separators[i]._visible = bShowSeparators;
	}
	
	private function calculateMaxScrollPosition(): Void
 	{
		var t = getListEnumSize() + paddedEntries - _maxListIndex;
		_maxScrollPosition = (t > 0) ? t : 0;

		updateScrollbar();

		if (_scrollPosition > _maxScrollPosition)
			scrollPosition = _maxScrollPosition;
	}
		
	public function moveSelectionRight(): Void
	{
		if (disableSelection)
			return;

		if (_selectedIndex == -1) {
			selectDefaultIndex(false);
		} else if ((getSelectedListEnumIndex() % columnCount) < (columnCount - 1) && _selectedIndex < getListEnumSize() - 1) {
			doSetSelectedIndex(getListEnumRelativeIndex(1), SELECT_KEYBOARD);
			isMouseDrivenNav = false;
		}
	}
}