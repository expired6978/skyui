﻿import skyui.defines.Actor;
import skyui.defines.Armor;
import skyui.defines.Form;
import skyui.defines.Item;
import skyui.defines.Material;
import skyui.defines.Weapon;
import skyui.defines.Inventory;

class InventoryDataSetter extends ItemcardDataExtender
{
  /* INITIALIZATION */
  
	public function InventoryDataSetter()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @override ItemcardDataExtender
	public function processEntry(a_entryObject: Object, a_itemInfo: Object): Void
	{
		a_entryObject.baseId = a_entryObject.formId & 0x00FFFFFF;
		a_entryObject.type = a_itemInfo.type;

		a_entryObject.isEquipped = (a_entryObject.equipState > 0);
		a_entryObject.isStolen = (a_itemInfo.stolen == true);

		a_entryObject.infoValue = (a_itemInfo.value > 0) ? (Math.round(a_itemInfo.value * 100) / 100) : null;
		a_entryObject.infoWeight =(a_itemInfo.weight > 0) ? (Math.round(a_itemInfo.weight * 100) / 100) : null;
		
		a_entryObject.infoValueWeight = (a_itemInfo.weight > 0 && a_itemInfo.value > 0) ? (Math.round((a_itemInfo.value / a_itemInfo.weight) * 100) / 100) : null;

		switch (a_entryObject.formType) {
			case Form.TYPE_SCROLLITEM:
				a_entryObject.subTypeDisplay = "$Scroll";
				
				a_entryObject.duration = (a_entryObject.duration > 0) ? (Math.round(a_entryObject.duration * 100) / 100) : null;
				a_entryObject.magnitude = (a_entryObject.magnitude > 0) ? (Math.round(a_entryObject.magnitude * 100) / 100) : null;
				
				break;

			case Form.TYPE_ARMOR:
				a_entryObject.isEnchanted = (a_itemInfo.effects != "");
				a_entryObject.infoArmor = (a_itemInfo.armor > 0) ? (Math.round(a_itemInfo.armor * 100) / 100) : null;
				
				processArmorClass(a_entryObject);
				processArmorPartMask(a_entryObject);
				processMaterialKeywords(a_entryObject);
				processArmorOther(a_entryObject);
				processArmorBaseId(a_entryObject);
				break;

			case Form.TYPE_BOOK:
				processBookType(a_entryObject);
				break;

			case Form.TYPE_INGREDIENT:
				a_entryObject.subTypeDisplay = "$Ingredient";
				break;

			case Form.TYPE_LIGHT:
				a_entryObject.subTypeDisplay = "$Torch";
				break;

			case Form.TYPE_MISC:
				processMiscType(a_entryObject);
				processMiscBaseId(a_entryObject);
				break;

			case Form.TYPE_WEAPON:
				a_entryObject.isEnchanted = (a_itemInfo.effects != "");
				a_entryObject.isPoisoned = (a_itemInfo.poisoned == true); 
				a_entryObject.infoDamage = (a_itemInfo.damage > 0) ? (Math.round(a_itemInfo.damage * 100) / 100) : null;
				
				processWeaponType(a_entryObject);
				processMaterialKeywords(a_entryObject);
				processWeaponBaseId(a_entryObject);
				break;

			case Form.TYPE_AMMO:
				a_entryObject.isEnchanted = (a_itemInfo.effects != "");
				a_entryObject.infoDamage = (a_itemInfo.damage > 0) ? (Math.round(a_itemInfo.damage * 100) / 100) : null;
				
				processAmmoType(a_entryObject);
				processMaterialKeywords(a_entryObject);
				processAmmoBaseId(a_entryObject);
				break;

			case Form.TYPE_KEY:
				processKeyType(a_entryObject);
				break;

			case Form.TYPE_POTION:
				a_entryObject.duration = (a_entryObject.duration > 0) ? (Math.round(a_entryObject.duration * 100) / 100) : null;
				a_entryObject.magnitude = (a_entryObject.magnitude > 0) ? (Math.round(a_entryObject.magnitude * 100) / 100) : null;
			
				processPotionType(a_entryObject);
				break;

			case Form.TYPE_SOULGEM:
				processSoulGemType(a_entryObject);
				processSoulGemStatus(a_entryObject);
				processSoulGemBaseId(a_entryObject);
				break;
		}
	}


  /* PRIVATE FUNCTIONS */

	private function processArmorClass(a_entryObject: Object): Void
	{
		if (a_entryObject.weightClass == Armor.WEIGHT_NONE)
			a_entryObject.weightClass = null;
			
		a_entryObject.weightClassDisplay = "$Other";

		switch (a_entryObject.weightClass) {
			case Armor.WEIGHT_LIGHT:
				a_entryObject.weightClassDisplay = "$Light";
				break;

			case Armor.WEIGHT_HEAVY:
				a_entryObject.weightClassDisplay = "$Heavy";
				break;

			default:
				if (a_entryObject.keywords == undefined)
					break;

				if (a_entryObject.keywords["VendorItemClothing"] != undefined) {
					a_entryObject.weightClass = Armor.WEIGHT_CLOTHING;
					a_entryObject.weightClassDisplay = "$Clothing";
				} else if (a_entryObject.keywords["VendorItemJewelry"] != undefined) {
					a_entryObject.weightClass = Armor.WEIGHT_JEWELRY;
					a_entryObject.weightClassDisplay = "$Jewelry";
				}	 
		}
	}

	private function processMaterialKeywords(a_entryObject: Object): Void
	{
		a_entryObject.material = null;
		a_entryObject.materialDisplay = "$Other";

		if (a_entryObject.keywords == undefined)
			return;

		if (a_entryObject.keywords["ArmorMaterialDaedric"] != undefined ||
			a_entryObject.keywords["WeapMaterialDaedric"] != undefined) {
			a_entryObject.material = Material.DAEDRIC;
			a_entryObject.materialDisplay = "$Daedric";
		
		} else if (a_entryObject.keywords["ArmorMaterialDragonplate"] != undefined) {
			a_entryObject.material = Material.DRAGONPLATE;
			a_entryObject.materialDisplay = "$Dragonplate";
		
		} else if (a_entryObject.keywords["ArmorMaterialDragonscale"] != undefined) {
			a_entryObject.material = Material.DRAGONSCALE;
			a_entryObject.materialDisplay = "$Dragonscale";
		
		} else if (a_entryObject.keywords["ArmorMaterialDwarven"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialDwarven"] != undefined) {
			a_entryObject.material = Material.DWARVEN;
			a_entryObject.materialDisplay = "$Dwarven";
		
		} else if (a_entryObject.keywords["ArmorMaterialEbony"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialEbony"] != undefined) {
			a_entryObject.material = Material.EBONY;
			a_entryObject.materialDisplay = "$Ebony";
		
		} else if (a_entryObject.keywords["ArmorMaterialElven"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialElven"] != undefined) {
			a_entryObject.material = Material.ELVEN;
			a_entryObject.materialDisplay = "$Elven";
		
		} else if (a_entryObject.keywords["ArmorMaterialElvenGilded"] != undefined) {
			a_entryObject.material = Material.ELVENGILDED;
			a_entryObject.materialDisplay = "$Elven Gilded";
		
		} else if (a_entryObject.keywords["ArmorMaterialGlass"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialGlass"] != undefined) {
			a_entryObject.material = Material.GLASS;
			a_entryObject.materialDisplay = "$Glass";
		
		} else if (a_entryObject.keywords["ArmorMaterialHide"] != undefined) {
			a_entryObject.material = Material.HIDE;
			a_entryObject.materialDisplay = "$Hide";
		
		} else if (a_entryObject.keywords["ArmorMaterialImperialHeavy"] != undefined ||
		 		   a_entryObject.keywords["ArmorMaterialImperialLight"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialImperial"] != undefined) {
			a_entryObject.material = Material.IMPERIAL;
			a_entryObject.materialDisplay = "$Imperial";
		
		} else if (a_entryObject.keywords["ArmorMaterialImperialStudded"] != undefined) {
			a_entryObject.material = Material.IMPERIALSTUDDED;
			a_entryObject.materialDisplay = "$Studded";
		
		} else if (a_entryObject.keywords["ArmorMaterialIron"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialIron"] != undefined) {
			a_entryObject.material = Material.IRON;
			a_entryObject.materialDisplay = "$Iron";
		
		} else if (a_entryObject.keywords["ArmorMaterialIronBanded"] != undefined) {
			a_entryObject.material = Material.IRONBANDED;
			a_entryObject.materialDisplay = "$Iron Banded";
		
		// Must be above leather, vampire armor has 2 material keywords
		} else if (a_entryObject.keywords["DLC1ArmorMaterialVampire"] != undefined) {
			a_entryObject.material = Material.VAMPIRE;
			a_entryObject.materialDisplay = "$Vampire";

		} else if (a_entryObject.keywords["ArmorMaterialLeather"] != undefined) {
			a_entryObject.material = Material.LEATHER;
			a_entryObject.materialDisplay = "$Leather";
		
		} else if (a_entryObject.keywords["ArmorMaterialOrcish"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialOrcish"] != undefined) {
			a_entryObject.material = Material.ORCISH;
			a_entryObject.materialDisplay = "$Orcish";
		
		} else if (a_entryObject.keywords["ArmorMaterialScaled"] != undefined) {
			a_entryObject.material = Material.SCALED;
			a_entryObject.materialDisplay = "$Scaled";
		
		} else if (a_entryObject.keywords["ArmorMaterialSteel"] != undefined ||
		 		   a_entryObject.keywords["WeapMaterialSteel"] != undefined) {
			a_entryObject.material = Material.STEEL;
			a_entryObject.materialDisplay = "$Steel";
		
		} else if (a_entryObject.keywords["ArmorMaterialSteelPlate"] != undefined) {
			a_entryObject.material = Material.STEELPLATE;
			a_entryObject.materialDisplay = "$Steel Plate";
		
		} else if (a_entryObject.keywords["ArmorMaterialStormcloak"] != undefined) {
			a_entryObject.material = Material.STORMCLOAK;
			a_entryObject.materialDisplay = "$Stormcloak";
		
		} else if (a_entryObject.keywords["ArmorMaterialStudded"] != undefined) {
			a_entryObject.material = Material.STUDDED;
			a_entryObject.materialDisplay = "$Studded";
		
		} else if (a_entryObject.keywords["DLC1ArmorMaterialDawnguard"] != undefined) {
			a_entryObject.material = Material.DAWNGUARD;
			a_entryObject.materialDisplay = "$Dawnguard";
		
		} else if (a_entryObject.keywords["DLC1ArmorMaterialFalmerHardened"] != undefined ||
					a_entryObject.keywords["DLC1ArmorMaterialFalmerHeavy"] != undefined) {
			a_entryObject.material = Material.FALMERHARDENED;
			a_entryObject.materialDisplay = "$Falmer Hardened";
		
		} else if (a_entryObject.keywords["DLC1ArmorMaterialHunter"] != undefined) {
			a_entryObject.material = Material.HUNTER;
			a_entryObject.materialDisplay = "$Hunter";
		
		} else if (a_entryObject.keywords["DLC1LD_CraftingMaterialAetherium"] != undefined) {
			a_entryObject.material = Material.AETHERIUM;
			a_entryObject.materialDisplay = "$Aetherium";
		
		} else if (a_entryObject.keywords["DLC1WeapMaterialDragonbone"] != undefined) {
			a_entryObject.material = Material.DRAGONBONE;
			a_entryObject.materialDisplay = "$Dragonbone";
		
		} else if (a_entryObject.keywords["DLC2ArmorMaterialBonemoldHeavy"] != undefined ||
		 		   a_entryObject.keywords["DLC2ArmorMaterialBonemoldLight"] != undefined) {
			a_entryObject.material = Material.BONEMOLD;
			a_entryObject.materialDisplay = "$Bonemold";

		} else if (a_entryObject.keywords["DLC2ArmorMaterialChitinHeavy"] != undefined ||
		 		   a_entryObject.keywords["DLC2ArmorMaterialChitinLight"] != undefined) {
			a_entryObject.material = Material.CHITIN;
			a_entryObject.materialDisplay = "$Chitin";
		
		} else if (a_entryObject.keywords["DLC2ArmorMaterialMoragTong"] != undefined) {
			a_entryObject.material = Material.MORAGTONG;
			a_entryObject.materialDisplay = "$Morag Tong";
		
		} else if (a_entryObject.keywords["DLC2ArmorMaterialNordicHeavy"] != undefined ||
		 		   a_entryObject.keywords["DLC2ArmorMaterialNordicLight"] != undefined ||
		 		   a_entryObject.keywords["DLC2WeapMaterialNordic"] != undefined) {
			a_entryObject.material = Material.NORDIC;
			a_entryObject.materialDisplay = "$Nordic";
		
		} else if (a_entryObject.keywords["DLC2ArmorMaterialStalhrimHeavy"] != undefined ||
		 		   a_entryObject.keywords["DLC2ArmorMaterialStalhrimLight"] != undefined ||
		 		   a_entryObject.keywords["DLC2WeapMaterialStalhrim"] != undefined) {
			a_entryObject.material = Material.STALHRIM;
			a_entryObject.materialDisplay = "$Stalhrim";
			if (a_entryObject.keywords["DLC2dunHaknirArmor"] != undefined) {
				a_entryObject.material = Material.DEATHBRAND;
				a_entryObject.materialDisplay = "$Deathbrand";
			}
		
		} else if (a_entryObject.keywords["WeapMaterialDraugr"] != undefined) {
			a_entryObject.material = Material.DRAUGR;
			a_entryObject.materialDisplay = "$Draugr";
		
		} else if (a_entryObject.keywords["WeapMaterialDraugrHoned"] != undefined) {
			a_entryObject.material = Material.DRAUGRHONED;
			a_entryObject.materialDisplay = "$Draugr Honed";
		
		} else if (a_entryObject.keywords["WeapMaterialFalmer"] != undefined) {
			a_entryObject.material = Material.FALMER;
			a_entryObject.materialDisplay = "$Falmer";
		
		} else if (a_entryObject.keywords["WeapMaterialFalmerHoned"] != undefined) {
			a_entryObject.material = Material.FALMERHONED;
			a_entryObject.materialDisplay = "$Falmer Honed";
		
		} else if (a_entryObject.keywords["WeapMaterialSilver"] != undefined) {
			a_entryObject.material = Material.SILVER;
			a_entryObject.materialDisplay = "$Silver";
		
		} else if (a_entryObject.keywords["WeapMaterialWood"] != undefined) {
			a_entryObject.material = Material.WOOD;
			a_entryObject.materialDisplay = "$Wood";
		}
	}

	private function processWeaponType(a_entryObject: Object): Void
	{
		a_entryObject.subType = null;
		a_entryObject.subTypeDisplay = "$Weapon";

		switch (a_entryObject.weaponType) {
			case Weapon.ANIM_HANDTOHANDMELEE:
			case Weapon.ANIM_H2H:
				a_entryObject.subType = Weapon.TYPE_MELEE;
				a_entryObject.subTypeDisplay = "$Melee";
				break;

			case Weapon.ANIM_ONEHANDSWORD:
			case Weapon.ANIM_1HS:
				a_entryObject.subType = Weapon.TYPE_SWORD;
				a_entryObject.subTypeDisplay = "$Sword";
				break;

			case Weapon.ANIM_ONEHANDDAGGER:
			case Weapon.ANIM_1HD:
				a_entryObject.subType = Weapon.TYPE_DAGGER;
				a_entryObject.subTypeDisplay = "$Dagger";
				break;

			case Weapon.ANIM_ONEHANDAXE:
			case Weapon.ANIM_1HA:
				a_entryObject.subType = Weapon.TYPE_WARAXE;
				a_entryObject.subTypeDisplay = "$War Axe";
				break;

			case Weapon.ANIM_ONEHANDMACE:
			case Weapon.ANIM_1HM:
				a_entryObject.subType = Weapon.TYPE_MACE;
				a_entryObject.subTypeDisplay = "$Mace";
				break;

			case Weapon.ANIM_TWOHANDSWORD:
			case Weapon.ANIM_2HS:
				a_entryObject.subType = Weapon.TYPE_GREATSWORD;
				a_entryObject.subTypeDisplay = "$Greatsword";
				break;

			case Weapon.ANIM_TWOHANDAXE:
			case Weapon.ANIM_2HA:
				a_entryObject.subType = Weapon.TYPE_BATTLEAXE;
				a_entryObject.subTypeDisplay = "$Battleaxe";

				if (a_entryObject.keywords != undefined && a_entryObject.keywords["WeapTypeWarhammer"] != undefined) {
					a_entryObject.subType = Weapon.TYPE_WARHAMMER;
					a_entryObject.subTypeDisplay = "$Warhammer";
				}
				break;

			case Weapon.ANIM_BOW:
			case Weapon.ANIM_BOW2:
				a_entryObject.subType = Weapon.TYPE_BOW;
				a_entryObject.subTypeDisplay = "$Bow";
				break;

			case Weapon.ANIM_STAFF:
			case Weapon.ANIM_STAFF2:
				a_entryObject.subType = Weapon.TYPE_STAFF;
				a_entryObject.subTypeDisplay = "$Staff";
				break;

			case Weapon.ANIM_CROSSBOW:
			case Weapon.ANIM_CBOW:
				a_entryObject.subType = Weapon.TYPE_CROSSBOW;
				a_entryObject.subTypeDisplay = "$Crossbow";
				break;
		}
	}

	private function processWeaponBaseId(a_entryObject: Object): Void
	{
		switch (a_entryObject.baseId) {
			case Form.BASEID_WEAPPICKAXE:
			case Form.BASEID_SSDROCKSPLINTERPICKAXE:
			case Form.BASEID_DUNVOLUNRUUDPICKAXE:
				a_entryObject.subType = Weapon.TYPE_PICKAXE;
				a_entryObject.subTypeDisplay = "$Pickaxe";
				break;
			case Form.BASEID_AXE01:
			case Form.BASEID_DUNHALTEDSTREAMPOACHERSAXE:
				a_entryObject.subType = Weapon.TYPE_WOODAXE;
				a_entryObject.subTypeDisplay = "$Wood Axe";
				break;
		}
	}

	private function processArmorPartMask(a_entryObject: Object): Void
	{
		if (a_entryObject.partMask == undefined)
			return;

		// Sets subType as the most important bitmask index.
		for (var i = 0; i < Armor.PARTMASK_PRECEDENCE.length; i++) {
			if (a_entryObject.partMask & Armor.PARTMASK_PRECEDENCE[i]) {
				a_entryObject.mainPartMask = Armor.PARTMASK_PRECEDENCE[i];
				break;
			}
		}

		if (a_entryObject.mainPartMask == undefined)
			return;

		switch (a_entryObject.mainPartMask) {
			case Armor.PARTMASK_HEAD:
				a_entryObject.subType = Armor.EQUIP_HEAD;
				a_entryObject.subTypeDisplay = "$Head";
				break;
			case Armor.PARTMASK_HAIR:
				a_entryObject.subType = Armor.EQUIP_HAIR;
				a_entryObject.subTypeDisplay = "$Head";
				break;
			case Armor.PARTMASK_LONGHAIR:
				a_entryObject.subType = Armor.EQUIP_LONGHAIR;
				a_entryObject.subTypeDisplay = "$Head";
				break;

			case Armor.PARTMASK_BODY:
				a_entryObject.subType = Armor.EQUIP_BODY;
				a_entryObject.subTypeDisplay = "$Body";
				break;

			case Armor.PARTMASK_HANDS:
				a_entryObject.subType = Armor.EQUIP_HANDS;
				a_entryObject.subTypeDisplay = "$Hands";
				break;

			case Armor.PARTMASK_FOREARMS:
				a_entryObject.subType = Armor.EQUIP_FOREARMS;
				a_entryObject.subTypeDisplay = "$Forearms";
				break;

			case Armor.PARTMASK_AMULET:
				a_entryObject.subType = Armor.EQUIP_AMULET;
				a_entryObject.subTypeDisplay = "$Amulet";
				break;

			case Armor.PARTMASK_RING:
				a_entryObject.subType = Armor.EQUIP_RING;
				a_entryObject.subTypeDisplay = "$Ring";
				break;

			case Armor.PARTMASK_FEET:
				a_entryObject.subType = Armor.EQUIP_FEET;
				a_entryObject.subTypeDisplay = "$Feet";
				break;

			case Armor.PARTMASK_CALVES:
				a_entryObject.subType = Armor.EQUIP_CALVES;
				a_entryObject.subTypeDisplay = "$Calves";
				break;

			case Armor.PARTMASK_SHIELD:
				a_entryObject.subType = Armor.EQUIP_SHIELD;
				a_entryObject.subTypeDisplay = "$Shield";
				break;

			case Armor.PARTMASK_CIRCLET:
				a_entryObject.subType = Armor.EQUIP_CIRCLET;
				a_entryObject.subTypeDisplay = "$Circlet";
				break;

			case Armor.PARTMASK_EARS:
				a_entryObject.subType = Armor.EQUIP_EARS;
				a_entryObject.subTypeDisplay = "$Ears";
				break;

			case Armor.PARTMASK_TAIL:
				a_entryObject.subType = Armor.EQUIP_TAIL;
				a_entryObject.subTypeDisplay = "$Tail";
				break;

			default:
				a_entryObject.subType = a_entryObject.mainPartMask;
				break;
		}
	}

	private function processArmorOther(a_entryObject): Void
	{
		if (a_entryObject.weightClass != null)
			return;

		switch (a_entryObject.mainPartMask) {
			case Armor.PARTMASK_HEAD:
			case Armor.PARTMASK_HAIR:
			case Armor.PARTMASK_LONGHAIR:
			case Armor.PARTMASK_BODY:
			case Armor.PARTMASK_HANDS:
			case Armor.PARTMASK_FOREARMS:
			case Armor.PARTMASK_FEET:
			case Armor.PARTMASK_CALVES:
			case Armor.PARTMASK_SHIELD:
			case Armor.PARTMASK_TAIL:
				a_entryObject.weightClass = Armor.WEIGHT_CLOTHING;
				a_entryObject.weightClassDisplay = "$Clothing";
				break;

			case Armor.PARTMASK_AMULET:
			case Armor.PARTMASK_RING:
			case Armor.PARTMASK_CIRCLET:
			case Armor.PARTMASK_EARS:
				a_entryObject.weightClass = Armor.WEIGHT_JEWELRY;
				a_entryObject.weightClassDisplay = "$Jewelry";
				break;
		}
	}

	private function processArmorBaseId(a_entryObject: Object): Void
	{
		switch (a_entryObject.baseId) {
			case Form.BASEID_CLOTHESWEDDINGWREATH:
				a_entryObject.weightClass = Armor.WEIGHT_JEWELRY;
				a_entryObject.weightClassDisplay = "$Jewelry";
				break
			case Form.BASEID_DLC1CLOTHESVAMPIRELORDARMOR:
				a_entryObject.subType = Armor.EQUIP_BODY;
				a_entryObject.subTypeDisplay = "$Body";
				break;
		}
	}

	private function processBookType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.OTHER;
		a_entryObject.subTypeDisplay = "$Book";
		
		if (a_entryObject.bookType == Item.BOOKTYPE_NOTE) {
			a_entryObject.subType = Item.BOOK_NOTE;
			a_entryObject.subTypeDisplay = "$Note";
		}

		if (a_entryObject.keywords == undefined)
			return;

		if (a_entryObject.keywords["VendorItemRecipe"] != undefined) {
			a_entryObject.subType = Item.BOOK_RECIPE;
			a_entryObject.subTypeDisplay = "$Recipe";
		} else if (a_entryObject.keywords["VendorItemSpellTome"] != undefined) {
			a_entryObject.subType = Item.BOOK_SPELLTOME;
			a_entryObject.subTypeDisplay = "$Spell Tome";
		}
	}

	private function processAmmoType(a_entryObject: Object): Void
	{
		if ((a_entryObject.flags & Weapon.AMMOFLAG_NONBOLT) != 0) {
			a_entryObject.subType = Weapon.AMMO_ARROW;
			a_entryObject.subTypeDisplay = "$Arrow";
		} else {
			a_entryObject.subType = Weapon.AMMO_BOLT;
			a_entryObject.subTypeDisplay = "$Bolt";
		}
	}

	private function processAmmoBaseId(a_entryObject: Object): Void
	{
		switch (a_entryObject.baseId) {
			case Form.BASEID_DAEDRICARROW:
				a_entryObject.material = Material.DAEDRIC;
				a_entryObject.materialDisplay = "$Daedric";
				break;
			case Form.BASEID_EBONYARROW:
				a_entryObject.material = Material.EBONY;
				a_entryObject.materialDisplay = "$Ebony";
				break;
			case Form.BASEID_GLASSARROW:
				a_entryObject.material = Material.GLASS;
				a_entryObject.materialDisplay = "$Glass";
				break;
			case Form.BASEID_ELVENARROW:
			case Form.BASEID_DLC1ELVENARROWBLESSED:
			case Form.BASEID_DLC1ELVENARROWBLOOD:
				a_entryObject.material = Material.ELVEN;
				a_entryObject.materialDisplay = "$Elven";
				break;
			case Form.BASEID_DWARVENARROW:
			case Form.BASEID_DWARVENSPHEREARROW:
			case Form.BASEID_DWARVENSPHEREBOLT01:
			case Form.BASEID_DWARVENSPHEREBOLT02:
			case Form.BASEID_DLC2DWARVENBALLISTABOLT:
				a_entryObject.material = Material.DWARVEN;
				a_entryObject.materialDisplay = "$Dwarven";
				break;
			case Form.BASEID_ORCISHARROW:
				a_entryObject.material = Material.ORCISH;
				a_entryObject.materialDisplay = "$Orcish";
				break;
			case Form.BASEID_NORDHEROARROW:
				a_entryObject.material = Material.NORDIC;
				a_entryObject.materialDisplay = "$Nordic";
				break;
			case Form.BASEID_DRAUGRARROW:
				a_entryObject.material = Material.DRAUGR;
				a_entryObject.materialDisplay = "$Draugr";
				break;
			case Form.BASEID_FALMERARROW:
				a_entryObject.material = Material.FALMER;
				a_entryObject.materialDisplay = "$Falmer";
				break;
			case Form.BASEID_STEELARROW:
			case Form.BASEID_MQ101STEELARROW:
				a_entryObject.material = Material.STEEL;
				a_entryObject.materialDisplay = "$Steel";
				break;
			case Form.BASEID_IRONARROW:
			case Form.BASEID_CWARROW:
			case Form.BASEID_CWARROWSHORT:
			case Form.BASEID_TRAPDART:
			case Form.BASEID_DUNARCHERPRATICEARROW:
			case Form.BASEID_DUNGEIRMUNDSIGDISARROWSILLUSION:
			case Form.BASEID_FOLLOWERIRONARROW:
			case Form.BASEID_TESTDLC1BOLT:
				a_entryObject.material = Material.IRON;
				a_entryObject.materialDisplay = "$Iron";
				break;
			case Form.BASEID_FORSWORNARROW:
				a_entryObject.material = Material.HIDE;
				a_entryObject.materialDisplay = "$Forsworn";
				break;
			case Form.BASEID_DLC2RIEKLINGSPEARTHROWN:
				a_entryObject.material = Material.WOOD;
				a_entryObject.materialDisplay = "$Wood";
				a_entryObject.subTypeDisplay = "$Spear";
				break;

		}
	}

	private function processKeyType(a_entryObject: Object): Void
	{
		a_entryObject.subTypeDisplay = "$Key";

		if (a_entryObject.infoValue <= 0)
			a_entryObject.infoValue = null;

		if (a_entryObject.infoValue <= 0)
			a_entryObject.infoValue = null;
	}

	private function processPotionType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.POTION_POTION;
		a_entryObject.subTypeDisplay = "$Potion";

		if ((a_entryObject.flags & Item.ALCHFLAG_FOOD) != 0) {
			a_entryObject.subType = Item.POTION_FOOD;
			a_entryObject.subTypeDisplay = "$Food";

			// SKSE >= 1.6.6
			if (a_entryObject.useSound.formId != undefined && a_entryObject.useSound.formId == Form.FORMID_ITMPotionUse) {
				a_entryObject.subType = Item.POTION_DRINK;
				a_entryObject.subTypeDisplay = "$Drink";
			}
			
		} else if ((a_entryObject.flags & Item.ALCHFLAG_POISON) != 0) {
			a_entryObject.subType = Item.POTION_POISON;
			a_entryObject.subTypeDisplay = "$Poison";
		} else {
			switch (a_entryObject.actorValue) {
				case Actor.AV_HEALTH:
					a_entryObject.subType = Item.POTION_HEALTH;
					a_entryObject.subTypeDisplay = "$Health";
					break;
				case Actor.AV_MAGICKA:
					a_entryObject.subType = Item.POTION_MAGICKA;
					a_entryObject.subTypeDisplay = "$Magicka";
					break;
				case Actor.AV_STAMINA:
					a_entryObject.subType = Item.POTION_STAMINA;
					a_entryObject.subTypeDisplay = "$Stamina";
					break;

				case Actor.AV_HEALRATE:
					a_entryObject.subType = Item.POTION_HEALRATE;
					a_entryObject.subTypeDisplay = "$Health";
					break;
				case Actor.AV_MAGICKARATE:
					a_entryObject.subType = Item.POTION_MAGICKARATE;
					a_entryObject.subTypeDisplay = "$Magicka";
					break;
				case Actor.AV_STAMINARATE:
					a_entryObject.subType = Item.POTION_STAMINARATE;
					a_entryObject.subTypeDisplay = "$Stamina";
					break;

				case Actor.AV_HEALRATEMULT:
					a_entryObject.subType = Item.POTION_HEALRATEMULT;
					a_entryObject.subTypeDisplay = "$Health";
					break;
				case Actor.AV_MAGICKARATEMULT:
					a_entryObject.subType = Item.POTION_MAGICKARATEMULT;
					a_entryObject.subTypeDisplay = "$Magicka";
					break;
				case Actor.AV_STAMINARATEMULT:
					a_entryObject.subType = Item.POTION_STAMINARATEMULT;
					a_entryObject.subTypeDisplay = "$Stamina";
					break;

				case Actor.AV_FIRERESIST:
					a_entryObject.subType = Item.POTION_FIRERESIST;
					break;

				case Actor.AV_ELECTRICRESIST:
					a_entryObject.subType = Item.POTION_ELECTRICRESIST;
					break;

				case Actor.AV_FROSTRESIST:
					a_entryObject.subType = Item.POTION_FROSTRESIST;
					break;
			}
		}
	}

	private function processSoulGemType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.OTHER;
		a_entryObject.subTypeDisplay = "$Soul Gem";

		// Ignores soulgems that have a size of None
		if (a_entryObject.gemSize != undefined && a_entryObject.gemSize != Item.SOULGEM_NONE)
			a_entryObject.subType = a_entryObject.gemSize;
	}

	private function processSoulGemStatus(a_entryObject: Object): Void
	{
		if (a_entryObject.gemSize == undefined || a_entryObject.soulSize == undefined || a_entryObject.soulSize == Item.SOULGEM_NONE)
			a_entryObject.status = Item.SOULGEMSTATUS_EMPTY;
		else if (a_entryObject.soulSize >= a_entryObject.gemSize)
			a_entryObject.status = Item.SOULGEMSTATUS_FULL;
		else
			a_entryObject.status = Item.SOULGEMSTATUS_PARTIAL;
	}

	private function processSoulGemBaseId(a_entryObject: Object): Void
	{
		switch (a_entryObject.baseId) {
			case Form.BASEID_DA01SOULGEMBLACKSTAR:
			case Form.BASEID_DA01SOULGEMAZURASSTAR:
				a_entryObject.subType = Item.SOULGEM_AZURA;
				break;
		}
	}

	private function processMiscType(a_entryObject: Object): Void
	{
		a_entryObject.subType = Item.OTHER;
		a_entryObject.subTypeDisplay = "$Misc";

		if (a_entryObject.keywords == undefined)
			return;

		if (a_entryObject.keywords["BYOHAdoptionClothesKeyword"] != undefined) {
			a_entryObject.subType = Item.MISC_CHILDRENSCLOTHES;
			a_entryObject.subTypeDisplay = "$Clothing";

		} else if (a_entryObject.keywords["BYOHAdoptionToyKeyword"] != undefined) {
			a_entryObject.subType = Item.MISC_TOY;
			a_entryObject.subTypeDisplay = "$Toy";

		
		} else if (a_entryObject.keywords["BYOHHouseCraftingCategoryWeaponRacks"] != undefined ||
					a_entryObject.keywords["BYOHHouseCraftingCategoryShelf"] != undefined || 
					a_entryObject.keywords["BYOHHouseCraftingCategoryFurniture"] != undefined ||
					a_entryObject.keywords["BYOHHouseCraftingCategoryExterior"] != undefined || 
					a_entryObject.keywords["BYOHHouseCraftingCategoryContainers"] != undefined ||
					a_entryObject.keywords["BYOHHouseCraftingCategoryBuilding"] != undefined || 
					a_entryObject.keywords["BYOHHouseCraftingCategorySmithing"] != undefined) {
			a_entryObject.subType = Item.MISC_HOUSEPART;
			a_entryObject.subTypeDisplay = "$House Part";
		

		} else if (a_entryObject.keywords["VendorItemDaedricArtifact"] != undefined) {
			a_entryObject.subType = Item.MISC_ARTIFACT;
			a_entryObject.subTypeDisplay = "$Artifact";

		} else if (a_entryObject.keywords["VendorItemGem"] != undefined) {
			a_entryObject.subType = Item.MISC_GEM;
			a_entryObject.subTypeDisplay = "$Gem";

		} else if (a_entryObject.keywords["VendorItemAnimalHide"] != undefined) {
			a_entryObject.subType = Item.MISC_HIDE;
			a_entryObject.subTypeDisplay = "$Hide";

		} else if (a_entryObject.keywords["VendorItemTool"] != undefined) {
			a_entryObject.subType = Item.MISC_TOOL;
			a_entryObject.subTypeDisplay = "$Tool";

		} else if (a_entryObject.keywords["VendorItemAnimalPart"] != undefined) {
			a_entryObject.subType = Item.MISC_REMAINS;
			a_entryObject.subTypeDisplay = "$Remains";

		} else if (a_entryObject.keywords["VendorItemOreIngot"] != undefined) {
			a_entryObject.subType = Item.MISC_INGOT;
			a_entryObject.subTypeDisplay = "$Ingot";

		} else if (a_entryObject.keywords["VendorItemClutter"] != undefined) {
			a_entryObject.subType = Item.MISC_CLUTTER;
			a_entryObject.subTypeDisplay = "$Clutter";

		} else if (a_entryObject.keywords["VendorItemFirewood"] != undefined) {
			a_entryObject.subType = Item.MISC_FIREWOOD;
			a_entryObject.subTypeDisplay = "$Firewood";
		}
	}

	private function processMiscBaseId(a_entryObject: Object): Void
	{
		switch (a_entryObject.baseId) {
			case Form.BASEID_GEMAMETHYSTFLAWLESS:
				a_entryObject.subType = Item.MISC_GEM;
				a_entryObject.subTypeDisplay = "$Gem";
				break;

			case Form.BASEID_RUBYDRAGONCLAW:
			case Form.BASEID_IVORYDRAGONCLAW:
			case Form.BASEID_GLASSCLAW:
			case Form.BASEID_EBONYCLAW:
			case Form.BASEID_EMERALDDRAGONCLAW:
			case Form.BASEID_DIAMONDCLAW:
			case Form.BASEID_IRONCLAW:
			case Form.BASEID_CORALDRAGONCLAW:
			case Form.BASEID_E3GOLDENCLAW:
			case Form.BASEID_SAPPHIREDRAGONCLAW:
			case Form.BASEID_MS13GOLDENCLAW:
				a_entryObject.subTypeDisplay = "$Claw";
				a_entryObject.subType = Item.MISC_DRAGONCLAW;
				break;

			case Form.BASEID_LOCKPICK:
				a_entryObject.subType = Item.MISC_LOCKPICK;
				a_entryObject.subTypeDisplay = "$Lockpick";
				break;

			case Form.BASEID_GOLD001:
				a_entryObject.subType = Item.MISC_GOLD;
				a_entryObject.subTypeDisplay = "$Gold";
				break;

			case Form.BASEID_LEATHER01:
				a_entryObject.subTypeDisplay = "$Leather";
				a_entryObject.subType = Item.MISC_LEATHER;
				break;
			case Form.BASEID_LEATHERSTRIPS:
				a_entryObject.subTypeDisplay = "$Strips";
				a_entryObject.subType = Item.MISC_LEATHERSTRIPS;
				break;
		}
	}
}