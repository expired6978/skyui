import gfx.events.EventDispatcher;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import gfx.io.GameDelegate;

import skyui.components.ButtonPanel;
import skyui.util.GlobalFunctions;
import skyui.defines.Input;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.Linear;

class VertexEditor extends MovieClip
{
	public var wireframeDisplay: WireframeDisplay;
	public var meshWindow: MeshWindow;
	public var historyWindow: HistoryWindow;
	public var brushWindow: BrushWindow;
	
	public var bottomBar: BottomBar;
	public var navPanel: ButtonPanel;
		
	private var BOTTOMBAR_SHOWN_Y = 949;
	private var BOTTOMBAR_HIDDEN_Y = 1099;
	
	public var Lock: Function;
	
	public var tempText: TextField;
	
	private var _secondary: Boolean = false;
		
	/* CONTROLS */
	private var _acceptControl: Object;

	private var _modifierControl: Object;
	private var _upControl: Object;
	private var _downControl: Object;
	private var _leftControl: Object;
	private var _rightControl: Object;
	private var _udControl: Array;
	private var _lrControl: Array;
	private var _exportHeadControl: Object;
	private var _importHeadControl: Object;
	private var _clearSculptControl: Object;

	private var _platform: Number;
	private var _bPS3Switch: Boolean;

	private var _importName: String;
	private var _importPath: String;
	private var _importData: Array;
	
	public var dispatchEvent: Function;
	public var addEventListener: Function;
	
	function VertexEditor()
	{
		super();
		EventDispatcher.initialize(this);
		
		navPanel = bottomBar.buttonPanel;
		
		wireframeDisplay._visible = wireframeDisplay.enabled = false;
		wireframeDisplay._alpha = 0;
		
		meshWindow._visible = meshWindow.enabled = false;
		meshWindow._alpha = 0;
		
		historyWindow._visible = historyWindow.enabled = false;
		historyWindow._alpha = 0;
		
		brushWindow._visible = brushWindow.enabled = false;
		brushWindow._alpha = 0;
		
		tempText._visible = tempText.enabled = false;
		tempText._alpha = 0;
		
		bottomBar._y = BOTTOMBAR_HIDDEN_Y;
	}
	
	function onLoad()
	{
		super.onLoad();
		
		wireframeDisplay.addEventListener("beginPainting", this, "onBeginActivity");
		wireframeDisplay.addEventListener("endPainting", this, "onEndActivity");
		
		wireframeDisplay.addEventListener("beginRotating", this, "onBeginActivity");
		wireframeDisplay.addEventListener("endRotating", this, "onEndActivity");
		
		wireframeDisplay.addEventListener("beginPanning", this, "onBeginActivity");
		wireframeDisplay.addEventListener("endPanning", this, "onEndActivity");
		
		brushWindow.addEventListener("changeBrush", this, "onChangeBrush");
		
		bottomBar.playerInfo.RaceLabel.enabled = bottomBar.playerInfo.RaceLabel._visible = false;
		bottomBar.playerInfo.PlayerRace.enabled = bottomBar.playerInfo.PlayerRace._visible = false;
		bottomBar.playerInfo.NameLabel.text = "$Brush";
		
		var sPanel = bottomBar.attachMovie("ButtonPanel", "staticPanel", bottomBar.getNextHighestDepth(), {buttonRenderer: "MappedButton", maxButtons: 6, buttonInitializer: {disableConstraints: false, disabled: false, disableFocus: true, hiddenBackground: true}});
		sPanel._y = navPanel._y + 28;
		sPanel._x = navPanel._x;
	}
	
	function InitExtensions()
	{		
		historyWindow.InitExtensions();
		bottomBar.playerInfo.Lock("R");
		bottomBar.positionBackground();
		
		BOTTOMBAR_SHOWN_Y = Stage["originalRect"].height - bottomBar._height;
		BOTTOMBAR_HIDDEN_Y = Stage["originalRect"].height + bottomBar._height;
		
		//var rightEdge: Object = {x: Stage["originalRect"].x + Stage["originalRect"].width - Stage.safeRect.x, y: 0};
		//globalToLocal(rightEdge);
		
		var paddingGap: Number = 20;
		
		// Put in bottom right corner
		meshWindow._x = Stage["originalRect"].width - meshWindow._width / 2;
		meshWindow._y = BOTTOMBAR_SHOWN_Y - meshWindow._height / 2 - paddingGap;
		
		trace("Mesh: " + meshWindow._x);
								
		historyWindow._x = Stage["originalRect"].width - historyWindow._width / 2;
		historyWindow._y = BOTTOMBAR_SHOWN_Y - meshWindow._height - historyWindow._height / 2 - paddingGap * 2;
		trace("History: " + historyWindow._x);

		brushWindow._x = brushWindow._width / 2;
		brushWindow._y = BOTTOMBAR_SHOWN_Y - brushWindow._height / 2 - paddingGap;
		trace("Brush: " + brushWindow._x);
	}
	
	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		_bPS3Switch = a_bPS3Switch;
		
		bottomBar.setPlatform(a_platform, a_bPS3Switch);
		
		if(a_platform == 0) {
			_exportHeadControl = {keyCode: GlobalFunctions.getMappedKey("Quicksave", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
			_importHeadControl = {keyCode: GlobalFunctions.getMappedKey("Quickload", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		} else {
			_importHeadControl = {keyCode: GlobalFunctions.getMappedKey("Sneak", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
			_exportHeadControl = {keyCode: GlobalFunctions.getMappedKey("Toggle POV", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		}
		
		_acceptControl = {keyCode: GlobalFunctions.getMappedKey("Ready Weapon", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		_modifierControl = {keyCode: GlobalFunctions.getMappedKey("Sprint", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		_upControl = {keyCode: GlobalFunctions.getMappedKey("Up", Input.CONTEXT_MENUMODE, a_platform != 0)};
		_downControl = {keyCode: GlobalFunctions.getMappedKey("Down", Input.CONTEXT_MENUMODE, a_platform != 0)};
		_leftControl = {keyCode: GlobalFunctions.getMappedKey("Left", Input.CONTEXT_MENUMODE, a_platform != 0)};
		_rightControl = {keyCode: GlobalFunctions.getMappedKey("Right", Input.CONTEXT_MENUMODE, a_platform != 0)};
		_udControl = [_upControl, _downControl];
		_lrControl = [_leftControl, _rightControl];
		_clearSculptControl = {keyCode: GlobalFunctions.getMappedKey("Shout", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		bottomBar.positionElements(leftEdge, rightEdge);
				
		var staticPanel = bottomBar["staticPanel"];
		if(staticPanel) {
			staticPanel.setPlatform(a_platform, a_bPS3Switch);
			staticPanel._x = navPanel._x;
			staticPanel._y = navPanel._y + 28;
			
			staticPanel.clearButtons();
			if(_global.skse.plugins.CharGen) {
				if(_platform == 0) {			
					staticPanel.addButton({text: "$Export Head", controls: _exportHeadControl}).addEventListener("click", this, "onExportHeadClicked");
					staticPanel.addButton({text: "$Import Head", controls: _importHeadControl}).addEventListener("click", this, "onImportHeadClicked");
				} else {
					staticPanel.addButton({text: "$Import Head", controls: _importHeadControl}).addEventListener("click", this, "onImportHeadClicked");
					staticPanel.addButton({text: "$Export Head", controls: _exportHeadControl}).addEventListener("click", this, "onExportHeadClicked");
				}
				
				staticPanel.addButton({text: "$Clear Sculpt", controls: _clearSculptControl}).addEventListener("click", this, "onClearSculptClicked");
			}
			staticPanel.updateButtons(true);
		}
		
		updateBottomBar();
	}
	
	private function updateBottomBar(): Void
	{
		navPanel.clearButtons();
		navPanel.addButton({text: "$Done", controls: _acceptControl}).addEventListener("click", this._parent, "onDoneClicked");
		
		if(!_secondary)
			navPanel.addButton({text: "$Secondary", controls: _modifierControl});
		else
			navPanel.addButton({text: "$Primary", controls: _modifierControl});
		
		navPanel.addButton({text: "$Brush", controls: _udControl});
		navPanel.addButton({text: "$Property", controls: _lrControl});		
		
		navPanel.updateButtons(true);		
	}
	
	public function ShowAll(bShowAll: Boolean, bRequestLoad: Boolean, bRequestUnload: Boolean): Void
	{
		ShowBottomBar(bShowAll);		
		if(bShowAll) {
			TweenLite.to(this, 0.5, {autoAlpha: 100, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			TweenLite.to(this, 0.5, {autoAlpha: 0, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
		
		if(bShowAll) {
			if(bRequestLoad) {
				wireframeDisplay.loadAssets();
				brushWindow.loadAssets();
				historyWindow.loadAssets();
				meshWindow.loadAssets();
			}
			
			ShowMeshWindow(true);
			ShowWireframe(true);
			ShowHistoryWindow(true);
			ShowBrushWindow(true);
			TweenLite.to(tempText, 0.5, {autoAlpha: 100, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			if(bRequestUnload) {
				meshWindow.unloadAssets();
				historyWindow.unloadAssets();
				brushWindow.unloadAssets();
				wireframeDisplay.unloadAssets();
			}
			
			ShowMeshWindow(false);
			ShowWireframe(false);
			ShowHistoryWindow(false);
			ShowBrushWindow(false);
			TweenLite.to(tempText, 0.5, {autoAlpha: 0, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
		
		enabled = bShowAll;
	}
	
	public function ShowMeshWindow(bShowWindow: Boolean): Void
	{
		if(bShowWindow) {
			TweenLite.to(meshWindow, 0.5, {autoAlpha: 100, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			TweenLite.to(meshWindow, 0.5, {autoAlpha: 0, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
	}
	
	public function ShowHistoryWindow(bShowWindow: Boolean): Void
	{
		if(bShowWindow) {
			TweenLite.to(historyWindow, 0.5, {autoAlpha: 100, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			TweenLite.to(historyWindow, 0.5, {autoAlpha: 0, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
	}
	
	public function ShowBrushWindow(bShowWindow: Boolean): Void
	{
		if(bShowWindow) {
			TweenLite.to(brushWindow, 0.5, {autoAlpha: 100, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			TweenLite.to(brushWindow, 0.5, {autoAlpha: 0, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
	}
		
	public function ShowWireframe(bShowWireframe: Boolean): Void
	{
		if(bShowWireframe) {
			TweenLite.to(wireframeDisplay, 0.5, {autoAlpha: 100, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			TweenLite.to(wireframeDisplay, 0.5, {autoAlpha: 0, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
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
		if (details.skseKeycode == _modifierControl.keyCode) {
			_secondary = (details.value == "keyDown" || details.value == "keyHold");
			wireframeDisplay.secondary = _secondary;
			updateBottomBar(true);
			return true;
		}
		if (GlobalFunc.IsKeyPressed(details)) {			
			 if(IsBoundKeyPressed(details, _exportHeadControl, _platform)) {
				onExportHeadClicked();
				return true;
			}
			if(IsBoundKeyPressed(details, _importHeadControl, _platform)) {
				onImportHeadClicked();
				return true;
			}
			if(IsBoundKeyPressed(details, _clearSculptControl, _platform)) {
				onClearSculptClicked();
				return true;
			}
		}
		
		return brushWindow.handleInput(details, pathToFocus);
	}
	
	public function hasAssets(): Boolean
	{
		return wireframeDisplay.bLoadedAssets;
	}
	
	public function unloadAssets(): Void
	{
		meshWindow.unloadAssets();
		historyWindow.unloadAssets();
		brushWindow.unloadAssets();
		wireframeDisplay.unloadAssets();
	}
	
	public function onBeginActivity(event: Object)
	{
		brushWindow.bAllowBrushChange = false;
	}
	
	public function onEndActivity(event: Object)
	{
		brushWindow.bAllowBrushChange = true;
	}
	
	public function onChangeBrush(event: Object)
	{
		bottomBar.playerInfo.PlayerName.text = event.brushName;
	}
	
	private function onExportHeadClicked(): Void
	{		
		var now: Date = new Date();
		var dateStr: String = "Head_" + (now.getMonth()+1) + "-" + now.getDate() + "-" + now.getFullYear() + "_" + now.getHours() + "-" + now.getMinutes() + "-" + now.getSeconds();
		delete now;
		
		var dialog = DialogTweenManager.open(_root, "FileViewerDialog", {_platform: _platform, _bPS3Switch: _bPS3Switch, titleText: "$Export Head", defaultText: dateStr, path: "Data\\SKSE\\Plugins\\CharGen\\", patterns: ["*.nif"], disableInput: false});
		dialog.addEventListener("accept", this, "onExportFile");
	}
	
	private function onImportHeadClicked(): Void
	{
		var dialog = DialogTweenManager.open(_root, "FileViewerDialog", {_platform: _platform, _bPS3Switch: _bPS3Switch, titleText: "$Import Head", defaultText: "", path: "Data\\SKSE\\Plugins\\CharGen\\", patterns: ["*.nif"], disableInput: true});
		dialog.addEventListener("accept", this, "onImportFile");
		dialog.addEventListener("dialogClosed", this, "onImportDialogClosed");
		
		/*var dialog = DialogTweenManager.open(_root, "ImportDialog", {_platform: _platform, _bPS3Switch: _bPS3Switch, titleText: "$Import Part Matcher", importPath: _importPath, source: _importData, destination: meshWindow.GetInternalMeshes()});
		dialog.addEventListener("accept", this, "onImportHead");*/
	}
	
	public function onExportFile(event: Object): Void
	{
		var filePath = event.directoryPath + "\\" + event.input;
		_global.skse.plugins.CharGen.ExportHead(filePath);
	}
	
	public function onImportFile(event): Void
	{
		_importPath = event.directoryPath + "\\" + event.input;
		_importName = event.input;
		_importData = _global.skse.plugins.CharGen.ImportHead(_importPath);
	}
	
	public function onImportDialogClosed(event): Void
	{
		if(_importData.length > 0) {
			var dialog = DialogTweenManager.open(_root, "ImportDialog", {_platform: _platform, _bPS3Switch: _bPS3Switch, titleText: "$Import Part Matcher", importPath: _importPath, source: _importData, destination: meshWindow.GetInternalMeshes()});
			dialog.addEventListener("accept", this, "onImportHead");
		}
		
		dispatchEvent({type: "importedFile", success: (_importData.length > 0), name: _importName});
	}
	
	public function onImportHead(event): Void
	{
		_global.skse.plugins.CharGen.LoadImportedHead(event.matches);
	}
	
	public function onClearSculptClicked(): Void
	{
		var meshes: Array = meshWindow.GetInternalMeshes();
		var activeList: Array = new Array();
		for(var i = 0; i < meshes.length; i++) {
			if(meshes[i].locked == false) {
				activeList.push(meshes[i].meshIndex);
			}
		}
		
		_global.skse.plugins.CharGen.ClearSculptData(activeList);
		
		delete activeList;
	}
}
