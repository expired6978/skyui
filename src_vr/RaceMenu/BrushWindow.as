import gfx.events.EventDispatcher;
import gfx.io.GameDelegate;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.FilteredEnumeration;
import skyui.components.list.ScrollingList;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;

class BrushWindow extends MovableWindow
{
	public var brushList: BrushList;
	public var brushSlidingList: TextCategorySlidingList;
	public var categoryList: TextCategoryList;
	
	private var _typeFilter: CategoryFilter;
			
	public var brushes: Array;
	public var currentBrush: Number = -1;
	
	static var BRUSH_TYPE_NONE: Number = -1;
	static var BRUSH_TYPE_MASK_ADD: Number = 0;
	static var BRUSH_TYPE_MASK_SUB: Number = 1;
	static var BRUSH_TYPE_INFLATE: Number = 2;
	static var BRUSH_TYPE_DEFLATE: Number = 3;
	static var BRUSH_TYPE_MOVE: Number = 4;
	static var BRUSH_TYPE_SMOOTH: Number = 5;
	
	public var _allowBrushChange: Boolean = true;
	
	public var bLoadedAssets: Boolean = false;
	
	function BrushWindow()
	{
		super();
		categoryList = brushSlidingList.categoryList;
		_typeFilter = new CategoryFilter();
		
		categoryList.disableInput = brushList.disableInput = false;
	}
	
	function onLoad()
	{
		super.onLoad();
		
		_typeFilter.addEventListener("filterChange", this, "onFilterChange");
		categoryList.addEventListener("selectionChange", this, "onCategoryChange");
		
		categoryList.listEnumeration = new BasicEnumeration(categoryList.entryList);
		categoryList.requestInvalidate();
		
		var listEnumeration = new FilteredEnumeration(brushList.entryList);
		listEnumeration.addFilter(_typeFilter);
		brushList.listEnumeration = listEnumeration;
		brushList.requestInvalidate();
	}
	
	public function InitExtensions()
	{
		
	}
	
	public function set bAllowBrushChange(a_change: Boolean)
	{
		_allowBrushChange = a_change;
		categoryList.disableInput = brushList.disableInput = !_allowBrushChange;
	}
	
	public function loadAssets()
	{
		if(bLoadedAssets)
			return true;
		/*brushes = [{type: 1, radius: 1.0, strength: 0.01},
				   {type: 2, radius: 1.5, strength: 0.02},
				   {type: 3, radius: 2.0, strength: 0.03},
				   {type: 4, radius: 3.0, strength: 0.04},
				   {type: 5, radius: 4.0, strength: 0.05}
				   ];*/
		brushes = _global.skse.plugins.CharGen.GetBrushes();
		for(var b = 0; b < brushes.length; b++) {
			var filter: String = "brush_" + brushes[b].type;
			
			categoryList.entryList.push({text: getBrushName(brushes[b].type), flag: 0, textFilter: filter, bDontHide: true, filterFlag: 1, enabled: true});
			
			var radius: Object = {text: "$Radius", sliderMin: brushes[b].radiusMin, sliderMax: brushes[b].radiusMax, filterFlag: 0, textFilters: [filter], interval: brushes[b].radiusInterval, position: brushes[b].radius, brush: brushes[b], enabled: true};
			radius.internalCallback = function()
			{
				var brush: Object = this.entryObject.brush;
				brush.radius = this.entryObject.position;
				
				if(_global.skse.plugins.CharGen.SetBrushData)
					_global.skse.plugins.CharGen.SetBrushData(brush.type, brush);
			}
			brushList.entryList.push(radius);
			
			if(brushes[b].strength != 0) {
				var strength: Object = {text: "$Strength", sliderMin: brushes[b].strengthMin, sliderMax: brushes[b].strengthMax, filterFlag: 0, textFilters: [filter], interval: brushes[b].strengthInterval, position: brushes[b].strength, brush: brushes[b], enabled: true};
				strength.internalCallback = function()
				{
					var brush: Object = this.entryObject.brush;
					brush.strength = this.entryObject.position;
					
					if(_global.skse.plugins.CharGen.SetBrushData)
						_global.skse.plugins.CharGen.SetBrushData(brush.type, brush);
				}
				brushList.entryList.push(strength);
			}
			
			if(brushes[b].falloff != 0) {
				var falloff: Object = {text: "$Falloff", sliderMin: brushes[b].falloffMin, sliderMax: brushes[b].falloffMax, filterFlag: 0, textFilters: [filter], interval: brushes[b].falloffInterval, position: brushes[b].falloff, brush: brushes[b], enabled: true};
				falloff.internalCallback = function()
				{
					var brush: Object = this.entryObject.brush;
					brush.falloff = this.entryObject.position;
					
					if(_global.skse.plugins.CharGen.SetBrushData)
						_global.skse.plugins.CharGen.SetBrushData(brush.type, brush);
				}
				brushList.entryList.push(falloff);
			}
			
			var mirror: Object = {text: "$Mirror", sliderMin: 0, sliderMax: 1, filterFlag: 0, textFilters: [filter], interval: 1, position: brushes[b].mirror, brush: brushes[b], enabled: true};
			mirror.internalCallback = function()
			{
				var brush: Object = this.entryObject.brush;
				brush.mirror = this.entryObject.position;
				
				if(_global.skse.plugins.CharGen.SetBrushData)
					_global.skse.plugins.CharGen.SetBrushData(brush.type, brush);
			}
			brushList.entryList.push(mirror);
		}
		
		var brushId: Number = _global.skse.plugins.CharGen.GetCurrentBrush();
		currentBrush = getBrushIndex(brushId);
		categoryList.InvalidateData();
		categoryList.onItemPress(currentBrush, 0);

		brushList.requestInvalidate();
		bLoadedAssets = true;
		return true;
	}
	
	public function unloadAssets()
	{
		if(!bLoadedAssets)
			return false;
			
		categoryList.entryList.splice(0, categoryList.entryList.length);		
		brushList.entryList.splice(0, brushList.entryList.length);
		
		categoryList.requestInvalidate();
		brushList.requestInvalidate();
		
		brushes.splice(0, brushes.length);
		brushes = null;
		
		currentBrush = -1;
		
		bLoadedAssets = false;
		return true;
	}
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{		
		if(categoryList.handleInput(details, pathToFocus))
			return true;
			
		return brushList.handleInput(details, pathToFocus);
	}
	
	private function onFilterChange(event: Object): Void
	{
		brushList.requestInvalidate();
	}
	
	private function onCategoryChange(event: Object): Void
	{
		if (categoryList.selectedEntry != undefined) {
			var brush: Object = brushes[event.index];
			if(brush) {
				dispatchEvent({type: "changeBrush", id: brush.type, brushName: getBrushName(brush.type)});
				
				if(_global.skse.plugins.CharGen.SetCurrentBrush)
					_global.skse.plugins.CharGen.SetCurrentBrush(brush.type);
			}
			
			_typeFilter.changeFilterData(categoryList.selectedEntry.flag, categoryList.selectedEntry.textFilter);
		}
	}
	
	public function getBrushName(a_type: Number): String
	{
		switch(a_type) {
			case BRUSH_TYPE_MASK_ADD:
			return "$Mask Add";
			break;
			case BRUSH_TYPE_MASK_SUB:
			return "$Mask Subtract";
			break;
			case BRUSH_TYPE_INFLATE:
			return "$Inflate";
			break;
			case BRUSH_TYPE_DEFLATE:
			return "$Deflate";
			break;
			case BRUSH_TYPE_MOVE:
			return "$Move";
			break;
			case BRUSH_TYPE_SMOOTH:
			return "$Smooth";
			break;
			default:
			return "$Invalid";
			break;
		}
		
		return "$Invalid Brush";
	}
	
	public function getBrushIndex(a_brushId: Number): Number
	{
		for(var i = 0; i < brushes.length; i++)
		{
			if(brushes[i].type == a_brushId)
				return i;
		}
		
		return -1;
	}
}
