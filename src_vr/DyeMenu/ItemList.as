import skyui.components.list.ScrollingList;

class ItemList extends ScrollingList
{
	public var entryHeight: Number = 25;
	
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
}
