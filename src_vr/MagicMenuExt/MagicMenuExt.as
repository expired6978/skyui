import Shared.GlobalFunc;
import gfx.io.GameDelegate;
import gfx.ui.NavigationCode;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.props.PropertyDataExtender;

import skyui.util.ConfigManager;
import skyui.components.ButtonPanel;

import skyui.defines.Input;
import skyui.defines.Inventory;
import skyui.defines.Actor;

import mx.data.binding.ObjectDumper;

class MagicMenuExt extends ItemMenu
{
  /* PRIVATE VARIABLES */
	#include "../version.as"
  
	private var _bMenuClosing: Boolean = false;

	private var _magicButtonArt: Object;
	private var _categoryListIconArt: Array;
	private var _tabBarIconArt: Array;
	
	private var CATEGORY_ALL: Number = 0;
	private var CATEGORY_ALTERATION: Number = 1;
	private var CATEGORY_ILLUSION: Number = 2;
	private var CATEGORY_DESTRUCTION: Number = 3;
	private var CATEGORY_CONJURATION: Number = 4;
	private var CATEGORY_RESTORATION: Number = 5;
	private var CATEGORY_SHOUTS: Number = 6;
	private var CATEGORY_POWERS: Number = 7;
	private var CATEGORY_ACTIVE_EFFECTS: Number = 8;
	private var CATEGORY_END: Number = 9;
	
	private var _primaryActor: Object;
	private var _secondaryActor: Object;
	
	public var MessagesBlock: MovieClip;
	
	
  /* PROPERTIES */
  
	public var bRestrictTrade: Boolean = true;
	

  /* CONSTRUCTORS */

	public function MagicMenuExt()
	{
		super();
		_categoryListIconArt = ["mag_all", "mag_alteration", "mag_illusion",
							   "mag_destruction", "mag_conjuration", "mag_restoration", "mag_shouts",
							   "mag_powers", "mag_activeeffects"];
		_tabBarIconArt = ["take", "give"];
		_visible = false;
	}
	
	public function onLoad(): Void
	{
		super.onLoad();
	}
	
	
	/* PUBLIC FUNCTIONS */
	public function InitExtensions(): Void
	{
		super.InitExtensions();
		
		MessagesBlock.Lock("TL");
		
		inventoryLists.tabBarIconArt = _tabBarIconArt;
		
		inventoryLists.enableTabBar();
		
		bottomBar.setGiftInfo(0);
		bottomBar.hidePlayerInfo();
		
		var filterAll: Number = Inventory.FILTERFLAG_MAGIC_ALTERATION +
								Inventory.FILTERFLAG_MAGIC_ILLUSION +
								Inventory.FILTERFLAG_MAGIC_DESTRUCTION +
								Inventory.FILTERFLAG_MAGIC_CONJURATION +
								Inventory.FILTERFLAG_MAGIC_RESTORATION +
								Inventory.FILTERFLAG_MAGIC_SHOUTS +
								Inventory.FILTERFLAG_MAGIC_POWERS;
		var filterRecv: Number = (Inventory.FILTERFLAG_MAGIC_ALTERATION << 8) +
								(Inventory.FILTERFLAG_MAGIC_ILLUSION << 8) +
								(Inventory.FILTERFLAG_MAGIC_DESTRUCTION << 8) +
								(Inventory.FILTERFLAG_MAGIC_CONJURATION << 8) +
								(Inventory.FILTERFLAG_MAGIC_RESTORATION << 8) +
								(Inventory.FILTERFLAG_MAGIC_SHOUTS << 8) +
								(Inventory.FILTERFLAG_MAGIC_POWERS << 8);
				
		inventoryLists.categoryList.entryList.push({bDontHide: true, filterFlag: 0, flag: filterAll, text: "$ALL"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_ALTERATION, text: "$ALTERATION"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_ILLUSION, text: "$ILLUSION"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_DESTRUCTION, text: "$DESTRUCTION"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_CONJURATION, text: "$CONJURATION"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_RESTORATION, text: "$RESTORATION"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_SHOUTS, text: "$SHOUTS"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_POWERS, text: "$POWERS"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_ACTIVEEFFECTS, text: "$ACTIVE EFFECTS"});
		inventoryLists.categoryList.entryList.push({bDontHide: true, filterFlag: 0, flag: Inventory.FILTERFLAG_DIVIDER});
		inventoryLists.categoryList.entryList.push({bDontHide: true, filterFlag: 0, flag: filterRecv, text: "$ALL"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_ALTERATION << 8, text: "$ALTERATION"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_ILLUSION << 8, text: "$ILLUSION"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_DESTRUCTION << 8, text: "$DESTRUCTION"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_CONJURATION << 8, text: "$CONJURATION"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_RESTORATION << 8, text: "$RESTORATION"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_SHOUTS << 8, text: "$SHOUTS"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_POWERS << 8, text: "$POWERS"});
		inventoryLists.categoryList.entryList.push({bDontHide: false, filterFlag: 0, flag: Inventory.FILTERFLAG_MAGIC_ACTIVEEFFECTS << 8, text: "$ACTIVE EFFECTS"});
		inventoryLists.categoryList.dividerIndex = 9;
		inventoryLists.categoryList.InvalidateData();
		updateBottomBar(false);
		
		inventoryLists.itemList.addEventListener("selectionChange", this, "onItemsListSelectionChange");
		
		// Initialize menu-specific list components
		var categoryList: CategoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;
		_visible = true;
		
		skse.SendModEvent("UIMagicMenu_LoadMenu");
	}
	
	function onEnterFrame(): Void
	{
		MessagesBlock.Update();
	}
	
	private function onItemsListSelectionChange(event: Object): Void
	{
		if (event.index != -1) {
			var entry = inventoryLists.itemList.entryList[event.index];
			GameDelegate.call("UpdateItem3D", [entry.formId]);
		} else {
			GameDelegate.call("UpdateItem3D", [0]);
		}
	}
	
	// @override ItemMenu
	public function setConfig(a_config: Object): Void
	{
		super.setConfig(a_config);
		
		var itemList: TabularList = inventoryLists.itemList;
		itemList.addDataProcessor(new MagicDataSetterEx(a_config["Appearance"]));
		itemList.addDataProcessor(new MagicIconSetterEx(a_config["Appearance"]));
		itemList.addDataProcessor(new PropertyDataExtender(a_config["Appearance"], a_config["Properties"], "magicProperties", "magicIcons", "magicCompoundProperties"));
		
		var layout: ListLayout = ListLayoutManager.createLayout(a_config["ListLayout"], "MagicListLayout");
		itemList.layout = layout;

		// Not 100% happy with doing this here, but has to do for now.
		if (inventoryLists.categoryList.selectedEntry)
			layout.changeFilterFlag(inventoryLists.categoryList.selectedEntry.flag);
	}
	
	private function CreateItemInfo(spell: Object): Object
	{
		var itemInfo = new Object();
		
		itemInfo.spellCost = spell.trueCost;
		itemInfo.castTime = spell.castTime;
				
		switch(spell.subType) {
			case Actor.AV_ALTERATION:
			itemInfo.magicSchoolName = "$Alteration";
			itemInfo.type = Inventory.ICT_SPELL;
			break;
			case Actor.AV_CONJURATION:
			itemInfo.magicSchoolName = "$Conjuration";
			itemInfo.type = Inventory.ICT_SPELL;
			break;
			case Actor.AV_DESTRUCTION:
			itemInfo.magicSchoolName = "$Destruction";
			itemInfo.type = Inventory.ICT_SPELL;
			break;
			case Actor.AV_ILLUSION:
			itemInfo.magicSchoolName = "$Illusion";
			itemInfo.type = Inventory.ICT_SPELL;
			break;
			case Actor.AV_RESTORATION:
			itemInfo.magicSchoolName = "$Restoration";
			itemInfo.type = Inventory.ICT_SPELL;
			break;
			default:
			itemInfo.type = Inventory.ICT_SPELL_DEFAULT;
			break;
		}
				
		if(spell.castType == 0 || spell.isActiveEffect) { // Effect
			itemInfo.name = spell.spellName;
			itemInfo.negativeEffect = ((spell.effectFlags & 0x04) == 0x04); // Detrimental
			
			if(spell.duration > spell.elapsed) { // Remaining time
				itemInfo.timeRemaining = spell.duration - spell.elapsed;
			}
			
			itemInfo.type = Inventory.ICT_ACTIVE_EFFECT;
		} else {
			switch(spell.skillLevel) {
				case 0:		itemInfo.castLevel = skyui.util.Translator.translateNested("$Novice ({" + spell.skillLevel + "})");		break;
				case 25:	itemInfo.castLevel = skyui.util.Translator.translateNested("$Apprentice ({" + spell.skillLevel + "})");	break;
				case 50:	itemInfo.castLevel = skyui.util.Translator.translateNested("$Adept ({" + spell.skillLevel + "})");		break;
				case 75:	itemInfo.castLevel = skyui.util.Translator.translateNested("$Expert ({" + spell.skillLevel + "})");		break;
				case 100:	itemInfo.castLevel = skyui.util.Translator.translateNested("$Master ({" + spell.skillLevel + "})");		break;
			}
		}
		
		if(spell.words != undefined) { // Shout
			itemInfo.spellCost = "";
			for(var i = 0; i < spell.words.length; i++) {
				itemInfo.spellCost += spell.words[i].recoveryTime;
				if(i < spell.words.length - 1)
					itemInfo.spellCost += " , ";

				itemInfo["dragonWord" + i] = spell.words[i].word;
				itemInfo["word" + i] = spell.words[i].fullName;
				itemInfo["unlocked" + i] = true;
			}
			itemInfo.type = Inventory.ICT_SHOUT;
		}
		
		return itemInfo;
	}
	
	private function DeflateSpellData(entry: Object, spell: Object, dividerIndex: Number, flagShift: Number): Void
	{
		entry.count = 1;
		entry.enabled = true;
		entry.equipState = 0;
		entry.favorite = 0;
		
		entry.text = spell.spellName;
		entry.itemInfo = CreateItemInfo(spell);
		
		entry.filterFlag = Inventory.FILTERFLAG_MAGIC_POWERS << flagShift;
		
		switch(spell.subType) {
			case Actor.AV_ALTERATION:		entry.filterFlag = Inventory.FILTERFLAG_MAGIC_ALTERATION << flagShift;	break;
			case Actor.AV_CONJURATION:		entry.filterFlag = Inventory.FILTERFLAG_MAGIC_CONJURATION << flagShift;	break;
			case Actor.AV_DESTRUCTION:		entry.filterFlag = Inventory.FILTERFLAG_MAGIC_DESTRUCTION << flagShift;	break;
			case Actor.AV_ILLUSION:			entry.filterFlag = Inventory.FILTERFLAG_MAGIC_ILLUSION << flagShift;	break;
			case Actor.AV_RESTORATION:		entry.filterFlag = Inventory.FILTERFLAG_MAGIC_RESTORATION << flagShift;	break;
		}
		
		if(spell.spellType == 2) {
			entry.filterFlag = Inventory.FILTERFLAG_MAGIC_POWERS << flagShift;
		}
		
		if(spell.castType == 0 || spell.isActiveEffect) { // Effect
			entry.text = spell.effectName;
			entry.filterFlag = Inventory.FILTERFLAG_MAGIC_ACTIVEEFFECTS << flagShift;
		}
		
		if(spell.words != undefined) { // Shout
			entry.text = spell.fullName;
			entry.filterFlag = Inventory.FILTERFLAG_MAGIC_SHOUTS << flagShift;
		}
		
		// Hidden in UI
		if((spell.effectFlags & 0x8000) == 0x8000 || spell.inactive == true) {
			entry.filterFlag = 0;
			entry.enabled = false;
		}
	}
	
	private function UpdateCategoryAvailability(entry: Object, dividerIndex: Number, flagShift: Number): Void
	{
		if(entry.filterFlag != 0) {
			inventoryLists.categoryList.entryList[dividerIndex + CATEGORY_ALL].filterFlag = 1;
			switch(entry.filterFlag >>> flagShift) {
				case Inventory.FILTERFLAG_MAGIC_ALTERATION: 	inventoryLists.categoryList.entryList[dividerIndex + CATEGORY_ALTERATION].filterFlag = 1; break;
				case Inventory.FILTERFLAG_MAGIC_ILLUSION: 		inventoryLists.categoryList.entryList[dividerIndex + CATEGORY_ILLUSION].filterFlag = 1; break;
				case Inventory.FILTERFLAG_MAGIC_DESTRUCTION: 	inventoryLists.categoryList.entryList[dividerIndex + CATEGORY_DESTRUCTION].filterFlag = 1; break;
				case Inventory.FILTERFLAG_MAGIC_CONJURATION: 	inventoryLists.categoryList.entryList[dividerIndex + CATEGORY_CONJURATION].filterFlag = 1; break;
				case Inventory.FILTERFLAG_MAGIC_RESTORATION: 	inventoryLists.categoryList.entryList[dividerIndex + CATEGORY_RESTORATION].filterFlag = 1; break;
				case Inventory.FILTERFLAG_MAGIC_SHOUTS: 		inventoryLists.categoryList.entryList[dividerIndex + CATEGORY_SHOUTS].filterFlag = 1; break;
				case Inventory.FILTERFLAG_MAGIC_POWERS: 		inventoryLists.categoryList.entryList[dividerIndex + CATEGORY_POWERS].filterFlag = 1; break;
				case Inventory.FILTERFLAG_MAGIC_ACTIVEEFFECTS: 	inventoryLists.categoryList.entryList[dividerIndex + CATEGORY_ACTIVE_EFFECTS].filterFlag = 1; break;
			}
		}
	}
	
	private function ComputeCategoryAvailability(): Void
	{
		for(var k = 0; k < inventoryLists.categoryList.entryList.length; k++)
		{
			var entry: Object = inventoryLists.categoryList.entryList[k];
			entry.filterFlag = 0;
		}
		for(var i = 0; i < inventoryLists.itemList.entryList.length; i++)
		{
			var entry: Object = inventoryLists.itemList.entryList[i];
			if(entry.isPrimary)
				UpdateCategoryAvailability(entry, 0, 0);
			else
				UpdateCategoryAvailability(entry, 10, 8);
		}
		
		inventoryLists.categoryList.UpdateList();
	}
	
	// @Papyrus
	public function MagicMenu_SetActor(aObject: Object): Void
	{
		if(aObject.formId == undefined)
			return;
		
		skse.ExtendForm(aObject.formId >>> 0, aObject, true, true);
		
		var spells: Array = new Array();
		spells = spells.concat(aObject.race.spells, aObject.actorBase.spells, aObject.spells);
		var shouts: Array = new Array();
		shouts = shouts.concat(aObject.race.shouts, aObject.actorBase.shouts, aObject.shouts);
		var effects: Array = aObject.activeEffects;
		
		inventoryLists["_leftTabText"] = aObject.actorBase.fullName;
		inventoryLists.panelContainer.tabBar.leftLabel.SetText(aObject.actorBase.fullName.toUpperCase());

		for(var i = 0; i < spells.length; i++)
		{
			var entry: Object = spells[i];
			DeflateSpellData(entry, spells[i], 0, 0);
			UpdateCategoryAvailability(entry, 0, 0);
			entry.isPrimary = true;
			inventoryLists.itemList.entryList.push(entry);
			//skse.Log(ObjectDumper.toString(entry));
		}
		
		for(var i = 0; i < shouts.length; i++)
		{
			var entry: Object = shouts[i];
			DeflateSpellData(entry, shouts[i], 0, 0);
			UpdateCategoryAvailability(entry, 0, 0);
			entry.isPrimary = true;
			inventoryLists.itemList.entryList.push(entry);
			//skse.Log(ObjectDumper.toString(entry));
		}
		
		for(var i = 0; i < effects.length; i++)
		{
			var entry: Object = effects[i];
			entry.isActiveEffect = true;
			DeflateSpellData(entry, effects[i], 0, 0);
			UpdateCategoryAvailability(entry, 0, 0);
			entry.isPrimary = true;
			inventoryLists.itemList.entryList.push(entry);
			//skse.Log(ObjectDumper.toString(entry));
		}
		
		_primaryActor = aObject;
		
		inventoryLists.categoryList.InvalidateData();
		inventoryLists.categoryList.onItemPress(CATEGORY_ALL, 0);
		inventoryLists.itemList.InvalidateData();
	}
	
	public function MagicMenu_SetSecondaryActor(aObject: Object): Void
	{
		if(aObject.formId == undefined) {
			inventoryLists.panelContainer.gotoAndStop("normal");
			inventoryLists["_bTabbed"] = false;
			return;
		}
				
		skse.ExtendForm(aObject.formId >>> 0, aObject, true, true);
		var spells: Array = new Array();
		spells = spells.concat(aObject.race.spells, aObject.actorBase.spells, aObject.spells);
		var shouts: Array = new Array();
		shouts = shouts.concat(aObject.race.shouts, aObject.actorBase.shouts, aObject.shouts);
		var effects: Array = aObject.activeEffects;
		
		inventoryLists["_rightTabText"] = aObject.actorBase.fullName;
		inventoryLists.panelContainer.tabBar.rightLabel.SetText(aObject.actorBase.fullName.toUpperCase());

		for(var i = 0; i < spells.length; i++)
		{
			var entry: Object = spells[i];
			DeflateSpellData(entry, spells[i], 10, 8);
			UpdateCategoryAvailability(entry, 10, 8);
			inventoryLists.itemList.entryList.push(entry);
			//skse.Log(ObjectDumper.toString(entry));
		}
		
		for(var i = 0; i < shouts.length; i++)
		{
			var entry: Object = shouts[i];
			DeflateSpellData(entry, shouts[i], 10, 8);
			UpdateCategoryAvailability(entry, 10, 8);
			inventoryLists.itemList.entryList.push(entry);
			//skse.Log(ObjectDumper.toString(entry));
		}
		
		for(var i = 0; i < effects.length; i++)
		{
			var entry: Object = effects[i];
			entry.isActiveEffect = true;
			DeflateSpellData(entry, effects[i], 10, 8);
			UpdateCategoryAvailability(entry, 10, 8);
			inventoryLists.itemList.entryList.push(entry);
			//skse.Log(ObjectDumper.toString(entry));
		}
		
		_secondaryActor = aObject;
		
		inventoryLists.categoryList.InvalidateData();
		//inventoryLists.categoryList.onItemPress(CATEGORY_ALL, 0);			
		inventoryLists.itemList.InvalidateData();
	}
	
	public function MagicMenu_AddSpell(a_object: Object)
	{
		if(a_object.formId == undefined)
			return;
					
		skse.ExtendForm(a_object.formId >>> 0, a_object, true, true);
		
		var entry: Object = a_object;
		DeflateSpellData(entry, a_object, 0, 0);
		entry.isPrimary = true;
		UpdateCategoryAvailability(entry, 0, 0);
		inventoryLists.itemList.entryList.push(entry);
		inventoryLists.categoryList.InvalidateData();
		inventoryLists.itemList.InvalidateData();
	}
	
	public function MagicMenu_RemoveSpell(a_object: Object)
	{
		if(a_object.formId == undefined)
			return;
		
		for(var i = 0; i < inventoryLists.itemList.entryList.length; i++)
		{
			var entry = inventoryLists.itemList.entryList[i];
			if(entry.isPrimary && (entry.formId >>> 0) == (a_object.formId >>> 0)) {
				inventoryLists.itemList.entryList.splice(i, 1);
				break;
			}
		}
		ComputeCategoryAvailability();
		inventoryLists.itemList.InvalidateData();
	}
	
	public function MagicMenu_PushMessage(a_text: String)
	{
		MessagesBlock.MessageArray.push(skyui.util.Translator.translateNested(a_text));
	}

	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		if (bFadedIn && ! pathToFocus[0].handleInput(details,pathToFocus.slice(1))) {
			if (Shared.GlobalFunc.IsKeyPressed(details)) {
				if (details.navEquivalent == NavigationCode.TAB) {
					startMenuFade();
					//GameDelegate.call("CloseTweenMenu",[]);
				}
			}
		}
		return true;
	}

	// @override ItemMenu
	public function onExitMenuRectClick(): Void
	{
		onFadeCompletion();
	}

	public function onFadeCompletion(): Void
	{
		if (_bMenuClosing) {
			//GameDelegate.call("CloseMenu",[]);
			skse.SendModEvent("UIMagicMenu_CloseMenu");
			//GameDelegate.call("buttonPress",[1]);
			skse.CloseMenu("CustomMenu");
		}
	}

	// @override ItemMenu
	public function onShowItemsList(event: Object): Void
	{
		super.onShowItemsList(event);
		
		if (event.index != -1)
			updateBottomBar(false);
	}

	// @override ItemMenu
	public function onItemHighlightChange(event: Object)
	{
		/*super.onItemHighlightChange(event);
		
		if (event.index != -1)
			updateButtons();*/
	}

	// @API
	public function DragonSoulSpent(): Void
	{
		// Do nothing
	}


	// @override ItemMenu
	public function onHideItemsList(event: Object): Void
	{
		super.onHideItemsList(event);
	}
	
	// @API
	public function AttemptEquip(a_slot: Number): Void
	{
		// Do nothing
	}

	// @override ItemMenu
	public function onItemSelect(event: Object): Void
	{
		if (event.entry.enabled)
		{
			if(bRestrictTrade)
			{
				if(inventoryLists.categoryList.activeSegment == 1) // Only restrict learning spells
				{
					switch(event.entry.school)
					{
						case Actor.AV_ALTERATION:
						case Actor.AV_CONJURATION:
						case Actor.AV_DESTRUCTION:
						case Actor.AV_ILLUSION:
						case Actor.AV_RESTORATION:
						{
							if(event.entry.skillLevel > _primaryActor.actorValues[event.entry.school].current) {
								MagicMenu_PushMessage("${" + _primaryActor.actorBase.fullName + "} is not skilled enough in {" + event.entry.itemInfo.magicSchoolName + "} to learn {" + event.entry.text + "}.");
								return;
							}
						}
						break;
					}
				}
			}
			
			if(event.entry.formId == undefined || event.entry.isActiveEffect) {
				return;
			}
					
			skse.SendModEvent("UIMagicMenu_AddRemoveSpell", "", inventoryLists.categoryList.activeSegment, (event.entry.formId >>> 0));
		}
	}
	
	// currently only used for controller users when pressing the BACK button
	private function openInventoryMenu(): Void
	{
		//GameDelegate.call("CloseMenu",[]);
		//GameDelegate.call("CloseTweenMenu",[]);
		//skse.OpenMenu("Inventory Menu");
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function updateBottomBar(a_bSelected: Boolean): Void
	{
		navPanel.clearButtons();
		navPanel.addButton({text: "$Exit", controls: _cancelControls});
		navPanel.updateButtons(true);
	}
	
	private function startMenuFade(): Void
	{
		inventoryLists.hidePanel();
		ToggleMenuFade();
		_bMenuClosing = true;
	}
}