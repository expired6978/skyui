import Shared.GlobalFunc;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.io.GameDelegate;
import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;

import skyui.defines.Input;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.components.ButtonPanel;

class StyleMenu extends MovieClip
{
	private var _platform: Number;
	
	/* Stage Clips */
	public var styleTable: ScrollingTable;
	public var bottomBar: BottomBar;
	public var navPanel: ButtonPanel;
	
	/* CONTROLS */
	private var _acceptControl: Object;
	private var _cancelControl: Object;
	
	/* Hook Data */
	private var _parentMenu: MovieClip;
	private var _parentHandleInput: Function;
	private var _parentSetPlatform: Function;
	private var _parentMouseDown: Function;
	
	/* GFx Dispatcher Functions */
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	public function StyleMenu()
	{
		super();
		
		GlobalFunc.MaintainTextFormat();
		EventDispatcher.initialize(this);
	}
	
	private function onLoad()
	{
		super.onLoad();
		
		navPanel = bottomBar.buttonPanel;
		bottomBar.hidePlayerInfo();
		
		_parentMenu = _root.DialogueMenu_mc;
		_parentHandleInput = _parentMenu.handleInput;
		_parentSetPlatform = _parentMenu.setPlatform;
		_parentMouseDown = _parentMenu.onMouseDown;
		
		HookMenu();
				
		styleTable.listEnumeration = new BasicEnumeration(styleTable.entryList);
		styleTable.addEventListener("itemPress", this, "onStylePress");
		styleTable.addEventListener("selectionChange", this, "onStyleChange");

		// Test Code
		/*for(var i = 0; i < 37; i++) {
			styleTable.entryList.push({text: "Text" + i, flags: 0, editorId: "Style" + i, value: "(" + (Math.floor(Math.random()*(1+999-100))+100) + ")"});
		}

		styleTable.InvalidateData();*/
		
		Mouse.addListener(this);
		
		FocusHandler.instance.setFocus(styleTable, 0);
		
		setPlatform(_global.platform, false);
		
		skse.SendModEvent("SSM_Initialized", "", _global.menuMode);
	}
	
	public function HookMenu(): Void
	{
		_parentMenu.setPlatform = function(a_platform: Number, a_bPS3Switch: Boolean): Void
		{
			_root.StyleMenu.setPlatform(a_platform, a_bPS3Switch);
		};
		
		_parentMenu.handleInput = function(details: InputDetails, pathToFocus: Array): Boolean
		{
			return _root.StyleMenu.handleInput(details, pathToFocus);
		};
		_parentMenu.onMouseDown = function(){};
		_parentMenu.enabled = false;
		_parentMenu._visible = false;
	}
	
	public function UnhookMenu(): Void
	{		
		_parentMenu.handleInput = _parentHandleInput;
		_parentMenu.setPlatform = _parentSetPlatform;
		_parentMenu.onMouseDown = _parentMouseDown;
		_parentMenu.enabled = true;
		_parentMenu._visible = true;
	}
	
	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		
		if(a_platform == 0) {
			_acceptControl = Input.Accept;
			_cancelControl = {name: "Tween Menu", context: Input.CONTEXT_GAMEPLAY};
		} else {
			_acceptControl = Input.Accept;
			_cancelControl = Input.Cancel;
		}
		
		bottomBar.setPlatform(a_platform, a_bPS3Switch);
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		bottomBar.positionElements(leftEdge, rightEdge);
		updateBottomBar();
	}
	
	// @GFx
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{		
		var nextClip = pathToFocus.shift();
		if (nextClip && nextClip.handleInput(details, pathToFocus))
			return true;
	
		if (GlobalFunc.IsKeyPressed(details, false)) {
			if (details.navEquivalent == NavigationCode.TAB) {
				onExitClicked();
				return true;
			}
		}
		
		// Don't forward to higher level
		return true;
	}
	
	private function onStylePress(a_event: Object): Void
	{
		selectOption(styleTable.entryList[a_event.index]);
	}
	
	private function onStyleChange(a_event: Object): Void
	{
		var selectedEntry: Object = styleTable.entryList[a_event.index];
		styleTable.listState.selectedEntry = selectedEntry;
		updateBottomBar();
		GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}
	
	private function selectOption(a_entryObject: Object): Void
	{
		if(!a_entryObject)
			return;
		
		skse.SendModEvent("SSM_ChangeHeadPart", a_entryObject.editorId);
	}
	
	private function updateBottomBar(): Void
	{
		navPanel.clearButtons();
		navPanel.addButton({text: "$Exit", controls: _cancelControl}).addEventListener("click", this, "onExitClicked");
		if(styleTable.listState.selectedEntry) {
			navPanel.addButton({text: "$Choose Hair", controls: _acceptControl}).addEventListener("click", this, "onChooseHairClicked");
		}
		navPanel.updateButtons(true);		
	}
	
	private function onExitClicked(): Void
	{		
		GameDelegate.call("CloseMenu", []);
		GameDelegate.call("FadeDone", []);
	}
	
	private function onChooseHairClicked(): Void
	{		
		var selectedEntry = styleTable.listState.selectedEntry;
		if(selectedEntry) {
			selectOption(selectedEntry);
		}
	}
	
	/* Papyrus Calls */
	public function SSM_AddHeadParts()
	{
		for(var i = 0; i < arguments.length; i++)
		{
			var headPartParams: Array = arguments[i].split(";;");
			if(headPartParams[0] != "") {
				styleTable.entryList.push({text: headPartParams[0], flags: 0, editorId: headPartParams[1], imageSource: headPartParams[2], value: Number(headPartParams[3])});
			}
		}
		
		styleTable.InvalidateData();
	}
}