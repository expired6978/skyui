import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;

import skyui.defines.Input;
import skyui.util.GlobalFunctions;
import skyui.components.list.EntryClipManager;
import skyui.components.list.BasicList;
import skyui.filter.IFilter;


class RaceMenuList extends skyui.components.list.ScrollingList
{
	public var entryHeight: Number = 45;
	
	private var _textureControl: Object;
	private var _platform: Number;
	
	public function RaceMenuList()
	{
		super();
	}
	
	public function set listHeight(a_height: Number): Void
	{
		_listHeight = background._height = a_height;
		
		if (scrollbar != undefined)
			scrollbar.height = _listHeight;
			
		_maxListIndex = Math.floor(_listHeight / entryHeight);
	}
	
	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		super.setPlatform(a_platform,a_bPS3Switch);
		
		_platform = a_platform;
		if(_platform == 0) {
			_textureControl = {keyCode: GlobalFunctions.getMappedKey("Wait", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		} else {
			_textureControl = {keyCode: GlobalFunctions.getMappedKey("Jump", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		}
	}
	
	public function IsBoundKeyPressed(details: InputDetails, boundKey: Object, platform: Number): Boolean
	{
		return ((details.control && details.control == boundKey.name) || (details.skseKeycode && boundKey.name && boundKey.context && details.skseKeycode == GlobalFunctions.getMappedKey(boundKey.name, Number(boundKey.context), platform != 0)) || (details.skseKeycode && details.skseKeycode == boundKey.keyCode));
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (disableInput)
			return false;

		// That makes no sense, does it?
		var bHandled = selectedClip != undefined && selectedClip.handleInput != undefined && selectedClip.handleInput(details, pathToFocus.slice(1));
		if (bHandled)
			return true;

		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.UP || details.navEquivalent == NavigationCode.PAGE_UP || details.navEquivalent == NavigationCode.GAMEPAD_L3) {
				moveSelectionUp(details.navEquivalent == NavigationCode.PAGE_UP || details.navEquivalent == NavigationCode.GAMEPAD_L3);
				return true;
			} else if (details.navEquivalent == NavigationCode.DOWN || details.navEquivalent == NavigationCode.PAGE_DOWN || details.navEquivalent == NavigationCode.GAMEPAD_R3) {
				moveSelectionDown(details.navEquivalent == NavigationCode.PAGE_DOWN || details.navEquivalent == NavigationCode.GAMEPAD_R3);
				return true;
			} else if (!disableSelection && (details.navEquivalent == NavigationCode.ENTER || details.skseKeycode == GlobalFunctions.getMappedKey("Activate", Input.CONTEXT_GAMEPLAY, _platform != 0))) {
				onItemPress();
				return true;
			} else if (!disableSelection && IsBoundKeyPressed(details, _textureControl, _platform)) {
				dispatchEvent({type: "itemPressSecondary", index: _selectedIndex, entry: selectedEntry, clip: selectedClip});
				return true;
			}
		}
		return false;
	}
	
	public function invalidateSelection(): Void
	{
		doSetSelectedIndex(-1, SELECT_MOUSE);
	}

	public function moveSelectionUp(a_bScrollPage: Boolean): Void
	{
		if (!disableSelection && !a_bScrollPage) {
			if (_selectedIndex == -1) {
				selectDefaultIndex(false);
			} else if (getSelectedListEnumIndex() >= scrollDelta) {
				doSetSelectedIndex(getListEnumRelativeIndex(-scrollDelta), SELECT_KEYBOARD);
				isMouseDrivenNav = false;
			} else {
				doSetSelectedIndex(-1, SELECT_MOUSE);
			}
		} else if (a_bScrollPage) {
			var t = scrollPosition - _listIndex;
			scrollPosition = t > 0 ? t : 0;
			doSetSelectedIndex(-1, SELECT_MOUSE);
		} else {
			scrollPosition = scrollPosition - scrollDelta;
		}
	}
	
	public function getClipGlobalCoordinate(): Object
	{
		var currentClip: MovieClip = getClipByIndex(_curClipIndex);
		var totalX: Number = currentClip._x;
		var totalY: Number = currentClip._y + (_curClipIndex * 0.95); // Not sure what the hell this offset is from
		var clipParent: MovieClip = currentClip._parent;
		while(clipParent) {
			totalX += clipParent._x;
			totalY += clipParent._y;
			clipParent = clipParent._parent;
		}
		
		return {x: totalX, y: totalY};
	}

	public function moveSelectionDown(a_bScrollPage: Boolean): Void
	{
		if (!disableSelection && !a_bScrollPage) {
			if (_selectedIndex == -1) {
				selectDefaultIndex(true);
			} else if (getSelectedListEnumIndex() < getListEnumSize() - scrollDelta) {
				doSetSelectedIndex(getListEnumRelativeIndex(scrollDelta), SELECT_KEYBOARD);
				isMouseDrivenNav = false;
			} else {
				doSetSelectedIndex(-1, SELECT_MOUSE);
			}
		} else if (a_bScrollPage) {
			var t = scrollPosition + _listIndex;
			scrollPosition = t < _maxScrollPosition ? t : _maxScrollPosition;
			doSetSelectedIndex(-1, SELECT_MOUSE);
		} else {
			scrollPosition = scrollPosition + scrollDelta;
		}
	}
}
