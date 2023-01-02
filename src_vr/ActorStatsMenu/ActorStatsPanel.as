import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.io.GameDelegate;
import Shared.GlobalFunc;

import skyui.components.list.FilteredEnumeration;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ButtonEntryFormatter;
import skyui.components.list.ScrollingList;
import skyui.filter.ItemTypeFilter;
import skyui.util.ConfigManager;

import skyui.defines.Actor;
import skyui.defines.Form;

class ActorStatsPanel extends MovieClip
{	
  /* PRIVATE VARIABLES */
  	
	private var _subList: ScrollingList;
	private var _statsList: ScrollingList;
	private var _categoryList: CategoryList;
	private var _typeFilter: ItemTypeFilter;
	private var _showStats: Boolean = false;
	private var _quitting: Boolean = false;
	
	private var CATEGORY_FLAG_ALL = -257;
	private var CATEGORY_FLAG_GENERAL = 1;
	private var CATEGORY_FLAG_RESISTANCES = 2;
	private var CATEGORY_FLAG_COMBAT = 4;
	private var CATEGORY_FLAG_SKILL = 8;
	private var CATEGORY_FLAG_MAGIC = 16;
	
	private var STATE_ENTERING_STATS = 0;
	private var STATE_EXITING_STATS = 1;
	
	private var _config: Object;
	
  /* STAGE ELEMENTS */

	public var contentHolder: MovieClip;	
	
  /* INITIALIATZION */
	
	function ActorStatsPanel()
	{
		_typeFilter = new ItemTypeFilter();
		_subList = contentHolder.actorListPanel.list;
		_statsList = contentHolder.statsPanel.statsList;
		_categoryList = contentHolder.categoryList;
	}
	
	// @override MovieClip
	private function onLoad()
	{
		super.onLoad();
		
		_categoryList.listEnumeration = new BasicEnumeration(_categoryList.entryList);
		//_categoryList.entryFormatter = new CategoryEntryFormatter(_categoryList);
		
		_subList.listEnumeration = new BasicEnumeration(_subList.entryList);
		//_subList.entryFormatter = new ButtonEntryFormatter(_subList);
		
		var listEnumeration = new FilteredEnumeration(_statsList.entryList);
		listEnumeration.addFilter(_typeFilter);
		_statsList.listEnumeration = listEnumeration;
		//_statsList.entryFormatter = new ActorValueEntryFormatter(_statsList);
		
		_typeFilter.addEventListener("filterChange", this, "onFilterChange");
		
		_categoryList.addEventListener("itemPress", this, "onCategoryPress");
		_subList.addEventListener("itemPress", this, "onActorPress");
		
		_subList.addEventListener("selectionChange", this, "onSelectionChange");
		_statsList.addEventListener("selectionChange", this, "onSelectionChange");
		
		// Debug
		
		_subList.InvalidateData();
		
		//setActorNames("Sub 1", "Sub 2", "Sub 3", "Sub 4", "Sub 5", "Sub 6", "Sub 7", "Sub 8", "Sub 9", "Sub 10", "Sub 11");
		/*setActorStatsPanelForm({actorBase: {fullName: "Jack"}, formType: 1, actorValues: [{base: 0, current: 0, maximum: 0},
												  {base: 10, current: 1, maximum: 0},
												  {base: 10, current: 2, maximum: 0},
												  {base: 10, current: 3, maximum: 0},
												  {base: 10, current: 4, maximum: 0},
												  {base: 10, current: 5, maximum: 0},
												  {base: 10, current: 6, maximum: 0},
												  {base: 10, current: 7, maximum: 0},
												  {base: 10, current: 8, maximum: 0},
												  {base: 10, current: 9, maximum: 0},
												  {base: 10, current: 10, maximum: 0},
												  {base: 10, current: 11, maximum: 0},
												  {base: 10, current: 12, maximum: 0},
												  {base: 10, current: 13, maximum: 0},
												  {base: 10, current: 14, maximum: 0},
												  {base: 10, current: 15, maximum: 0},
												  {base: 10, current: 16, maximum: 0},
												  {base: 10, current: 17, maximum: 0},
												  {base: 10, current: 18, maximum: 0},
												  {base: 10, current: 19, maximum: 0},
												  {base: 10, current: 20, maximum: 0},
												  {base: 10, current: 21, maximum: 0},
												  {base: 1000, current: 22, maximum: 100},
												  {base: 100, current: 23, maximum: 500},
												  {base: 100, current: 510000/2.54, maximum: 510000},
												  {base: 100, current: 25, maximum: 520},
												  {base: 100, current: 26, maximum: 530},
												  {base: 100, current: 27, maximum: 540},
												  {base: 100, current: 28, maximum: 550},
												  {base: 100, current: 29, maximum: 560},
												  {base: 100, current: 30, maximum: 570},
												  {base: 100, current: 31, maximum: 1000}]});*/
				
		addActorValue("$Health", CATEGORY_FLAG_GENERAL, Actor.AV_HEALTH, "pc");
		addActorValue("$Magicka", CATEGORY_FLAG_GENERAL, Actor.AV_MAGICKA, "pc");
		addActorValue("$Stamina", CATEGORY_FLAG_GENERAL, Actor.AV_STAMINA, "pc");
		addActorValue("$Health Rate", CATEGORY_FLAG_GENERAL, Actor.AV_HEALRATE, "p");
		addActorValue("$Magicka Rate", CATEGORY_FLAG_GENERAL, Actor.AV_MAGICKARATE, "p");
		addActorValue("$Stamina Rate", CATEGORY_FLAG_GENERAL, Actor.AV_STAMINARATE, "p");
		addActorValue("$Armor", CATEGORY_FLAG_RESISTANCES, Actor.AV_DAMAGERESIST);
		addActorValue("$Disease Resist", CATEGORY_FLAG_RESISTANCES, Actor.AV_DISEASERESIST, "p");
		addActorValue("$Electric Resist", CATEGORY_FLAG_RESISTANCES, Actor.AV_ELECTRICRESIST, "p");
		addActorValue("$Fire Resist", CATEGORY_FLAG_RESISTANCES, Actor.AV_FIRERESIST, "p");
		addActorValue("$Frost Resist", CATEGORY_FLAG_RESISTANCES, Actor.AV_FROSTRESIST, "p");
		addActorValue("$Poison Resist", CATEGORY_FLAG_RESISTANCES, Actor.AV_POISONRESIST, "p");
		addActorValue("$Magic Resist", CATEGORY_FLAG_RESISTANCES, Actor.AV_MAGICRESIST, "p");
		addActorValue("$One Handed", CATEGORY_FLAG_COMBAT, Actor.AV_ONEHANDED);
		addActorValue("$Two Handed", CATEGORY_FLAG_COMBAT, Actor.AV_TWOHANDED);
		addActorValue("$Archery", CATEGORY_FLAG_COMBAT, Actor.AV_MARKSMAN);
		addActorValue("$Block", CATEGORY_FLAG_COMBAT, Actor.AV_BLOCK);
		addActorValue("$Heavy Armor", CATEGORY_FLAG_COMBAT, Actor.AV_HEAVYARMOR);
		addActorValue("$Light Armor", CATEGORY_FLAG_COMBAT, Actor.AV_LIGHTARMOR);
		addActorValue("$Sneak", CATEGORY_FLAG_COMBAT, Actor.AV_SNEAK);
		addActorValue("$Alchemy", CATEGORY_FLAG_SKILL, Actor.AV_ALCHEMY);
		addActorValue("$Enchanting", CATEGORY_FLAG_SKILL, Actor.AV_ENCHANTING);
		addActorValue("$Smithing", CATEGORY_FLAG_SKILL, Actor.AV_SMITHING);
		addActorValue("$Lockpicking", CATEGORY_FLAG_SKILL, Actor.AV_LOCKPICKING);
		addActorValue("$Pickpocket", CATEGORY_FLAG_SKILL, Actor.AV_PICKPOCKET);
		addActorValue("$Speechcraft", CATEGORY_FLAG_SKILL, Actor.AV_SPEECHCRAFT);
		addActorValue("$Alteration", CATEGORY_FLAG_MAGIC, Actor.AV_ALTERATION);
		addActorValue("$Conjuration", CATEGORY_FLAG_MAGIC, Actor.AV_CONJURATION);
		addActorValue("$Destruction", CATEGORY_FLAG_MAGIC, Actor.AV_DESTRUCTION);
		addActorValue("$Illusion", CATEGORY_FLAG_MAGIC, Actor.AV_ILLUSION);
		addActorValue("$Restoration", CATEGORY_FLAG_MAGIC, Actor.AV_RESTORATION);
		
		_categoryList.iconArt = ["inv_all", "mag_powers", "inv_armor", "inv_weapons", "inv_ingredients", "mag_all"];
		_categoryList.listState.iconSource = "extension_assets/icons_category_psychosteve.swf";
		
		_categoryList.entryList.push({bDontHide: true, filterFlag: 1, flag: CATEGORY_FLAG_ALL, text: "$All"});
		_categoryList.entryList.push({bDontHide: false, filterFlag: 1, flag: CATEGORY_FLAG_GENERAL, text: "$General"});
		_categoryList.entryList.push({bDontHide: false, filterFlag: 1, flag: CATEGORY_FLAG_RESISTANCES, text: "$Resistances"});
		_categoryList.entryList.push({bDontHide: false, filterFlag: 1, flag: CATEGORY_FLAG_COMBAT, text: "$Combat"});
		_categoryList.entryList.push({bDontHide: false, filterFlag: 1, flag: CATEGORY_FLAG_SKILL, text: "$Skill"});
		_categoryList.entryList.push({bDontHide: false, filterFlag: 1, flag: CATEGORY_FLAG_MAGIC, text: "$Magic"});
		_categoryList.InvalidateData();
		_categoryList.onItemPress(0, 0);
		
		startPage();
		FocusHandler.instance.setFocus(_subList, 0);
	}
	
	public function InitExtensions(): Void
	{
		skse.SendModEvent("UIStatsMenu_LoadMenu");
	}
	
	/* PAPYRUS INTERFACE */
	
	public function setActorStatsPanelForm(a_object: Object): Void
	{
		if(a_object == undefined || a_object.formId == undefined)
			return;
			
		skse.ExtendForm(a_object.formId >>> 0, a_object, true, false);
		
		if(a_object.formType == Form.TYPE_FORMLIST)
		{
			_subList.clearList();
			for(var i = 0; i < a_object.forms.length; i++) {
				if(a_object.forms[i].formId != undefined) {
					skse.ExtendForm(a_object.forms[i].formId >>> 0, a_object.forms[i], true, false);
					if(a_object.forms[i].actorBase.formId != undefined) {
						skse.ExtendForm(a_object.forms[i].actorBase.formId >>> 0, a_object.forms[i].actorBase, true, false);
						if(a_object.forms[i].fullName != undefined)
							a_object.forms[i].text = a_object.forms[i].fullName;
						else
							a_object.forms[i].text = a_object.forms[i].actorBase.fullName;
						a_object.forms[i].align = "right";
						a_object.forms[i].enabled = true;
						_subList.entryList.push(a_object.forms[i]);
					}
				}
			}
			_subList.InvalidateData();
		} else {
			_subList.clearList();
			if(a_object.actorBase.formId != undefined) {
				skse.ExtendForm(a_object.actorBase.formId >>> 0, a_object.actorBase, true, false);
				if(a_object.fullName != undefined)
					a_object.text = a_object.fullName;
				else
					a_object.text = a_object.actorBase.fullName;
				a_object.align = "right";
				a_object.enabled = true;
				_subList.entryList.push(a_object);
				_subList.InvalidateData();
			}
		}
	}
		
	public function setActorStatsPanelActorNames(/* names */): Void
	{
		_subList.clearList();
		for (var i = 0; i < arguments.length; i++) {
			_subList.entryList.push({text: arguments[i], align: "right", enabled: true});
		}
		_subList.InvalidateData();
	}
	
	public function setActorStatsPanelStatNames(/* names */): Void
	{
		_statsList.clearList();
		for (var i = 0; i < arguments.length; i++) {
			_statsList.entryList.push({text: arguments[i], align: "left", filterFlag: 2, enabled: true});
		}
		_statsList.InvalidateData();
	}
				
  /* PUBLIC FUNCTIONS */
	
	public function onCategoryPress(a_event: Object): Void
	{
		if (_categoryList.selectedEntry != undefined) {
			_typeFilter.changeFilterFlag(_categoryList.selectedEntry.flag);
		}
	}
	
	public function onFilterChange(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuFocus"]);
		_statsList.InvalidateData();
	}
		
	public function onActorPress(a_event: Object): Void
	{
		selectActor(a_event.entry);
		setState(STATE_ENTERING_STATS);
	}
	
	public function onSelectionChange(a_event: Object): Void
	{
		GameDelegate.call("PlaySound",["UIMenuFocus"]);
	}
	
	private function setState(a_state: Number): Boolean
	{
		switch(a_state) {
			case STATE_ENTERING_STATS:
			{
				if(!_showStats) {
					if(_subList.listState.activeEntry == undefined)
						return false;
						
					GameDelegate.call("PlaySound",["UIMagicSelect"]);
					contentHolder.statsPanel.gotoAndPlay("fadeIn");
					_showStats = true;
					return true;
				}
			}
			break;
			case STATE_EXITING_STATS:
			{
				if(_showStats) {
					GameDelegate.call("PlaySound",["UIMagicUnselect"]);
					contentHolder.statsPanel.gotoAndPlay("fadeOut");
					selectActor();
					_showStats = false;
					return true;
				} else {
					return false;
				}
			}
			break;
		}
		
		return false;
	}
	
	function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bHandledInput = false;
		if(_quitting)
			return true;
			
		if (pathToFocus[0].handleInput(details, pathToFocus.slice(1)))
			return true;
		
		if (GlobalFunc.IsKeyPressed(details)) {
			if (details.navEquivalent == NavigationCode.LEFT) {
				bHandledInput = _categoryList.handleInput(details, pathToFocus);
			} else if (details.navEquivalent == NavigationCode.RIGHT) {
				bHandledInput = _categoryList.handleInput(details, pathToFocus);
			} else if (details.navEquivalent == NavigationCode.ENTER) {
				setState(STATE_ENTERING_STATS);
			} else if (details.navEquivalent == NavigationCode.TAB) {
				if(!setState(STATE_EXITING_STATS)) {
					_quitting = true;
					_subList.disableSelection = _subList.disableInput = true;
					_statsList.disableSelection = _statsList.disableInput = true;
					endPage();
				}
			}
		}
		
		return bHandledInput;
	}
	
	
	/* PRIVATE FUNCTIONS */
	private function startPage(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeOpenSD"]);
		_parent.gotoAndPlay("fadeIn");
	}
		
	private function endPage(): Void
	{
		GameDelegate.call("PlaySound",["UIMenuBladeCloseSD"]);
		_parent.gotoAndPlay("fadeOut");
	}
	
	private function onStatsPanelFadeIn(): Void
	{
		_statsList.disableSelection = _statsList.disableInput = true;
		FocusHandler.instance.setFocus(_statsList, 0);
	}
	
	private function onStatsPanelFadeInComplete(): Void
	{
		_statsList.disableSelection = _statsList.disableInput = false;
	}
	
	private function onStatsPanelFadeOut(): Void
	{
		_statsList.disableSelection = _statsList.disableInput = true;
	}
	
	private function onStatsPanelFadeOutComplete(): Void
	{
		FocusHandler.instance.setFocus(_subList, 0);
	}

	private function onFadeOutCompletion(): Void
	{
		closeMenu();
	}
  
	private function closeMenu()
	{
		skse.SendModEvent("UIStatsMenu_CloseMenu");
		//gfx.io.GameDelegate.call("buttonPress", [0]);
		skse.CloseMenu("CustomMenu");
	}
	
	private function addActorValue(a_text: String, a_filter: Number, a_actorValue: Number, a_type: String)
	{
		_statsList.entryList.push({text: a_text, align: "left", filterFlag: a_filter, actorValue: a_actorValue, type: a_type, enabled: true});
	}
	
	private function updateActorValues()
	{
		var object: Object = _subList.listState.activeEntry;
		if(object.formType != undefined) {
			for(var i = 0; i < _statsList.entryList.length; i++) {
				_statsList.entryList[i].value = object.actorValues[_statsList.entryList[i].actorValue];
			}
			_statsList.InvalidateData();
		}
	}
		
	private function selectActor(a_entry: Object): Void
	{		
		_subList.listState.activeEntry = a_entry;
		_subList.UpdateList();
		updateActorValues();
	}
}

