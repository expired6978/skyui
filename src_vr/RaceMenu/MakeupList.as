import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;

import skyui.defines.Input;
import skyui.util.GlobalFunctions;
import skyui.components.list.EntryClipManager;
import skyui.components.list.BasicList;
import skyui.filter.IFilter;


class MakeupList extends skyui.components.list.ScrollingList
{
	public var entryHeight: Number = 25;
	
	public function MakeupList()
	{
		super();
	}
	
	public function set entryList(a_list: Array): Void
	{
		_entryList = a_list;
	}
	
	public function set listHeight(a_height: Number): Void
	{
		_listHeight = background._height = a_height;
		
		if (scrollbar != undefined)
			scrollbar.height = _listHeight;
			
		_maxListIndex = Math.floor(_listHeight / entryHeight);
	}
}
