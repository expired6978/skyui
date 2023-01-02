import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.io.GameDelegate;
import Shared.GlobalFunc;
import flash.utils.Timer;

import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;
import com.greensock.OverwriteManager;
import com.greensock.easing.Linear;

import skyui.components.SearchWidget;
import skyui.components.list.FilteredEnumeration;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.components.ButtonPanel;

import CategoryFilter;
import skyui.filter.NameFilter;
import skyui.filter.SortFilter;
import skyui.util.GlobalFunctions;
import skyui.util.Debug;
import skyui.defines.Input;

import RaceMenuDefines;
import TextEntryField;
import ColorField;
import MakeupPanel;

class RaceMenu extends MovieClip
{
	#include "version.as"
	
	/* PRIVATE VARIABLES */
	private var _platform: Number;
	private var _bPS3Switch: Boolean;
	private var _typeFilter: CategoryFilter;
	private var _nameFilter: NameFilter;
	private var _sortFilter: SortFilter;
	private var _categorySortFilter: SortFilter;
	private var _itemSortFilter: SortFilter;
	private var _panelX: Number;
	private var _updateInterval: Number;
	private var _pendingData: Object = null;
	private var _raceList: Array;
	private var _reloadInterval: Number;
	private var _savedColor: Number;
	private var _artPrimary: Array;
	private var _artSecondary: Array;
	private var _pauseInputHandling: Boolean = false;
	
	public var makeupList: Array;
	
	private var ITEMLIST_HEIGHT_FULL = 528;
	private var ITEMLIST_HEIGHT_SHARED = 335;
	private var ITEMLIST_HIDDEN_X = -478;
	
	private var DESCRIPTION_WIDTH_FULL = 405;
	private var DESCRIPTION_WIDTH_SHARED = 262;
	
	private var BOTTOMBAR_SHOWN_Y = 645;
	private var BOTTOMBAR_HIDDEN_Y = 745;
	
	/* CONTROLS */
	private var _activateControl: Object;
	private var _acceptControl: Object;
	private var _zoomControl: Object;
	private var _lightControl: Object;
	private var _textureControl: Object;
	private var _searchControl: Object;
	
	/* PUBLIC VARIABLES */
	public var bLimitedMenu: Boolean;
	public var bPlayerZoom: Boolean = true;
	public var bShowLight: Boolean = true;
	public var bTextEntryMode: Boolean = false;
	public var bMenuInitialized: Boolean = false;
	public var bRaceChanging: Boolean = false;
	public var bCustomMenu: Boolean = true;
	
	public var customSliders: Array;
	
	/* STAGE ELEMENTS */
	public var racePanel: MovieClip;
	public var itemList: RaceMenuList;
	public var categoryList: TextCategoryList;
	public var categoryButtons: TextCategoryButtons;
	public var searchWidget: SearchWidget;
	public var vertexEditor: VertexEditor;
	public var cameraEditor: CameraEditor;
	public var presetEditor: PresetEditor;
	
	public var bottomBar: BottomBar;
	public var navPanel: ButtonPanel;
	
	public var raceDescription: MovieClip;
	public var textEntry: TextEntryField;
	public var loadingIcon: MovieClip;
	public var colorField: ColorField;
	public var textDisplay: TextField;
	
	public var bonusPanel: MovieClip;
	public var bonusList: ScrollingList;
	
	public var makeupPanel: MakeupPanel;
	public var itemDescriptor: MovieClip;
	public var statusText: String = "";
	
	public var modeSelect: ModeSwitcher;
	
	/* GFx Dispatcher Functions */
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;	
			
	function RaceMenu()
	{
		super();
		
		TweenPlugin.activate([AutoAlphaPlugin]);
		PapyrusInterface.initialize(this);
		
		_global.tintCount = 0;
		_global.maxTints = RaceMenuDefines.MAX_TINTS;
		_global.eventPrefix = "RSM_";
		_global.presetSlot = 0;
		
		itemList = racePanel.itemList;
		categoryList = racePanel.slidingCategoryList.categoryList;
		categoryButtons = racePanel.categoryButtons;
		searchWidget = racePanel.searchWidget;
		navPanel = bottomBar.buttonPanel;
		bonusList = raceDescription.bonusList;
		bonusPanel = bonusList;
		
		customSliders = new Array();
				
		_raceList = new Array();
		makeupList = new Array();
		makeupList.push(new Array()); // War Paint
		makeupList.push(new Array()); // Body Paint
		makeupList.push(new Array()); // Hand Paint
		makeupList.push(new Array()); // Feet Paint
		makeupList.push(new Array()); // Face Paint
		
		textDisplay._alpha = 0;
		textDisplay._visible = textDisplay.enabled = false;
		
		loadingIcon._visible = loadingIcon.enabled = false;
		textEntry._visible = textEntry.enabled = false;
		itemDescriptor._visible = itemDescriptor.enabled = false;
		vertexEditor._visible = vertexEditor.enabled = false;
		cameraEditor._visible = cameraEditor.enabled = false;
		presetEditor._visible = presetEditor.enabled = false;
		
		GlobalFunc.MaintainTextFormat();
		GlobalFunc.SetLockFunction();
		
		EventDispatcher.initialize(this);
		
		_typeFilter = new CategoryFilter();
		_nameFilter = new NameFilter();
		_sortFilter = new SortFilter();
		_categorySortFilter = new SortFilter();
		_itemSortFilter = new SortFilter();
		
		GameDelegate.initialize();
		GameDelegate.addCallBack("SetCategoriesList", this, "SetCategoriesList");
		GameDelegate.addCallBack("ShowTextEntry", this, "ShowTextEntry");
		GameDelegate.addCallBack("SetNameText", this, "SetNameText");
		GameDelegate.addCallBack("SetRaceText", this, "SetRaceText");
		GameDelegate.addCallBack("SetRaceList", this, "SetRaceList");
		GameDelegate.addCallBack("SetOptionSliders", this, "SetSliders");
		GameDelegate.addCallBack("ShowTextEntryField", this, "ShowTextEntryField");
		GameDelegate.addCallBack("HideLoadingIcon", this, "HideLoadingIcon");
	}
				
	private function onLoad()
	{
		super.onLoad();
		
		ShowRaceBonuses(null, false);
		ShowRaceDescription(false);
		ShowColorField(false);
		ShowMakeupPanel(false);
		
		raceDescription.textField.textAutoSize = "shrink";
		
		var bonusEnumeration = new FilteredEnumeration(bonusList.entryList);
		bonusEnumeration.addFilter(_sortFilter);
		bonusList.listEnumeration = bonusEnumeration;
		
		var categoryEnumeration = new FilteredEnumeration(categoryList.entryList);
		categoryEnumeration.addFilter(_categorySortFilter);
		categoryList.listEnumeration = categoryEnumeration;
		
		var listEnumeration = new FilteredEnumeration(itemList.entryList);
		listEnumeration.addFilter(_typeFilter);
		listEnumeration.addFilter(_nameFilter);
		listEnumeration.addFilter(_itemSortFilter);
		itemList.listEnumeration = listEnumeration;

		_sortFilter.addEventListener("filterChange", this, "onBonusFilterChange");
		_typeFilter.addEventListener("filterChange", this, "onFilterChange");
		_nameFilter.addEventListener("filterChange", this, "onFilterChange");
		_itemSortFilter.addEventListener("filterChange", this, "onFilterChange");
		_categorySortFilter.addEventListener("filterChange", this, "onCategoryFilterChange");
		
		itemList.addEventListener("itemPress", this, "onItemPress");
		itemList.addEventListener("itemPressSecondary", this, "onItemPressSecondary");
		itemList.addEventListener("itemPressAux", this, "onItemPressAux");
		itemList.addEventListener("selectionChange", this, "onSelectionChange");
		categoryList.addEventListener("itemPress", this, "onCategoryPress");
		categoryList.addEventListener("selectionChange", this, "onCategoryChange");
		
		categoryButtons.addEventListener("pressLeft", categoryList, "gotoStart");
		categoryButtons.addEventListener("pressRight", categoryList, "gotoEnd");
		
		searchWidget.addEventListener("inputStart", this, "onSearchInputStart");
		searchWidget.addEventListener("inputEnd", this, "onSearchInputEnd");
		searchWidget.addEventListener("inputChange", this, "onSearchInputChange");
		
		textEntry.addEventListener("nameChange", this, "onNameChange");
		colorField.addEventListener("changeColor", this, "onChangeColor");
		colorField.addEventListener("switchMode", this, "onSwitchColorMode");
		colorField.addEventListener("saveColor", this, "onSaveColor");
		
		makeupPanel.addEventListener("changeTexture", this, "onChangeTexture");
		modeSelect.addEventListener("changeMode", this, "onChangeMode");
		modeSelect.addEventListener("tabRollOver", this, "onTabRollOver");
		
		presetEditor.addEventListener("loadedPreset", this, "onLoadPreset");
		presetEditor.addEventListener("savedPreset", this, "onSavePreset");
		
		vertexEditor.addEventListener("importedFile", this, "onImportedFile");
		
		//categoryList.iconArt = ["skyrim", "race", "body", "head", "face", "eyes", "brow", "mouth", "hair"];
		//categoryList.listState.iconSource = "racemenu/racesex_icons.swf";
		
		_sortFilter.setSortBy(["text"], [0]);
		_categorySortFilter.setSortBy(["priority", "itemIndex"], [Array.NUMERIC, Array.NUMERIC]);
		_itemSortFilter.setSortBy(["priority", "itemIndex"], [Array.NUMERIC, Array.NUMERIC]);
		
		
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: true, filterFlag: 1, text: "$ALL", flag: 2044, savedItemIndex: -1, priority: RaceMenuDefines.CATEGORY_PRIORITY_START, enabled: true});
		
		// Test Code
		/*//categoryList.iconArt = ["skyrim", "race", "body", "head", "face", "eyes", "brow", "mouth", "hair", "palette", "face", "skyrim"];
		//_artPrimary = categoryList.iconArt;
		//_artSecondary = ["face"];
		
		_raceList.push({skillBonuses: [{skill: 10, bonus: 255},
									   {skill: 11, bonus: 176},
									   {skill: 12, bonus: 45},
									   {skill: 13, bonus: 766},
									   {skill: 14, bonus: 465},
									   {skill: 15, bonus: 122},
									   {skill: 16, bonus: 11}
									   ]});
		_global.skse = new Array();
		
		var priority = -500;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "RACE", flag: RaceMenuDefines.CATEGORY_RACE, savedItemIndex: -1, priority: priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "BODY", flag: RaceMenuDefines.CATEGORY_BODY, savedItemIndex: -1, priority: priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "HEAD", flag: RaceMenuDefines.CATEGORY_HEAD, savedItemIndex: -1, priority: -priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "FACE", flag: RaceMenuDefines.CATEGORY_FACE, savedItemIndex: -1, priority: priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "EYES", flag: RaceMenuDefines.CATEGORY_EYES, savedItemIndex: -1, priority: priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "BROW", flag: RaceMenuDefines.CATEGORY_BROW, savedItemIndex: -1, priority: priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "MOUTH", flag: RaceMenuDefines.CATEGORY_MOUTH, savedItemIndex: -1, priority: priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "HAIR", flag: RaceMenuDefines.CATEGORY_HAIR, savedItemIndex: -1, priority: priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$COLORS", flag: RaceMenuDefines.CATEGORY_COLOR, savedItemIndex: -1, priority: priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$MAKEUP", flag: RaceMenuDefines.CATEGORY_WARPAINT, savedItemIndex: -1, priority: priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$BODY PAINT", flag: RaceMenuDefines.CATEGORY_BODYPAINT, priority: priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$HAND PAINT", flag: RaceMenuDefines.CATEGORY_HANDPAINT, priority: priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$FOOT PAINT", flag: RaceMenuDefines.CATEGORY_FEETPAINT, priority: priority, enabled: true}); priority += 25;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$FACE PAINT", flag: RaceMenuDefines.CATEGORY_FACEPAINT, priority: priority, enabled: true}); priority += 25;
		
		
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$DUMMY", flag: 0, textFilter: "my_category", priority: priority, enabled: true}); priority += 25;
		
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Dummy", textFilters:["my_category"], filterFlag: 0, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 7, sliderID: 45, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		
		
		SetMakeup([RaceMenuDefines.TINT_TYPE_FACEPAINT,RaceMenuDefines.TINT_TYPE_FACEPAINT,RaceMenuDefines.TINT_TYPE_FACEPAINT], [0,0,0], ["FacePaint1.dds","FacePaint2.dds","FacePaint3.dds"], [0,0,0], RaceMenuDefines.TINT_TYPE_FACEPAINT, RaceMenuDefines.CATEGORY_FACEPAINT, RaceMenuDefines.PAINT_FACE, RaceMenuDefines.ENTRY_TYPE_FACEPAINT);
		
		//categoryList.dividerIndex = 10;
		categoryList.requestInvalidate();
		categoryList.onItemPress(0, 0);
		
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "Argonian", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "This reptilian race, well-suited for the treacherous swamps of their Black Marsh homeland, has developed a natural resistance to diseases and the ability to breathe underwater. They can call upon the Histskin to regenerate health very quickly.", equipState: 0, raceID: 0, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "Breton", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "In addition to their quick and perceptive grasp of spellcraft, even the humblest of High Rock's Bretons can boast a resistance to magic. Bretons can call upon the Dragonskin power to absorb spells.", equipState: 0, raceID: 1, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "Dark Elf", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "Also known as \"Dunmer\" in their homeland of Morrowind, dark elves are noted for their stealth and magic skills. They are naturally resistant to fire and can call upon their Ancestor's Wrath to surround themselves in fire.", equipState: 0, raceID: 2, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "High Elf", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "Also known as \"Altmer\" in their homeland of Summerset Isle, the high elves are the most strongly gifted in the arcane arts of all the races. They can call upon their Highborn power to regenerate Magicka quickly.", equipState: 0, raceID: 3, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "Imperial", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "Natives of Cyrodiil, they have proved to be shrewd diplomats and traders. They are skilled with combat and magic. Anywhere gold coins might be found, Imperials always seem to find a few more. They can call upon the Voice of the Emperor to calm an enemy.", equipState: 0, raceID: 4, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "Khajiit", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "Hailing from the province of Elsweyr, they are intelligent, quick, and agile.  They make excellent thieves due to their natural stealthiness. All Khajiit can see in the dark at will and have unarmed claw attacks.", equipState: 0, raceID: 5, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "Nord", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "Citizens of Skyrim, they are a tall and fair-haired people.  Strong and hardy, Nords are famous for their resistance to cold and their talent as warriors. They can use a Battlecry to make opponents flee.", equipState: 0, raceID: 6, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "Orc", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "The people of the Wrothgarian and Dragontail Mountains, Orcish smiths are prized for their craftsmanship. Orc troops in Heavy Armor are among the finest in the Empire, and are fearsome when using their Berserker Rage.", equipState: 0, raceID: 7, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "Redguard", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "The most naturally talented warriors in Tamriel, the Redguards of Hammerfell have a hardy constitution and a natural resistance to poison. They can call upon an Adrenaline Rush in combat.", equipState: 0, raceID: 8, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "Wood Elf", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "The clanfolk of the Western Valenwood forests, also known as \"Bosmer.\" Wood elves make good scouts and thieves, and there are no finer archers in all of Tamriel. They have natural resistances to both poisons and diseases. They can Command Animals to fight for them.", equipState: 0, raceID: 9, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "TestRace1", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "TestRace1", equipState: 0, raceID: 10, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "TestRace2", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "TestRace2", equipState: 0, raceID: 11, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "TestRace3", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "TestRace3", equipState: 0, raceID: 12, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "TestRace4", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "TestRace4", equipState: 0, raceID: 13, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_RACE, text: "TestRace5", filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: "TestRace5", equipState: 0, raceID: 14, enabled: true});
		
		
		var isEnabled: Function = function(): Boolean { return true; }
		var colorIndex: Number = 0;
		var GetTextureList: Function = function(raceMenu: Object): Array { return raceMenu.makeupList[RaceMenuDefines.PAINT_WAR]; }
		var showDescriptor: Function = function(): Boolean { return true; }
		
		var extraData = {partName: "TestPart", formId: 1234};
		
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Sex", filterFlag: 4, callbackName: "ChangeSex", sliderMin: 0, sliderMax: 1, sliderID: -1, position: 0, interval: 1, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Presets", filterFlag: 4, callbackName: "ChangeHeadPreset", sliderMin: 0, sliderMax: 0, sliderID: 0, position: 0, interval: 1, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Skin Tone", filterFlag: 4 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 2892, sliderID: 1, position: 2885, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Weight", filterFlag: 4, callbackName: "ChangeWeight", sliderMin: 0, sliderMax: 1, sliderID: 2, position: 0, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Complexion", filterFlag: 8, callbackName: "ChangeFaceDetails", sliderMin: 0, sliderMax: 5, sliderID: 3, position: 0, interval: 1, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Dirt", filterFlag: 8, callbackName: "ChangeMask", sliderMin: -1, sliderMax: 2, sliderID: 4, position: -1, interval: 1, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Dirt Color", filterFlag: 8 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeMaskColor", sliderMin: 1, sliderMax: 4, sliderID: 5, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Scars", filterFlag: 8, callbackName: "ChangeHeadPart", sliderMin: 0, sliderMax: 12, sliderID: 6, position: 7, interval: 1, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "War Paint", filterFlag: 8, callbackName: "ChangeMask", sliderMin: -1, sliderMax: 14, sliderID: 7, position: -1, interval: 1, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "War Paint Color", filterFlag: 8 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeMaskColor", sliderMin: 1, sliderMax: 23, sliderID: 8, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Hair", filterFlag: 256, callbackName: "ChangeHeadPart", sliderMin: 0, sliderMax: 69, sliderID: 9, position: 10, interval: 1, enabled: true, extraData: extraData});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Facial Hair", filterFlag: 256, callbackName: "ChangeHeadPart", sliderMin: 0, sliderMax: 45, sliderID: 10, position: 41, interval: 1, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Hair Color", filterFlag: 256 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeHairColorPreset", sliderMin: 0, sliderMax: 6594, sliderID: 11, position: 6578, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Eye Shape", filterFlag: 32, callbackName: "ChangePreset", sliderMin: 0, sliderMax: 37, sliderID: 12, position: 1, interval: 1, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Eye Color", filterFlag: 32, callbackName: "ChangeHeadPart", sliderMin: 0, sliderMax: 1, sliderID: 13, position: 0, interval: 1, enabled: true, showDescriptor: showDescriptor});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Eye Height", filterFlag: 32, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 14, position: 0.5, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Eye Width", filterFlag: 32, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 15, position: -0.059999998658895, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Eye Depth", filterFlag: 32, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 16, position: -0.63999998569489, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Eyeliner Color", filterFlag: 32 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 3, sliderID: 17, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Eye Shadow", filterFlag: 32 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 7, sliderID: 18, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Eye Tint", filterFlag: 32 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 7, sliderID: 19, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Brow Type", filterFlag: 64, callbackName: "ChangeHeadPart", sliderMin: 0, sliderMax: 11, sliderID: 20, position: 0, interval: 1, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Brow Height", filterFlag: 64, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 21, position: -1, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Brow Width", filterFlag: 64, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 22, position: -0.10000000149012, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Brow Forward", filterFlag: 64, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 23, position: -0.10000000149012, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Nose Type", filterFlag: 16, callbackName: "ChangePreset", sliderMin: 0, sliderMax: 30, sliderID: 24, position: 4, interval: 1, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Nose Height", filterFlag: 16, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 25, position: 0.10000000149012, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Nose Length", filterFlag: 16, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 26, position: 0.10000000149012, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Jaw Width", filterFlag: 16, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 27, position: -1, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Jaw Height", filterFlag: 16, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 28, position: 0.079999998211861, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Jaw Forward", filterFlag: 16, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 29, position: 0.03999999910593, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Cheekbone Height", filterFlag: 16, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 30, position: 0.019999999552965, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Cheekbone Width", filterFlag: 16, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 31, position: 0.5, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Cheek Color", filterFlag: 16 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 6, sliderID: 32, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Laugh Lines", filterFlag: 16 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 3, sliderID: 33, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Cheek Color Lower", filterFlag: 16 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 6, sliderID: 34, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Nose Color", filterFlag: 16 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 5, sliderID: 35, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Chin Color", filterFlag: 16 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 4, sliderID: 36, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Neck Color", filterFlag: 16 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 4, sliderID: 37, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Forehead Color", filterFlag: 16 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 3, sliderID: 38, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Mouth Shape", filterFlag: 128, callbackName: "ChangePreset", sliderMin: 0, sliderMax: 30, sliderID: 39, position: 19, interval: 1, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Mouth Height", filterFlag: 128, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 40, position: 0.66000002622604, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Mouth Forward", filterFlag: 128, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 41, position: 0.15999999642372, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Chin Width", filterFlag: 128, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 42, position: -0.34000000357628, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Chin Length", filterFlag: 128, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 43, position: -0.40000000596046, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Chin Forward", filterFlag: 128, callbackName: "ChangeDoubleMorph", sliderMin: -1, sliderMax: 1, sliderID: 44, position: 0.18000000715256, interval: 0.10000000149012, enabled: true});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: "Lip Color", filterFlag: 128 + RaceMenuDefines.CATEGORY_COLOR, callbackName: "ChangeTintingMask", sliderMin: 0, sliderMax: 7, sliderID: 45, position: 0, interval: 1, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_WARPAINT, text: "Warpaint1", texture: "actors\\character\\Character assets\\tintmasks\\femalenordeyelinerstyle_01.dds", filterFlag: RaceMenuDefines.CATEGORY_WARPAINT, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, GetTextureList: GetTextureList, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		itemList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_WARPAINT, text: "Warpaint2", texture: "actors/character/Character assets/tintmasks/femalenordeyelinerstyle_01.dds", filterFlag: RaceMenuDefines.CATEGORY_WARPAINT, enabled: true, isColorEnabled: isEnabled, hasColor: isEnabled, GetTextureList: GetTextureList, tintType: RaceMenuDefines.TINT_MAP[colorIndex++]});
		*/
		// Test Code End
		
		categoryList.InvalidateData();
		categoryList.onItemPress(0, 0);
		itemList.requestInvalidate();
		
		FocusHandler.instance.setFocus(itemList, 0);
		
		//trace(Date().toString());
		
		// Test Code
		/*InitExtensions();
		SetPlatform(1, false);*/
		/*vertexEditor.loadAssets();
		vertexEditor.ShowUV(true);
		vertexEditor.ShowWireframe(true);*/
	}
		
	public function InitExtensions()
	{
		_global.gfxExtensions = true;
		Stage.scaleMode = "showAll";		
		racePanel.Lock("L");
		raceDescription.Lock("L");
		modeSelect.Lock("TR");
		bottomBar.playerInfo.Lock("R");
		bottomBar.positionBackground();
		
		vertexEditor.InitExtensions();
		modeSelect.InitExtensions();
		cameraEditor.InitExtensions();
		presetEditor.InitExtensions();
		
		_panelX = racePanel._x;
		
		colorField._x = racePanel._x + racePanel._width / 2;
		makeupPanel._x = racePanel._x + racePanel._width / 2;
	}
	
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		_bPS3Switch = a_bPS3Switch;
		itemList.setPlatform(a_platform, a_bPS3Switch);
		textEntry.setPlatform(a_platform, a_bPS3Switch);
		bottomBar.setPlatform(a_platform, a_bPS3Switch);
		colorField.setPlatform(a_platform, a_bPS3Switch);
		makeupPanel.setPlatform(a_platform, a_bPS3Switch);
		vertexEditor.setPlatform(a_platform, a_bPS3Switch);
		cameraEditor.setPlatform(a_platform, a_bPS3Switch);
		presetEditor.setPlatform(a_platform, a_bPS3Switch);
		
		_acceptControl = {keyCode: GlobalFunctions.getMappedKey("Ready Weapon", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		_zoomControl = {keyCode: GlobalFunctions.getMappedKey("Sprint", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		_activateControl = Input.Activate;
		
		if(_platform == 0) {
			_lightControl = {keyCode: GlobalFunctions.getMappedKey("Sneak", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
			_searchControl = {keyCode: GlobalFunctions.getMappedKey("Jump", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
			_textureControl = {keyCode: GlobalFunctions.getMappedKey("Wait", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		} else {
			_lightControl = {keyCode: GlobalFunctions.getMappedKey("Wait", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
			_textureControl = {keyCode: GlobalFunctions.getMappedKey("Jump", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
			_searchControl = null;
		}
		
		textEntry.TextInputInstance.maxChars = 26;
		textEntry.SetupButtons();
		colorField.SetupButtons();
		makeupPanel.SetupButtons();
		
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		bottomBar.positionElements(leftEdge, rightEdge);	
		updateBottomBar();
	}
	
	public function IsBoundKeyPressed(details: InputDetails, boundKey: Object, platform: Number): Boolean
	{
		return ((details.control && details.control == boundKey.name) || (details.skseKeycode && boundKey.name && boundKey.context && details.skseKeycode == GlobalFunctions.getMappedKey(boundKey.name, Number(boundKey.context), platform != 0)) || (details.skseKeycode && details.skseKeycode == boundKey.keyCode));
	}
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{		
		// Consume input when these windows are open
		if(colorField.enabled) {
			return colorField.handleInput(details, pathToFocus);
		} else if(textEntry.enabled) {
			return textEntry.handleInput(details, pathToFocus);
		} else if(makeupPanel.enabled) {
			return makeupPanel.handleInput(details, pathToFocus);
		} else if(vertexEditor.enabled) {
			if(vertexEditor.handleInput(details, pathToFocus))
				return true;
			else
				return modeSelect.handleInput(details, pathToFocus);
		} else if(cameraEditor.enabled) {
			if(cameraEditor.handleInput(details, pathToFocus))
				return true;
			else
				return modeSelect.handleInput(details, pathToFocus);
		} else if(presetEditor.enabled) {
			if(presetEditor.handleInput(details, pathToFocus))
				return true;
			else
				return modeSelect.handleInput(details, pathToFocus);
		}
		
		if (GlobalFunc.IsKeyPressed(details)) {
			if (IsBoundKeyPressed(details, _searchControl, _platform) && _platform == 0) {
				onSearchClicked();
				return true;
			} else if (IsBoundKeyPressed(details, _zoomControl, _platform) && !bTextEntryMode) {
				onZoomClicked();
				return true;
			} else if(IsBoundKeyPressed(details, _lightControl, _platform) && !bTextEntryMode) {
				onLightClicked();
				return true;
			}
		}
		
		if(itemList.handleInput(details, pathToFocus)) {
			return true;
		}
		
		if(categoryList.handleInput(details, pathToFocus)) {
			return true;
		}
		
		if(modeSelect.handleInput(details, pathToFocus)) {
			return true;
		}
		
		/*var nextClip = pathToFocus.shift();
		if (nextClip.handleInput(details, pathToFocus)) {
			return true;
		}*/
		
		return false;
	}
	
	/* Component Toggles */
	public function ShowTextEntry(abShowTextEntry: Boolean): Void
	{
		itemList.invalidateSelection();
		textEntry._visible = textEntry.enabled = abShowTextEntry;
		if(abShowTextEntry) {
			if(colorField._visible)
				ShowColorField(false);
			else if(makeupPanel._visible)
				ShowMakeupPanel(false);
			
			modeSelect.setMode(0);
			vertexEditor.unloadAssets();
			DialogTweenManager.close();
			
			textEntry.updateButtons(true);
			FocusHandler.instance.setFocus(textEntry, 0);
		} else {
			FocusHandler.instance.setFocus(itemList, 0);
		}
		
		ShowRacePanel(!abShowTextEntry);
		ShowBottomBar(!abShowTextEntry);
		ShowModeSwitcher(!abShowTextEntry);
	}
	
	// No idea why they have two of these
	public function ShowTextEntryField(): Void
	{
		if (textEntry.enabled) {
			textEntry.TextInputInstance.text = bottomBar.playerInfo.PlayerName.text;
			textEntry.TextInputInstance.focused = true;
			GameDelegate.call("SetAllowTextInput", []);
			return;
		}
		GameDelegate.call("ShowVirtualKeyboard", []);
		GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
	}
	
	public function ShowColorField(bShowField: Boolean, initParams: Object): Void
	{
		colorField._visible = colorField.enabled = bShowField;
		colorField.ResetSlider();
		if(bShowField) {
			colorField.initParams = initParams;
			colorField.updateButtons(true);
			FocusHandler.instance.setFocus(colorField.colorSelector, 0);
		} else {
			FocusHandler.instance.setFocus(itemList, 0);
		}
		ShowRacePanel(!bShowField);
		ShowBottomBar(!bShowField);
		ShowModeSwitcher(!bShowField);
	}
	
	public function ShowRaceDescription(bShowDescription: Boolean): Void
	{
		var toggled: Boolean = (raceDescription._visible != bShowDescription);
		raceDescription._visible = raceDescription.enabled = bShowDescription;
		if(bShowDescription) {
			itemList.listHeight = ITEMLIST_HEIGHT_SHARED;
		} else {
			itemList.listHeight = ITEMLIST_HEIGHT_FULL;
		}
		
		if(toggled) {
			itemList.requestInvalidate();
		}
	}
	
	public function ShowRaceBonuses(a_race: Object, bShowBonuses: Boolean): Void
	{
		bonusPanel._visible = bonusPanel.enabled = (bShowBonuses && _global.skse);
		if(bShowBonuses) {
			bonusList.entryList.splice(0, bonusList.entryList.length);
			for(var i = 0; i < a_race.skillBonuses.length; i++) {
				var skillId: Number = a_race.skillBonuses[i].skill;
				var skillBonus: Number = a_race.skillBonuses[i].bonus;
				
				if(skillId == RaceMenuDefines.ACTORVALUE_NONE || skillBonus == 0)
					continue;
					
				bonusList.entryList.push({text: GetActorValueText(skillId), value: skillBonus});
			}
			
			if(bonusList.entryList.length == 0 || a_race == undefined) {
				bonusPanel._visible = bonusPanel.enabled = false;
			}
			
			bonusList.requestInvalidate();
		}
		if(bonusPanel._visible) {
			raceDescription.textField._width = DESCRIPTION_WIDTH_SHARED;
		} else {
			raceDescription.textField._width = DESCRIPTION_WIDTH_FULL;
		}
	}
	
	public function ShowMakeupPanel(bShowPanel: Boolean, initParams: Object): Void
	{
		makeupPanel._visible = makeupPanel.enabled = bShowPanel;
		if(bShowPanel) {
			makeupPanel.initParams = initParams;
			FocusHandler.instance.setFocus(makeupPanel.makeupList, 0);
		} else {
			FocusHandler.instance.setFocus(itemList, 0);
		}
		
		ShowRacePanel(!bShowPanel);
		ShowBottomBar(!bShowPanel);
		ShowModeSwitcher(!bShowPanel);
	}
	
	public function ShowRacePanel(bShowPanel: Boolean): Void
	{
		if(bShowPanel) {
			categoryList.disableSelection = categoryList.disableInput = false;
			itemList.disableSelection = itemList.disableInput = false;
			searchWidget.isDisabled = false;
			TweenLite.to(racePanel, 0.5, {autoAlpha: 100, _x: _panelX, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
			//TweenLite.to(itemDescriptor, 0.5, {_alpha: 100, _x: (_panelX + racePanel._width), overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
			TweenLite.to(raceDescription, 0.5, {_alpha: 100, _x: _panelX, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			categoryList.disableSelection = categoryList.disableInput = true;
			itemList.disableSelection = itemList.disableInput = true;
			searchWidget.isDisabled = true;
			TweenLite.to(racePanel, 0.5, {autoAlpha: 0, _x: ITEMLIST_HIDDEN_X, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
			//TweenLite.to(itemDescriptor, 0.5, {_alpha: 0, _x: (ITEMLIST_HIDDEN_X + racePanel._width), overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
			TweenLite.to(raceDescription, 0.5, {_alpha: 0, _x: ITEMLIST_HIDDEN_X, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
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
	
	public function ShowModeSwitcher(bShowSwitcher: Boolean): Void
	{
		if(bShowSwitcher) {
			TweenLite.to(modeSelect, 0.5, {autoAlpha: 100, _y: 0, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			TweenLite.to(modeSelect, 0.5, {autoAlpha: 0, _y: -80, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
	}
	
	public function onNameChange(event: Object): Void
	{
		if (event.nameChanged == true) {
			ShowTextEntry(false);
			ShowRacePanel(false);
			ShowBottomBar(false);
			ShowModeSwitcher(false);
			GameDelegate.call("ChangeName", [textEntry.TextInputInstance.text]);
		} else {
			ShowTextEntry(false);
			GameDelegate.call("ChangeName", []);
		}
		
		GameDelegate.call("PlaySound", ["UIMenuBladeCloseSD"]);
	}
	
	public function HideLoadingIcon(): Void
	{
		loadingIcon._visible = false;
		if(bRaceChanging) {
			skse.SendModEvent(_global.eventPrefix + "RaceChanged");
			bRaceChanging = false;
		}
	}
	
	public function SetNameText(astrPlayerName: String): Void
	{
		bottomBar.playerInfo.PlayerName.SetText(astrPlayerName);
	}

	public function SetRaceText(astrPlayerRace: String): Void
	{
		bottomBar.playerInfo.PlayerRace.SetText(astrPlayerRace);
	}
	
	private function SetCategoriesList(): Void
	{
		categoryList.entryList.splice(1, categoryList.entryList.length - 1);
		
		var priority: Number = RaceMenuDefines.CATEGORY_PRIORITY_START + RaceMenuDefines.CATEGORY_PRIORITY_STEP;
		
		var categoryCount: Number = 1;
		for (var i: Number = 0; i < arguments.length; i += RaceMenuDefines.CAT_STRIDE) {
			var entryObject: Object = {type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: arguments[i + RaceMenuDefines.CAT_TEXT].toUpperCase(), flag: arguments[i + RaceMenuDefines.CAT_FLAG], priority: priority, enabled: true}; priority += RaceMenuDefines.CATEGORY_PRIORITY_STEP;
			if(bLimitedMenu && entryObject.flag & RaceMenuDefines.CATEGORY_RACE) {
				entryObject.filterFlag = 0;
			}
			categoryList.entryList.push(entryObject);
			categoryCount++;
		}
		
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$COLORS", flag: RaceMenuDefines.CATEGORY_COLOR, priority: priority, enabled: true}); priority += RaceMenuDefines.CATEGORY_PRIORITY_STEP;
		categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$MAKEUP", flag: RaceMenuDefines.CATEGORY_WARPAINT, priority: priority, enabled: true}); priority += RaceMenuDefines.CATEGORY_PRIORITY_STEP;
		
		if(_global.skse.plugins.NiOverride.bEnableOverlays) {
			var bodyOverlays: Object = _global.skse.plugins.NiOverride.body;
			var handOverlays: Object = _global.skse.plugins.NiOverride.hand;
			var feetOverlays: Object = _global.skse.plugins.NiOverride.feet;
			var faceOverlays: Object = _global.skse.plugins.NiOverride.face;
			
			if(bodyOverlays.iNumOverlays + bodyOverlays.iSpellOverlays > 0) {
				categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$BODY PAINT", flag: RaceMenuDefines.CATEGORY_BODYPAINT, priority: priority, enabled: true});
			}
			priority += RaceMenuDefines.CATEGORY_PRIORITY_STEP;
			if(handOverlays.iNumOverlays + handOverlays.iSpellOverlays > 0) {
				categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$HAND PAINT", flag: RaceMenuDefines.CATEGORY_HANDPAINT, priority: priority, enabled: true});
			}
			priority += RaceMenuDefines.CATEGORY_PRIORITY_STEP;
			if(feetOverlays.iNumOverlays + feetOverlays.iSpellOverlays > 0) {
				categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$FOOT PAINT", flag: RaceMenuDefines.CATEGORY_FEETPAINT, priority: priority, enabled: true});
			}
			priority += RaceMenuDefines.CATEGORY_PRIORITY_STEP;
			if(faceOverlays.iNumOverlays + faceOverlays.iSpellOverlays > 0) {
				categoryList.entryList.push({type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: "$FACE PAINT", flag: RaceMenuDefines.CATEGORY_FACEPAINT, priority: priority, enabled: true});
			}
			priority += RaceMenuDefines.CATEGORY_PRIORITY_STEP;
		}
		
		skse.SendModEvent(_global.eventPrefix + "CategoriesInitialized");
		
		categoryList.requestInvalidate();
	}

	private function SetRaceList(): Void
	{	
		// Remove only Race types
		if(itemList.entryList.length > 0) {
			for(var k: Number = itemList.entryList.length; k >= 0; k--) {
				if(itemList.entryList[k].type == RaceMenuDefines.ENTRY_TYPE_RACE)
					itemList.entryList.splice(k, 1);
			}
		}
		
		var id = 0;
		for (var i: Number = 0; i < arguments.length; i += RaceMenuDefines.RACE_STRIDE, id++) {
			var entryObject: Object = {type: RaceMenuDefines.ENTRY_TYPE_RACE, text: arguments[i + RaceMenuDefines.RACE_NAME], filterFlag: RaceMenuDefines.CATEGORY_RACE, raceDescription: arguments[i + RaceMenuDefines.RACE_DESCRIPTION].length <= 0 ? "No race description for " + arguments[i + RaceMenuDefines.RACE_NAME] : arguments[i + RaceMenuDefines.RACE_DESCRIPTION], equipState: arguments[i + RaceMenuDefines.RACE_EQUIPSTATE], raceID: id, enabled: true};
			entryObject.isColorEnabled = function(): Boolean { return false; }
			entryObject.hasColor = function(): Boolean { return false; }
			entryObject.hasGlow = function(): Boolean { return false; }
			if (entryObject.equipState > 0) {
				itemList.listState.activeEntry = entryObject;
				SetRaceText(entryObject.text);
			}

			itemList.entryList.push(entryObject);
		}
		
		itemList.requestInvalidate();
	}

	private function SetSliders(): Void
	{
		// Remove only Slider types
		if(itemList.entryList.length > 0) {
			for(var k: Number = itemList.entryList.length; k >= 0; k--) {
				if(itemList.entryList[k].type == RaceMenuDefines.ENTRY_TYPE_SLIDER)
					itemList.entryList.splice(k, 1);
			}
		}
		customSliders.splice(0, customSliders.length);
				
		var colorIndex: Number = 0;
		for (var i: Number = 0; i < arguments.length; i += RaceMenuDefines.SLIDER_STRIDE) {
			var entryObject: Object = {type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: arguments[i + RaceMenuDefines.SLIDER_NAME], filterFlag: arguments[i + RaceMenuDefines.SLIDER_FILTERFLAG], callbackName: arguments[i + RaceMenuDefines.SLIDER_CALLBACKNAME], sliderMin: arguments[i + RaceMenuDefines.SLIDER_MIN], sliderMax: arguments[i + RaceMenuDefines.SLIDER_MAX], sliderID: arguments[i + RaceMenuDefines.SLIDER_ID], position: arguments[i + RaceMenuDefines.SLIDER_POSITION], interval: arguments[i + RaceMenuDefines.SLIDER_INTERVAL], enabled: true};
						
			// Add new category
			if(entryObject.callbackName == "ChangeTintingMask" || entryObject.callbackName == "ChangeMaskColor" || entryObject.callbackName == "ChangeHairColorPreset") {
				entryObject.filterFlag += RaceMenuDefines.CATEGORY_COLOR;
				entryObject.tintType = RaceMenuDefines.TINT_MAP[colorIndex];
				entryObject.isColorEnabled = function(): Boolean { return (_global.skse && (_global.tintCount < _global.maxTints || (this.fillColor >>> 24) != 0 || this.tintType == RaceMenuDefines.TINT_TYPE_HAIR)) || !_global.skse; }
				entryObject.hasColor = function(): Boolean { return true; }
				entryObject.hasGlow = function(): Boolean { return false; }
				colorIndex++;
			} else {
				entryObject.hasColor = function(): Boolean { return false; }
				entryObject.hasGlow = function(): Boolean { return false; }
			}
			if(entryObject.callbackName == "ChangeWeight") {
				entryObject.interval = 0.01;
			}
			
			// CharGen 2.1.3 signature
			if(_global.skse.plugins.CharGen.GetSliderData) {
				if(entryObject.sliderID != undefined && entryObject.position != undefined) {
					entryObject.extraData = _global.skse.plugins.CharGen.GetSliderData(entryObject.sliderID, entryObject.position);
					switch(entryObject.extraData.type) {
						case 5: // ChangeHairColorPreset
							entryObject.tintType = RaceMenuDefines.TINT_TYPE_HAIR;
							break;
						case 4: // ChangeTintingMask
						case 9: // ChangeMaskColor
							entryObject.tintType = entryObject.extraData.index;
							break;
					}
				} else {
					entryObject.extraData = null;
				}
				entryObject.internalCallback = function()
				{
					if(this.sliderID != undefined && this.position != undefined) {
						this.entryObject.extraData = _global.skse.plugins.CharGen.GetSliderData(this.sliderID, this.position);
					} else {
						this.entryObject.extraData = null;
					}
					_root.RaceSexMenuBaseInstance.RaceSexPanelsInstance.updateItemDescriptor();
				}
			}
			
			entryObject.GetTextureList = function(raceMenu: Object): Array { return null; }		
			
			itemList.entryList.push(entryObject);
		}
				
		if(!_updateInterval) {
			_updateInterval = setInterval(this, "InitializeSliders", 500);
		}
	}
	
	public function InitializeSliders()
	{
		if(!bMenuInitialized) {
			skse.SendModEvent(_global.eventPrefix + "Initialized");
			bMenuInitialized = true;
		} else {
			skse.SendModEvent(_global.eventPrefix + "Reinitialized");
		}
		
		//EnhancedCharacterEdit.init(this);
		
		itemList.requestInvalidate();
		clearInterval(_updateInterval);
		delete _updateInterval;
	}
	
	public function SetMakeup(a_types: Array, a_colors: Array, a_textures: Array, a_glows: Array, a_tintType: Number, a_categoryFilter: Number, a_makeupType: Number, a_entryType: Number): Void
	{
		// Remove only Makeup types
		if(itemList.entryList.length > 0) {
			for(var k: Number = itemList.entryList.length; k >= 0; k--) {
				if(itemList.entryList[k].type == a_entryType)
					itemList.entryList.splice(k, 1);
			}
		}
		
		var tintIndex: Number = 0;
		for(var i = 0; i < a_types.length; i++) {
			var nTintType: Number = a_types[i];
			var nTintTexture: String = a_textures[i];
			var nTintIndex: Number = tintIndex;
			var nTintColor: Number = a_colors[i];
			if(nTintType == a_tintType) {
				++tintIndex;
			} else {
				tintIndex = 0;
				continue;
			}
			var nGlowColor: Number = 0xFF000000;
			if(a_glows) {
				nGlowColor = a_glows[i];
			}
			
			nTintTexture = nTintTexture.split("|")[0];
			
			// Strip Path and extension
			var slashIndex: Number = -1;
			for(var k = nTintTexture.length - 1; k > 0; k--) {
				if(nTintTexture.charAt(k) == "\\" || nTintTexture.charAt(k) == "/") {
					slashIndex = k;
					break;
				}
			}
			var formatIndex: Number = nTintTexture.indexOf(".dds");
			if(formatIndex == -1)
				formatIndex = nTintTexture.length;
			
			var displayText: String = nTintTexture.substring(slashIndex + 1, formatIndex);
			
			var entryObject: Object = {type: a_entryType, listType: a_makeupType, text: displayText, texture: nTintTexture, tintType: nTintType, tintIndex: nTintIndex, fillColor: nTintColor, glowColor: nGlowColor, filterFlag: a_categoryFilter, enabled: true};
			
			if(a_entryType == RaceMenuDefines.ENTRY_TYPE_WARPAINT) {
				entryObject.isColorEnabled = function(tintColors: Number): Boolean { return (_global.skse && (_global.tintCount < _global.maxTints || (this.fillColor >>> 24) != 0)); }
			} else {
				entryObject.isColorEnabled = function(tintColors: Number): Boolean { return true; }
			}
			
			entryObject.GetTextureList = function(raceMenu: Object): Array { return raceMenu.makeupList[this.listType]; }
			entryObject.hasColor = function(): Boolean { return true; }
			entryObject.hasGlow = function(): Boolean { return (this.tintType == RaceMenuDefines.TINT_TYPE_BODYPAINT || this.tintType == RaceMenuDefines.TINT_TYPE_HANDPAINT || this.tintType == RaceMenuDefines.TINT_TYPE_FEETPAINT || this.tintType == RaceMenuDefines.TINT_TYPE_FACEPAINT); }
			
			itemList.entryList.push(entryObject);
		}
		
		itemList.requestInvalidate();
	}
	
	public function onBonusFilterChange(): Void
	{
		bonusList.requestInvalidate();
	}
	
	public function onFilterChange(): Void
	{
		itemList.requestInvalidate();
	}
	
	public function onCategoryFilterChange(): Void
	{
		categoryList.requestInvalidate();
	}
	
	private function onSearchInputStart(event: Object): Void
	{
		bTextEntryMode = true;
		categoryList.disableSelection = categoryList.disableInput = true;
		itemList.disableSelection = itemList.disableInput = true;
		_nameFilter.filterText = "";
	}

	private function onSearchInputChange(event: Object)
	{
		_nameFilter.filterText = event.data;
	}

	private function onSearchInputEnd(event: Object)
	{
		categoryList.disableSelection = categoryList.disableInput = false;
		itemList.disableSelection = itemList.disableInput = false;
		_nameFilter.filterText = event.data;
		bTextEntryMode = false;
	}
	
	public function onCategoryPress(a_event: Object): Void
	{
		if (categoryList.selectedEntry != undefined) {
			_typeFilter.changeFilterData(categoryList.selectedEntry.flag, categoryList.selectedEntry.textFilter);
		}
	}
	
	public function onCategoryChange(a_event: Object): Void
	{
		itemList.listState.focusEntry = null;
		itemList.selectedIndex = -1;
		//GameDelegate.call("PlaySound",["UIMenuFocus"]);
		GameDelegate.call("PlaySound", ["UIMenuPrevNext"]);
	}
		
	public function onChangeTexture(event: Object): Void
	{
		if(event.texture != undefined)
		{
			var selectedEntry = itemList.listState.selectedEntry;
			if(isMakeup(selectedEntry.tintType)) {
				if(event.apply) {
					selectedEntry.text = event.displayText;
					selectedEntry.texture = event.texture;
				}
				requestUpdate({type: "makeupTexture", tintType: selectedEntry.tintType, tintIndex: selectedEntry.tintIndex, replacementTexture: event.texture});
			}
			
			if(event.apply)
				itemList.requestUpdate();
		}
		
		if(event.apply) {
			ShowMakeupPanel(false);
			GameDelegate.call("PlaySound", ["UIMenuBladeCloseSD"]);
		}
	}

	public function onChangeMode(event: Object): Void
	{
		switch(event.index) {
			case 0:
			ShowRacePanel(true);
			ShowBottomBar(true);
			vertexEditor.ShowAll(false, false, true);
			cameraEditor.ShowAll(false);
			presetEditor.ShowAll(false);
			break;
			case 1:
			ShowRacePanel(false);
			ShowBottomBar(false);
			vertexEditor.ShowAll(false, false, false);
			cameraEditor.ShowAll(false);
			presetEditor.ShowAll(true);
			break;
			case 2:
			ShowRacePanel(false);
			ShowBottomBar(false);
			cameraEditor.ShowAll(true);
			vertexEditor.ShowAll(false, false, false);
			presetEditor.ShowAll(false);
			break;
			case 3:
			ShowRacePanel(true);
			ShowRacePanel(false);
			ShowBottomBar(false);
			vertexEditor.ShowAll(true, true, false);
			cameraEditor.ShowAll(false);
			presetEditor.ShowAll(false);
			break;
		}
	}
	
	public function onTabRollOver(event: Object): Void
	{
		switch(event.index) {
			case 0:
			{
				if(vertexEditor.hasAssets())
					setStatusText("$Sculpt history will be lost", 3.0);
			}
			break;
			case 1:
			{
				if(vertexEditor.hasAssets())
					setStatusText("$Loading a preset will erase sculpt history", 3.0);
			}
			break;
			case 2:
			case 3:
			{
				if(vertexEditor.hasAssets())
					setStatusText("__CLEAR__", 3.0);
			}
			break;
		}
	}
	
	public function onImportedFile(event: Object): Void
	{
		if(event.success) {
			setStatusText("$Imported data from {" + event.name + "}", 3.0);
		} else {
			setStatusText("$Failed to import data from {" + event.name + "}", 3.0);
		}
	}
	
	public function onLoadPreset(event: Object): Void
	{
		if(event.success) {
			vertexEditor.unloadAssets();
			skse.SendModEvent(_global.eventPrefix + "RequestTintSave");
			requestSliderUpdate(event);
		} else {
			setStatusText("$Failed to load preset from {" + event.name + "}", 3.0);
		}
	}
	
	public function onSavePreset(event: Object): Void
	{
		if(event.success) {
			setStatusText("$Saved preset to {" + event.name + "}", 3.0);
		} else {
			setStatusText("$Failed to save preset to {" + event.name + "}", 3.0);
		}
	}
	
	public function onChangeColor(event: Object): Void
	{
		if(event.color != undefined)
		{
			var selectedEntry = event.entry;
			switch(event.mode)
			{
				case "tint":
				{
					if(selectedEntry.filterFlag & RaceMenuDefines.CATEGORY_COLOR) {
						if(event.apply) {
							// Update Tint Count
							if(selectedEntry.tintType != RaceMenuDefines.TINT_TYPE_HAIR && (selectedEntry.fillColor >>> 24) == 0 && (event.color >>> 24) != 0) {
								_global.tintCount++;
								UpdateTintCount();
							} else if(selectedEntry.tintType != RaceMenuDefines.TINT_TYPE_HAIR && (selectedEntry.fillColor >>> 24) != 0 && (event.color >>> 24) == 0) {
								_global.tintCount--;
								UpdateTintCount();
							}
							selectedEntry.fillColor = event.color;
						}
						requestUpdate({type: "sliderColor", slider: selectedEntry, argbColor: event.color});
					} else if(isMakeup(selectedEntry.tintType)) {
						if(event.apply) {
							// Update Tint Count
							if(selectedEntry.tintType != RaceMenuDefines.TINT_TYPE_HAIR && (selectedEntry.fillColor >>> 24) == 0 && (event.color >>> 24) != 0) {
								_global.tintCount++;
								UpdateTintCount();
							} else if(selectedEntry.tintType != RaceMenuDefines.TINT_TYPE_HAIR && (selectedEntry.fillColor >>> 24) != 0 && (event.color >>> 24) == 0) {
								_global.tintCount--;
								UpdateTintCount();
							}
							selectedEntry.fillColor = event.color;
						}
						requestUpdate({type: "makeupColor", tintType: selectedEntry.tintType, tintIndex: selectedEntry.tintIndex, argbColor: event.color});
					}
				}
				break;
				
				case "glow":
				{
					if(event.apply) {
						selectedEntry.glowColor = event.color;
					}
					
					requestUpdate({type: "glowColor", tintType: selectedEntry.tintType, tintIndex: selectedEntry.tintIndex, argbColor: event.color});
				}
				break;
			}
			
			if(event.apply)
				itemList.requestUpdate();
		}
		
		if(event.closeField) {
			ShowColorField(false);
			GameDelegate.call("PlaySound", ["UIMenuBladeCloseSD"]);
		}
	}
	
	public function isMakeup(tintType: Number): Boolean
	{
		return tintType == RaceMenuDefines.TINT_TYPE_WARPAINT || isOverlayType(tintType);
	}
	
	public function isOverlayType(tintType: Number): Boolean
	{
		return (tintType == RaceMenuDefines.TINT_TYPE_BODYPAINT ||
				  tintType == RaceMenuDefines.TINT_TYPE_HANDPAINT ||
				  tintType == RaceMenuDefines.TINT_TYPE_FEETPAINT ||
				  tintType == RaceMenuDefines.TINT_TYPE_FACEPAINT);
	}
	
	public function requestUpdate(pendingData: Object)
	{
		_pendingData = pendingData;
		if(!_updateInterval) {
			_updateInterval = setInterval(this, "processDataUpdate", 100, pendingData);
		}
	}
	
	public function requestSliderUpdate(pendingData: Object)
	{
		if(!_reloadInterval) {
			_reloadInterval = setInterval(this, "ReloadSliders", 500, pendingData);
		}
	}
	
	public function processDataUpdate()
	{
		switch(_pendingData.type) {
			case "makeupTexture":
			SendPlayerTexture(_pendingData.tintType, _pendingData.tintIndex, _pendingData.replacementTexture);
			break;
			case "makeupColor":
			SendPlayerTint(_pendingData.tintType, _pendingData.tintIndex, _pendingData.argbColor);
			break;
			case "sliderColor":
			SendPlayerTintBySlider(_pendingData.slider, _pendingData.argbColor);
			break;
			case "glowColor":
			SendPlayerGlow(_pendingData.tintType, _pendingData.tintIndex, _pendingData.argbColor);
			break;
		}
		
		_pendingData = null;
		clearInterval(_updateInterval);
		delete _updateInterval;
	}
	
	// This function is a mess right now
	public function SendPlayerTintBySlider(slider: Object, argbColor: Number): Void
	{
		var tintType: Number = slider.tintType;
		var tintIndex: Number = 0;
		
		if(argbColor == undefined) {
			skyui.util.Debug.log("RSM Warning: Invalid color.");
			return;
		}
						
		// Apply warpaint color based on warpaint slider value
		if(tintType == RaceMenuDefines.TINT_TYPE_WARPAINT) {
			for(var i: Number = 0; i < itemList.entryList.length; i++) {
				if(itemList.entryList[i].sliderID == RaceMenuDefines.STATIC_SLIDER_WARPAINT) {
					tintIndex = itemList.entryList[i].position;
					break;
				}
			}
		}
		
		// Apply dirt color based on dirt slider value
		if(tintType == RaceMenuDefines.TINT_TYPE_DIRT) {
			for(var i: Number = 0; i < itemList.entryList.length; i++) {
				if(itemList.entryList[i].sliderID == RaceMenuDefines.STATIC_SLIDER_DIRT) {
					tintIndex = itemList.entryList[i].position;
					break;
				}
			}
		}
		
		SendPlayerTint(tintType, tintIndex, argbColor);
	}
	
	private function SendPlayerTexture(tintType: Number, tintIndex: Number, replacementTexture: String)
	{
		if(isOverlayType(tintType)) {
			skse.SendModEvent(_global.eventPrefix + "OverlayTextureChange", replacementTexture, tintType * 1000 + tintIndex);
		} else {
			skse.SendModEvent(_global.eventPrefix + "TintTextureChange", replacementTexture, tintType * 1000 + tintIndex);
		}
	}
	
	private function SendPlayerTint(tintType: Number, tintIndex: Number, argbColor: Number)
	{
		if(tintType == RaceMenuDefines.TINT_TYPE_HAIR) {
			skse.SendModEvent(_global.eventPrefix + "HairColorChange", Number(argbColor).toString(), 0);
		} else if(isOverlayType(tintType)) {
			skse.SendModEvent(_global.eventPrefix + "OverlayColorChange", Number(argbColor).toString(), tintType * 1000 + tintIndex);
		} else if(tintType != -1) {
			skse.SendModEvent(_global.eventPrefix + "TintColorChange", Number(argbColor).toString(), tintType * 1000 + tintIndex);
		}
	}
	
	private function SendPlayerGlow(tintType: Number, tintIndex: Number, argbColor: Number)
	{
		skse.SendModEvent(_global.eventPrefix + "OverlayGlowColorChange", Number(argbColor).toString(), tintType * 1000 + tintIndex);
	}
	
	private function onItemPress(event: Object): Void
	{
		var pressedEntry: Object = itemList.entryList[event.index];
		if(pressedEntry != itemList.listState.activeEntry && pressedEntry.type == RaceMenuDefines.ENTRY_TYPE_RACE) {
			itemList.listState.activeEntry = pressedEntry;
			itemList.requestUpdate();
			loadingIcon._visible = true;
			GameDelegate.call("ChangeRace", [pressedEntry.raceID, -1]);
			bRaceChanging = true;
			bPlayerZoom = true; // Reset zoom, this happens when race is changed
			updateBottomBar();
		} else if(pressedEntry.isColorEnabled()) {
			colorField.setText(pressedEntry.text);
			colorField.setColor(pressedEntry.fillColor);
			GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
			ShowColorField(true, {entry: pressedEntry, mode: "tint", bCanSwitchMode: isOverlayType(pressedEntry.tintType), savedColor: _savedColor});
		}/* else {
			itemList.listState.focusEntry = entryObject;
			itemList.requestUpdate();
		}*/
	}
	
	private function onItemPressSecondary(event: Object): Void
	{
		var pressedEntry: Object = itemList.entryList[event.index];
		var textureList: Array = pressedEntry.GetTextureList(this);
		if(textureList) {
			makeupPanel.setMakeupList(textureList);
			makeupPanel.updateButtons(true);
			makeupPanel.setSelectedEntry(pressedEntry.texture);
			makeupPanel.setTexture(pressedEntry.text, pressedEntry.texture);
			GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
			ShowMakeupPanel(true, {entry: pressedEntry});
		}
	}
	
	private function onItemPressAux(event: Object): Void
	{
		var pressedEntry: Object = itemList.entryList[event.index];
		if(pressedEntry.hasGlow() && isOverlayType(pressedEntry.tintType)) {
			colorField.setText(pressedEntry.text);
			colorField.setColor(pressedEntry.glowColor); 
			GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
			ShowColorField(true, {entry: pressedEntry, mode: "glow", bCanSwitchMode: true, savedColor: _savedColor});
		}
	}
	
	private function onSwitchColorMode(event: Object): Void
	{
		switch(event.mode) {
			case "tint":
			colorField["mode"] = "glow";
			//colorField.disableAlpha(true);
			colorField.disableAlpha(false);
			colorField.setColor(colorField["entry"].glowColor);
			break;
			case "glow":
			colorField["mode"] = "tint";
			colorField.disableAlpha(false);
			colorField.setColor(colorField["entry"].fillColor);
			break;
		}
	}
	
	private function onSaveColor(event: Object): Void
	{
		_savedColor = event.color;
		setDisplayText("$Saved Color", _savedColor);
	}
	
	private function onSelectionChange(event: Object): Void
	{
		var selectedEntry: Object = itemList.entryList[event.index];
		itemList.listState.selectedEntry = selectedEntry;
		if(selectedEntry.filterFlag & RaceMenuDefines.CATEGORY_RACE) {
			raceDescription.textField.SetText(selectedEntry.raceDescription);
			ShowRaceDescription(true);
			ShowRaceBonuses(_raceList[selectedEntry.raceID], true);
		} else {
			ShowRaceBonuses(null, false);
			ShowRaceDescription(false);
			raceDescription.textField.SetText("");
		}		
		
		GameDelegate.call("PlaySound",["UIMenuFocus"]);
		updateItemDescriptor();
		updateBottomBar();
	}
	
	private function updateItemDescriptor(a_fadeDelay: Number): Void
	{
		var selectedEntry = itemList.listState.selectedEntry;
		if(selectedEntry.extraData && itemList.disableInput == false) {
			var formName = selectedEntry.extraData.partName;
			var formId = selectedEntry.extraData.formId;
			if(formName != undefined && formId != undefined) {
				//itemDescriptor._x = itemList.disableSelection ? (ITEMLIST_HIDDEN_X + racePanel._width) : (_panelX + racePanel._width);
				//itemDescriptor._y = itemList.getClipGlobalCoordinate().y - 10;
				var modName: String = _global.skse.plugins.CharGen.GetModName(formId);
				itemDescriptor.setText(modName + " (" + formName + ")", a_fadeDelay);
				itemDescriptor._x = Stage.visibleRect.x + Stage.visibleRect.width - itemDescriptor._width;
				itemDescriptor.toggle(true);
				itemDescriptor.fadeOut();
			} else {
				itemDescriptor.toggle(false);
			}
		} else if(selectedEntry.filterFlag & RaceMenuDefines.CATEGORY_RACE && itemList.disableInput == false) {
			var raceForm: Object = _raceList[selectedEntry.raceID];
			if(raceForm != undefined) {
				var formName: String = raceForm.editorId;
				var formId: Number = raceForm.formId;
				//itemDescriptor._y = itemList.getClipGlobalCoordinate().y - 10;
				var modName: String = _global.skse.plugins.CharGen.GetModName(formId);
				itemDescriptor.setText(modName + " (" + formName + ")", a_fadeDelay);
				itemDescriptor._x = Stage.visibleRect.x + Stage.visibleRect.width - itemDescriptor._width;
				itemDescriptor.toggle(true);
				itemDescriptor.fadeOut();
			} else {
				itemDescriptor.toggle(false);
			}
		} else if(statusText != "") {
			if(statusText != "__CLEAR__") {
				itemDescriptor.setText(statusText, a_fadeDelay);
				itemDescriptor._x = Stage.visibleRect.x + Stage.visibleRect.width - itemDescriptor._width;
				itemDescriptor.toggle(true);
				itemDescriptor.fadeOut();
			} else {
				statusText = "";
				itemDescriptor.toggle(false);
			}
		} else {
			itemDescriptor.toggle(false);
		}
	}
	
	private function updateBottomBar(): Void
	{
		navPanel.clearButtons();
		navPanel.addButton({text: "$Done", controls: _acceptControl}).addEventListener("click", this, "onDoneClicked");
		if(_platform == 0) {
			navPanel.addButton({text: "$Search", controls: _searchControl}).addEventListener("click", this, "onSearchClicked");
		}
		navPanel.addButton({text: bPlayerZoom ? "$Zoom Out" : "$Zoom In", controls: _zoomControl}).addEventListener("click", this, "onZoomClicked");
		
		if(_global.skse)
			navPanel.addButton({text: bShowLight ? "$Light Off" : "$Light On", controls: _lightControl}).addEventListener("click", this, "onLightClicked");
		
		var selectedEntry = itemList.listState.selectedEntry;
		if(selectedEntry != itemList.listState.activeEntry && selectedEntry.filterFlag & RaceMenuDefines.CATEGORY_RACE)
			navPanel.addButton({text: "$Change Race", controls: _activateControl}).addEventListener("click", this, "onChangeRaceClicked");
		if(selectedEntry.isColorEnabled())
			navPanel.addButton({text: "$Choose Color", controls: _activateControl}).addEventListener("click", this, "onChooseColorClicked");
		if(selectedEntry.GetTextureList(this))
			navPanel.addButton({text: "$Choose Texture", controls: _textureControl}).addEventListener("click", this, "onChooseTextureClicked");
				
		navPanel.updateButtons(true);
	}
	
	private function setDisplayText(a_text: String, a_color: Number): Void
	{
		textDisplay._visible = true;
		textDisplay._alpha = 100;
		textDisplay.text = skyui.util.Translator.translateNested(a_text);
		if(a_color != undefined)
			textDisplay.textColor = a_color;
		else
			textDisplay.textColor = 0xFFFFFF;
		TweenLite.to(textDisplay, 2.5, {autoAlpha: 0, easing: Linear.easeNone});
	}
	
	private function setStatusText(a_text: String, a_fadeDelay: Number): Void
	{
		statusText = skyui.util.Translator.translateNested(a_text);
		updateItemDescriptor(a_fadeDelay);
		statusText = "";
	}
	
	private function onDoneClicked(): Void
	{
		if(colorField._visible || textEntry._visible || makeupPanel._visible)
			return;
		
		GameDelegate.call("ConfirmDone", []);
	}
	
	private function onSearchClicked(): Void
	{
		if(colorField._visible || textEntry._visible || makeupPanel._visible)
			return;
		
		searchWidget.startInput();
	}
	
	private function onZoomClicked(): Void
	{
		if(colorField._visible || textEntry._visible || makeupPanel._visible)
			return;
		
		bPlayerZoom = !bPlayerZoom;
		GameDelegate.call("ZoomPC", [bPlayerZoom]);
		updateBottomBar();
	}
	
	private function onLightClicked(): Void
	{
		if(colorField._visible || textEntry._visible || makeupPanel._visible)
			return;
		
		bShowLight = !bShowLight;
		skse.SendModEvent(_global.eventPrefix + "ToggleLight", "", Number(bShowLight));
		updateBottomBar();
	}
	
	private function onChangeRaceClicked(): Void
	{
		if(colorField._visible || textEntry._visible || makeupPanel._visible)
			return;
		
		var selectedEntry = itemList.listState.selectedEntry;
		if(selectedEntry) {
			itemList.listState.activeEntry = selectedEntry;
			itemList.requestUpdate();
			loadingIcon._visible = true;
			GameDelegate.call("ChangeRace", [selectedEntry.raceID, -1]);
			bRaceChanging = true;
			bPlayerZoom = true; // Reset zoom, this happens when race is changed
			updateBottomBar();
		}
	}
	
	private function onChooseColorClicked(): Void
	{
		if(colorField._visible || textEntry._visible || makeupPanel._visible)
			return;
		
		var selectedEntry = itemList.listState.selectedEntry;
		if(selectedEntry.isColorEnabled()) {
			colorField.setText(selectedEntry.text);
			colorField.setColor(selectedEntry.fillColor);
			GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
			ShowColorField(true, {entry: selectedEntry, mode: "tint", bCanSwitchMode: isOverlayType(selectedEntry.tintType), savedColor: _savedColor});
		}
	}
	
	private function onChooseTextureClicked(): Void
	{
		if(colorField._visible || textEntry._visible || makeupPanel._visible)
			return;
		
		var selectedEntry = itemList.listState.selectedEntry;
		var textureList: Array = selectedEntry.GetTextureList(this);
		if(textureList) {
			makeupPanel.setMakeupList(textureList);
			makeupPanel.updateButtons(true);
			makeupPanel.setSelectedEntry(selectedEntry.texture);
			makeupPanel.setTexture(selectedEntry.text, selectedEntry.texture);
			GameDelegate.call("PlaySound", ["UIMenuBladeOpenSD"]);
			ShowMakeupPanel(true, {entry: selectedEntry});
		}
	}
		
	private function ReloadSliders(event: Object): Void
	{
		_global.skse.plugins.CharGen.ReloadSliders();
		skse.SendModEvent(_global.eventPrefix + "RequestTintLoad");
		SendPlayerTint(RaceMenuDefines.TINT_TYPE_HAIR, 0, event.data.hairColor);
		setStatusText("$Loaded preset from {" + event.name + "}", 3.0);
		loadingIcon._visible = false;
		clearInterval(_reloadInterval);
		delete _reloadInterval;
	}
		
	private function GetSliderByType(tintType: Number): Object
	{
		for(var i = 0; i < itemList.entryList.length; i++)
		{
			if(itemList.entryList[i].tintType == tintType) {
				return itemList.entryList[i];
			}
		}
		
		return null;
	}
	
	private function GetActorValueText(a_actorValue: Number): String
	{
		for(var i = 0; i < RaceMenuDefines.ACTORVALUE_MAP.length; i++)
		{
			if(RaceMenuDefines.ACTORVALUE_MAP[i].value == a_actorValue)
				return RaceMenuDefines.ACTORVALUE_MAP[i].text;
		}
		
		return "UNKAV " + a_actorValue;
	}
	
	private function SetSliderColors(tintTypes: Array, tintColors: Array): Void
	{
		var typesSet: Array = new Array();
		for(var i = 0; i < tintTypes.length; i++) {
			if(tintTypes[i] != 0 && tintColors[i] != 0) {
				var skipType: Boolean = false;
				for(var k = 0; k < typesSet.length; k++) {
					if(typesSet[k] == tintTypes[i]) {
						skipType = true;
						break;
					}
				}
				
				// Type was already found and the target value has no alpha
				if(skipType && tintColors[i] <= 0x00FFFFFF)
					continue;
				
				var slider: Object = GetSliderByType(tintTypes[i]);
				if(slider) {
					slider.fillColor = tintColors[i];
					if(!skipType)
						typesSet.push(tintTypes[i]);
				}
			}
		}
	}
	
	private function UpdateTintCount(): Void
	{
		racePanel.tintCount.text = "(" + _global.tintCount + "/" + _global.maxTints + ")";
	}
	
	public function AddMakeup(a_type: Number, a_array: Array, a_name: String, a_texture: String)
	{
		var makeupObject: Object = {type: a_type, text: a_name, texture: a_texture, filterFlag: 1, enabled: true};
				
		// Strip Path and extension
		var slashIndex: Number = -1;
		for(var k = a_texture.length - 1; k > 0; k--) {
			if(a_texture.charAt(k) == "\\" || a_texture.charAt(k) == "/") {
				slashIndex = k;
				break;
			}
		}
		var formatIndex: Number = a_texture.lastIndexOf(".dds");
		if(formatIndex == -1)
			formatIndex = a_texture.length;
		
		var displayText: String = a_texture.substring(slashIndex + 1, formatIndex);
		makeupObject.displayText = displayText;
		
		a_array.push(makeupObject);
	}
	
	
}
