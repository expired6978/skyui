import skyui.components.list.BasicList;
import skyui.components.list.ButtonListEntry;
import skyui.components.list.ListState;

class ActorValueEntry extends ButtonListEntry
{
	/* PROPERTIES */
	
	/* STAGE ELMENTS */

	public var valueField: TextField;
	
	/* PUBLIC FUNCTIONS */
		
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		super.setEntry(a_entryObject, a_state);
		
		if (a_entryObject.value == undefined) {
			valueField.text = "0";
			return;
		}
		
		valueField.textAutoSize = "shrink";
		
		var statStr: String;
		if(a_entryObject.type == undefined)
			statStr = "" + Math.round(1000 * a_entryObject.value.current) / 1000 + "";
		else if(a_entryObject.type == "pc")
			statStr = "" + Math.round(100 * (a_entryObject.value.current / a_entryObject.value.maximum)) + "%";
		else if(a_entryObject.type == "p")
			statStr = "" + Math.round(a_entryObject.value.current) + "%";

		if(a_entryObject.value.base < a_entryObject.value.maximum) { // Net Gain
			statStr += " <font color=\'#189515\'>(+" + Math.round(a_entryObject.value.maximum - a_entryObject.value.base) + ")</font>";
		} else if(a_entryObject.value.base > a_entryObject.value.maximum){ // Net Loss
			statStr += " <font color=\'#FF0000\'>(" + Math.round(a_entryObject.value.maximum - a_entryObject.value.base) + ")</font>";
		}
		valueField.html = true;
		valueField.SetText(statStr, true);
	}
}
