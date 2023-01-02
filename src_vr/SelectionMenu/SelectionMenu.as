class SelectionMenu extends MovieClip
{
	var SELECT_MODE_SINGLE: Number = 0;
	var SELECT_MODE_MULTI: Number = 1;
	
	/* Movie Clips */
	var ItemList: MovieClip;
	var LeftPanel: MovieClip;
	var List_mc: MovieClip;
	
	/* Modes */
	var _selectMode: Number = 0;

	function SelectionMenu()
	{
		super();
		ItemList = List_mc;
	}

	function onLoad()
	{
		super.onLoad();
		
		ItemList.InvalidateData();
		ItemList.addEventListener("listMovedUp", this, "onListMoveUp");
		ItemList.addEventListener("listMovedDown", this, "onListMoveDown");
		ItemList.addEventListener("itemPress", this, "onItemSelect");
		gfx.managers.FocusHandler.instance.setFocus(ItemList, 0);
		_parent.gotoAndPlay("startFadeIn");
	}
	
	function InitExtensions()
	{
		skse.SendModEvent("UISelectionMenu_LoadMenu");
	}
	
	private function handleInput(details: gfx.ui.InputDetails, pathToFocus: Array): Boolean
	{
		if (Shared.GlobalFunc.IsKeyPressed(details)) {
			if(details.navEquivalent == gfx.ui.NavigationCode.TAB) {
				startFadeOut();
				return true;
			}
		}
		
		if(ItemList.handleInput(details, pathToFocus)) {
			return true;
		}
		
		return false;
	}

	function get selectedIndex()
	{
		return ItemList.selectedEntry.index;
	}

	function get itemList()
	{
		return ItemList;
	}

	private function setSelectedItem(aiIndex)
	{
		for (var i = 0; i < ItemList.entryList.length; i++) 
		{
			if (ItemList.entryList[i].index == aiIndex) 
			{
				ItemList.selectedIndex = i;
				ItemList.RestoreScrollPosition(i);
				ItemList.UpdateList();
				return;
			}
		}
	}

	private function onListMoveUp(event)
	{
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) 
			this.gotoAndPlay("moveUp");
	}

	private function onListMoveDown(event)
	{
		gfx.io.GameDelegate.call("PlaySound", ["UIMenuFocus"]);
		if (event.scrollChanged == true) 
			this.gotoAndPlay("moveDown");
	}

	private function onItemSelect(event)
	{				
		SetSelectionMenuEntryByIndex(event.index);
	}
	
	private function startFadeOut()
	{
		_parent.gotoAndPlay("startFadeOut");
	}
	
	private function closeMenu(option: Number)
	{
		skse.SendModEvent("UISelectionMenu_CloseMenu");
		//gfx.io.GameDelegate.call("buttonPress", [option]);
		skse.CloseMenu("CustomMenu");
	}

	private function onFadeOutCompletion()
	{
		var hasSelection: Boolean = false;
		if(_selectMode == SELECT_MODE_MULTI) {
			for (var i = 0; i < ItemList.entryList.length; i++) {
				if (ItemList.entryList[i].selectState != undefined && ItemList.entryList[i].selectState >= 1) {
					skse.SendModEvent("UISelectionMenu_SelectForm", "", _selectMode, ItemList.entryList[i].formId >>> 0);
					hasSelection = true;
				}
			}
			if(hasSelection)
				skse.SendModEvent("UISelectionMenu_SelectionReady");
		}
		closeMenu(hasSelection ? 1 : 0);
	}

	private function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean)
	{
		ItemList.SetPlatform(aiPlatform, abPS3Switch);
		LeftPanel._x = aiPlatform == 0 ? -90 : -78.2;
		LeftPanel.gotoAndStop(aiPlatform == 0 ? "Mouse" : "Gamepad");
	}
	
	// @Papyrus
	public function SetSelectionMenuEntryByIndex(index: Number)
	{
		if(_selectMode == SELECT_MODE_MULTI) {
			if(ItemList.entryList[index].selectState != undefined && ItemList.entryList[index].selectState >= 1) {
				ItemList.entryList[index].selectState = 0;
				ItemList.UpdateList();
			} else {
				ItemList.entryList[index].selectState = 1;
				ItemList.UpdateList();
			}
		} else if(_selectMode == SELECT_MODE_SINGLE) {
			if(ItemList.entryList[index].formId != undefined) {
				skse.SendModEvent("UISelectionMenu_SelectForm", "", _selectMode, ItemList.entryList[index].formId);
				skse.SendModEvent("UISelectionMenu_SelectionReady");
				closeMenu(1);
			}
		}
	}
	
	// @Papyrus
	public function SetSelectionMenuEntryByForm(aObject: Object)
	{
		var index: Number = -1;
		for (var i = 0; i < ItemList.entryList.length; i++) {
			if (ItemList.entryList[i].formId != undefined && (ItemList.entryList[i].formId >>> 0) == (aObject.formId >>> 0))
				index = i;
		}
		if(index == -1)
			return;
		
		SetSelectionMenuEntryByIndex(index);
	}
	
	// @Papyrus
	public function SetSelectionMenuFormData(aObject: Object)
	{
		if(aObject.forms != undefined)
		{
			for(var i = 0; i < aObject.forms.length; i++)
			{
				if(aObject.forms[i].formId != undefined) {
					skse.ExtendForm(aObject.forms[i].formId >>> 0, aObject.forms[i], true, false);
					if(aObject.forms[i].actorBase.formId != undefined) {
						skse.ExtendForm(aObject.forms[i].actorBase.formId >>> 0, aObject.forms[i].actorBase, true, false);
						if(aObject.forms[i].fullName != undefined)
							aObject.forms[i].text = aObject.forms[i].fullName;
						else
							aObject.forms[i].text = aObject.forms[i].actorBase.fullName;
					}
				}
			}
			
			ItemList.entryList = aObject.forms;
			ItemList.InvalidateData();
		}
	}
	
	// @Papyrus
	public function SetSelectionMenuMode(mode: Number)
	{
		if(mode >= 0 && mode <= SELECT_MODE_MULTI)
			_selectMode = mode;
	}
}

