import gfx.events.EventDispatcher;
import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;
import gfx.ui.InputDetails;

import gfx.io.GameDelegate;
import gfx.controls.Slider;

import flash.utils.Timer;
import flash.events.TimerEvent;

import RaceMenuDefines;

class SliderListEntry extends MovieClip
{	
	/* PROPERTIES */
  	public static var defaultTextColor: Number = 0xffffff;
	public static var disabledTextColor: Number = 0x4c4c4c;
	public static var squareFillColor: Number = 0x0000000;

	private var proxyObject: Object;
	
	/* STAGE ELMENTS */
	public var itemIndex: Number;
	public var background: MovieClip;
	public var activeIndicator: MovieClip;
	public var selectIndicator: MovieClip;
	public var focusIndicator: MovieClip;
	public var textField: TextField;
	public var valueField: TextField;
	public var SliderInstance: RaceMenuSlider;
	public var trigger: MovieClip;
	public var colorSquare: MovieClip;
	public var glowSquare: MovieClip;
	
	private var rateInterval: Number;
	private var eventData:Object;
		
	/* PUBLIC FUNCTIONS */
	
	public function SliderListEntry()
	{
		super();
		/*delete this.onRollOver;
		delete this.onRollOut;
		delete this.onPress;
		delete this.onPressAux;*/
		
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
		activeIndicator.onPress = trigger.onPress;
		
		colorSquare.onRollOver = trigger.onRollOver;
		colorSquare.onPress = function()
		{
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemPress(_parent.itemIndex);
		}
		
		glowSquare.onRollOver = trigger.onRollOver;
		glowSquare.onPress = function()
		{
			var list = this._parent._parent;
			
			if (_parent.itemIndex != undefined && enabled)
				list.onItemPressAux(_parent.itemIndex, undefined, 1);
		}
	}
		
	private function onTimerComplete()
	{
		skse.SendModEvent(eventData.event, eventData.callback, eventData.position);
		clearInterval(rateInterval);
		delete rateInterval;
    }
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var list = _parent;		
		var entryObject = list.selectedEntry;
		if(entryObject.type != RaceMenuDefines.ENTRY_TYPE_SLIDER)
			return false;
		
		if(!SliderInstance.disabled) {
			var handledInput: Boolean = SliderInstance.handleInput(details, pathToFocus);
			if(handledInput) {
				//list.requestUpdate();
				return true;
			}
		}
		
		return false;
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

	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{	
		var isSelected = a_entryObject == a_state.list.selectedEntry;
		var isActive = (a_state.activeEntry != undefined && a_entryObject == a_state.activeEntry);
		var isFocus = (a_entryObject == a_state.focusEntry);
		var hasFocus = (a_state.focusEntry != undefined);
		
		valueField._y = 6;
		activeIndicator._y = 13;
		textField._y = 6;
		colorSquare._y = 8;
		glowSquare._y = 8;

		switch(a_entryObject.type)
		{
			case RaceMenuDefines.ENTRY_TYPE_RACE:
			{
				valueField.enabled = valueField._visible = false;
				SliderInstance.enabled = SliderInstance._visible = false;
				colorSquare.enabled = colorSquare._visible = false;
				glowSquare.enabled = glowSquare._visible = false;
				
				a_entryObject.enabled = true;
			}
			break;
			
			case RaceMenuDefines.ENTRY_TYPE_SLIDER:
			{
				valueField._y = -1;
				activeIndicator._y = 3;
				textField._y = -3;
				colorSquare._y = 1;
				glowSquare._y = 1;
				
				valueField._visible = valueField.enabled = true;
				SliderInstance._visible = SliderInstance.enabled = true;
				glowSquare.enabled = glowSquare._visible = false;
				
				a_entryObject.enabled = (!a_entryObject.hasColor() || a_entryObject.isColorEnabled());
										
				valueField.SetText(((a_entryObject.position * 100)|0)/100);
				
				if(a_entryObject.hasColor()) {
					var colorOverlay: Color = new Color(colorSquare.fill);
					colorOverlay.setRGB(a_entryObject.fillColor & 0x00FFFFFF);
					colorSquare.fill._alpha = ((a_entryObject.fillColor >>> 24) / 0xFF) * 100;
					colorSquare._visible = (_global.skse != undefined);
					colorSquare.enabled = (colorSquare._visible && a_entryObject.enabled);
				} else {
					colorSquare.enabled = colorSquare._visible = false;
				}
				
				// Yeah this is stupid, but its the only way to tell if the slider loaded
				if(!SliderInstance.initialized) {
					proxyObject = a_entryObject;
				} else {
					setSlider(SliderInstance, a_entryObject);
				}
			}
			break;
			
			case RaceMenuDefines.ENTRY_TYPE_WARPAINT:
			case RaceMenuDefines.ENTRY_TYPE_BODYPAINT:
			case RaceMenuDefines.ENTRY_TYPE_HANDPAINT:
			case RaceMenuDefines.ENTRY_TYPE_FEETPAINT:
			case RaceMenuDefines.ENTRY_TYPE_FACEPAINT:
			{
				valueField._visible = valueField.enabled = false;
				SliderInstance._visible = SliderInstance.enabled = false;
				
				colorSquare._visible = a_entryObject.hasColor();
				glowSquare._visible = a_entryObject.hasGlow();
				
				a_entryObject.enabled = a_entryObject.isColorEnabled();
				
				colorSquare.enabled = (colorSquare._visible && a_entryObject.enabled);
				glowSquare.enabled = (glowSquare._visible && a_entryObject.enabled);
				
				var colorOverlay: Color = new Color(colorSquare.fill);
				colorOverlay.setRGB(a_entryObject.fillColor & 0x00FFFFFF);
				colorSquare.fill._alpha = ((a_entryObject.fillColor >>> 24) / 0xFF) * 100;
				
				var glowOverlay: Color = new Color(glowSquare.fill);
				glowOverlay.setRGB(a_entryObject.glowColor & 0x00FFFFFF);
				glowSquare.fill._alpha = ((a_entryObject.glowColor >>> 24) / 0xFF) * 100;
			}
			break;
		}
		
		enabled = a_entryObject.enabled;
		if((hasFocus && !isFocus) || !enabled) {
			textField.textColor = disabledTextColor;
			valueField.textColor = disabledTextColor;
			SliderInstance._alpha = 40;
			colorSquare._alpha = 40;
			glowSquare._alpha = 40;
		} else {
			textField.textColor = defaultTextColor;
			valueField.textColor = defaultTextColor;
			SliderInstance._alpha = 100;
			colorSquare._alpha = 100;
			glowSquare._alpha = 100;
		}

		if (textField != undefined) {			
			textField.autoSize = a_entryObject.align ? a_entryObject.align : "left";
			textField.SetText(a_entryObject.text ? a_entryObject.text : " ");
		}
		
		if(selectIndicator != undefined)
			selectIndicator._visible = isSelected && !isFocus;
			
		if(activeIndicator != undefined) {
			activeIndicator._visible = isActive;
			activeIndicator._x = textField._x + textField._width + 5;
		}
		if(focusIndicator != undefined)
			focusIndicator._visible = isFocus;
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
		slider.callbackName = a_entryObject.callbackName;
		slider.sliderID = a_entryObject.sliderID;
		slider.internalCallback = a_entryObject.internalCallback;
		slider.entryObject = a_entryObject;
		slider.entryClip = this;
		slider.changedCallback = function()
		{
			GameDelegate.call(this.callbackName, [this.position, this.sliderID]);
			GameDelegate.call("PlaySound",["UIMenuFocus"]);
			
			this.entryClip.eventData = {
				event: _global.eventPrefix + "SliderChange",
				callback: this.callbackName,
				position: this.position
			};
			
			if(!this.entryClip.rateInterval) {
				this.entryClip.rateInterval = setInterval(this.entryClip, "onTimerComplete", 100);
			}
						
			this.entryObject.position = this.position;
			_parent.valueField.SetText(((this.position * 100)|0)/100);
			
			if(this.internalCallback) {
				this.internalCallback();
			}
		};
		slider.addEventListener("change", slider, "changedCallback");
		slider.disabled = !a_entryObject.enabled;
	}
}
