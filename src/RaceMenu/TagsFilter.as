import gfx.events.EventDispatcher;

import skyui.util.GlobalFunctions;


class TagsFilter implements skyui.filter.IFilter
{
  /* PROPERTIES */
  
	private var _filterTags: Object = null;
    private var _totalFilters: Number = 0;

	public function get filterTags(): Object
	{
		return _filterTags;
	}

	public function set filterTags(a_filterTags: Array)
	{
		_filterTags = new Object();
        _totalFilters = 0;
        for(var i = 0; i < a_filterTags.length; i++) {
            _filterTags[a_filterTags[i].toLowerCase()] = true;
        }
        for(var id:String in _filterTags) {
            _totalFilters++;
        }
		dispatchEvent({type:"filterChange"});
	}
	
  /* CONSTRUCTORS */
	
	public function TagsFilter()
	{
		EventDispatcher.initialize(this);
	}
	

  /* PUBLIC FUNCTIONS */

	// @override skyui.IFilter
	public function applyFilter(a_filteredList:Array): Void
	{
		if (_filterTags == null || _totalFilters == 0)
			return;

		for (var i = 0; i < a_filteredList.length; i++) {
			if (!isMatch(a_filteredList[i])) {
				a_filteredList.splice(i,1);
				i--;
			}
		}
	}
  
	// @mixin by gfx.events.EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;


  /* PRIVATE FUNCTIONS */

	private function isMatch(a_entry: Object): Boolean
	{
        var matches: Number = 0;
		for(var i = 0; i < a_entry.tags.length; ++i) {
            if(_filterTags[a_entry.tags[i].toLowerCase()]) {
                matches++;
            }
        }

		return matches == _totalFilters;
	}
}