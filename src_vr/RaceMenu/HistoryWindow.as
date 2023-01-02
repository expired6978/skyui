import gfx.events.EventDispatcher;
import gfx.io.GameDelegate;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;

class HistoryWindow extends MovableWindow
{
	public var historyList: HistoryList;
	public var bLoadedAssets: Boolean = false;
			
	static var UNDO_TYPE_NONE: Number = 0;
	static var UNDO_TYPE_STROKE: Number = 1;
	static var UNDO_TYPE_RESETMASK: Number = 2;
	static var UNDO_TYPE_RESETSCULPT: Number = 3;
	static var UNDO_TYPE_IMPORTGEOMETRY: Number = 4;
	
	static var STROKE_TYPE_NONE: Number = 0;
	static var STROKE_TYPE_MASK_ADD: Number = 1;
	static var STROKE_TYPE_MASK_SUB: Number = 2;
	static var STROKE_TYPE_INFLATE: Number = 3;
	static var STROKE_TYPE_DEFLATE: Number = 4;
	static var STROKE_TYPE_MOVE: Number = 5;
	static var STROKE_TYPE_SMOOTH: Number = 6;
	
	function HistoryWindow()
	{
		super();
		historyList.disableSelection = historyList.disableInput = true;
	}
	
	function onLoad()
	{
		super.onLoad();		
		
		historyList.listEnumeration = new BasicEnumeration(historyList.entryList);
		historyList["historyIndex"] = -1;
		historyList.addEventListener("itemPress", this, "onItemPress");
		historyList.addEventListener("selectionChange", this, "onSelectionChange");
		historyList.requestInvalidate();
	}
	
	public function InitExtensions()
	{
		GameDelegate.addCallBack("AddAction", this, "onAddAction");
	}
	
	private function onSelectionChange(event: Object): Void
	{
		var selectedEntry: Object = historyList.entryList[event.index];
		historyList.listState.selectedEntry = selectedEntry;
		historyList.requestUpdate();
		
		_parent._parent.setStatusText(selectedEntry.part);
	}
	
	private function onItemPress(event: Object): Void
	{
		if(event.index >= 0) {			
			var lastHistory: Number = historyList["historyIndex"];
			var currentHistory: Number = _global.skse.plugins.CharGen.GoToAction(event.index);
			
			// Special case for first entry
			if(lastHistory == currentHistory && currentHistory == 0)
				currentHistory = _global.skse.plugins.CharGen.GoToAction(-1);
			
			// Change the history index to the current index
			historyList["historyIndex"] = currentHistory;
			historyList.requestUpdate();
		}
	}
	
	public function onAddAction(action: Object): Void
	{
		// Erase newly added entries
		if(historyList["historyIndex"] < (historyList.entryList.length - 1))
			historyList.entryList.splice(historyList["historyIndex"] + 1, historyList.entryList.length - historyList["historyIndex"]);
		
		// Erase old entries
		if(historyList.entryList.length == _global.skse.plugins.CharGen.GetActionLimit())
			historyList.entryList.splice(0, 1);
		
		action.text = createActionName(action);
		historyList.entryList.push(action);
				
		// Set the history index to the end
		historyList["historyIndex"] = historyList.entryList.length - 1;
		
		historyList.requestInvalidate();
		historyList.onInvalidate = function()
		{
			this.lastEntry();
			delete this.onInvalidate;
		}
	}
		
	public function createActionName(action: Object): String
	{
		var text: String = "";
		var info: String = "";
		if(action.vertices > 0)
			info = " (" + action.vertices + ")";
		
		if(action.mirror == true)
			info += " (M)";
		
		switch(action.type) {
			case UNDO_TYPE_STROKE:
			{
				switch(action.stroke) {
					case STROKE_TYPE_MASK_ADD:
					text = "$Mask Add";
					break;
					case STROKE_TYPE_MASK_SUB:
					text = "$Mask Subtract";
					break;
					case STROKE_TYPE_INFLATE:
					text = "$Inflate";
					break;
					case STROKE_TYPE_DEFLATE:
					text = "$Deflate";
					break;
					case STROKE_TYPE_MOVE:
					text = "$Move";
					break;
					case STROKE_TYPE_SMOOTH:
					text = "$Smooth";
					break;
					default:
					text = "Unknown Stroke";
					break;
				}
			}
			break;
			case UNDO_TYPE_RESETMASK:
			text = "$Clear Mask";
			break;
			case UNDO_TYPE_RESETSCULPT:
			text = "$Clear Sculpt";
			break;
			case UNDO_TYPE_IMPORTGEOMETRY:
			text = "$Import Geometry";
			break;
			default:
			text = "Unknown Action";
			break;
		}
		
		return skyui.util.Translator.translateNested(text) + info;
	}
	
	public function loadAssets()
	{
		if(bLoadedAssets)
			return true;
			
		historyList.disableSelection = historyList.disableInput = false;
		historyList.entryList = null;
		historyList.listEnumeration = new BasicEnumeration(historyList.entryList);
		historyList.requestInvalidate();
		bLoadedAssets = true;
		return true;
	}
	
	public function unloadAssets()
	{
		if(!bLoadedAssets)
			return false;
			
		historyList.disableSelection = historyList.disableInput = true;
		historyList.entryList.splice(0, historyList.entryList.length);
		historyList.requestInvalidate();
		bLoadedAssets = false;
	}
}
