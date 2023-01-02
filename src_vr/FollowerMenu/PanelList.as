class PanelList extends skyui.components.list.ScrollingList
{
	public var entryHeight: Number = 85;
	public var maxEntries: Number = 5;
	public var paddingBottom: Number = 10;
	
	public function PanelList()
	{
		super();
	}
	
	public function InvalidateData(): Void
	{
		background._height = Math.min(entryHeight * entryList.length + paddingBottom, entryHeight * maxEntries + paddingBottom);
		super.InvalidateData();
	}
}
