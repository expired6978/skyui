import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;

class ItemListEntry extends BasicListEntry
{
	/* STAGE ELEMENTS */
	private var background: MovieClip;
	private var textField: TextField;
	private var selectIndicator: MovieClip;
	private var focusIndicator: MovieClip;
	
	public static var defaultTextColor: Number = 0xffffff;
	public static var disabledTextColor: Number = 0x4c4c4c;

	
	/* PRIVATE VARIABLES */	
	public function ItemListEntry()
	{
		super();
	}
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		var isFocus = (a_entryObject == a_state.focusEntry);
		var hasFocus = (a_state.focusEntry != undefined);
		
		enabled = a_entryObject.enabled;
		if((hasFocus && !isFocus) || !enabled) {
			textField.textColor = disabledTextColor;
		} else {
			textField.textColor = defaultTextColor;
		}
		
		if(selectIndicator != undefined)
			selectIndicator._visible = isSelected && !isFocus;
		if(focusIndicator != undefined)
			focusIndicator._visible = isFocus;
		
		textField.text = a_entryObject.text;
	}
}

