import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;

class ItemListEntry extends BasicListEntry
{
	/* STAGE ELEMENTS */
	private var background: MovieClip;
	private var childIndicator: MovieClip;
	private var textField: TextField;
	private var selectIndicator: MovieClip;
	
	/* PRIVATE VARIABLES */	
	public function ItemListEntry()
	{
		super();
	}
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		var hasChildren = a_entryObject.hasChildren == 1;
		if(childIndicator != undefined)
			childIndicator._visible = hasChildren;
		if(selectIndicator != undefined)
			selectIndicator._visible = isSelected;
		
		textField.text = a_entryObject.text;
	}
}

