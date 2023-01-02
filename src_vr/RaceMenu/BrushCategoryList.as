import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;

import skyui.components.list.EntryClipManager;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.AlphaEntryFormatter;
import skyui.components.list.BasicList;


class BrushCategoryList extends TextCategoryList
{
	
	public function BrushCategoryList()
	{
		super();
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (disableInput)
			return false;
			
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.UP) {
				moveSelectionLeft(true);
				return true;
			} else if (details.navEquivalent == NavigationCode.DOWN) {
				moveSelectionRight(true);
				return true;
			}
		}
		
		return false;
	}
}