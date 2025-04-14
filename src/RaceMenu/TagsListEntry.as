import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;

import gfx.io.GameDelegate;

class TagsListEntry extends BasicListEntry
{	
	/* STAGE ELMENTS */
	public var textField: TextField;
	public var trigger: MovieClip;
	public var selectIndicator: MovieClip;
	public var checkbox: MovieClip;
		
	/* PUBLIC FUNCTIONS */
	
	public function TagsListEntry()
	{
		super();
		textField.textAutoSize = "shrink";
	}

	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var isSelected: Boolean = a_entryObject == a_state.list.selectedEntry && FocusHandler.instance.getFocus(0) == a_state.list;
		var isChecked: Boolean = a_entryObject.checked ? a_entryObject.checked : false;

		checkbox.gotoAndStop(isChecked ? "checked" : "unchecked");
		
		textField.SetText(a_entryObject.label ? a_entryObject.label : " ");
		
		if(selectIndicator != undefined)
			selectIndicator._visible = isSelected;
	}
	
	public function onRollOver(): Void
	{
		super.onRollOver();
		this._parent.dispatchEvent({type: "itemRollOver", index: itemIndex});
	}
}
