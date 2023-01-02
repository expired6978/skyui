import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.io.GameDelegate;

import Shared.GlobalFunc;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.Linear;

import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;

class ListMenu extends MovieClip
{
	public var itemView: ItemView;
	public var background: MovieClip;
	public var itemList: ScrollingList;
	
	public var _childView: Array;
	
	public var _linearChildren: Array;
	
	public var _viewPosX: Number = 0;
	public var _viewPosY: Number = 0;
	
	public var _viewPortMin: Number = 5;
	public var _viewPortMax: Number = 15;
		
	public function ListMenu()
	{
		super();
		GlobalFunc.MaintainTextFormat();
		GlobalFunc.SetLockFunction();
		
		itemList = itemView.itemList;
		
		_linearChildren = new Array();
		
		_childView = new Array();
		_childView.push(itemView);
		
		_viewPosX = itemView._x;
		_viewPosY = itemView._y;
		
		_visible = false;
				
		Mouse.addListener(this);
		EventDispatcher.initialize(this);
	}
	
	public function onLoad()
	{
		super.onLoad();
		
		itemView.setMinViewport(_viewPortMin);
		itemView.setMaxViewport(_viewPortMax);
		
		itemList.addEventListener("selectionChange", this, "onSelectionChange");
		itemList.addEventListener("itemPress", this, "onItemPressed");
		
		//addTreeEntries("Item 1;;-1;;0;;0;;1", "Item 2;;-1;;1;;0;;0", "Item 3;;-1;;2;;0;;0", "Child 1;;0;;3;;0;;0");
		
		/*for(var i = 0; i < 25; i++) {
			var entry: Object = {text: "Item " + i, parent: -1, id: _linearChildren.length, children: new Array()};
			_linearChildren.push(entry);
			itemList.entryList.push(entry);
		}
		
		for(var i = 0; i < 24; i++) {
			var entry: Object = {text: "Item1 " + i, parent: 0, id: _linearChildren.length, children: new Array()};
			_linearChildren.push(entry);
		}
		
		for(var i = 0; i < 24; i++) {
			var entry: Object = {text: "Item2 " + i, parent: 1, id: _linearChildren.length, children: new Array()};
			_linearChildren.push(entry);
		}
		
		for(var i = 0; i < 24; i++) {
			var entry: Object = {text: "Item3 " + i, parent: 2, id: _linearChildren.length, children: new Array()};
			_linearChildren.push(entry);
		}
		
		for(var i = 0; i < 24; i++) {
			var entry: Object = {text: "Item4 " + i, parent: 3, id: _linearChildren.length, children: new Array()};
			_linearChildren.push(entry);
		}
		
		for(var i = 0; i < 24; i++) {
			var entry: Object = {text: "Item5 " + i, parent: 4, id: _linearChildren.length, children: new Array()};
			_linearChildren.push(entry);
		}
		
		itemList.requestInvalidate();*/
		FocusHandler.instance.setFocus(itemList, 0);
		
		/*for(var i = 0; i < 25; i++) {
			var children: Array = new Array();
			for(var k = 0; k < 25; k++) {
				var children2: Array = new Array();
				for(var l = 0; l < 25; l++) {
					children2.push({text: "Level 3 Item " + l});
				}
				children.push({text: "Level 2 Item " + k, children: children2});
			}
			itemList.entryList.push({text: "Level 1 Item " + i, children: children});
		}		
			
		itemList.requestInvalidate();
		FocusHandler.instance.setFocus(itemList, 0);*/
	}
	
	public function InitExtensions(): Void
	{
		skse.SendModEvent("UIListMenu_LoadMenu");
	}
	
	public function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean): Void
	{
		
	}
	
	private function closeMenu(): Void
	{
		skse.SendModEvent("UIListMenu_CloseMenu");
		//GameDelegate.call("buttonPress", [option]);
		skse.CloseMenu("CustomMenu");
	}
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var currentView: Object = _childView[_childView.length - 1];
		if(currentView && currentView.handleInput(details, pathToFocus)) {
			return true;
		}
		
		var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus))
			return true;
			
		if (GlobalFunc.IsKeyPressed(details)) {
			if(details.navEquivalent == NavigationCode.TAB) {
				closeChildView();
			}
		}
		return true;
	}
	
	private function onSelectionChange(event: Object): Void
	{
		var currentView: Object = _childView[_childView.length - 1];
		if(currentView) {
			var selectedEntry: Object = currentView.entryList[event.index];
			currentView.itemList.listState.selectedEntry = selectedEntry;
			//GameDelegate.call("PlaySound",["UIMenuFocus"]);
		}
	}
	
	private function onItemPressed(event: Object): Void
	{
		var currentView: Object = _childView[_childView.length - 1];
		if(currentView) {
			var pressedEntry: Object = currentView.entryList[event.index];
			
			// Build children based on parents
			pressedEntry.children.splice(0);
			for(var i = 0; i < _linearChildren.length; i++) {
				if(_linearChildren[i].parent == pressedEntry.id) {
					pressedEntry.children.push(_linearChildren[i]);
				}
			}
			
			if(pressedEntry.children.length > 0) {
				openChildView(pressedEntry, pressedEntry.children);
			} else {
				skse.SendModEvent("UIListMenu_SelectItemText", pressedEntry.text, pressedEntry.callback);
				skse.SendModEvent("UIListMenu_SelectItem", Number(pressedEntry.id).toString(), pressedEntry.callback);
				closeMenu();
			}
		}
	}
			
	public function openChildView(parentEntry: Object, childEntries: Array): Void
	{
		var lastChild: Object = _childView[_childView.length - 1];
		if(lastChild) {
			lastChild.itemList.disableSelection = lastChild.itemList.disableInput = true;
			this.attachMovie("ItemView", "childView_" + _childView.length, this.getNextHighestDepth(), {_alpha: 0, _x: _viewPosX, _y: _viewPosY, objectList: childEntries, parentEntry: parentEntry});
			var newChild: ItemView = this["childView_" + _childView.length];
			newChild.addEventListener("onLoad", this, "onChildViewLoad");
			_childView.push(newChild);
			
			TweenLite.to(lastChild, 0.5, {_alpha: 0, _x: _viewPosX - lastChild._width, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
			TweenLite.to(newChild, 0.5, {_alpha: 100, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
	}
	
	public function closeChildView(): Void
	{
		var lastChild: Object = _childView[_childView.length - 1];
		if(lastChild == itemView) {
			skse.SendModEvent("UIListMenu_SelectItemText", "", -1);
			skse.SendModEvent("UIListMenu_SelectItem", Number(-1).toString(), -1);
			closeMenu();
			//skse.SendModEvent("UIListMenu_SelectItem", Number(-1).toString(), -1);
			return;
		}
		
		// Disable and fade view
		lastChild.itemList.disableSelection = lastChild.itemList.disableInput = true;
		TweenLite.to(lastChild, 0.5, {_alpha: 0, onCompleteScope: this, onComplete: onChildViewRemoved, onCompleteParams: [lastChild], overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		
		// Remove view
		_childView.splice(_childView.length - 1, 1);
		
		// Bring back previous view if there is one
		lastChild = _childView[_childView.length - 1];
		if(lastChild) {
			lastChild.children.splice(0); // Remove all temporary children
			TweenLite.to(lastChild, 0.5, {_alpha: 100, _x: _viewPosX, onCompleteScope: this, onComplete: onChildViewRestored, onCompleteParams: [lastChild], overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
	}
	
	public function onChildViewRestored(lastChild: Object): Void
	{
		lastChild.itemList.disableSelection = lastChild.itemList.disableInput = false;
		FocusHandler.instance.setFocus(lastChild.itemList, 0);
	}
	
	public function onChildViewRemoved(lastChild: Object): Void
	{
		if(lastChild) {
			lastChild.removeMovieClip();
		}
	}
	
	public function onChildViewLoad(event: Object): Void
	{
		if(event.view) {
			event.view.setMinViewport(_viewPortMin);
			event.view.setMaxViewport(_viewPortMax);
			event.view.itemList.addEventListener("itemPress", this, "onItemPressed");
			event.view.itemList.addEventListener("selectionChange", this, "onSelectionChange");
			event.view.entryList = event.view.objectList;
			event.view.itemList.requestInvalidate();
		}
		FocusHandler.instance.setFocus(event.view.itemList, 0);
	}
	
	// Papyrus
	public function LM_AddTreeEntries()
	{
		var rootAdded: Boolean = false;
		for(var i = 0; i < arguments.length; i++)
		{
			var entryParams: Array = arguments[i].split(";;");
			if(entryParams[0] != "") {
				var newEntry: Object = {text: entryParams[0], parent: Number(entryParams[1]), id: Number(entryParams[2]), callback: Number(entryParams[3]), hasChildren: Number(entryParams[4]), children: new Array()};
				_linearChildren.push(newEntry);
				
				if(newEntry.parent == -1) {
					itemList.entryList.push(newEntry);
					rootAdded = true;
				}
			}
		}
				
		if(rootAdded) {
			itemList.InvalidateData();
			_visible = true;
		}
	}
	
	public function LM_SetSortingEnabled(a_sort: Boolean)
	{
		for(var i = 0; i < _childView.length; i++)
		{
			_childView[i].sortEnabled = a_sort;
		}
	}
}
