import skyui.components.list.ScrollingList;
import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;
import skyui.util.GlobalFunctions;
import skyui.defines.Input;

class DyeList extends ScrollingList
{
	public var entryHeight: Number = 25;
	
	private var _platform = 0;
	private var _selectColorControl: Object;
	
	public function ItemList()
	{
		super();
	}
	
	public function set entryList(a_newArray: Array): Void
	{
		_entryList = a_newArray;
	}
	
	public function set listHeight(a_height: Number): Void
	{
		_listHeight = background._height = a_height;
		
		if (scrollbar != undefined)
			scrollbar.height = _listHeight;
			
		_maxListIndex = Math.floor(_listHeight / entryHeight);
	}
	
	public function setPlatform(aiPlatform: Number, abPS3Switch: Boolean): Void
	{
		_platform = aiPlatform;
		if(_platform == 0) {
			_selectColorControl = Input.Wait;
		} else {
			_selectColorControl = Input.YButton;
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
			if (details.navEquivalent == NavigationCode.UP || details.navEquivalent == NavigationCode.PAGE_UP) {
				moveSelectionUp(details.navEquivalent == NavigationCode.PAGE_UP);
				return true;
			} else if (details.navEquivalent == NavigationCode.DOWN || details.navEquivalent == NavigationCode.PAGE_DOWN) {
				moveSelectionDown(details.navEquivalent == NavigationCode.PAGE_DOWN);
				return true;
			} else if (!disableSelection && (details.navEquivalent == NavigationCode.ENTER || details.skseKeycode == GlobalFunctions.getMappedKey("Activate", Input.CONTEXT_GAMEPLAY, _platform != 0))) {
				onItemPress();
				return true;
			} else if (!disableSelection && IsBoundKeyPressed(details, _selectColorControl, _platform)) {
				onItemPressAux();
				return true;
			}
		}
		return false;
	}
	
	private function onItemPressAux(a_index: Number, a_keyboardOrMouse: Number, a_buttonIndex: Number): Void
	{
		if (disableInput || disableSelection || _selectedIndex == -1)
			return;
			
		if (a_keyboardOrMouse == undefined)
			a_keyboardOrMouse = SELECT_KEYBOARD;
		
		dispatchEvent({type: "itemPressAux", index: _selectedIndex, entry: selectedEntry, clip: selectedClip, keyboardOrMouse: a_keyboardOrMouse});
	}
	
	public function invalidateSelection(): Void
	{
		doSetSelectedIndex(-1, SELECT_MOUSE);
	}
}
