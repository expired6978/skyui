import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.ShortRotationPlugin;
import com.greensock.easing.Expo;

import flash.geom.Transform;
import flash.geom.ColorTransform;

import Shared.GlobalFunc;

import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;

import skyui.defines.Actor;
import skyui.defines.Form;

class FollowerWheel extends MovieClip
{
	/* Private Variables */
	private var _options: Array;
	private var _side: Number = -1;
	private var _option: Number = -1;
	private var _iconSource: String = "";
	
	private var _movieLoader: MovieClipLoader;
	
	var TOTAL_OPTIONS: Number = 8;
	var SLICE_COLUMN_SIZE: Number = 4;
	
	/* Private Scene Clips */	
	private var Left00: MovieClip;
	private var Left01: MovieClip;
	private var Left02: MovieClip;
	private var Left03: MovieClip;
	
	private var Right00: MovieClip;
	private var Right01: MovieClip;
	private var Right02: MovieClip;
	private var Right03: MovieClip;
	
	private var Icon0: MovieClip;
	private var Icon1: MovieClip;
	private var Icon2: MovieClip;
	private var Icon3: MovieClip;
	private var Icon4: MovieClip;
	private var Icon5: MovieClip;
	private var Icon6: MovieClip;
	private var Icon7: MovieClip;
	
	private var Knot: MovieClip;
	
	private var Name: TextField;
	private var Group: TextField;
	private var Option: TextField;
	
	private var TextLeft00: TextField;
	private var TextLeft01: TextField;
	private var TextLeft02: TextField;
	private var TextLeft03: TextField;
	
	private var TextRight00: TextField;
	private var TextRight01: TextField;
	private var TextRight02: TextField;
	private var TextRight03: TextField;
	
	public var panelList: ScrollingList;
	
	function FollowerWheel()
	{
		super();
		
		TweenPlugin.activate([ShortRotationPlugin]);
				
		// 17 is for angle offset, each slice is 35 degrees
		_options = [ {slice: Left00, label: TextLeft00, rot: -20 - 17, iconData: {icon: Icon0, name: "", size: 32, color: 0xFFFFFF}, option: "Option0"},
					 {slice: Left01, label: TextLeft01, rot: -55 - 17, iconData: {icon: Icon1, name: "", size: 32, color: 0xFFFFFF}, option: "Option1"},
					 {slice: Left02, label: TextLeft02, rot: -90 - 17, iconData: {icon: Icon2, name: "", size: 32, color: 0xFFFFFF}, option: "Option2"},
					 {slice: Left03, label: TextLeft03, rot: -125 - 17, iconData: {icon: Icon3, name: "", size: 32, color: 0xFFFFFF}, option: "Option3"},
					 {slice: Right00, label: TextRight00, rot: 20 + 17, iconData: {icon: Icon4, name: "", size: 32, color: 0xFFFFFF}, option: "Option4"},
					 {slice: Right01, label: TextRight01, rot: 55 + 17, iconData: {icon: Icon5, name: "", size: 32, color: 0xFFFFFF}, option: "Option5"},
					 {slice: Right02, label: TextRight02, rot: 90 + 17, iconData: {icon: Icon6, name: "", size: 32, color: 0xFFFFFF}, option: "Option6"},
					 {slice: Right03, label: TextRight03, rot: 125 + 17, iconData: {icon: Icon7, name: "", size: 32, color: 0xFFFFFF}, option: "Option7"}
					];
		
		for(var o = 0; o < _options.length; o++) {
			_options[o].slice.gotoAndStop("Inactive");
			_options[o].slice.option = o;
			_options[o].slice.onRollOver = function() {
				this._parent.setWheelOption(this.option);
			}
			_options[o].slice.onRelease = function() {
				this._parent.onWheelOption(this.option);
			}
		}
		
		GlobalFunc.MaintainTextFormat();
		GlobalFunc.SetLockFunction();
		
		_movieLoader = new MovieClipLoader();
		_movieLoader.addListener(this);
		gfx.events.EventDispatcher.initialize(this);
	}
	
	function InitExtensions()
	{
		skse.SendModEvent("UIWheelMenu_LoadMenu");
	}
	
	function onLoad()
	{		
		Name.autoSize = "center";
		gfx.managers.FocusHandler.instance.setFocus(this, 0);
		setWheelIconSource("extension_assets/skyui_icons_psychosteve.swf");
		
		panelList.background._visible = false;
		panelList.listEnumeration = new BasicEnumeration(panelList.entryList);
	}
	
	function handleInput(details: gfx.ui.InputDetails, pathToFocus: Array): Boolean
	{
		var bHandledInput: Boolean = false;
		if (Shared.GlobalFunc.IsKeyPressed(details)) 
		{
			if (details.navEquivalent == gfx.ui.NavigationCode.TAB) {
				closeMenu(-1);
				bHandledInput = true;
			} else if(details.navEquivalent == gfx.ui.NavigationCode.LEFT) {
				var deltaOption = _option;
				if(deltaOption >= SLICE_COLUMN_SIZE)
					deltaOption -= SLICE_COLUMN_SIZE;
				deltaOption = GetNearestOption(deltaOption, true);
				setWheelOption(deltaOption, false);
				bHandledInput = true;
			} else if(details.navEquivalent == gfx.ui.NavigationCode.RIGHT) {
				var deltaOption = _option;
				if(deltaOption < SLICE_COLUMN_SIZE)
					deltaOption += SLICE_COLUMN_SIZE;
				deltaOption = GetNearestOption(deltaOption, true);
				setWheelOption(deltaOption, false);
				bHandledInput = true;
			} else if(details.navEquivalent == gfx.ui.NavigationCode.UP) {
				var deltaOption: Number = _option;
				var top: Boolean = false;
				if(deltaOption > 0)
					deltaOption--;
				else {
					deltaOption = _options.length - 1;
					top = true;
				}
				deltaOption = GetNearestOption(deltaOption, top);
				setWheelOption(deltaOption, false);
				bHandledInput = true;
			} else if(details.navEquivalent == gfx.ui.NavigationCode.DOWN) {
				var deltaOption: Number= _option;
				var top: Boolean = true;
				if(deltaOption < _options.length - 1)
					deltaOption++;
				else {
					deltaOption = 0;
					top = false;
				}
				deltaOption = GetNearestOption(deltaOption, true);
				setWheelOption(deltaOption, false);
				bHandledInput = true;
			} else if(details.navEquivalent == gfx.ui.NavigationCode.ENTER) {
				onWheelOption(_option);
				bHandledInput = true;
			}
		}
		
		return bHandledInput;
	}
	
	// @override MovieClipLoader
	public function onLoadInit(a_clip: MovieClip): Void
	{
		updateIcon(int(a_clip._name.substring(4, _name.length)));
	}
	
	// @override MovieClipLoader
	public function onLoadError(a_clip:MovieClip, a_errorCode: String): Void
	{
		unloadIcon(int(a_clip._name.substring(4, _name.length)));
	}
	
	private function onWheelOption(option: Number)
	{
		if(!_options[option].slice.enabled)
			return;
			
		//skse.SendModEvent("AcceptWheelOption", "", option);
		closeMenu(option);
	}
	
	private function GetNearestOption(option: Number, top: Boolean): Number
	{
		var foundDown: Number = -1;
		var foundUp: Number = -1;
		var foundOption: Number = -1;
		
		var downSkip: Number = 0;
		var upSkip: Number = 0;
		
		// Search Down
		for(var i = option; i < TOTAL_OPTIONS; i++) {
			if(_options[i].slice.enabled) {
				foundDown = i;
				break;
			} else {
				downSkip++;
			}
		}
		// Search Up
		for(var i = option; i >= 0; --i) {
			if(_options[i].slice.enabled) {
				foundUp = i;
				break;
			} else {
				upSkip++;
			}
		}
				
		if(foundDown != -1 && foundUp != -1) { // Found item on both sides go for nearest
			var deltaUp = Math.abs(option - foundUp) - upSkip;
			var deltaDown = Math.abs(option - foundDown) - downSkip;
			if(deltaDown < deltaUp && deltaDown != 0) {
				foundOption = foundDown;
			} else if(deltaUp < deltaDown && deltaUp != 0) {
				foundOption = foundUp;
			} else {
				foundOption = top ? foundDown : foundUp;
			}
		} else if(foundDown != -1) {
			foundOption = foundDown;
		} else if(foundUp != -1) {
			foundOption = foundUp;
		}
		
		return foundOption;
	}
	
	private function setWheelOption(option: Number, silent: Boolean)
	{
		if(option == _option || option == -1)
			return;
			
		if(option < 0 || option >= TOTAL_OPTIONS) // Invalid option
			return;
		
		if(_option != -1) // De-select previous state
			_options[_option].slice.gotoAndStop("Inactive");
					
		TweenLite.to(Knot, 0.5, {shortRotation:{_rotation:_options[option].rot}, ease:Expo.easeOut});
		
		// Select new state
		_options[option].slice.gotoAndStop("Active");
		_option = option;
		
		Option.text = _options[option].option;
		
		if(!silent) {
			gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		}
		
		skse.SendModEvent("UIWheelMenu_SetOption", "", option);
	}
	
	private function closeMenu(option: Number)
	{
		//skse.SendModEvent("MenuClosing", "", 0);
		skse.SendModEvent("UIWheelMenu_CloseMenu");
		skse.SendModEvent("UIWheelMenu_ChooseOption", "", option);
		skse.CloseMenu("CustomMenu");
		//gfx.io.GameDelegate.call("buttonPress", [option]);
		//skse.SendModEvent("MenuClosing", "", 1);
	}
	
	// @Papyrus
	public function setWheelSelection(option: Number, silent: Number): Void
	{
		var newOption: Number = GetNearestOption(option, true);
		setWheelOption(newOption, silent >= 1 ? true : false);
	}
	
	// @Papyrus
	public function setWheelIconSource(a_iconSource: String): Void
	{
		if (_iconSource == a_iconSource)
			return;
			
		_iconSource = a_iconSource;		
		if (_iconSource == "") {
			for(var i = 0; i < TOTAL_OPTIONS; i++)
				unloadIcon(i);
		} else {
			for(var i = 0; i < TOTAL_OPTIONS; i++)
				loadIcon(i);
		}
	}
	
	// @Papyrus
	public function setWheelForm(a_object: Object)
	{
		if(a_object == undefined || a_object.formId == undefined)
			return;
		
		panelList.background._visible = false;
		panelList.entryList.splice(0, panelList.entryList.length);

		skse.ExtendForm(a_object.formId >>> 0, a_object, true, false);
		if(a_object.formType == Form.TYPE_FORMLIST) {
			setWheelText("$Group");
			for(var i = 0; i < a_object.forms.length; i++) {
				if(a_object.forms[i].formId != undefined) {
					skse.ExtendForm(a_object.forms[i].formId >>> 0, a_object.forms[i], true, false); // Extend the form itself
					if(a_object.forms[i].actorBase.formId != undefined) {
						skse.ExtendForm(a_object.forms[i].actorBase.formId >>> 0, a_object.forms[i].actorBase, true, false); // Extend actorBase
						panelList.entryList.push({actor: a_object.forms[i]});
					}
				}
			}
		} else {
			if(a_object.actorBase.formId != undefined) {
				skse.ExtendForm(a_object.actorBase.formId >>> 0, a_object.actorBase, true, false);
				if(a_object.fullName != undefined)
					setWheelText(a_object.fullName);
				else
					setWheelText(a_object.actorBase.fullName);
				panelList.entryList.push({actor: a_object});
			}
		}
		
		panelList.InvalidateData();
		
		if(panelList.entryList.length > 0) {
			panelList.background._visible = true;
		}
	}
	
	// @Papyrus
	public function setWheelText(a_text: String)
	{
		Name.text = a_text;
		Group.text = "";
	}
	
	// @Papyrus
	public function setWheelOptions()
	{
		var options: Array = arguments;
		for(var i = 0; i < options.length; i++) {
			if(options[i].charAt(options[i].length-1) == ' ')
				options[i] = options[i].substring(0, options[i].length-1);
				
			_options[i].option = options[i];
		}
	}
	
	// @Papyrus
	public function setWheelOptionLabels()
	{
		var options: Array = arguments;
		for(var i = 0; i < options.length; i++) {
			if(options[i].charAt(options[i].length-1) == ' ')
				options[i] = options[i].substring(0, options[i].length-1);
				
			_options[i].label.text = options[i];
		}
	}
	
	// @Papyrus
	public function setWheelOptionIcons()
	{
		var options: Array = arguments;
		for(var i = 0; i < options.length; i++) {
			if(options[i].charAt(options[i].length-1) == ' ')
				options[i] = options[i].substring(0, options[i].length-1);
				
			_options[i].iconData.name = options[i];
			updateIcon(i);
		}
	}
	
	// @Papyrus
	public function setWheelOptionIconColors()
	{
		var options: Array = arguments;
		for(var i = 0; i < options.length; i++) {				
			_options[i].iconData.color = options[i];
			updateIcon(i);
		}
	}
	
	// @Papyrus
	public function setWheelOptionTextColors()
	{
		var options: Array = arguments;
		for(var i = 0; i < options.length; i++) {
			_options[i].label.textColor = options[i];
		}
	}
	
	// @Papyrus
	function setWheelOptionsEnabled()
	{
		var options: Array = arguments;
		for(var i = 0; i < options.length; i++) {
			_options[i].slice.enabled = options[i] >= 1 ? true : false;
			_options[i].slice._visible = options[i] >= 1 ? true : false;
		}
	}
	
	// @Papyrus
	public function setWheelOptionText(option: Number, a_text: String)
	{
		if(option < 0 || option >= TOTAL_OPTIONS)
			return;
			
		_options[option].option = a_text;
	}
	
	// @Papyrus
	public function setWheelOptionIcon(option: Number, a_icon: String)
	{
		if(option < 0 || option >= TOTAL_OPTIONS)
			return;
			
		_options[option].iconData.name = a_icon;
		updateIcon(option);
	}
	
	// @Papyrus
	public function setWheelOptionIconColor(option: Number, a_color: Number)
	{
		if(option < 0 || option >= TOTAL_OPTIONS)
			return;
			
		_options[option].iconData.color = a_color;
		updateIcon(option);
	}
	
	
	private function loadIcon(option: Number): Void
	{
		_movieLoader.loadClip(_iconSource, _options[option].iconData.icon);
	}
	
	private function unloadIcon(option: Number): Void
	{
		_movieLoader.unloadClip(_options[option].iconData.icon);
	}
	
	private function updateIcon(option: Number): Void
	{
		var iconData = _options[option].iconData;
		var tf: Transform = new Transform(iconData.icon);
		var colorTf: ColorTransform = new ColorTransform();
		colorTf.rgb = iconData.color;
		tf.colorTransform = colorTf;
		
		iconData.icon._width = iconData.icon._height = iconData.size;
		if(iconData.name != "")
			iconData.icon.gotoAndStop(iconData.name);
		else
			iconData.icon.gotoAndStop(0);
	}
}
