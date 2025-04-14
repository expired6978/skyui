import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;
import Shared.GlobalFunc;
import gfx.io.GameDelegate;

import skyui.components.SearchWidget;
import skyui.components.list.FilteredEnumeration;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.components.ButtonPanel;
import skyui.filter.SortFilter;
import skyui.filter.NameFilter;
import skyui.defines.Input;
import skyui.util.GlobalFunctions;

class PartsPanel extends MovieClip
{
	public var buttonPanel: ButtonPanel;
	public var partsList: PartsList;
	public var tagsList: TagsList;
	public var searchWidget: SearchWidget;
	public var bTextEntryMode: Boolean = false;
	public var partCount: TextField;
	public var titleField: TextField;
	public var sourceField: TextField;
	
	public var bSuppressFocus: Boolean = false;
	public var bSuppressSelect: Boolean = false;
	
	private var _acceptButton: Object;
	private var _cancelButton: Object;
	
	private var _sortFilter: SortFilter;
	private var _nameFilter: NameFilter;
	private var _tagsFilter: TagsFilter;
	
	private var _platform: Number;
	private var _initParams: Object = null;
	
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	function PartsPanel()
	{
		super();
		
		sourceField.textAutoSize = "shrink";
		
		_sortFilter = new SortFilter();
		_nameFilter = new NameFilter();
		_tagsFilter = new TagsFilter();
		_nameFilter.nameAttribute = "name";
		
		GlobalFunc.MaintainTextFormat();
		GlobalFunc.SetLockFunction();
		
		EventDispatcher.initialize(this);
	}
	
	private function onLoad()
	{
		super.onLoad();

		var listEnumeration = new FilteredEnumeration(partsList.entryList);
		listEnumeration.addFilter(_sortFilter);
		listEnumeration.addFilter(_nameFilter);
		listEnumeration.addFilter(_tagsFilter);
		partsList.listEnumeration = listEnumeration;
		partsList["baseInvalidate"] = function() {
			_parent.partCount.text = this.itemCount.toString();
			_parent.bSuppressFocus = false;
		}
		partsList.onInvalidate = partsList["baseInvalidate"];
		tagsList.listEnumeration = new BasicEnumeration(tagsList.entryList);
		
		_sortFilter.setSortBy(["name"], [0]);
		_sortFilter.addEventListener("filterChange", this, "onFilterChange");
		_nameFilter.addEventListener("filterChange", this, "onFilterChange");
		_tagsFilter.addEventListener("filterChange", this, "onFilterChange");
		
		partsList.addEventListener("itemPress", this, "onItemPress");
		partsList.addEventListener("selectionChange", this, "onSelectionChanged");
		partsList.addEventListener("itemRollOver", this, "onPartItemRollOver");
		tagsList.addEventListener("itemPress", this, "onTagItemPress");
		tagsList.addEventListener("selectionChange", this, "onTagSelectionChanged");
		tagsList.addEventListener("itemRollOver", this, "onTagItemRollOver");
		
		searchWidget.addEventListener("inputStart", this, "onSearchInputStart");
		searchWidget.addEventListener("inputEnd", this, "onSearchInputEnd");
		searchWidget.addEventListener("inputChange", this, "onSearchInputChange");
		searchWidget.gotoAndStop("Double");
		
		// Test Code
		/*for(var i = 0; i < 50; i++) {
			AddParts("Texture" + i, "Actor\\Texture_" + i + ".dds");
		}
		InvalidateList();*/
	}
	
	public function set initParams(a_object: Object): Void
	{
		for(var i:String in a_object)
		{
			this[i] = a_object[i];
		}
	}
	
	private function onSearchInputStart(event: Object): Void
	{
		bTextEntryMode = true;
		partsList.disableSelection = partsList.disableInput = true;
		tagsList.disableSelection = tagsList.disableInput = true;
		_nameFilter.filterText = "";
	}

	private function onSearchInputChange(event: Object)
	{
		_nameFilter.filterText = event.data;
	}

	private function onSearchInputEnd(event: Object)
	{
		partsList.disableSelection = partsList.disableInput = false;
		tagsList.disableSelection = tagsList.disableInput = false;
		_nameFilter.filterText = event.data;
		bTextEntryMode = false;
	}
	
	private function onFilterChange(): Void
	{
		partsList.requestInvalidate();
	}
	
	public function clearData(): Void
	{
		if(partsList.listEnumeration) {
			delete partsList.listEnumeration;
			partsList.listEnumeration = null;
		}
		if(partsList.entryList) {
			delete partsList.entryList;
			partsList.entryList = null;
		}
		if(tagsList.listEnumeration) {
			delete tagsList.listEnumeration;
			tagsList.listEnumeration = null;
		}
		if(tagsList.entryList) {
			delete tagsList.entryList;
			tagsList.entryList = null;
		}
		if(_tagsFilter.filterTags) {
			delete _tagsFilter.filterTags;
		}
		setPartsList([]);
		setTagsList([]);
		_nameFilter.filterText = "";
		_tagsFilter.filterTags = [];
		searchWidget.textField.SetText("$FILTER");
	}
	
	public function clearFilter(): Void
	{
		_nameFilter.filterText = "";
		searchWidget.endInput();
	}
	
	public function setPartsList(list: Array): Void
	{
		if(partsList.listEnumeration) {
			delete partsList.listEnumeration;
			partsList.listEnumeration = null;
		}
		
		partsList.entryList = list;
		if(partsList.entryList) {
			var listEnumeration = new FilteredEnumeration(partsList.entryList);
			listEnumeration.addFilter(_sortFilter);
			listEnumeration.addFilter(_nameFilter);
			listEnumeration.addFilter(_tagsFilter);
			partsList.listEnumeration = listEnumeration;
			partsList.requestInvalidate();
		}
	}
	
	public function setTagsList(list: Array): Void
	{
		if(tagsList.listEnumeration) {
			delete tagsList.listEnumeration;
			tagsList.listEnumeration = null;
		}
		tagsList.entryList = list;
		if(tagsList.entryList) {
			tagsList.listEnumeration = new BasicEnumeration(tagsList.entryList);
			tagsList.requestInvalidate();
			tagsList.onInvalidate = function() {
				this.selectDefaultIndex(true);
			}
		}
	}
		
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bHandledInput: Boolean = false;
		if (GlobalFunc.IsKeyPressed(details) && !bTextEntryMode) {
			if(details.navEquivalent == NavigationCode.ENTER || (details.skseKeycode && details.skseKeycode == GlobalFunctions.getMappedKey("Activate", Input.CONTEXT_GAMEPLAY, _platform != 0))) {
				if(FocusHandler.instance.getFocus(0) == partsList) {
					onAccept();
					bHandledInput = true;
				}
			} else if(details.navEquivalent == NavigationCode.TAB || (details.skseKeycode && details.skseKeycode == GlobalFunctions.getMappedKey("Cancel", Input.CONTEXT_GAMEPLAY, _platform != 0))) {
				onCancel();
				bHandledInput = true;
			} else if(details.navEquivalent == NavigationCode.LEFT) {
				bHandledInput = focusParts(true);
			} else if(details.navEquivalent == NavigationCode.RIGHT) {
				bHandledInput = focusTags(true);
			}
		}
		
		if(!bHandledInput) {
			var nextClip = pathToFocus.shift();
			bHandledInput = nextClip.handleInput(details, pathToFocus);
		}

		return bHandledInput;
	}
	
	public function SetupButtons(): Void
	{
		buttonPanel.clearButtons();
		var acceptButton: MovieClip = buttonPanel.addButton({text: "$Accept", controls: _acceptButton});
		var cancelButton: MovieClip = buttonPanel.addButton({text: "$Cancel", controls: _cancelButton});
		acceptButton.addEventListener("click", this, "onAccept");
		cancelButton.addEventListener("click", this, "onCancel");
		buttonPanel.updateButtons(true);
	}
	
	public function updateButtons(bInstant: Boolean)
	{
		buttonPanel.updateButtons(bInstant);
	}
	
	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		if(a_platform == 0) {
			_acceptButton = Input.Accept;
			_cancelButton = {name: "Tween Menu", context: Input.CONTEXT_GAMEPLAY};
		} else {
			_acceptButton = Input.Accept;
			_cancelButton = Input.Cancel;
		}
		buttonPanel.setPlatform(a_platform, a_bPS3Switch);
	}
	
	public function setSelectedEntry(a_index: Number): Void
	{
		for(var i = 0; i < partsList.entryList.length; i++) {
			if(partsList.entryList[i].index == a_index) {
				partsList.listState.selectedEntry = partsList.entryList[i];
				partsList.listState.activeEntry = partsList.entryList[i];
				partsList.selectedIndex = i;
				break;
			}
		}
	}
	
	public function setPart(a_entry:Object): Void
	{
		titleField.SetText(a_entry.text.toUpperCase());
		bSuppressSelect = true;
		partsList.listState.initial = a_entry.position;
		partsList.onInvalidate = function() {
			_parent.setSelectedEntry(this.listState.initial);
			this.baseInvalidate();
			_parent.focusParts(true);
			_parent.bSuppressSelect = false;
			this.onInvalidate = this.baseInvalidate;
		}
	}
	
	public function onTagItemPress(event: Object): Void
	{
		var entryObject: Object = tagsList.entryList[event.index];
		if(entryObject) {
			entryObject.checked = !entryObject.checked;
			tagsList.requestUpdate();
		}
		var tags = new Array();
		for(var i = 0; i < tagsList.entryList.length; ++i) {
			if(tagsList.entryList[i].checked) {
				tags.push(tagsList.entryList[i].name);
			}
		}
		bSuppressFocus = true;
		_tagsFilter.filterTags = tags;
	}
	
	public function onItemPress(event: Object): Void
	{
		var entryObject: Object = partsList.entryList[event.index];
		if(entryObject) {
			dispatchEvent({type: "changePart", entry: this["entry"], selection: entryObject.index, apply: true});
		}
	}
	
	public function onAccept(): Void
	{
		var selectedEntry = partsList.listState.selectedEntry;
		if(selectedEntry) {
			dispatchEvent({type: "changePart", entry: this["entry"], selection: partsList.listState.selectedEntry.index, apply: true});
		}
	}

	public function onCancel(): Void
	{
		dispatchEvent({type: "changePart", entry: this["entry"], selection: this["entry"].position, apply: true});
	}
	
	public function onSelectionChanged(event: Object): Void
	{
		partsList.listState.selectedEntry = partsList.entryList[event.index];
		
		if(bSuppressSelect)
			return;
		
		if(partsList.listState.selectedEntry && this["entry"]) {
			dispatchEvent({type: "changePart", entry: this["entry"], selection: partsList.listState.selectedEntry.index, apply: false});
		}
		GameDelegate.call("PlaySound",["UIMenuFocus"]);
		
		if(bSuppressFocus)
			return;
		
		focusParts();
	}
	public function onTagSelectionChanged(event: Object): Void
	{
		tagsList.listState.selectedEntry = tagsList.entryList[event.index];
		
		if(bSuppressSelect)
			return;
		
		GameDelegate.call("PlaySound",["UIMenuFocus"]);
		
		if(bSuppressFocus)
			return;
		
		focusTags();
	}
	
	public function focusParts(a_force: Boolean): Boolean
	{
		if(a_force || FocusHandler.instance.getFocus(0) != partsList) {
			FocusHandler.instance.setFocus(partsList, 0);
			partsList.refreshSelection();
			tagsList.refreshSelection();
			sourceField.text = partsList.listState.selectedEntry.source;
			sourceField._visible = true;
			return true;
		}
		return false;
	}
	
	public function focusTags(a_force: Boolean): Boolean
	{
		if(a_force || FocusHandler.instance.getFocus(0) != tagsList) {
			FocusHandler.instance.setFocus(tagsList, 0);
			tagsList.refreshSelection();
			partsList.refreshSelection();
			sourceField.text = "";
			sourceField._visible = false;
			return true;
		}
		return false;
	}
	
	// Special case to handle if you moved the mouse over the already-selected item
	public function onPartItemRollOver(event: Object): Void
	{
		focusParts();
	}
	public function onTagItemRollOver(event: Object): Void
	{
		focusTags();
	}
}
