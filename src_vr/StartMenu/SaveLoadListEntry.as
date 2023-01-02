import gfx.events.EventDispatcher;
import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;

import gfx.io.GameDelegate;

class SaveLoadListEntry extends BasicListEntry
{	
	/* PROPERTIES */
  	
	/* STAGE ELMENTS */
	public var textField: TextField;
	public var SaveNumber: TextField;
	public var nameField: TextField;
	public var trigger: MovieClip;
		
	/* PUBLIC FUNCTIONS */
	
	public function SaveLoadListEntry()
	{
		super();
	}

	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		
		textField.SetText(a_entryObject.text ? a_entryObject.text : " ");
		nameField.SetText(a_entryObject.levelText ? a_entryObject.levelText : " ");
		
		textField.textAutoSize = "shrink";
		nameField.textAutoSize = "shrink";
		
		if(isSelected) {
			_alpha = 100;
		} else {
			_alpha = 40;
		}
		
		if (a_entryObject.fileNum != undefined) {
			if (a_entryObject.fileNum < 10) {
				SaveNumber.SetText("00" + a_entryObject.fileNum);
			} else if (a_entryObject.fileNum < 100) {
				SaveNumber.SetText("0" + a_entryObject.fileNum);
			} else {
				SaveNumber.SetText(a_entryObject.fileNum);
			}
			return;
		}
		SaveNumber.SetText(" ");
	}
}
