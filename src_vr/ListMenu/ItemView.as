import gfx.events.EventDispatcher;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import skyui.components.list.FilteredEnumeration;
import skyui.filter.SortFilter;
import gfx.ui.InputDetails;

class ItemView extends MovieClip
{
	public var itemList: ItemList;
	public var background: MovieClip;
	
	public var paddingBottom = 2;
	public var paddingTop = 0;
	
	private var _sortFilter: SortFilter;
	private var _sortEnabled: Boolean = false;
	
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
		
	public function ItemView()
	{
		super();
		EventDispatcher.initialize(this);
		_sortFilter = new SortFilter();
	}
	
	public function onLoad()
	{
		itemList.listEnumeration = new BasicEnumeration(itemList.entryList);
		itemList.addEventListener("invalidateHeight", this, "onInvalidateHeight");
		dispatchEvent({type: "onLoad", view: this});
	}
	
	public function get entryList(): Array
	{
		return itemList.entryList;
	}
	
	public function get sortEnabled(): Boolean
	{
		return _sortEnabled;
	}
	
	public function set sortEnabled(a_sort: Boolean): Void
	{
		_sortEnabled = a_sort;
		if(a_sort) {
			var enumeration = itemList.listEnumeration = new FilteredEnumeration(itemList.entryList);
			enumeration.addFilter(_sortFilter);
			itemList.listEnumeration = enumeration;
		} else {
			itemList.listEnumeration = new BasicEnumeration(itemList.entryList);
		}
	}
	
	public function set entryList(a_newArray: Array): Void
	{
		itemList.entryList = a_newArray;
		sortEnabled = sortEnabled;
	}
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{		
		return itemList.handleInput(details, pathToFocus);
	}
	
	public function get listHeight(): Number
	{
		return itemList.listHeight;
	}
	
	public function setMinViewport(a_minEntries: Number, a_update: Boolean): Void
	{
		itemList.minViewport = a_minEntries;
		if(a_update) {
			itemList.requestInvalidate();
		}
	}
	
	public function setMaxViewport(a_maxEntries: Number, a_update: Boolean): Void
	{
		itemList.maxViewport = a_maxEntries;
		if(a_update) {
			itemList.requestInvalidate();
		}
	}
	
	public function set listHeight(a_height: Number): Void
	{
		itemList.listHeight = a_height;
		
		background._y = -paddingTop;
		background._height = a_height + paddingTop + paddingBottom;
	}
	
	public function onInvalidateHeight(event: Object): Void
	{
		listHeight = event.height;
	}
}
