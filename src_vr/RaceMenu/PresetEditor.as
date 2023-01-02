import gfx.events.EventDispatcher;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.managers.FocusHandler;

import Shared.GlobalFunc;

import skyui.components.ButtonPanel;
import skyui.util.GlobalFunctions;
import skyui.defines.Input;

import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.Linear;

class PresetEditor extends MovieClip
{
	public var bottomBar: BottomBar;
	public var navPanel: ButtonPanel;
	public var itemList: PresetList;
	
	private var presetPanel: MovieClip;
	
	private var ITEMLIST_HIDDEN_X = -478;
	private var BOTTOMBAR_SHOWN_Y = 949;
	private var BOTTOMBAR_HIDDEN_Y = 1099;
	private var _panelX;
		
	public var Lock: Function;
		
	/* CONTROLS */
	private var _platform: Number;
	private var _bPS3Switch: Boolean;
	private var _acceptControl: Object;
	private var _activateControl: Object;
	private var _cancelControl: Object;
	private var _loadPresetControl: Object;
	private var _savePresetControl: Object;
	
	public var dispatchEvent: Function;
	public var addEventListener: Function;
	
	function PresetEditor()
	{
		super();

		Mouse.addListener(this);
		EventDispatcher.initialize(this);
		
		navPanel = bottomBar.buttonPanel;
		itemList = presetPanel.itemList;
		itemList.disableSelection = itemList.disableInput = false;
				
		bottomBar._y = BOTTOMBAR_HIDDEN_Y;
	}
	
	function onLoad()
	{
		super.onLoad();		
		bottomBar.hidePlayerInfo();
	}
	
	function InitExtensions()
	{
		BOTTOMBAR_SHOWN_Y = Stage["originalRect"].height - bottomBar._height;
		BOTTOMBAR_HIDDEN_Y = Stage["originalRect"].height + bottomBar._height;
		
		presetPanel.Lock("L");
		_panelX = presetPanel._x;
		presetPanel._x = ITEMLIST_HIDDEN_X;
		bottomBar.positionBackground();
		
		itemList.listEnumeration = new BasicEnumeration(itemList.entryList);
		if(!_global.skse.plugins.CharGen) {
			var entryObject: Object = {type: RaceMenuDefines.PRESET_ENTRY_TYPE_TEXT, text: "CharGen Presets Unavailable", filterFlag: 1, enabled: true};
			itemList.entryList.push(entryObject);
		}
		
		FocusHandler.instance.setFocus(itemList, 0);
		itemList.requestInvalidate();
	}
	
	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		_bPS3Switch = a_bPS3Switch;
		bottomBar.setPlatform(a_platform, a_bPS3Switch);
		
		_activateControl = Input.Accept;
		
		if(_platform == 0) {
			_cancelControl = {name: "Tween Menu", context: Input.CONTEXT_GAMEPLAY};
			_savePresetControl = {keyCode: GlobalFunctions.getMappedKey("Quicksave", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
			_loadPresetControl = {keyCode: GlobalFunctions.getMappedKey("Quickload", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		} else {
			_cancelControl = Input.Cancel;
			_loadPresetControl = {keyCode: GlobalFunctions.getMappedKey("Sneak", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
			_savePresetControl = {keyCode: GlobalFunctions.getMappedKey("Toggle POV", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		}
		
		_acceptControl = {keyCode: GlobalFunctions.getMappedKey("Ready Weapon", Input.CONTEXT_GAMEPLAY, a_platform != 0)};

		
		
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		bottomBar.positionElements(leftEdge, rightEdge);
		
		updateBottomBar();
	}
	
	private function updateBottomBar(): Void
	{
		navPanel.clearButtons();
		navPanel.addButton({text: "$Done", controls: _acceptControl}).addEventListener("click", _parent, "onDoneClicked");
		if(_platform == 0) {			
			navPanel.addButton({text: "$Save Preset", controls: _savePresetControl}).addEventListener("click", this, "onSavePresetClicked");
			navPanel.addButton({text: "$Load Preset", controls: _loadPresetControl}).addEventListener("click", this, "onLoadPresetClicked");
		} else {
			navPanel.addButton({text: "$Load Preset", controls: _loadPresetControl}).addEventListener("click", this, "onLoadPresetClicked");
			navPanel.addButton({text: "$Save Preset", controls: _savePresetControl}).addEventListener("click", this, "onSavePresetClicked");
		}
		navPanel.updateButtons(true);		
	}
	
	public function ShowPanel(bShowPanel: Boolean): Void
	{
		if(bShowPanel) {
			itemList.disableSelection = itemList.disableInput = false;
			TweenLite.to(presetPanel, 0.5, {autoAlpha: 100, _x: _panelX, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			itemList.disableSelection = itemList.disableInput = true;
			TweenLite.to(presetPanel, 0.5, {autoAlpha: 0, _x: ITEMLIST_HIDDEN_X, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
	}
	
	public function ShowAll(bShowAll: Boolean): Void
	{
		ShowPanel(bShowAll);
		ShowBottomBar(bShowAll);
		if(bShowAll) {
			TweenLite.to(this, 0.5, {autoAlpha: 100, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			TweenLite.to(this, 0.5, {autoAlpha: 0, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
		
		enabled = bShowAll;
	}
		
	public function ShowBottomBar(bShowBottomBar: Boolean): Void
	{
		if(bShowBottomBar) {
			TweenLite.to(bottomBar, 0.5, {autoAlpha: 100, _y: BOTTOMBAR_SHOWN_Y, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			TweenLite.to(bottomBar, 0.5, {autoAlpha: 0, _y: BOTTOMBAR_HIDDEN_Y, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
	}
	
	public function IsBoundKeyPressed(details: InputDetails, boundKey: Object, platform: Number): Boolean
	{
		return ((details.control && details.control == boundKey.name) || (details.skseKeycode && boundKey.name && boundKey.context && details.skseKeycode == GlobalFunctions.getMappedKey(boundKey.name, Number(boundKey.context), platform != 0)) || (details.skseKeycode && details.skseKeycode == boundKey.keyCode));
	}
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (GlobalFunc.IsKeyPressed(details)) {
			if(IsBoundKeyPressed(details, _loadPresetControl, _platform) && !_parent.bTextEntryMode) {
				onLoadPresetClicked();
				return true;
			} else if(IsBoundKeyPressed(details, _savePresetControl, _platform) && !_parent.bTextEntryMode) {
				onSavePresetClicked();
				return true;
			}
		}
		
		if(itemList.handleInput(details, pathToFocus)) {
			return true;
		}
		
		// Consume Left/Right input
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.RIGHT) {
				return true;
			} else if (details.navEquivalent == NavigationCode.LEFT) {
				return true;
			}
		}
		
		return false;
	}
	
	private function readPreset(a_path: String, a_json: Boolean): Void
	{
		var preset: Object = new Object;
		var loadError: Boolean = _global.skse.plugins.CharGen.ReadPreset(a_path, preset, a_json);
		if(loadError == false) {			
			itemList.entryList.push({type: RaceMenuDefines.PRESET_ENTRY_TYPE_HEADER, text: "$Mods", filterFlag: 1, enabled: true});
			for(var i = 0; i < preset.mods.length; i++) {
				var mod = preset.mods[i];
				var textColor: Number = 0x189515;
				if(mod.loadedIndex == 255)
					textColor = 0xFF0000;				
				itemList.entryList.push({type: RaceMenuDefines.PRESET_ENTRY_TYPE_TEXT, text: mod.name, filterFlag: 1, textFieldColor: textColor, enabled: true});
			}
			
			itemList.entryList.push({type: RaceMenuDefines.PRESET_ENTRY_TYPE_HEADER, text: "$Head Parts", filterFlag: 1, enabled: true});
			
			for(var i = 0; i < preset.headParts.length; i++)
				itemList.entryList.push({type: RaceMenuDefines.PRESET_ENTRY_TYPE_TEXT, text: preset.headParts[i], filterFlag: 1, enabled: true});
			
			itemList.entryList.push({type: RaceMenuDefines.PRESET_ENTRY_TYPE_HEADER, text: "$Colors", filterFlag: 1, enabled: true});
			var hairColor: Object = {type: RaceMenuDefines.PRESET_ENTRY_TYPE_COLOR, text: preset.hair.name, fillColor: (0xFF000000 | preset.hair.value), filterFlag: 1, enabled: true};
			hairColor.isColorEnabled = function(): Boolean { return true; }
			hairColor.hasColor = function(): Boolean { return true; }
			hairColor.hasGlow = function(): Boolean { return false; }
			itemList.entryList.push(hairColor);
			
			for(var i = 0; i < preset.tints.length; i++) {
				var tint = preset.tints[i];
				if((tint.color >>> 24) > 0) {
					var tintEntry: Object = {type: RaceMenuDefines.PRESET_ENTRY_TYPE_COLOR, text: stripTexturePath(tint.texture), fillColor: tint.color, filterFlag: 1, enabled: true};
					tintEntry.isColorEnabled = function(): Boolean { return true; }
					tintEntry.hasColor = function(): Boolean { return true; }
					tintEntry.hasGlow = function(): Boolean { return false; }
					itemList.entryList.push(tintEntry);
				}
			}
			
			itemList.entryList.push({type: RaceMenuDefines.PRESET_ENTRY_TYPE_HEADER, text: "$Sliders", filterFlag: 1, enabled: true});
			itemList.entryList.push({type: RaceMenuDefines.PRESET_ENTRY_TYPE_TEXT_VALUE, text: preset.weight.name, position: preset.weight.value, filterFlag: 1, enabled: true});
			
			for(var i = 0; i < preset.morphs.length; i++) {
				var morph = preset.morphs[i];
				if(morph.name)
					itemList.entryList.push({type: RaceMenuDefines.PRESET_ENTRY_TYPE_TEXT_VALUE, text: morph.name, position: morph.value, filterFlag: 1, enabled: true});
			}
		}
	}
	
	private function stripTexturePath(a_texture: String): String
	{
		// Strip Path and extension
		var slashIndex: Number = -1;
		for(var k = a_texture.length - 1; k > 0; k--) {
			if(a_texture.charAt(k) == "\\" || a_texture.charAt(k) == "/") {
				slashIndex = k;
				break;
			}
		}
		var formatIndex: Number = a_texture.indexOf(".dds");
		if(formatIndex == -1)
			formatIndex = a_texture.length;
		
		return a_texture.substring(slashIndex + 1, formatIndex);
	}
	
	private function onSavePresetClicked(): Void
	{
		var now: Date = new Date();
		var dateStr: String = "Preset_" + (now.getMonth()+1) + "-" + now.getDate() + "-" + now.getFullYear() + "_" + now.getHours() + "-" + now.getMinutes() + "-" + now.getSeconds();
		delete now;
		
		var dialog = DialogTweenManager.open(_root, "FileViewerDialog", {_platform: _platform, _bPS3Switch: _bPS3Switch, titleText: "$Save preset file", defaultText: dateStr, path: "Data\\SKSE\\Plugins\\CharGen\\Presets\\", patterns: ["*.jslot", "*.slot"], disableInput: false});
		dialog.addEventListener("accept", this, "onSaveFile");
	}
	
	private function onLoadPresetClicked(): Void
	{
		var dialog = DialogTweenManager.open(_root, "FileViewerDialog", {_platform: _platform, _bPS3Switch: _bPS3Switch, titleText: "$Select preset file", defaultText: "", path: "Data\\SKSE\\Plugins\\CharGen\\Presets\\", patterns: ["*.jslot", "*.slot"], disableInput: true});
		dialog.addEventListener("selectionChanged", this, "onSelectFile");
		dialog.addEventListener("accept", this, "onLoadFile");
	}
	
	private function onSelectFile(event: Object)
	{
		itemList.entryList.splice(0, itemList.entryList.length);
		if(!event.directory) {
			var filePath = event.directoryPath + "\\" + event.input;
			var extension = filePath.substring(filePath.lastIndexOf("."), filePath.length);
			var json: Boolean = (extension == ".jslot") ? true : false;
		
			readPreset(filePath, json);
		}
			
		itemList.requestInvalidate();
	}
	
	private function onSaveFile(event): Void
	{
		var filePath = event.directoryPath + "\\" + event.input;
		if(filePath.lastIndexOf(".") == -1)
			filePath += ".jslot";
		
		var saveError: Boolean = _global.skse.plugins.CharGen.SavePreset(filePath, true);
		
		dispatchEvent({type: "savedPreset", name: event.input, success: !saveError});
		
		if(!saveError) {
			itemList.entryList.splice(0, itemList.entryList.length);
			readPreset(filePath, true);
			itemList.requestInvalidate();
		}
	}
	
	private function onLoadFile(event: Object)
	{
		var filePath = event.directoryPath + "\\" + event.input;
		if(filePath) {
			var extension = filePath.substring(filePath.lastIndexOf("."), filePath.length);
			var json: Boolean = (extension == ".jslot") ? true : false;
			
			var dataObject: Object = new Object();
			_parent.loadingIcon._visible = true;
			var loadError: Boolean = _global.skse.plugins.CharGen.LoadPreset(filePath, dataObject, json);
			_parent.loadingIcon._visible = false;
			dispatchEvent({type: "loadedPreset", name: event.input, success: !loadError, data: dataObject});
		}
	}
}
