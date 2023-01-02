import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;

import skyui.components.list.EntryClipManager;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.AlphaEntryFormatter;
import skyui.components.list.BasicList;
import skyui.components.list.ScrollingList;


class TextCategoryList extends BasicList
{
  /* CONSTANTS */	
	
  /* STAGE ELEMENTS */
	public var background: MovieClip;
	
	
  /* PRIVATE VARIABLES */
	private var _listIndex: Number = 0;
	
	private var _curClipIndex: Number = -1;

  /* PROPERTIES */
	
	// Distance from border to start icon.
	public var _clipSpacing: Number = 10;
			
	
  /* INITIALIZATION */
	
	public function TextCategoryList()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */
  
  	// Clears the list. For the category list, that's ok since the entryList isn't manipulated directly.
	// @override BasicList
	public function clearList(): Void
	{
		_entryList.splice(0);
	}
	
	// @override BasicList
	public function InvalidateData(): Void
	{
		if (_bSuspended) {
			_bRequestInvalidate = true;
			return;
		}
		
		for (var i = 0; i < _entryList.length; i++) {
			_entryList[i].itemIndex = i;
			_entryList[i].clipIndex = undefined;
		}
		
		listEnumeration.invalidate();
		
		if (_selectedIndex >= listEnumeration.size())
			_selectedIndex = listEnumeration.size() - 1;

		UpdateList();
		
		if (_curClipIndex != undefined && _curClipIndex != -1 && _listIndex > 0) {
			if (_curClipIndex >= _listIndex)
				_curClipIndex = _listIndex - 1;
				
			var entryClip = getClipByIndex(_curClipIndex);
			doSetSelectedIndex(entryClip.itemIndex, SELECT_MOUSE);
		}
		
		if (onInvalidate)
			onInvalidate();
	}
	
	// @override BasicList
	public function UpdateList(): Void
	{
		if (_bSuspended) {
			_bRequestUpdate = true;
			return;
		}
		
		setClipCount(_entryList.length);
		
		for (var i = 0; i < getListEnumSize(); i++)
			getListEnumEntry(i).clipIndex = undefined;

		_listIndex = 0;

		for (var i = 0; i < _entryList.length; i++) {
			var entryClip = getClipByIndex(_listIndex);
			var entryItem = getListEnumEntry(i);

			entryClip.setEntry(entryItem, listState);

			entryClip.itemIndex = entryItem.itemIndex;
			entryItem.clipIndex = _listIndex;
			
			++_listIndex;
		}

		var xPos = 0;
		for (var i = 0; i < _entryList.length; i++) {
			var entryClip = getClipByIndex(i);
			entryClip._x = xPos;
			xPos += entryClip.background._width + _clipSpacing;
			entryClip._visible = true;
		}
	}
	
	public function gotoStart(): Void
	{
		if (disableSelection)
			return;
			
		var curIndex = _entryList.length - 1;
		var startIndex = _curClipIndex;
		var curClip;
			
		do {
			if (curIndex < _entryList.length - 1) {
				curIndex++;
			} else {
				curIndex = 0;
			}
			curClip = getClipByIndex(curIndex);
		} while (curIndex != startIndex && curClip.filterFlag == 0 && !curClip.bDontHide);
			
		onItemPress(curClip.itemIndex, 0);
	}
	
	public function gotoEnd(): Void
	{
		if (disableSelection)
			return;

		var curIndex = 0;
		var startIndex = _curClipIndex;
		var curClip;
		
		do {
			if (curIndex > 0) {
				curIndex--;
			} else {
				curIndex = _entryList.length - 1;					
			}
			curClip = getClipByIndex(curIndex);
		} while (curIndex != startIndex && curClip.filterFlag == 0 && !curClip.bDontHide);
			
		onItemPress(curClip.itemIndex, 0);
	}
	
	// Moves the selection left to the next element. Wraps around.
	public function moveSelectionLeft(a_wrap: Boolean): Void
	{
		if (disableSelection)
			return;

		var curIndex = _curClipIndex;
		var startIndex = _curClipIndex;
		var curClip;
			
		do {
			if (curIndex > 0) {
				curIndex--;
			} else if (a_wrap) {
				curIndex = _entryList.length - 1;					
			}
			curClip = getClipByIndex(curIndex);
		} while (curIndex != startIndex && curClip.filterFlag == 0 && !curClip.bDontHide);
			
		onItemPress(curClip.itemIndex, 0);
	}

	// Moves the selection right to the next element. Wraps around.
	public function moveSelectionRight(a_wrap: Boolean): Void
	{
		if (disableSelection)
			return;
		
		var curIndex = _curClipIndex;
		var startIndex = _curClipIndex;
		var curClip;
			
		do {
			if (curIndex < _entryList.length - 1) {
				curIndex++;
			} else if (a_wrap) {
				curIndex = 0;
			}
			curClip = getClipByIndex(curIndex);
		} while (curIndex != startIndex && curClip.filterFlag == 0 && !curClip.bDontHide);
			
		onItemPress(curClip.itemIndex, 0);
	}
	
	public function getClipData()
	{
		return [selectedClip._x, selectedClip.background._width];
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (disableInput)
			return false;
			
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.LEFT) {
				moveSelectionLeft(true);
				return true;
			} else if (details.navEquivalent == NavigationCode.RIGHT) {
				moveSelectionRight(true);
				return true;
			}
		}
		return false;
	}
	
	private function doSetSelectedIndex(a_newIndex: Number, a_keyboardOrMouse: Number): Void
	{
		if (disableSelection || a_newIndex == _selectedIndex)
			return;
			
		if (a_newIndex != -1 && getListEnumIndex(a_newIndex) == undefined)
			return;
			
		var oldIndex = _selectedIndex;
		_selectedIndex = a_newIndex;

		if (oldIndex != -1) {
			var clip = _entryClipManager.getClip(_entryList[oldIndex].clipIndex);
			clip.setEntry(_entryList[oldIndex], listState);
		}

		if (_selectedIndex != -1) {
			var clip = _entryClipManager.getClip(_entryList[_selectedIndex].clipIndex);
			clip.setEntry(_entryList[_selectedIndex], listState);
		}
		
		if (_selectedIndex != -1) {
			_curClipIndex = _entryList[_selectedIndex].clipIndex;
		} else {
			_curClipIndex = -1;
		}

		dispatchEvent({type: "selectionChange", index: _selectedIndex, keyboardOrMouse: a_keyboardOrMouse});
	}
		
	// @override BasicList
	public function onItemPress(a_index: Number, a_keyboardOrMouse: Number): Void
	{
		if (disableInput || disableSelection || a_index == -1)
			return;
			
		doSetSelectedIndex(a_index, a_keyboardOrMouse);
		dispatchEvent({type: "itemPress", index: _selectedIndex, entry: selectedEntry, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	// @override BasicList
	private function onItemPressAux(a_index: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number): Void
	{
		if (disableInput || disableSelection || a_index == -1 || a_buttonIndex != 1)
			return;
		
		doSetSelectedIndex(a_index, a_keyboardOrMouse);
		dispatchEvent({type: "itemPressAux", index: _selectedIndex, entry: selectedEntry, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	// @override BasicList
	public function onItemRollOver(a_index: Number): Void
	{
		if (disableInput || disableSelection)
			return;
			
		isMouseDrivenNav = true;
		
		if (a_index == _selectedIndex)
			return;
			
		var entryClip = getClipByIndex(_entryList[a_index].clipIndex);
		entryClip._alpha = 75;
	}

	// @override BasicList
	public function onItemRollOut(a_index: Number): Void
	{
		if (disableInput || disableSelection)
			return;
			
		isMouseDrivenNav = true;
		
		if (a_index == _selectedIndex)
			return;
			
		var entryClip = getClipByIndex(_entryList[a_index].clipIndex);
		entryClip._alpha = 50;
	}
}