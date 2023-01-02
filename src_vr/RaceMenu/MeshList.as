class MeshList extends skyui.components.list.ScrollingList
{
	public var entryHeight: Number = 25;
	
	public function MeshList()
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
	
	public function onItemPressVisibility(a_index: Number)
	{
		if (disableInput || disableSelection || _selectedIndex == -1)
			return;
			
		dispatchEvent({type: "itemPressVisibility", index: _selectedIndex, entry: selectedEntry, clip: selectedClip, keyboardOrMouse: SELECT_KEYBOARD});
	}
	
	public function onItemPressWireframe(a_index: Number)
	{
		if (disableInput || disableSelection || _selectedIndex == -1)
			return;
			
		dispatchEvent({type: "itemPressWireframe", index: _selectedIndex, entry: selectedEntry, clip: selectedClip, keyboardOrMouse: SELECT_KEYBOARD});
	}
	
	public function onItemPressLock(a_index: Number)
	{
		if (disableInput || disableSelection || _selectedIndex == -1)
			return;
			
		dispatchEvent({type: "itemPressLock", index: _selectedIndex, entry: selectedEntry, clip: selectedClip, keyboardOrMouse: SELECT_KEYBOARD});
	}
	
	public function onStatusRollOver(a_index: Number, a_type: Number)
	{
		if (isListAnimating || disableSelection || disableInput)
			return;
			
		dispatchEvent({type: "statusRollOver", index: a_index, status: a_type});
	}
}
