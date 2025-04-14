import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;

import gfx.io.GameDelegate;

class PartsListEntry extends BasicListEntry
{	
	/* STAGE ELMENTS */
	public var textField: TextField;
	public var trigger: MovieClip;
	public var activeIndicator: MovieClip;
	public var selectIndicator: MovieClip;
		
	/* PUBLIC FUNCTIONS */
	
	public function PartsListEntry()
	{
		super();
		textField.textAutoSize = "shrink";
	}

	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var isSelected = a_entryObject == a_state.list.selectedEntry && FocusHandler.instance.getFocus(0) == a_state.list;
		var isActive = (a_state.activeEntry != undefined && a_entryObject == a_state.activeEntry);
		
		textField.htmlText = a_entryObject.name ? a_entryObject.name : "";
		
		if(activeIndicator != undefined) {
			activeIndicator._visible = isActive;
			activeIndicator._x = textField._x + textField.textWidth + 5;
		}
		if(selectIndicator != undefined)
			selectIndicator._visible = isSelected;
	}
	
	public function onRollOver(): Void
	{
		super.onRollOver();
		this._parent.dispatchEvent({type: "itemRollOver", index: itemIndex});
	}
}
