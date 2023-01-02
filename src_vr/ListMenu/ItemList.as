import skyui.components.list.ScrollingList;

class ItemList extends ScrollingList
{
	public var entryHeight: Number = 25;
	
	public var minViewport: Number = 5;
	public var maxViewport: Number = 15;
	
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
	
	public function InvalidateData(): Void
	{
		var maxHeight = Math.min(Math.max(entryHeight * minViewport, entryHeight * entryList.length), entryHeight * maxViewport);
		dispatchEvent({type: "invalidateHeight", height: maxHeight});
		super.InvalidateData();
	}
}
