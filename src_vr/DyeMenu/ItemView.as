import gfx.events.EventDispatcher;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;

class ItemView extends MovieClip
{
	public var itemList: ItemList;
	public var background: MovieClip;
	public var layerSelect: MovieClip;
	
	public var _selection = -1;
	public var _focused = -1;
	
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	public var Lock: Function;
		
	public function ItemView()
	{
		super();
		EventDispatcher.initialize(this);
		GlobalFunc.MaintainTextFormat();
		GlobalFunc.SetLockFunction();
	}
	
	public function setLayerSelected(a_colorId: Number, a_playSound: Boolean)
	{
		for(var i = 0; i < 15; i++) {
			var entry: MovieClip = layerSelect["color"+i];
			if(i == a_colorId) {
				entry.setSelected(true);
			} else
				entry.setSelected(false);
		}
		
		_selection = a_colorId;
		dispatchEvent({type: "selectionChange", index: a_colorId, playSound: a_playSound});
	}
	
	public function get focusedLayer(): Object
	{
		if(_focused != -1)
			return layerSelect["color"+_focused];
			
		return undefined;
	}
	
	public function get selectedLayer(): Object
	{
		if(_selection != -1)
			return layerSelect["color"+_selection];
			
		return undefined;
	}
	
	public function setLayerFocused(a_colorId: Number)
	{
		for(var i = 0; i < 15; i++) {
			var entry: MovieClip = layerSelect["color"+i];
			if(i == a_colorId)
				entry.setFocused(true);
			else
				entry.setFocused(false);
		}
		
		_focused = a_colorId;
	}
	
	public function setColorList(a_array: Array)
	{
		for(var i = 0; i < 15; i++) {
			var entry: MovieClip = layerSelect["color"+i];
			entry.setColor(a_array[i]);
		}
	}
	
	public function onLoad()
	{
		itemList.listEnumeration = new BasicEnumeration(itemList.entryList);
		
		for(var i = 0; i < 15; i++) {
			var entry: MovieClip = layerSelect["color"+i];
			entry.id = i;
			entry.setColor(0);
			entry.onRollOver = function()
			{
				var view = this._parent._parent;
				view.setLayerSelected(this.id, true);
			}
			entry.onRollOut = function()
			{
				var view = this._parent._parent;
				view.setLayerSelected(-1);
			}
			entry.onPress = function()
			{
				var view = this._parent._parent;
				view.onLayerPressed(this);
			}
		}
	}
	
	public function get entryList(): Array
	{
		return itemList.entryList;
	}
	
	public function onLayerPressed(entry: Object): Void
	{
		dispatchEvent({type: "layerPressed", entry: entry});
	}
	
	public function set entryList(a_newArray: Array): Void
	{
		itemList.entryList = a_newArray;
		itemList.listEnumeration = new BasicEnumeration(a_newArray);
	}
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bHandledInput: Boolean = false;
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.ENTER) {
				if(itemList.listState.focusEntry) {
					if(_selection != -1 && (_focused == -1 || _selection != _focused)) {
						onLayerPressed(layerSelect["color"+_selection]);
						return true;
					}
				}
			}
			if (details.navEquivalent == NavigationCode.LEFT) {
				if(itemList.listState.focusEntry) {
					_selection--;
					if(_selection < 0)
						_selection = 14;
					
					setLayerSelected(_selection, true);
					return true;
				}
			}
			if(details.navEquivalent == NavigationCode.RIGHT) {
				if(itemList.listState.focusEntry) {
					_selection++;
					if(_selection > 14)
						_selection = 0;
						
					setLayerSelected(_selection, true);
					return true;
				}
			}
		}
		return itemList.handleInput(details, pathToFocus);
	}
	
	public function get listHeight(): Number
	{
		return itemList.listHeight;
	}
		
	public function set listHeight(a_height: Number): Void
	{
		itemList.listHeight = a_height;
	}
}
