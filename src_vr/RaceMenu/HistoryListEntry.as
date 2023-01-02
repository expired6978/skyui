import gfx.events.EventDispatcher;
import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;

import gfx.io.GameDelegate;

class HistoryListEntry extends MovieClip
{	
	/* PROPERTIES */
	public static var defaultTextColor: Number = 0xffffff;
	public static var disabledTextColor: Number = 0x4c4c4c;
  	
	/* STAGE ELMENTS */
	public var itemIndex: Number;
	public var selectIndicator: MovieClip;
	public var textField: TextField;
	public var trigger: MovieClip;
		
	/* PUBLIC FUNCTIONS */
	
	public function HistoryListEntry()
	{
		super();
		
		trigger.onRollOver = function()
		{
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemRollOver(_parent.itemIndex);
		}
		
		trigger.onRollOut = function()
		{
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemRollOut(_parent.itemIndex);
		}
		
		/* Build all the onPress functions for the underlying pieces*/

		trigger.onPress = function()
		{
			// Four levels up...
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemPress(_parent.itemIndex);
		}
	}

	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		
		if (textField != undefined) {			
			textField.autoSize = a_entryObject.align ? a_entryObject.align : "left";
			textField.SetText(a_entryObject.text ? a_entryObject.text : " ");
		}
		
		if(itemIndex > a_state.list["historyIndex"])
			textField.textColor = disabledTextColor;
		else
			textField.textColor = defaultTextColor;
		
		if(selectIndicator != undefined)
			selectIndicator._visible = isSelected;
	}
}
