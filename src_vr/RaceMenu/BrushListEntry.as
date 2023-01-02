import gfx.events.EventDispatcher;
import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;
import gfx.ui.InputDetails;

import gfx.io.GameDelegate;

class BrushListEntry extends MovieClip
{	
	/* PROPERTIES */
	public static var defaultTextColor: Number = 0xffffff;
	public static var disabledTextColor: Number = 0x4c4c4c;
	
	private var proxyObject: Object;
  	
	/* STAGE ELMENTS */
	public var itemIndex: Number;
	public var background: MovieClip;
	public var selectIndicator: MovieClip;
	public var textField: TextField;
	public var valueField: TextField;
	public var trigger: MovieClip;
	public var SliderInstance: RaceMenuSlider;
		
	/* PUBLIC FUNCTIONS */
	
	public function BrushListEntry()
	{
		super();
		
		trigger.onRollOver = function()
		{
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemRollOver(_parent.itemIndex);
		}
		
		trigger.onRollOut = function()
		{
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemRollOut(_parent.itemIndex);
		}
		
		/* Build all the onPress functions for the underlying pieces*/

		trigger.onPress = function()
		{
			// Four levels up...
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemPress(_parent.itemIndex);
		}
	}
	
	public function onLoad()
	{
		super.onLoad();
		SliderInstance.addEventListener("onWidgetLoad", this, "onSliderLoad");
	}
	
	public function onSliderLoad(event: Object)
	{
		setSlider(event.target, proxyObject);
	}
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var list = _parent;		
		var entryObject = list.selectedEntry;
		
		if(!SliderInstance.disabled) {
			var handledInput: Boolean = SliderInstance.handleInput(details, pathToFocus);
			if(handledInput) {
				return true;
			}
		}
		
		return false;
	}

	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		
		if (textField != undefined) {			
			textField.autoSize = a_entryObject.align ? a_entryObject.align : "center";
			textField.SetText(a_entryObject.text ? a_entryObject.text : " ");
		}
		
		if (valueField != undefined) {
			valueField._x = textField._x + textField._width / 2 + textField.textWidth / 2 + 5;
			valueField.autoSize = "left";
			valueField.SetText("(" + ((a_entryObject.position * 100000)|0)/100000 + ")");
		}
	
		textField.textColor = defaultTextColor;
		
		if(!SliderInstance.initialized) {
			proxyObject = a_entryObject;
		} else {
			setSlider(SliderInstance, a_entryObject);
		}
		
		if(selectIndicator != undefined)
			selectIndicator._visible = isSelected;
	}
	
	public function updatePosition(a_position: Number): Void
	{
		SliderInstance.position = a_position;
		SliderInstance.changedCallback();
	}
	
	private function setSlider(slider:Object, a_entryObject: Object): Void
	{
		if(!slider)
			return;
		
		slider.minimum = a_entryObject.sliderMin;
		slider.maximum = a_entryObject.sliderMax;
		slider.snapInterval = a_entryObject.interval;
		slider.position = a_entryObject.position;
		slider.internalCallback = a_entryObject.internalCallback;
		slider.entryObject = a_entryObject;
		slider.changedCallback = function()
		{
			this.entryObject.position = this.position;
			_parent.valueField.SetText("(" + ((this.position * 1000)|0)/1000 + ")");
			
			if(this.internalCallback) {
				this.internalCallback();
			}
		};
		slider.addEventListener("change", slider, "changedCallback");
		slider.disabled = !a_entryObject.enabled;
	}
}
