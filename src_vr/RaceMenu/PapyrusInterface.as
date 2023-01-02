/* PAPYRUS INTERFACE */
import RaceMenu;

class PapyrusInterface
{
	static var _instance;
	
	public function PapyrusInterface()
	{
		
	}
	
	static public function initialize(parent: Object)
	{
		if (_instance == undefined)
			_instance = new PapyrusInterface();
		
		parent.RSM_AddSliders = _instance.RSM_AddSliders;
		parent.RSM_SetSliderParameters = _instance.RSM_SetSliderParameters;
		parent.RSM_SetSliderParametersEx = _instance.RSM_SetSliderParametersEx;
		parent.RSM_AddWarpaints = _instance.RSM_AddWarpaints;
		parent.RSM_AddBodyPaints = _instance.RSM_AddBodyPaints;
		parent.RSM_AddHandPaints = _instance.RSM_AddHandPaints;
		parent.RSM_AddFeetPaints = _instance.RSM_AddFeetPaints;
		parent.RSM_AddFacePaints = _instance.RSM_AddFacePaints;
		parent.RSM_AddTints = _instance.RSM_AddTints;
		parent.RSM_AddBodyTints = _instance.RSM_AddBodyTints;
		parent.RSM_AddHandTints = _instance.RSM_AddHandTints;
		parent.RSM_AddFeetTints = _instance.RSM_AddFeetTints;
		parent.RSM_AddFaceTints = _instance.RSM_AddFaceTints;
		parent.RSM_ExtendRace = _instance.RSM_ExtendRace;
		parent.RSM_SaveClipboard = _instance.RSM_SaveClipboard;
		parent.RSM_LoadClipboard = _instance.RSM_LoadClipboard;
		parent.RSM_ToggleLoader = _instance.RSM_ToggleLoader;
		parent.RSM_SetPresetSlot = _instance.RSM_SetPresetSlot;
		parent.RSM_AddCategories = _instance.RSM_AddCategories;
	}
	
	public function RSM_AddSliders()
	{
		for(var i = 0; i < arguments.length; i++)
		{
			var sliderParams: Array = arguments[i].split(";;");
			if(sliderParams[0] != "") {
				var newSliderID = this["customSliders"].length + RaceMenuDefines.CUSTOM_SLIDER_OFFSET;
				
				var textFilters = undefined;
				var priority = undefined;
				if(sliderParams.length >= 8)
					textFilters = sliderParams[7].split("|");
				if(sliderParams.length >= 9)
					priority = Number(sliderParams[8]);
				
				var sliderObject: Object = {type: RaceMenuDefines.ENTRY_TYPE_SLIDER, text: sliderParams[0], filterFlag: Number(sliderParams[1]), textFilters: textFilters, callbackName: sliderParams[2], sliderMin: Number(sliderParams[3]), sliderMax: Number(sliderParams[4]), sliderID: newSliderID, position: Number(sliderParams[6]), interval: Number(sliderParams[5]), priority: priority, enabled: true};
				this["customSliders"].push(sliderObject);
				this["itemList"].entryList.push(sliderObject);
				this["itemList"].requestInvalidate();
			}
		}
	}
	
	public function RSM_AddCategories()
	{
		for(var i = 0; i < arguments.length; i++)
		{
			var categoryParams: Array = arguments[i].split(";;");
			if(categoryParams[0] != "") {
				var categoryObject: Object = {type: RaceMenuDefines.ENTRY_TYPE_CAT, bDontHide: false, filterFlag: 1, text: categoryParams[1], flag: 0, textFilter: categoryParams[0], priority: Number(categoryParams[2]), enabled: true};
				
				// Check if the category filter already exists
				var exists: Boolean = false;
				for(var cat = 0; cat < this["categoryList"].entryList.length; cat++) {
					if(this["categoryList"].entryList[cat].textFilter == categoryParams[0]) {
						exists = true;
						break;
					}
				}
				
				// Category filter key already exists, skip
				if(exists)
					continue;
				
				this["categoryList"].entryList.push(categoryObject);
				this["categoryList"].requestInvalidate();
			}
		}
	}
	
	public function RSM_SetSliderParameters()
	{
		for(var i = 0; i < this["customSliders"].length; i++) {
			if(this["customSliders"][i].callbackName.toLowerCase() == arguments[0].toLowerCase()) {
				this["customSliders"][i].sliderMin = Number(arguments[1]);
				this["customSliders"][i].sliderMax = Number(arguments[2]);
				this["customSliders"][i].interval = Number(arguments[3]);
				this["customSliders"][i].position = Number(arguments[4]);
				this["itemList"].requestUpdate();
				break;
			}
		}
	}
	
	public function RSM_SetSliderParametersEx()
	{
		var callbacks: Array = arguments[0].split(";;");
		var minimums: Array = arguments[1].split(";;");
		var maximums: Array = arguments[2].split(";;");
		var intervals: Array = arguments[3].split(";;");
		var positions: Array = arguments[4].split(";;");
		var flags: Array = arguments[5].split(";;");
		
		for(var i = 0; i < this["customSliders"].length; i++) {
			for(var k = 0; k < callbacks.length; k++) {
				if(this["customSliders"][i].callbackName.toLowerCase() == callbacks[k].toLowerCase()) {
					var flag = Number(flags[k]) >>> 0;
					if((flag & 2) == 0) this["customSliders"][i].sliderMin = Number(minimums[k]);
					if((flag & 4) == 0) this["customSliders"][i].sliderMax = Number(maximums[k]);
					if((flag & 8) == 0) this["customSliders"][i].interval = Number(intervals[k]);
					if((flag & 16) == 0) this["customSliders"][i].position = Number(positions[k]);
					if((flag & 1) == 0) this["itemList"].requestUpdate();
					break;
				}
			}
		}
	}

	public function RSM_AddWarpaints()
	{
		for(var i = 0; i < arguments.length; i++)
		{
			var warpaintParams: Array = arguments[i].split(";;");
			if(warpaintParams[0] != "" && warpaintParams[1] != "") {
				var a_name: String = warpaintParams[0];
				var a_texture: String = warpaintParams[1];
				
				this["AddMakeup"](RaceMenuDefines.ENTRY_TYPE_WARPAINT, this["makeupList"][RaceMenuDefines.PAINT_WAR], a_name, a_texture);
			}
		}
	}
	
	public function RSM_AddBodyPaints()
	{
		for(var i = 0; i < arguments.length; i++)
		{
			var bodypaintParams: Array = arguments[i].split(";;");
			if(bodypaintParams[0] != "" && bodypaintParams[1] != "") {
				var a_name: String = bodypaintParams[0];
				var a_texture: String = bodypaintParams[1];
				
				this["AddMakeup"](RaceMenuDefines.ENTRY_TYPE_BODYPAINT, this["makeupList"][RaceMenuDefines.PAINT_BODY], a_name, a_texture);
			}
		}
	}
	
	public function RSM_AddHandPaints()
	{
		for(var i = 0; i < arguments.length; i++)
		{
			var handpaintParams: Array = arguments[i].split(";;");
			if(handpaintParams[0] != "" && handpaintParams[1] != "") {
				var a_name: String = handpaintParams[0];
				var a_texture: String = handpaintParams[1];
				
				this["AddMakeup"](RaceMenuDefines.ENTRY_TYPE_HANDPAINT, this["makeupList"][RaceMenuDefines.PAINT_HAND], a_name, a_texture);
			}
		}
	}
	
	public function RSM_AddFeetPaints()
	{
		for(var i = 0; i < arguments.length; i++)
		{
			var feetpaintParams: Array = arguments[i].split(";;");
			if(feetpaintParams[0] != "" && feetpaintParams[1] != "") {
				var a_name: String = feetpaintParams[0];
				var a_texture: String = feetpaintParams[1];
				
				this["AddMakeup"](RaceMenuDefines.ENTRY_TYPE_FEETPAINT, this["makeupList"][RaceMenuDefines.PAINT_FEET], a_name, a_texture);
			}
		}
	}
	
	public function RSM_AddFacePaints()
	{
		for(var i = 0; i < arguments.length; i++)
		{
			var facepaintParams: Array = arguments[i].split(";;");
			if(facepaintParams[0] != "" && facepaintParams[1] != "") {
				var a_name: String = facepaintParams[0];
				var a_texture: String = facepaintParams[1];
				
				this["AddMakeup"](RaceMenuDefines.ENTRY_TYPE_FACEPAINT, this["makeupList"][RaceMenuDefines.PAINT_FACE], a_name, a_texture);
			}
		}
	}
	
	public function RSM_AddTints()
	{
		var tintTypes = new Array();
		var tintColors = new Array();
		var tintTextures = new Array();
		
		_global.tintCount = 0;
		for(var i = 0; i < arguments.length; i++)
		{		
			var tintParams: Array = arguments[i].split(";;");
			if(tintParams.length > 0 && (Number(tintParams[0]) != 0 || Number(tintParams[1]) != 0 || tintParams[2] != "")) {
				tintTypes.push(Number(tintParams[0]));
				tintColors.push(Number(tintParams[1]));
				tintTextures.push(tintParams[2]);
				
				// Tint has a color
				if(Number(tintParams[0]) != RaceMenuDefines.TINT_TYPE_HAIR && (Number(tintParams[1]) >>> 24) > 0) {
					_global.tintCount++;
				}
			}
		}
		this["UpdateTintCount"]();
		
		this["SetSliderColors"](tintTypes, tintColors);
		
		var tintType: Number = RaceMenuDefines.TINT_TYPE_WARPAINT;
		var category: Number = RaceMenuDefines.CATEGORY_WARPAINT;
		var listIndex: Number = RaceMenuDefines.PAINT_WAR;
		var entryType: Number = RaceMenuDefines.ENTRY_TYPE_WARPAINT;
		this["SetMakeup"](tintTypes, tintColors, tintTextures, null, tintType, category, listIndex, entryType);
		delete tintTypes;
		delete tintColors;
		delete tintTextures;
	}
	
	public function RSM_AddBodyTints()
	{
		var tintTypes = new Array();
		var tintColors = new Array();
		var tintTextures = new Array();
		var tintGlows = new Array();
		
		for(var i = 0; i < arguments.length; i++)
		{		
			var tintParams: Array = arguments[i].split(";;");
			if(tintParams.length > 0 && (Number(tintParams[0]) != 0 || Number(tintParams[1]) != 0 || tintParams[2] != "")) {
				tintTypes.push(Number(tintParams[0]));
				tintColors.push(Number(tintParams[1]));
				tintTextures.push(tintParams[2]);
				tintGlows.push(Number(tintParams[3]));
			}
		}
		
		var tintType: Number = RaceMenuDefines.TINT_TYPE_BODYPAINT;
		var category: Number = RaceMenuDefines.CATEGORY_BODYPAINT;
		var listIndex: Number = RaceMenuDefines.PAINT_BODY;
		var entryType: Number = RaceMenuDefines.ENTRY_TYPE_BODYPAINT;
		this["SetMakeup"](tintTypes, tintColors, tintTextures, tintGlows, tintType, category, listIndex, entryType);
		delete tintTypes;
		delete tintColors;
		delete tintTextures;
		delete tintGlows;
	}
	
	public function RSM_AddHandTints()
	{
		var tintTypes = new Array();
		var tintColors = new Array();
		var tintTextures = new Array();
		var tintGlows = new Array();
		
		for(var i = 0; i < arguments.length; i++)
		{		
			var tintParams: Array = arguments[i].split(";;");
			if(tintParams.length > 0 && (Number(tintParams[0]) != 0 || Number(tintParams[1]) != 0 || tintParams[2] != "")) {
				tintTypes.push(Number(tintParams[0]));
				tintColors.push(Number(tintParams[1]));
				tintTextures.push(tintParams[2]);
				tintGlows.push(Number(tintParams[3]));
			}
		}
		
		var tintType: Number = RaceMenuDefines.TINT_TYPE_HANDPAINT;
		var category: Number = RaceMenuDefines.CATEGORY_HANDPAINT;
		var listIndex: Number = RaceMenuDefines.PAINT_HAND;
		var entryType: Number = RaceMenuDefines.ENTRY_TYPE_HANDPAINT;
		this["SetMakeup"](tintTypes, tintColors, tintTextures, tintGlows, tintType, category, listIndex, entryType);
		delete tintTypes;
		delete tintColors;
		delete tintTextures;
		delete tintGlows;
	}
	
	public function RSM_AddFeetTints()
	{
		var tintTypes = new Array();
		var tintColors = new Array();
		var tintTextures = new Array();
		var tintGlows = new Array();
		
		for(var i = 0; i < arguments.length; i++)
		{		
			var tintParams: Array = arguments[i].split(";;");
			if(tintParams.length > 0 && (Number(tintParams[0]) != 0 || Number(tintParams[1]) != 0 || tintParams[2] != "")) {
				tintTypes.push(Number(tintParams[0]));
				tintColors.push(Number(tintParams[1]));
				tintTextures.push(tintParams[2]);
				tintGlows.push(Number(tintParams[3]));
			}
		}
		
		var tintType: Number = RaceMenuDefines.TINT_TYPE_FEETPAINT;
		var category: Number = RaceMenuDefines.CATEGORY_FEETPAINT;
		var listIndex: Number = RaceMenuDefines.PAINT_FEET;
		var entryType: Number = RaceMenuDefines.ENTRY_TYPE_FEETPAINT;
		this["SetMakeup"](tintTypes, tintColors, tintTextures, tintGlows, tintType, category, listIndex, entryType);
		delete tintTypes;
		delete tintColors;
		delete tintTextures;
		delete tintGlows;
	}
	
	public function RSM_AddFaceTints()
	{
		var tintTypes = new Array();
		var tintColors = new Array();
		var tintTextures = new Array();
		var tintGlows = new Array();
		
		for(var i = 0; i < arguments.length; i++)
		{		
			var tintParams: Array = arguments[i].split(";;");
			if(tintParams.length > 0 && (Number(tintParams[0]) != 0 || Number(tintParams[1]) != 0 || tintParams[2] != "")) {
				tintTypes.push(Number(tintParams[0]));
				tintColors.push(Number(tintParams[1]));
				tintTextures.push(tintParams[2]);
				tintGlows.push(Number(tintParams[3]));
			}
		}
		
		var tintType: Number = RaceMenuDefines.TINT_TYPE_FACEPAINT;
		var category: Number = RaceMenuDefines.CATEGORY_FACEPAINT;
		var listIndex: Number = RaceMenuDefines.PAINT_FACE;
		var entryType: Number = RaceMenuDefines.ENTRY_TYPE_FACEPAINT;
		this["SetMakeup"](tintTypes, tintColors, tintTextures, tintGlows, tintType, category, listIndex, entryType);
		delete tintTypes;
		delete tintColors;
		delete tintTextures;
		delete tintGlows;
	}
	
	public function RSM_ExtendRace(a_object: Object)
	{
		if(a_object.formId != undefined) {
			skse.ExtendForm(a_object.formId, a_object, true, false);
		}
		this["_raceList"].push(a_object);
	}
	
	/* Clipboard functions */
	public function RSM_SaveClipboard()
	{
		var outputString: String = "";
		for(var i = 0; i < arguments.length; i++) {
			outputString += "" + ((arguments[i]*100|0)/100) + "";
			
			if(i < arguments.length - 1) {
				outputString += ",";
			}
		}
		skse.SetClipboardData(outputString);
	}
	
	public function RSM_LoadClipboard()
	{
		var clipboardData: String = skse.GetClipboardData();
		var sliderArray: Array = clipboardData.split(',');
		
		for(var i = 0; i < sliderArray.length; i++) {
			skse.SendModEvent(_global.eventPrefix + "ClipboardData", Number(i).toString(), Number(sliderArray[i]));
		}
		skse.SendModEvent(_global.eventPrefix + "ClipboardFinished");
	}
	
	public function RSM_ToggleLoader(a_toggle: Boolean)
	{
		this["loadingIcon"]._visible = a_toggle;
	}
	
	public function RSM_SetPresetSlot(a_slot: Number)
	{
		_global.presetSlot = a_slot;
	}
}