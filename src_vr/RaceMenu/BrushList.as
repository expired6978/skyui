import gfx.ui.InputDetails;

class BrushList extends skyui.components.list.ScrollingList
{
	public var entryHeight: Number = 45;
	
	public function BrushList()
	{
		super();
	}
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (disableInput)
			return false;
			
		// That makes no sense, does it?
		var bHandled = selectedClip != undefined && selectedClip.handleInput != undefined && selectedClip.handleInput(details, pathToFocus);
		if (bHandled)
			return true;
		
		return false;
	}
}
