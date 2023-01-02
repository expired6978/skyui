import gfx.events.EventDispatcher;
import gfx.io.GameDelegate;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.FilteredEnumeration;

class SaveLoadListPanel extends MovieClip
{
	static var SCREENSHOT_DELAY: Number = 250; //750
	
	
	var List_mc: skyui.components.list.ScrollingList;
	var SaveLoadList_mc: MovieClip;
	var ScreenshotHolder: MovieClip;
	var ScreenshotRect: MovieClip;
	var characterSlidingList: TextCategorySlidingList;
	var characterList: TextCategoryList;
	private var _typeFilter: CategoryFilter;
	
	var ScreenshotLoader: MovieClipLoader;
	
	var PlayerInfoText: TextField;

	var dispatchEvent: Function;
	
	var bSaving: Boolean;
	
	var iBatchSize: Number;
	var iPlatform: Number;
	var iScreenshotTimerID: Number;

	function SaveLoadListPanel()
	{
		super();
		EventDispatcher.initialize(this);
		SaveLoadList_mc = List_mc;
		characterList = characterSlidingList.categoryList;
		_typeFilter = new CategoryFilter();
		bSaving = true;
	}

	function onLoad(): Void
	{
		_typeFilter.addEventListener("filterChange", this, "onFilterChange");
		characterList.addEventListener("selectionChange", this, "onCharacterChange");
		
		var listEnumeration = new FilteredEnumeration(SaveLoadList_mc.entryList);
		listEnumeration.addFilter(_typeFilter);
		SaveLoadList_mc.listEnumeration = listEnumeration;
		
		characterList.listEnumeration = new BasicEnumeration(characterList.entryList);
		ScreenshotLoader = new MovieClipLoader();
		ScreenshotLoader.addListener(this);
		GameDelegate.addCallBack("ConfirmOKToLoad", this, "onOKToLoadConfirm");
		GameDelegate.addCallBack("onSaveLoadBatchComplete", this, "onSaveLoadBatchComplete");
		GameDelegate.addCallBack("ScreenshotReady", this, "ShowScreenshot");
		SaveLoadList_mc.addEventListener("itemPress", this, "onSaveLoadItemPress");
		SaveLoadList_mc.addEventListener("selectionChange", this, "onSaveLoadItemHighlight");
		
		iBatchSize = 0x7FFFFFFF;
		PlayerInfoText.createTextField("LevelText", PlayerInfoText.getNextHighestDepth(), 0, 0, 200, 30);
		PlayerInfoText.LevelText.text = "$Level";
		PlayerInfoText.LevelText._visible = false;
	}
	
	function handleInput(details: gfx.ui.InputDetails, pathToFocus: Array): Boolean
	{
		if(characterList.handleInput(details, pathToFocus)) {
			return true;
		}
		
		if(SaveLoadList_mc.handleInput(details, pathToFocus)) {
			return true;
		}
		
		return false;
	}
	
	private function onFilterChange(event: Object): Void
	{
		SaveLoadList_mc.requestInvalidate();
	}
	
	private function onCharacterChange(event: Object): Void
	{
		if (characterList.selectedEntry != undefined) {			
			_typeFilter.changeFilterData(characterList.selectedEntry.flag, characterList.selectedEntry.textFilter);
			GameDelegate.call("PlaySound", ["UIMenuPrevNext"]);
		}
	}

	function get isSaving(): Boolean
	{
		return bSaving;
	}

	function set isSaving(abFlag: Boolean): Void
	{
		bSaving = abFlag;
	}

	function get selectedIndex(): Number
	{
		return SaveLoadList_mc.selectedIndex;
	}

	function get platform(): Number
	{
		return iPlatform;
	}

	function set platform(aiPlatform: Number): Void
	{
		iPlatform = aiPlatform;
	}

	function get batchSize(): Number
	{
		return iBatchSize;
	}

	function get numSaves(): Number
	{
		return SaveLoadList_mc.entryList.length;
	}

	function onSaveLoadItemPress(event: Object): Void
	{
		if (!bSaving) {
			GameDelegate.call("IsOKtoLoad", [SaveLoadList_mc.selectedIndex]);
			return;
		}
		dispatchEvent({type: "saveGameSelected", index: SaveLoadList_mc.selectedIndex});
	}

	function onOKToLoadConfirm(): Void
	{
		dispatchEvent({type: "loadGameSelected", index: SaveLoadList_mc.selectedIndex});
	}

	function onSaveLoadItemHighlight(event: Object): Void
	{
		if (iScreenshotTimerID != undefined) {
			clearInterval(iScreenshotTimerID);
			iScreenshotTimerID = undefined;
		}
		if (ScreenshotRect != undefined) {
			ScreenshotRect.removeMovieClip();
			PlayerInfoText.textField.SetText(" ");
			PlayerInfoText.DateText.SetText(" ");
			PlayerInfoText.PlayTimeText.SetText(" ");
			ScreenshotRect = undefined;
		}
		if (event.index != -1) 
			iScreenshotTimerID = setInterval(this, "PrepScreenshot", SaveLoadPanel.SCREENSHOT_DELAY);
		dispatchEvent({type: "saveHighlighted", index: SaveLoadList_mc.selectedIndex});
	}
	
	function PrepScreenshot(): Void
	{
		clearInterval(iScreenshotTimerID);
		iScreenshotTimerID = undefined;
		if (bSaving) {
			GameDelegate.call("PrepSaveGameScreenshot", [SaveLoadList_mc.selectedIndex - 1, SaveLoadList_mc.selectedEntry]);
			return;
		}
		GameDelegate.call("PrepSaveGameScreenshot", [SaveLoadList_mc.selectedIndex, SaveLoadList_mc.selectedEntry]);
	}

	function ShowScreenshot(): Void
	{
		ScreenshotRect = ScreenshotHolder.createEmptyMovieClip("ScreenshotRect", 0);
		ScreenshotLoader.loadClip("img://BGSSaveLoadHeader_Screenshot", ScreenshotRect);
		
		if (SaveLoadList_mc.selectedEntry.corrupt == true) {
			PlayerInfoText.textField.SetText("$SAVE CORRUPT");
		} else if (SaveLoadList_mc.selectedEntry.obsolete == true) {
			PlayerInfoText.textField.SetText("$SAVE OBSOLETE");
		} else if (SaveLoadList_mc.selectedEntry.name == undefined) {
			PlayerInfoText.textField.SetText(" ");
		} else {
			var strSaveName: String = SaveLoadList_mc.selectedEntry.name;
			var iSaveNameMaxLength: Number = 20;
			if (strSaveName.length > iSaveNameMaxLength) 
				strSaveName = strSaveName.substr(0, iSaveNameMaxLength - 3) + "...";
			if (SaveLoadList_mc.selectedEntry.raceName != undefined && SaveLoadList_mc.selectedEntry.raceName.length > 0) 
				strSaveName = strSaveName + (", " + SaveLoadList_mc.selectedEntry.raceName);
			if (SaveLoadList_mc.selectedEntry.level != undefined && SaveLoadList_mc.selectedEntry.level > 0) 
				strSaveName = strSaveName + (", " + PlayerInfoText.LevelText.text + " " + SaveLoadList_mc.selectedEntry.level);
			PlayerInfoText.textField.textAutoSize = "shrink";
			PlayerInfoText.textField.SetText(strSaveName);
		}
		
		if (SaveLoadList_mc.selectedEntry.playTime == undefined) 
			PlayerInfoText.PlayTimeText.SetText(" ");
		else 
			PlayerInfoText.PlayTimeText.SetText(SaveLoadList_mc.selectedEntry.playTime);
			
		if (SaveLoadList_mc.selectedEntry.dateString != undefined) {
			PlayerInfoText.DateText.SetText(SaveLoadList_mc.selectedEntry.dateString);
			return;
		}
		PlayerInfoText.DateText.SetText(" ");
	}

	function onLoadInit(aTargetClip: MovieClip): Void
	{
		aTargetClip._width = ScreenshotHolder.sizer._width;
		aTargetClip._height = ScreenshotHolder.sizer._height;
	}
	
	function stringToDate(strToCheck):Date {
		var year:String;
		var month:String;
		var day:String;
		var newDate:Date;
		
		month = strToCheck;
		month = month.substr(0, month.indexOf("/"));

		var DDYYYYTIME: String = strToCheck.substr(month.length + 1, strToCheck.length);

		day = DDYYYYTIME;
		day = day.substr(0, day.indexOf("/"));

		var YYYYTIME: String = DDYYYYTIME.substr(day.length + 1, DDYYYYTIME.length);

		year = YYYYTIME;
		year = year.substr(0, year.indexOf(","));

		var time: String = YYYYTIME.substr(year.length + 2, YYYYTIME.length);
		var hour: String = time.substr(0, time.indexOf(":"));
		var minute: String = time.substr(time.indexOf(":")+1, time.length-5);
		var AMPM: String = time.substr(time.length-2, time.length);
		
		var hourNumber = Number(hour);
		if(AMPM == "PM") {
			hourNumber += 12;
		}
		newDate = new Date(Number(year),Number(month)-1,Number(day), hourNumber, Number(minute));
	 
		return(newDate);
	}

	function onSaveLoadBatchComplete(abDoInitialUpdate: Boolean): Void
	{
		var iSaveNameMaxLength: Number = 80;
		
		var characterMap: Object = new Object();
		for (var i: Number = 0; i < SaveLoadList_mc.entryList.length; i++) {
			var listEntry = SaveLoadList_mc.entryList[i];
			if (listEntry.text.length > iSaveNameMaxLength) 
				listEntry.text = listEntry.text.substr(0, iSaveNameMaxLength - 3) + "...";
			
			// Request all entry data
			GameDelegate.call("PrepSaveGameScreenshot", [i, listEntry]);
			
			listEntry.filterFlag = 0;
			listEntry.levelText = PlayerInfoText.LevelText.text + " " + listEntry.level;
			listEntry.textFilters = [listEntry.name];
			if(!characterMap[listEntry.name]) {
				characterMap[listEntry.name] = stringToDate(listEntry.dateString).valueOf();
			}
		}
		
		// Sort the character list by last played
		var sortedList: Array = new Array();
		for (var t: String in characterMap) {
			sortedList.push({name: t, date: characterMap[t]});
		}
		
		sortedList.sortOn("date", Array.DESCENDING | Array.NUMERIC);
		
		
		// Build character list
		characterList.entryList.splice(0, characterList.entryList.length);
		characterList.entryList.push({text: "$All", flag: 0, filterFlag: 1, textFilter: "all", bDontHide: true, enabled: true});
		for (var i = 0; i < sortedList.length; i++) {
			characterList.entryList.push({text: sortedList[i].name, flag: 0, filterFlag: 1, textFilter: sortedList[i].name, bDontHide: true, enabled: true});
		}
				
		if (abDoInitialUpdate) {
			var strNewSave: String = "$[NEW SAVE]";
			if (bSaving && SaveLoadList_mc.entryList[0].text != strNewSave) {
				var newSaveObj: Object = {name: " ", playTime: " ", text: strNewSave};
				SaveLoadList_mc.entryList.unshift(newSaveObj);
			} else if (!bSaving && SaveLoadList_mc.entryList[0].text == strNewSave) {
				SaveLoadList_mc.entryList.shift();
			}
		}
		SaveLoadList_mc.InvalidateData();

		if (abDoInitialUpdate) {
			if (iPlatform != 0) {
				if (SaveLoadList_mc.selectedIndex == 0) 
					onSaveLoadItemHighlight({index: 0});
				else
					SaveLoadList_mc.selectedIndex = 0;
			}
			dispatchEvent({type: "saveListPopulated"});
		}
		
		characterList.InvalidateData();
		characterList.selectedIndex = 0;
		SaveLoadList_mc.selectedIndex = 0;
	}

	function DeleteSelectedSave(): Void
	{
		if (!bSaving || SaveLoadList_mc.selectedIndex != 0) {
			if (bSaving) 
				GameDelegate.call("DeleteSave", [SaveLoadList_mc.selectedIndex - 1]);
			else 
				GameDelegate.call("DeleteSave", [SaveLoadList_mc.selectedIndex]);
			SaveLoadList_mc.entryList.splice(SaveLoadList_mc.selectedIndex, 1);
			SaveLoadList_mc.InvalidateData();
			onSaveLoadItemHighlight({index: SaveLoadList_mc.selectedIndex});
		}
	}

}
