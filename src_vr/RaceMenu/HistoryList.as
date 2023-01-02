class HistoryList extends skyui.components.list.ScrollingList
{
	public var entryHeight: Number = 25;
	
	public function HistoryList()
	{
		super();
	}
	
	public function lastEntry()
	{
		scrollPosition = _maxScrollPosition;
		selectedIndex = entryList.length - 1;
	}
}
