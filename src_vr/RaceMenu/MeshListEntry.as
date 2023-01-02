import gfx.events.EventDispatcher;
import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;

import gfx.io.GameDelegate;

class MeshListEntry extends MovieClip
{	
	/* PROPERTIES */
  	
	/* STAGE ELMENTS */
	public var itemIndex: Number;
	public var selectIndicator: MovieClip;
	public var textField: TextField;
	public var visibleToggle: MovieClip;
	public var wireToggle: MovieClip;
	public var lockToggle: MovieClip;
	public var wireColor: MovieClip;
	public var trigger: MovieClip;
		
	/* PUBLIC FUNCTIONS */
	
	public function MeshListEntry()
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
		
		visibleToggle.onRollOver = function()
		{
			var list = this._parent._parent;
			if (_parent.itemIndex != undefined && enabled) {
				list.onItemRollOver(_parent.itemIndex);
				list.onStatusRollOver(_parent.itemIndex, 0);
			}
		}
		visibleToggle.onPress = function()
		{
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemPressVisibility(_parent.itemIndex);
		}
		
		wireToggle.onRollOver = function()
		{
			var list = this._parent._parent;
			if (_parent.itemIndex != undefined && enabled) {
				list.onItemRollOver(_parent.itemIndex);
				list.onStatusRollOver(_parent.itemIndex, 1);
			}
		}
		wireToggle.onPress = function()
		{
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemPressWireframe(_parent.itemIndex);
		}
		
		lockToggle.onRollOver = function()
		{
			var list = this._parent._parent;
			if (_parent.itemIndex != undefined && enabled) {
				list.onItemRollOver(_parent.itemIndex);
				list.onStatusRollOver(_parent.itemIndex, 2);
			}
		}
		lockToggle.onPress = function()
		{
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemPressLock(_parent.itemIndex);
		}
		
		wireColor.onRollOver = function()
		{
			var list = this._parent._parent;
			if (_parent.itemIndex != undefined && enabled) {
				list.onItemRollOver(_parent.itemIndex);
				list.onStatusRollOver(_parent.itemIndex, 3);
			}
		}
		wireColor.onPress = function()
		{
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemPressAux(_parent.itemIndex, undefined, 1);
		}
	}

	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		
		visibleToggle.gotoAndStop(a_entryObject.visible ? "checked" : "unchecked");
		wireToggle.gotoAndStop(a_entryObject.wireframe ? "checked" : "unchecked");
		lockToggle.gotoAndStop(a_entryObject.locked ? "unchecked" : "checked");
		
		var colorOverlay: Color = new Color(wireColor.fill);
		colorOverlay.setRGB(a_entryObject.wfColor & 0x00FFFFFF);
		wireColor.fill._alpha = ((a_entryObject.wfColor >>> 24) / 0xFF) * 100;
		
		if (textField != undefined) {
			textField.autoSize = a_entryObject.align ? a_entryObject.align : "left";
			textField.SetText(a_entryObject.name ? a_entryObject.name : " ");
		}
		
		if(!a_entryObject.morphable) {
			lockToggle.enabled = false;
			lockToggle._alpha = 40;
		} else {
			lockToggle.enabled = true;
			lockToggle._alpha = 100;
		}
		
		if(selectIndicator != undefined)
			selectIndicator._visible = isSelected;
	}
}
