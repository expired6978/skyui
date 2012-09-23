﻿import gfx.io.GameDelegate;

import skyui.components.list.ListLayoutManager;
import skyui.components.list.TabularList;
import skyui.components.list.ListLayout;
import skyui.props.PropertyDataExtender;


class BarterMenu extends ItemMenu
{
  /* PRIVATE VARIABLES */
  
	private var _playerInfoObj: Object;
	private var _buyMult: Number = 1;
	private var _sellMult: Number = 1;
	private var _confirmAmount: Number = 0;
	private var _playerGold: Number = 0;
	private var _vendorGold: Number = 0;

	private var _categoryListIconArt: Array;
	private var _tabBarIconArt: Array;
	
	private var _dataExtender: BarterDataExtender;
	
  /* PROPERTIES */
	
	// @override ItemMenu
	public var bEnableTabs: Boolean = true;


  /* INITIALIZATION */

	public function BarterMenu()
	{
		super();

		_categoryListIconArt = ["inv_all", "inv_weapons", "inv_armor", "inv_potions", "inv_scrolls", "inv_food", "inv_ingredients", "inv_books", "inv_keys", "inv_misc"];
		_tabBarIconArt = ["buy", "sell"];
	}
	
	public function InitExtensions(): Void
	{
		super.InitExtensions();
		GameDelegate.addCallBack("SetBarterMultipliers", this, "SetBarterMultipliers");
		
		itemCard.addEventListener("messageConfirm",this,"onTransactionConfirm");
		itemCard.addEventListener("sliderChange",this,"onQuantitySliderChange");
		bottomBar.setButtonArt({PCArt:"Tab", XBoxArt:"360_B", PS3Art:"PS3_B"},1);

		bottomBar.buttons[1].addEventListener("click",this,"onExitButtonPress");
		bottomBar.buttons[1].disabled = false;
		
		inventoryLists.tabBarIconArt = _tabBarIconArt;
		
		// Initialize menu-specific list components
		var categoryList: CategoryList = inventoryLists.categoryList;
		categoryList.iconArt = _categoryListIconArt;
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @override ItemMenu
	public function setConfig(a_config: Object): Void
	{
		super.setConfig(a_config);
		
		skyui.util.Debug.log("Setting config");
		
		// Save this to modify multipliers later.
		_dataExtender = new BarterDataExtender();

		var itemList: TabularList = inventoryLists.itemList;		
		itemList.addDataProcessor(_dataExtender);
		itemList.addDataProcessor(new PropertyDataExtender(a_config["Properties"], "itemProperties", "itemIcons", "itemCompoundProperties"));
		
		var layout: ListLayout = ListLayoutManager.createLayout(a_config["ListLayout"], "ItemListLayout");
		itemList.layout = layout;

		// Not 100% happy with doing this here, but has to do for now.
		if (inventoryLists.categoryList.selectedEntry)
			layout.changeFilterFlag(inventoryLists.categoryList.selectedEntry.flag);
	}

	public function onExitButtonPress(): Void
	{
		GameDelegate.call("CloseMenu",[]);
	}

	// @API
	public function SetBarterMultipliers(a_buyMult: Number, a_sellMult: Number): Void
	{
		_buyMult = a_buyMult;
		_sellMult = a_sellMult;
		_dataExtender.barterSellMult = a_sellMult;
		_dataExtender.barterBuyMult = a_buyMult;
		bottomBar.setButtonsText("","$Exit");
	}
	
	// @override ItemMenu
	public function onShowItemsList(event: Object): Void
	{
		inventoryLists.showItemsList();

		//super.onShowItemsList(event);
	}

	// @override ItemMenu
	public function onItemHighlightChange(event: Object): Void
	{
		if (event.index != -1) {
			if (isViewingVendorItems())
				bottomBar.setButtonsText("$Buy","$Exit");
			else
				bottomBar.setButtonsText("$Sell","$Exit");
		}

		super.onItemHighlightChange(event);
	}

	// @override ItemMenu
	public function onHideItemsList(event: Object): Void
	{
		super.onHideItemsList(event);
		bottomBar.setButtonsText("","$Exit");
	}

	// @override ItemMenu
	public function onQuantityMenuSelect(event: Object): Void
	{
		var price = event.amount * itemCard.itemInfo.value;
		if (price > _vendorGold && !isViewingVendorItems()) {
			_confirmAmount = event.amount;
			GameDelegate.call("GetRawDealWarningString", [price], this, "ShowRawDealWarning");
			return;
		}
		doTransaction(event.amount);
	}

	// @API
	public function ShowRawDealWarning(a_warning: String): Void
	{
		itemCard.ShowConfirmMessage(a_warning);
	}

	public function onTransactionConfirm(): Void
	{
		doTransaction(_confirmAmount);
		_confirmAmount = 0;
	}
	
	// @override ItemMenu
	public function UpdateItemCardInfo(a_updateObj: Object): Void
	{
		if (isViewingVendorItems()) {
			a_updateObj.value = a_updateObj.value * _buyMult;
			a_updateObj.value = Math.max(a_updateObj.value, 1);
		} else {
			a_updateObj.value = a_updateObj.value * _sellMult;
		}
		a_updateObj.value = Math.floor(a_updateObj.value + 0.5);
		itemCard.itemInfo = a_updateObj;
		bottomBar.setBarterPerItemInfo(a_updateObj,_playerInfoObj);
	}

	// @override ItemMenu
	public function UpdatePlayerInfo(a_playerGold: Number, a_vendorGold: Number, a_vendorName: String, a_updateObj: Object): Void
	{
		_vendorGold = a_vendorGold;
		_playerGold = a_playerGold;
		bottomBar.setBarterInfo(a_playerGold,a_vendorGold,undefined,a_vendorName);
		_playerInfoObj = a_updateObj;
	}

	public function onQuantitySliderChange(event: Object): Void
	{
		var price = itemCard.itemInfo.value * event.value;
		if (isViewingVendorItems()) {
			price = price * -1;
		}
		bottomBar.setBarterInfo(_playerGold,_vendorGold,price);
	}

	// @override ItemMenu
	public function onItemCardSubMenuAction(event: Object): Void
	{
		super.onItemCardSubMenuAction(event);
		if (event.menu == "quantity") {
			if (event.opening) {
				onQuantitySliderChange({value:itemCard.itemInfo.count});
				return;
			}
			bottomBar.setBarterInfo(_playerGold,_vendorGold);
		}
	}
	
	
  /* PRIVATE FUNCTIONS */
	
	private function doTransaction(a_amount: Number): Void
	{
		GameDelegate.call("ItemSelect",[a_amount, itemCard.itemInfo.value, isViewingVendorItems()]);
	}
	
	private function isViewingVendorItems(): Boolean
	{
		return inventoryLists.categoryList.activeSegment == 0;
	}

}