import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;

import com.greensock.easing.Linear;
import com.greensock.TweenMin;

import skyui.util.ColorFunctions;

class DyeListEntry extends BasicListEntry
{
	/* STAGE ELEMENTS */
	private var background: MovieClip;
	private var textField: TextField;
	private var selectIndicator: MovieClip;
	private var focusIndicator: MovieClip;
	private var activeIndicator: MovieClip;
	private var colorDiamond: ColorDiamond;
	private var colorize: Boolean = true;
	
	public static var defaultTextColor: Number = 0xffffff;
	public static var disabledTextColor: Number = 0x4c4c4c;
	
	private var hueValue: Number = 0;
	private var satValue: Number = 100;
	private var valValue: Number = 100;

	
	/* PRIVATE VARIABLES */	
	public function DyeListEntry()
	{
		super();
		delete this.onRollOver;
		delete this.onRollOut;
		delete this.onPress;
		delete this.onPressAux;
		
		background.onRollOver = function()
		{
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemRollOver(_parent.itemIndex);
		}
		
		background.onRollOut = function()
		{
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemRollOut(_parent.itemIndex);
		}
		background.onPress = function()
		{
			// Four levels up...
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemPress(_parent.itemIndex);
		}
		activeIndicator.onPress = background.onPress;
		selectIndicator.onPress = background.onPress;
		focusIndicator.onPress = background.onPress;
		
		colorDiamond.onRollOver = background.onRollOver;
		colorDiamond.onPress = function()
		{
			var list = this._parent._parent;			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemPressAux(_parent.itemIndex);
		}
	}
	
	public function initialize(a_index: Number, a_state: ListState): Void
	{
		TweenMin.to(this, 3, {hueValue:360, ease:Linear.easeNone, repeat:-1, yoyo:true, onUpdate: updateHue, onUpdateParams:[this]});
	}
	
	public function updateHue(entry)
	{
		if (entry.colorize && entry.textField != undefined) {
			entry.textField.textColor = ColorFunctions.hsvToHex([entry.hueValue, entry.satValue, entry.valValue]);
		}
	}
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var isSelected: Boolean = a_entryObject == a_state.list.selectedEntry;
		var isActive: Boolean = a_entryObject.active;
		var isColorized: Boolean = a_entryObject.colorized;
		var isFocus: Boolean = (a_entryObject == a_state.focusEntry);
		var hasFocus: Boolean = (a_state.focusEntry != undefined);
						
		var colorOverlay: Color = new Color(colorDiamond.fill);
		colorOverlay.setRGB(a_entryObject.fillColor & 0x00FFFFFF);
		colorDiamond.fill._alpha = ((a_entryObject.fillColor >>> 24) / 0xFF) * 100;		
		
		enabled = a_entryObject.enabled;
		if(a_state.activeCount == a_state.maxCount && !isActive) {
			enabled = false;
		}
		
		colorize = isColorized;
		if(!colorize) {
			if((hasFocus && !isFocus) || !enabled) {
				textField.textColor = disabledTextColor;
			} else {
				textField.textColor = defaultTextColor;
			}
		} else {
			if((hasFocus && !isFocus) || !enabled) {
				satValue = 50;
				valValue = 25;
			} else {
				satValue = 100;
				valValue = 100;
			}
			textField.textColor = ColorFunctions.hsvToHex([hueValue, satValue, valValue]);
		}
		
		if (textField != undefined) {			
			textField.autoSize = a_entryObject.align ? a_entryObject.align : "left";
			if(a_entryObject.count > 1) {
				textField.SetText(a_entryObject.text ? a_entryObject.text + " (" + a_entryObject.count + ")" : " ");
			} else {
				textField.SetText(a_entryObject.text ? a_entryObject.text : " ");
			}
		}
		
		if(activeIndicator != undefined) {
			activeIndicator._visible = isActive;
			activeIndicator._x = textField._x + textField._width + 5;
		}
		
		if(selectIndicator != undefined)
			selectIndicator._visible = isSelected && !isFocus;
		if(focusIndicator != undefined)
			focusIndicator._visible = isFocus;
	}
}

