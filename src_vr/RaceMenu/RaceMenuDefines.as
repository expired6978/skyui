class RaceMenuDefines
{
	static var ENTRY_TYPE_CAT: Number = 0;
	static var ENTRY_TYPE_RACE: Number = 1;
	static var ENTRY_TYPE_SLIDER: Number = 2;
	static var ENTRY_TYPE_WARPAINT: Number = 3;
	static var ENTRY_TYPE_BODYPAINT: Number = 4;
	static var ENTRY_TYPE_HANDPAINT: Number = 5;
	static var ENTRY_TYPE_FEETPAINT: Number = 6;
	static var ENTRY_TYPE_FACEPAINT: Number = 7;
	
	static var PRESET_ENTRY_TYPE_TEXT: Number = 0;
	static var PRESET_ENTRY_TYPE_TEXT_VALUE: Number = 1;
	static var PRESET_ENTRY_TYPE_SLIDER: Number = 2;
	static var PRESET_ENTRY_TYPE_COLOR: Number = 3;
	static var PRESET_ENTRY_TYPE_HEADER: Number = 4;
	
	static var CAT_TEXT: Number = 0;
	static var CAT_FLAG: Number = 1;
	static var CAT_STRIDE: Number = 2;
	
	static var RACE_NAME: Number = 0;
	static var RACE_DESCRIPTION: Number = 1;
	static var RACE_EQUIPSTATE: Number = 2;
	static var RACE_STRIDE: Number = 3;
		
	static var SLIDER_NAME: Number = 0;
	static var SLIDER_FILTERFLAG: Number = 1;
	static var SLIDER_CALLBACKNAME: Number = 2;
	static var SLIDER_MIN: Number = 3;
	static var SLIDER_MAX: Number = 4;
	static var SLIDER_POSITION: Number = 5;
	static var SLIDER_INTERVAL: Number = 6;
	static var SLIDER_ID: Number = 7;
	static var SLIDER_STRIDE: Number = 8;
	
	static var CATEGORY_PRIORITY_START: Number = -1000;
	static var CATEGORY_PRIORITY_STEP: Number = 25;
	
	static var CATEGORY_RACE: Number = 2;
	static var CATEGORY_BODY: Number = 4;
	static var CATEGORY_HEAD: Number = 8;
	static var CATEGORY_FACE: Number = 16;
	static var CATEGORY_EYES: Number = 32;
	static var CATEGORY_BROW: Number = 64;
	static var CATEGORY_MOUTH: Number = 128;
	static var CATEGORY_HAIR: Number = 256;
	
	static var CATEGORY_COLOR: Number = 8192;
	static var CATEGORY_WARPAINT: Number = 16384;
	static var CATEGORY_BODYPAINT: Number = 32768;
	static var CATEGORY_HANDPAINT: Number = 65536;
	static var CATEGORY_FEETPAINT: Number = 131072;
	static var CATEGORY_FACEPAINT: Number = 262144;									  
	
	static var HEADPART_MISC: Number = 0;
	static var HEADPART_FACE: Number = 1;
	static var HEADPART_EYES: Number = 2;
	static var HEADPART_HAIR: Number = 3;
	static var HEADPART_FACIALHAIR: Number = 4;
	static var HEADPART_SCAR: Number = 5;
	static var HEADPART_BROWS: Number = 6;
	
	static var PAINT_WAR: Number = 0;
	static var PAINT_BODY: Number = 1;
	static var PAINT_HAND: Number = 2;
	static var PAINT_FEET: Number = 3;
	static var PAINT_FACE: Number = 4;
	
	static var STATIC_SLIDER_SEX: Number = -1;
	static var STATIC_SLIDER_PRESET: Number = 0;
	static var STATIC_SLIDER_SKIN: Number = 1;
	static var STATIC_SLIDER_WEIGHT: Number = 2;
	static var STATIC_SLIDER_COMPLEXION: Number = 3;
	static var STATIC_SLIDER_DIRT: Number = 4;
	static var STATIC_SLIDER_WARPAINT: Number = 7;
	
	static var MAX_TINTS: Number = 15;
	
	static var TINT_TYPE_BODYPAINT: Number = 256;
	static var TINT_TYPE_HANDPAINT: Number = 257;
	static var TINT_TYPE_FEETPAINT: Number = 258;
	static var TINT_TYPE_FACEPAINT: Number = 259;
		
	static var TINT_TYPE_HAIR: Number = 128;
	static var TINT_TYPE_FRECKLES: Number = 0;
	static var TINT_TYPE_LIPS: Number = 1;
	static var TINT_TYPE_CHEEKS: Number = 2;
	static var TINT_TYPE_EYELINER: Number = 3;
	static var TINT_TYPE_UPPEREYE: Number = 4;
	static var TINT_TYPE_LOWEREYE: Number = 5;
	static var TINT_TYPE_SKINTONE: Number = 6;
	static var TINT_TYPE_WARPAINT: Number = 7;
	static var TINT_TYPE_LAUGHLINES: Number = 8;
	static var TINT_TYPE_LOWERCHEEKS: Number = 9;
	static var TINT_TYPE_NOSE: Number = 10;
	static var TINT_TYPE_CHIN: Number = 11;
	static var TINT_TYPE_NECK: Number = 12;
	static var TINT_TYPE_FOREHEAD: Number = 13;
	static var TINT_TYPE_DIRT: Number = 14;
	
	static var CUSTOM_SLIDER_OFFSET: Number = 1000;
	static var ECE_SLIDER_OFFSET: Number = 10000;
	
	static var TINT_MAP: Array = [TINT_TYPE_SKINTONE,
								  TINT_TYPE_DIRT,
								  TINT_TYPE_WARPAINT,
								  TINT_TYPE_HAIR,
								  TINT_TYPE_EYELINER,
								  TINT_TYPE_UPPEREYE,
								  TINT_TYPE_LOWEREYE,
								  TINT_TYPE_CHEEKS,
								  TINT_TYPE_LAUGHLINES,
								  TINT_TYPE_LOWERCHEEKS,
								  TINT_TYPE_NOSE,
								  TINT_TYPE_CHIN,
								  TINT_TYPE_NECK,
								  TINT_TYPE_FOREHEAD,
								  TINT_TYPE_LIPS];
	
	static var ACTORVALUE_ALCHEMY: Number = 16;
	static var ACTORVALUE_ALTERATION: Number = 18;
	static var ACTORVALUE_MARKSMAN: Number = 8;
	static var ACTORVALUE_BLOCK: Number = 9;
	static var ACTORVALUE_CONJURATION: Number = 19;
	static var ACTORVALUE_DESTRUCTION: Number = 20;
	static var ACTORVALUE_ENCHANTING: Number = 23;
	static var ACTORVALUE_HEAVYARMOR: Number = 11;
	static var ACTORVALUE_ILLUSION: Number = 21;
	static var ACTORVALUE_LIGHTARMOR: Number = 12;
	static var ACTORVALUE_LOCKPICKING: Number = 14;
	static var ACTORVALUE_ONEHANDED: Number = 6;
	static var ACTORVALUE_PICKPOCKET: Number = 13;
	static var ACTORVALUE_RESTORATION: Number = 22;
	static var ACTORVALUE_SMITHING: Number = 10;
	static var ACTORVALUE_SNEAK: Number = 15;
	static var ACTORVALUE_SPEECHCRAFT: Number = 17;
	static var ACTORVALUE_TWOHANDED: Number = 7;
	static var ACTORVALUE_NONE: Number = 255;
	
	static var ACTORVALUE_MAP: Array = [{value: ACTORVALUE_ALCHEMY, text: "$Alchemy"},
										{value: ACTORVALUE_ALTERATION, text: "$Alteration"},
										{value: ACTORVALUE_MARKSMAN, text: "$Archery"},
										{value: ACTORVALUE_BLOCK, text: "$Block"},
										{value: ACTORVALUE_CONJURATION, text: "$Conjuration"},
										{value: ACTORVALUE_DESTRUCTION, text: "$Destruction"},
										{value: ACTORVALUE_ENCHANTING, text: "$Enchanting"},
										{value: ACTORVALUE_HEAVYARMOR, text: "$Heavy Armor"},
										{value: ACTORVALUE_ILLUSION, text: "$Illusion"},
										{value: ACTORVALUE_LIGHTARMOR, text: "$Light Armor"},
										{value: ACTORVALUE_LOCKPICKING, text: "$Lockpicking"},
										{value: ACTORVALUE_ONEHANDED, text: "$One Handed"},
										{value: ACTORVALUE_PICKPOCKET, text: "$Pickpocket"},
										{value: ACTORVALUE_RESTORATION, text: "$Restoration"},
										{value: ACTORVALUE_SMITHING, text: "$Smithing"},
										{value: ACTORVALUE_SNEAK, text: "$Sneak"},
										{value: ACTORVALUE_SPEECHCRAFT, text: "$Speechcraft"},
										{value: ACTORVALUE_TWOHANDED, text: "$Two Handed"},
										{value: ACTORVALUE_NONE, text: "$None"}
										];
}