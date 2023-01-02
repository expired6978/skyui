import gfx.events.EventDispatcher;
import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;

import gfx.io.GameDelegate;

class BonusListEntry extends BasicListEntry
{	
	/* PROPERTIES */
  	
	/* STAGE ELMENTS */
	public var textField: TextField;
	public var valueField: TextField;
	public var trigger: MovieClip;
		
	/* PUBLIC FUNCTIONS */
	
	public function BonusListEntry()
	{
		super();
	}

	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		textField.SetText(a_entryObject.text ? a_entryObject.text : " ");
		valueField.SetText(((a_entryObject.value * 100)|0)/100);
	}
}
