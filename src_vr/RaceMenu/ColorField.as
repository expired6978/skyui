import gfx.events.EventDispatcher;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import gfx.controls.Slider;
import gfx.io.GameDelegate;
import Shared.GlobalFunc;


import skyui.components.ButtonPanel;
import skyui.defines.Input;
import skyui.util.GlobalFunctions;

class ColorField extends MovieClip
{
	public var buttonPanel: ButtonPanel;
	public var presetPanel: ButtonPanel;
	public var colorSelector: HSVSelector;
	public var colorText: TextField;
	public var hexCode: TextField;
	public var currentSelectionLeft: MovieClip;
	public var currentSelectionRight: MovieClip;
	
	private var _platform: Number;
	private var _acceptButton: Object;
	private var _cancelButton: Object;
	private var _switchModeButton: Object;
	private var _loadColorButton: Object;
	private var _saveColorButton: Object;
	
	private var _currentColor: Number;
	public var _currentSlider: Number;
	
	private var _sliderCount: Number = 4;

	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	public function ColorField()
	{
		super();
		_currentColor = 0;
		_currentSlider = 0;
		EventDispatcher.initialize(this);
		colorText.textAutoSize = "shrink";
	}
	
	public function onLoad()
	{
		colorSelector.addEventListener("changeColor", this, "onSliderChange");
	}
	
	public function IsBoundKeyPressed(details: InputDetails, boundKey: Object, platform: Number): Boolean
	{
		return ((details.control && details.control == boundKey.name) || (details.skseKeycode && boundKey.name && boundKey.context && details.skseKeycode == GlobalFunctions.getMappedKey(boundKey.name, Number(boundKey.context), platform != 0)) || (details.skseKeycode && details.skseKeycode == boundKey.keyCode));
	}
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{			
		var bHandledInput: Boolean = false;
		if (GlobalFunc.IsKeyPressed(details)) {
			if(details.navEquivalent == NavigationCode.ENTER || details.skseKeycode == GlobalFunctions.getMappedKey("Activate", Input.CONTEXT_GAMEPLAY, _platform != 0)) {
				onAccept();
				bHandledInput = true;
			} else if(details.navEquivalent == NavigationCode.TAB || details.skseKeycode == GlobalFunctions.getMappedKey("Cancel", Input.CONTEXT_GAMEPLAY, _platform != 0)) {
				onCancel();
				bHandledInput = true;
			} else if (details.navEquivalent == NavigationCode.DOWN) {
				_currentSlider++;
				if(_currentSlider > _sliderCount - 1)
					_currentSlider = 0;
				UpdateSelection();
				GameDelegate.call("PlaySound",["UIMenuFocus"]);
				bHandledInput = true;
			} else if(details.navEquivalent == NavigationCode.UP) {
				_currentSlider--;
				if(_currentSlider < 0)
					_currentSlider = _sliderCount - 1;
				UpdateSelection();
				GameDelegate.call("PlaySound",["UIMenuFocus"]);
				bHandledInput = true;
			} else if (details.navEquivalent == NavigationCode.LEFT || 
					   details.navEquivalent == NavigationCode.RIGHT || 
					   details.navEquivalent == NavigationCode.HOME || 
					   details.navEquivalent == NavigationCode.END || 
					   details.navEquivalent == NavigationCode.GAMEPAD_L2 || 
					   details.navEquivalent == NavigationCode.GAMEPAD_R2 || 
					   details.navEquivalent == NavigationCode.GAMEPAD_L1 || 
					   details.navEquivalent == NavigationCode.GAMEPAD_R1) {
				var sliderObject: Slider = null;
				switch(_currentSlider) {
					case 0:	sliderObject = colorSelector.hSlider;	break;
					case 1:	sliderObject = colorSelector.sSlider;	break;
					case 2:	sliderObject = colorSelector.vSlider;	break;
					case 3:	sliderObject = colorSelector.aSlider;	break;
				}
				bHandledInput = sliderObject.handleInput(details, pathToFocus);
			} else if (this["bCanSwitchMode"] == true && IsBoundKeyPressed(details, _switchModeButton, _platform)) {
				onSwitchMode();
				bHandledInput = true;
			} else if (IsBoundKeyPressed(details, _loadColorButton, _platform)) {
				onLoadColor();
				bHandledInput = true;
			} else if (IsBoundKeyPressed(details, _saveColorButton, _platform)) {
				onSaveColor();
				bHandledInput = true;
			}
		}

		return bHandledInput;
	}

	public function SetupButtons(): Void
	{
		buttonPanel.clearButtons();
		presetPanel.clearButtons();
		
		var acceptButton: MovieClip = buttonPanel.addButton({text: "$Accept", controls: _acceptButton});
		acceptButton.addEventListener("click", this, "onAccept");
		
		var cancelButton: MovieClip = buttonPanel.addButton({text: "$Cancel", controls: _cancelButton});
		cancelButton.addEventListener("click", this, "onCancel");
		
		if(this["bCanSwitchMode"]) {
			var switchButton: MovieClip = buttonPanel.addButton({text: getModeText(), controls: _switchModeButton});
			switchButton.addEventListener("click", this, "onSwitchMode");
		}
		
		var loadColorButton: MovieClip = presetPanel.addButton({text: "$Load Color", controls: _loadColorButton});
		loadColorButton.addEventListener("click", this, "onLoadColor");
		
		var saveColorButton: MovieClip = presetPanel.addButton({text: "$Save Color", controls: _saveColorButton});
		saveColorButton.addEventListener("click", this, "onSaveColor");
				
		buttonPanel.updateButtons(true);
		presetPanel.updateButtons(true);
	}
	
	public function UpdateSelection(): Void
	{
		currentSelectionLeft.gotoAndStop(_currentSlider + 1);
		currentSelectionRight.gotoAndStop(_currentSlider + 1);
	}
	
	public function ResetSlider(): Void
	{
		_currentSlider = 0;
		UpdateSelection();
	}
	
	public function hexToStr(a_AARRGGBB: Number, a_prefix: Boolean): String
	{
		var str:String = a_AARRGGBB.toString(16).toUpperCase();

		var padding: String = '';
		for (var i: Number = str.length; i < 8; i++) {
			padding += '0';
		}

		str = ((a_prefix)? "0x": "") + padding + str;

		return str;
	}
		
	public function set initParams(a_object: Object): Void
	{		
		for(var i:String in a_object)
		{
			this[i] = a_object[i];
		}
		
		disableAlpha(a_object["bNoAlpha"]);
		SetupButtons();
	}
	
	public function disableAlpha(a_disable: Boolean): Void
	{
		if(a_disable) {
			_sliderCount = 3;
			colorSelector.aSlider._visible = false;
			colorSelector.aSlider.enabled = false;
			colorSelector["_alphaValue"] = 0xFF;
			if(_currentSlider == 3) {
				_currentSlider = 0;
				UpdateSelection();
				updateHexCode();
			}
		} else {
			_sliderCount = 4;
			colorSelector.aSlider._visible = true;
			colorSelector.aSlider.enabled = true;
		}
		
		this["bNoAlpha"] = a_disable;
	}
	
	public function getColor(): Number
	{
		return _currentColor;
	}
		
	public function setText(a_text: String): Void
	{
		colorText.text = a_text;
	}
	
	public function updateHexCode(): Void
	{
		var alpha: Number = (colorSelector.getAlpha() >>> 0)
		var red: Number = colorSelector.getColor() >>> 16;
		var green: Number = (colorSelector.getColor() >>> 8) & 0xFF;
		var blue: Number = colorSelector.getColor() & 0xFF;
		hexCode.text = hexToStr((colorSelector.getColor() | colorSelector.getAlpha() << 24), false) + " (A:" + alpha + " R:" + red + " G:" + green + " B:" + blue + ")";
	}
	
	public function setColor(a_color: Number, bUpdate: Boolean): Void
	{
		_currentColor = a_color;
		colorSelector.setColor(_currentColor & 0x00FFFFFF, (_currentColor >>> 24));
		updateHexCode();
	}
	
	public function updateButtons(bInstant: Boolean)
	{
		buttonPanel.updateButtons(bInstant);
		presetPanel.updateButtons(bInstant);
	}

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		if(a_platform == 0) {
			_acceptButton = Input.Accept;
			_cancelButton = {name: "Tween Menu", context: Input.CONTEXT_GAMEPLAY};
			_switchModeButton = Input.Wait;
			_saveColorButton = {keyCode: GlobalFunctions.getMappedKey("Quicksave", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
			_loadColorButton = {keyCode: GlobalFunctions.getMappedKey("Quickload", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		} else {
			_acceptButton = Input.Accept;
			_cancelButton = Input.Cancel;
			_switchModeButton = Input.YButton;
			_saveColorButton = {keyCode: GlobalFunctions.getMappedKey("Toggle POV", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
			_loadColorButton = {keyCode: GlobalFunctions.getMappedKey("Sneak", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
			
		}
		buttonPanel.setPlatform(a_platform, a_bPS3Switch);
		presetPanel.setPlatform(a_platform, a_bPS3Switch);
	}
	
	public function onSwitchMode(): Void
	{
		if(this["bCanSwitchMode"])
		{
			dispatchEvent({type: "changeColor", entry: this["entry"], mode: this["mode"], color: (colorSelector.getColor() | colorSelector.getAlpha() << 24), apply: true, closeField: false});
			dispatchEvent({type: "switchMode", mode: this["mode"]});
			SetupButtons();
		}
	}
	
	public function getModeText(): String
	{
		switch(this["mode"])
		{
			case "tint":
			return "$Glow";
			break;
			case "glow":
			return "$Tint";
			break;
		}
		
		return "";
	}
	
	public function onLoadColor(): Void
	{
		var newColor: Number = 0;		
		if(this["bNoAlpha"]) {
			newColor = (this["savedColor"] & 0x00FFFFFF) | 0xFF000000;
		} else {
			newColor = this["savedColor"];
		}
		
		colorSelector.setColor(newColor & 0x00FFFFFF, (newColor >>> 24));
		updateHexCode();
		
		dispatchEvent({type: "changeColor", entry: this["entry"], mode: this["mode"], color: (colorSelector.getColor() | colorSelector.getAlpha() << 24), apply: false, closeField: false});
	}
	
	public function onSaveColor(): Void
	{
		this["savedColor"] = (colorSelector.getColor() | colorSelector.getAlpha() << 24);
		dispatchEvent({type: "saveColor", color: this["savedColor"]});
	}
	
	public function onSliderChange(event: Object): Void
	{
		dispatchEvent({type: "changeColor", entry: this["entry"], mode: this["mode"], color: (event.color | event.alpha << 24), apply: false, closeField: false});
		updateHexCode();
	}

	public function onAccept(): Void
	{
		dispatchEvent({type: "changeColor", entry: this["entry"], mode: this["mode"], color: (colorSelector.getColor() | colorSelector.getAlpha() << 24), apply: true, closeField: true});
	}

	public function onCancel(): Void
	{
		dispatchEvent({type: "changeColor", entry: this["entry"], mode: this["mode"], color: _currentColor >> 0, apply: true, closeField: true}); // Shift to make signed
	}
}
