import gfx.events.EventDispatcher;

import skyui.filter.IFilter;


class CategoryFilter implements IFilter
{
  /* PRIVATE VARIABLES */

	private var _filterArray:Array;
	private var _matcherFunc:Function;
	
	
  /* PROPERTIES */

	private var _itemFilter: Number = 0xFFFFFFFF;
	private var _textFilter: String = "all";

	function get itemFilter():Number
	{
		return _itemFilter;
	}
	
	function get textFilter(): String
	{
		return _textFilter;
	}


  /* INITIALIZATION */

	public function CategoryFilter()
	{
		EventDispatcher.initialize(this);
		
		_matcherFunc = entryMatchesFilter;
	}
	
	
  /* PUBLIC FUNCTIONS */

	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	public function changeFilterData(a_newFilter:Number, a_newTextFilter: String, a_bDoNotUpdate: Boolean): Void
	{
		if (a_bDoNotUpdate == undefined)
			a_bDoNotUpdate = false;
		
		_itemFilter = a_newFilter;
		_textFilter = a_newTextFilter;
		
		if (!a_bDoNotUpdate)
			dispatchEvent({type:"filterChange"});
	}

	public function setPartitionedFilterMode(a_bPartition: Boolean): Void
	{
		_matcherFunc = a_bPartition ? entryMatchesPartitionedFilter : entryMatchesFilter;
	}
	
	// @override skyui.IFilter
	public function applyFilter(a_filteredList: Array): Void
	{
		for (var i = 0; i < a_filteredList.length; i++) {
			if (!_matcherFunc(a_filteredList[i])) {
				a_filteredList.splice(i,1);
				i--;
			}
		}
	}
	
	
  /* PRIVATE FUNCTIONS */

	private function entryMatchesFilter(a_entry:Object): Boolean
	{
		return (a_entry != undefined && (a_entry.filterFlag == undefined || (a_entry.filterFlag & _itemFilter) != 0) || (a_entry.textFilters && matchText(a_entry.textFilters)));
	}
	
	private function matchText(a_filters: Array): Boolean
	{
		if(a_filters) {
			for(var i = 0; i < a_filters.length; i++) {
				if(a_filters[i] == _textFilter) {
					return true;
					break;
				}
			}
		}
		
		return false;
	}

	private function entryMatchesPartitionedFilter(a_entry:Object): Boolean
	{
		var matched = false;
		if (a_entry != undefined) {
			if (_itemFilter == 0xFFFFFFFF || _textFilter == "all") {
				matched = true;
			} else {
				var flag = a_entry.filterFlag;
				matched = (flag & 0xFF) == _itemFilter || ((flag & 0xFF00) >>> 8) == _itemFilter || ((flag & 0xFF0000) >>> 16) == _itemFilter || ((flag & 0xFF000000) >>> 24) == _itemFilter;
				if(!matched)
					matched = matchText(a_entry.textFilters);
			}
		}
		return matched;
	}
}