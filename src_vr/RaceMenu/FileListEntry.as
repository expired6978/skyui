import gfx.events.EventDispatcher;
import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;

import gfx.io.GameDelegate;

class FileListEntry extends MovieClip
{	
	/* PROPERTIES */
  	
	/* STAGE ELMENTS */
	public var itemIndex: Number;
	public var selectIndicator: MovieClip;
	public var textField: TextField;
	public var trigger: MovieClip;
	public var dateField: TextField;
	public var sizeField: TextField;
		
	/* PUBLIC FUNCTIONS */
	
	public function FileListEntry()
	{
		super();
		textField.textAutoSize = "shrink";
		
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
	
	public function doubleDigit(a_number: Number): String
	{
		return String(Math.floor(a_number / 10)) + String(Math.floor(a_number % 10));
	}
	
	public function formatDate(a_date: Date): String
	{
		return doubleDigit(a_date.getDate()) + "/" + doubleDigit(a_date.getMonth()+1) + "/" + a_date.getFullYear() + " " + doubleDigit(a_date.getHours()) + ":" + doubleDigit(a_date.getMinutes()) + ":" + doubleDigit(a_date.getSeconds());
	}
	
	public function formatSize(a_size: Number): String
	{
		return Math.ceil(a_size / 1000) + " KB";
	}

	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		
		if (textField != undefined) {			
			textField.autoSize = a_entryObject.align ? a_entryObject.align : "left";
			textField.SetText(a_entryObject.name ? a_entryObject.name : " ");
		}
		if (dateField != undefined) {
			if(!a_entryObject.formattedDate)
				a_entryObject.formattedDate = formatDate(a_entryObject.lastModified);

			dateField.SetText(a_entryObject.formattedDate);
		}
		
		if (sizeField != undefined) {
			var format:TextFormat = sizeField.getTextFormat();
			if(!a_entryObject.directory) {
				if(!a_entryObject.formattedSize)
					a_entryObject.formattedSize = formatSize(a_entryObject.size);
				
				format.align = "right";
				sizeField.SetText(a_entryObject.formattedSize);
			} else {
				format.align = "center";
				sizeField.SetText("-");
			}
			sizeField.setTextFormat(format);
		}
				
		if(selectIndicator != undefined)
			selectIndicator._visible = isSelected;
	}
}
