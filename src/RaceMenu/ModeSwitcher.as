﻿import gfx.events.EventDispatcher;
import gfx.controls.ButtonGroup;
import Shared.GlobalFunc;

class ModeSwitcher extends MovieClip
{
	private var _offset: Number = 10;
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
		Lock("R");
	}
	
	function onLoad()
	{
		tabContainer = this.createEmptyMovieClip("tabContainer", this.getNextHighestDepth());
		
		buttonGroup = new ButtonGroup("tabs", this);
		
		var button0 = addMode("$Sliders");
		var button1 = addMode("$Overlays");
		var button2 = addMode("$Vertices");
		buttonGroup.addButton(button0);
		buttonGroup.addButton(button1);
		buttonGroup.addButton(button2);
		buttonGroup.setSelectedButton(button0);
		
		buttonGroup.addEventListener("change", this, "onItemChanged");		
	}
	
	public function updateAlignment()
	{
		tabContainer._x = -tabContainer._width - _offset;
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
	
	public function onItemChanged(event): Void
	{
		dispatchEvent({type: "changeMode", index: _modes.indexOf(event.item), item: event.item});
	}
}