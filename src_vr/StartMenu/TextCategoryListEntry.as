import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;


class TextCategoryListEntry extends BasicListEntry
{
  /* PRIVATE VARIABLES */
	
  /* STAGE ELMENTS */
  
  	public var textField: TextField;

	
  /* PUBLIC FUNCTIONS */
	
	public function initialize(a_index: Number, a_state: ListState): Void
	{
		super.initialize();
	}
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		textField.SetText("");
		textField._width = 1;
		textField.autoSize = "left";
		textField.SetText(a_entryObject.text);
		background._width = textField._width;
		
		if (a_entryObject.filterFlag == 0 && !a_entryObject.bDontHide) {
			_alpha = 15;
			enabled = false;
		} else if (a_entryObject == a_state.list.selectedEntry) {
			_alpha = 100;
			enabled = true;
		} else {
			_alpha = 50;
			enabled = true;
		}
	}
}