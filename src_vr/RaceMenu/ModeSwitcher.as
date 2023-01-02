import gfx.events.EventDispatcher;
import gfx.controls.ButtonGroup;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;

class ModeSwitcher extends MovieClip
{
	private var _offset: Number = 5;
	private var _padding: Number = 25;
	private var _modes: Array;
	
	private var buttonGroup: ButtonGroup;
	private var tabContainer: MovieClip;
	
	public var Lock: Function;
	public var dispatchEvent: Function;
	public var addEventListener: Function;
	
	function ModeSwitcher()
	{
		_modes = new Array();
		GlobalFunc.SetLockFunction();
		EventDispatcher.initialize(this);
	}
	
	function InitExtensions()
	{		
		/*if(_global.skse.plugins.CharGen.bEnableSculpting) {
			var button3 = addMode("$Sculpt");
			buttonGroup.addButton(button3);
			button3.addEventListener("rollOver", this, "onItemRollOver");
		}*/
		tabContainer = this.createEmptyMovieClip("tabContainer", this.getNextHighestDepth());
		
		buttonGroup = new ButtonGroup("tabs", tabContainer);
		var button0 = addMode("$Sliders");
		var button1 = addMode("$Presets");
		var button2 = addMode("$Camera");
		buttonGroup.addButton(button0);
		buttonGroup.addButton(button1);
		buttonGroup.addButton(button2);
		
		if(_global.skse.plugins.CharGen.bEnableSculpting) {
			var button3 = addMode("$Sculpt");
			buttonGroup.addButton(button3);
			button3.addEventListener("rollOver", this, "onItemRollOver");
		}
		
		buttonGroup.setSelectedButton(button0);
		
		button0.addEventListener("rollOver", this, "onItemRollOver");
		button1.addEventListener("rollOver", this, "onItemRollOver");
		button2.addEventListener("rollOver", this, "onItemRollOver");
		
		buttonGroup.addEventListener("change", this, "onItemChanged");
		
		Lock("R");
	}
	
	function onLoad()
	{
		/*tabContainer = this.createEmptyMovieClip("tabContainer", this.getNextHighestDepth());
		
		buttonGroup = new ButtonGroup("tabs", tabContainer);
		var button0 = addMode("$Sliders");
		var button1 = addMode("$Presets");
		var button2 = addMode("$Camera");
		buttonGroup.addButton(button0);
		buttonGroup.addButton(button1);
		buttonGroup.addButton(button2);
		buttonGroup.setSelectedButton(button0);
		
		if(_global.skse.plugins.CharGen.bEnableSculpting) {
			var button3 = addMode("$Sculpt");
			buttonGroup.addButton(button3);
			button3.addEventListener("rollOver", this, "onItemRollOver");
		}
		
		button0.addEventListener("rollOver", this, "onItemRollOver");
		button1.addEventListener("rollOver", this, "onItemRollOver");
		button2.addEventListener("rollOver", this, "onItemRollOver");
		
		buttonGroup.addEventListener("change", this, "onItemChanged");*/
	}
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{			
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.GAMEPAD_R2) {
				nextCategory();
				return true;
			} else if (details.navEquivalent == NavigationCode.GAMEPAD_L2) {
				previousCategory();
				return true;
			}
		}

		return false;
	}
	
	public function nextCategory()
	{
		var i: Number = buttonGroup.indexOf(buttonGroup.selectedButton);
		i += 1;
		if(i >= buttonGroup.length)
			i = 0;
		buttonGroup.setSelectedButton(buttonGroup.getButtonAt(i));
	}
	
	public function previousCategory()
	{
		var i: Number = buttonGroup.indexOf(buttonGroup.selectedButton);
		i -= 1;
		if(i < 0)
			i = buttonGroup.length - 1;
		buttonGroup.setSelectedButton(buttonGroup.getButtonAt(i));
	}
	
	public function setMode(index: Number): Void
	{
		var button = buttonGroup.getButtonAt(index);
		if(button.enabled)
			buttonGroup.setSelectedButton(button);
	}
	
	public function updateAlignment()
	{
		tabContainer._x = -tabContainer._width - _offset;
	}
	
	public function getMode(): Number
	{
		return _modes.indexOf(buttonGroup.selectedButton)
	}
	
	public function addMode(a_text: String): MovieClip
	{
		var modeTab: MovieClip = tabContainer.attachMovie("ModeTab", "tab" + _modes, tabContainer.getNextHighestDepth());
		modeTab.tab.textField.text = a_text;
		modeTab.tab.textField.autoSize = "center";
		modeTab.tab.background._width = modeTab.tab.textField._width + _padding * 2;
		var totalOffset = 0;
		for(var i = 0; i < _modes.length; i++)
			totalOffset += _modes[i].tab.background._width + _offset;		
		modeTab._x = totalOffset + modeTab.tab.background._width/2;
		_modes.push(modeTab);
		updateAlignment();
		return modeTab;
	}
	
	public function onItemRollOver(event): Void
	{
		dispatchEvent({type: "tabRollOver", index: _modes.indexOf(event.target), item: event.target});
	}
	
	public function onItemChanged(event): Void
	{
		dispatchEvent({type: "changeMode", index: _modes.indexOf(event.item), item: event.item});
	}
}