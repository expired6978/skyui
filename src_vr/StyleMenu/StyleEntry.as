import skyui.components.list.ScrollingList;
import skyui.components.list.ListState;
import skyui.components.list.BasicListEntry;

class StyleEntry extends BasicListEntry
{
	public static var FLAG_DISABLED = 0x01;
	public static var ALPHA_ENABLED = 100;
	public static var ALPHA_DISABLED = 50;
	
	public var textField: TextField;
	public var valueField: TextField;
	public var selectIndicator: MovieClip;
	public var image: MovieClip;
	public var backdrop: MovieClip;
	
	private var _movieLoader: MovieClipLoader;
	
	public function get width(): Number
	{
		return background._width;
	}

	public function set width(a_val: Number)
	{
		background._width = a_val;
		selectIndicator._width = a_val;
	}
	
	public function initialize(a_index: Number, a_list: ScrollingList): Void
	{
		_movieLoader = new MovieClipLoader();
		_movieLoader.addListener(this);
	}
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var entryWidth = background._width;
		var isSelected = (a_entryObject != undefined && a_entryObject == a_state.list.selectedEntry);

		var flags = a_entryObject.flags;
		var isEnabled = !(flags & FLAG_DISABLED);
		
		selectIndicator._visible = isSelected;
		_alpha = isEnabled ? ALPHA_ENABLED : ALPHA_DISABLED;
		
		if(a_entryObject.text) {
			backdrop.gotoAndStop("backdrop");
		} else {
			backdrop.gotoAndStop("empty");
		}
		
		enabled = isEnabled;
		textField.textAutoSize = "shrink";
		textField._width = entryWidth;
		textField.SetText(a_entryObject.text);
		
		valueField.textAutoSize = "shrink";
		valueField._width = entryWidth;
		valueField.SetText(a_entryObject.value);
		
		if(a_entryObject.imageSource) {
			_movieLoader.loadClip(a_entryObject.imageSource, image);
		}
	}
	
	public function onLoadInit(a_clip: MovieClip): Void
	{
		a_clip._width = a_clip._height = background._width;
	}
	
	// @override MovieClipLoader
	public function onLoadError(a_clip:MovieClip, a_errorCode: String): Void
	{
		skse.Log("Error " + a_errorCode + " failed to load image on: " + a_clip);
		_movieLoader.unloadClip(a_clip);
	}
}
