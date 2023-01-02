import gfx.ui.InputDetails;

class ImportList extends skyui.components.list.ScrollingList
{
	public var entryHeight: Number = 25;
	
	public function ImportList()
	{
		super();
	}
	
	public function set entryList(a_list: Array): Void
	{
		_entryList = a_list;
	}
	
	public function get entryList(): Array
	{
		return _entryList;
	}
	
	public function moveSelectionUp(a_bScrollPage: Boolean): Void
	{
		if (!disableSelection)
		{
			if(listState.focusEntry != undefined && listState.focusEntry >= 0) {
				var previousIndex = listState.focusEntry - 1;
				if(previousIndex >= 0) {
					var temp = entryList[previousIndex];
					entryList[previousIndex] = entryList[listState.focusEntry];
					entryList[listState.focusEntry] = temp;
					listState.focusEntry = previousIndex;
					InvalidateData();
					selectedIndex = listState.focusEntry;
					
					dispatchEvent({type: "shifted", index: listState.focusEntry});
					return;
				}
			}
		}
		
		super.moveSelectionUp(a_bScrollPage);
	}

	public function moveSelectionDown(a_bScrollPage: Boolean): Void
	{
		if (!disableSelection)
		{
			if(listState.focusEntry != undefined && listState.focusEntry >= 0) {
				var nextIndex = listState.focusEntry + 1;
				if(nextIndex < entryList.length) {
					var temp = entryList[nextIndex];
					entryList[nextIndex] = entryList[listState.focusEntry];
					entryList[listState.focusEntry] = temp;
					listState.focusEntry = nextIndex;
					InvalidateData();
					selectedIndex = listState.focusEntry;
					
					dispatchEvent({type: "shifted", index: listState.focusEntry});
					return;
				}
			}
		}
		
		super.moveSelectionDown(a_bScrollPage);
	}
}
