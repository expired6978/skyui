import gfx.events.EventDispatcher;
import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;

import gfx.io.GameDelegate;

class ImportListEntry extends BasicListEntry
{	
	/* PROPERTIES */
	public static var validTextColor: Number = 0x189515;
	public static var mismatchTextColor: Number = 0xff0000;
	public static var invalidTextColor: Number = 0x4c4c4c;
  	
	/* STAGE ELMENTS */
	public var textField: TextField;
	public var valueField: TextField;
	public var trigger: MovieClip;
	public var selectIndicator: MovieClip;
	public var focusIndicator: MovieClip;
	public var checkbox: MovieClip;
		
	/* PUBLIC FUNCTIONS */
	
	public function ImportListEntry()
	{
		super();
		textField.textAutoSize = "shrink";
	}

	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		var isFocus = a_entryObject.itemIndex == a_state.focusEntry;
		var hasFocus = a_state.focusEntry != undefined && a_state.focusEntry != -1;
		
		var objectPair = a_state.pair.entryList[a_entryObject.itemIndex];
		
		var isMorphable: Boolean = objectPair && (a_entryObject.morphable == true || objectPair.morphable == true);
		var isUnused: Boolean = objectPair && (a_entryObject.unused == true || objectPair.unused == true);
		var isDisabled: Boolean = objectPair && (a_entryObject.disabled == true || objectPair.disabled == true);
		
		var isPaired: Boolean = objectPair.vertices == a_entryObject.vertices;
		if(isPaired && isMorphable && !isDisabled) {
			textField.textColor = validTextColor;
			valueField.textColor = validTextColor;
		} else if(!isMorphable || isUnused || isDisabled){
			textField.textColor = invalidTextColor;
			valueField.textColor = invalidTextColor;
		} else if(!isPaired) {
			textField.textColor = mismatchTextColor;
			valueField.textColor = mismatchTextColor;
		}
		checkbox.gotoAndStop((isDisabled || !isMorphable || isUnused) ? "unchecked" : "checked");
		if(!isMorphable || isUnused)
			checkbox._alpha = 40;
		else
			checkbox._alpha = 100;
		
		textField.SetText(a_entryObject.name ? a_entryObject.name : " ");
		valueField.SetText(((a_entryObject.vertices * 100)|0)/100);
		
		if(selectIndicator != undefined)
			selectIndicator._visible = isSelected && !isFocus;
			
		if(focusIndicator != undefined)
			focusIndicator._visible = isFocus;
	}
}
