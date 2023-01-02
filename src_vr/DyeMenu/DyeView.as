import gfx.events.EventDispatcher;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import Shared.GlobalFunc;
import skyui.util.GlobalFunctions;
import skyui.defines.Input;

class DyeView extends MovieClip
{
	public var itemList: DyeList;
	public var background: MovieClip;
	public var colorRect: MovieClip;
	public var textField: TextField;
	
	public var activeList: Array;
	
	private var _consume: Boolean = true;
	private var _maxCount: Number = 1;
	private var _color: Number = 0;
	
	// GFx Events
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	private var _platform = 0;
	private var _dyeControl: Object;
	
		
	public function DyeView()
	{
		super();
		EventDispatcher.initialize(this);
		activeList = new Array();
		
		colorRect.onPress = function()
		{
			_parent.onPressColorRectangle();
		}
	}
		
	public function onLoad()
	{
		itemList.listEnumeration = new BasicEnumeration(itemList.entryList);
		
		itemList.listState.activeCount = 0;
		itemList.listState.maxCount = _maxCount;
		
		setColor(_color);
	}
	
	public function setPlatform(a_platform: Number, abPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		itemList.setPlatform(a_platform, abPS3Switch);
		if(a_platform == 0) {
			_dyeControl = {keyCode: GlobalFunctions.getMappedKey("Ready Weapon", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		} else {
			_dyeControl = {keyCode: GlobalFunctions.getMappedKey("Ready Weapon", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		}
	}
	
	public function IsBoundKeyPressed(details: InputDetails, boundKey: Object, platform: Number): Boolean
	{
		return ((details.control && details.control == boundKey.name) || (details.skseKeycode && boundKey.name && boundKey.context && details.skseKeycode == GlobalFunctions.getMappedKey(boundKey.name, Number(boundKey.context), platform != 0)) || (details.skseKeycode && details.skseKeycode == boundKey.keyCode));
	}
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var bHandledInput: Boolean = false;
		if (GlobalFunc.IsKeyPressed(details)) {
			if (IsBoundKeyPressed(details, _dyeControl, _platform)) {
				onPressColorRectangle();
				return true;
			}
		}
		return itemList.handleInput(details, pathToFocus);
	}
	
	public function onPressColorRectangle()
	{
		dispatchEvent({type: "applyColor", color: _color});
	}
	
	public function get activeCount(): Number
	{
		return activeList.length;
	}
	
	public function activate(entry: Object): Void
	{
		entry.active = true;
		activeList.push(entry);
		
		updateBlendCountText();
		itemList.listState.activeCount = activeCount;
		calculateResult(true);
	}
	
	public function deactivate(entry: Object): Void
	{
		entry.active = false;
		var found = undefined;
		for(var i = 0; i < activeList.length; i++) {
			if(activeList[i] == entry)
				found = i;
		}
		
		if(found != undefined)
			activeList.splice(found, 1);
		
		updateBlendCountText();
		itemList.listState.activeCount = activeCount;
		calculateResult(true);
	}
	
	public function clearDyes(a_update: Boolean): Void
	{
		for(var k: Number = activeList.length; k >= 0; k--) {
			activeList[k].active = false;
			activeList.splice(k, 1);
		}
		itemList.invalidateSelection();
		itemList.requestUpdate();
		updateBlendCountText();
		itemList.listState.activeCount = activeCount;
		calculateResult(a_update);
	}
	
	public function consumeItems(): Boolean
	{
		var consumed: Boolean = false;
		if(_consume) {
			for(var k: Number = activeList.length; k >= 0; k--) {
				var entry = activeList[k];
				if(entry.count > 1)
					entry.count -= 1;
				else {
					activeList.splice(k, 1);
					for(var j: Number = itemList.entryList.length; j >= 0; j--) {
						if(itemList.entryList[j] == entry) {
							itemList.entryList.splice(j, 1);
							break;
						}
					}
				}
				
				if(entry.formId) {
					_global.skse.SendModEvent("UIDyeMenu_ConsumeItem", "", 0, entry.formId);
					consumed = true;
				}
			}
		}
		
		updateBlendCountText();
		itemList.listState.activeCount = activeCount;
		itemList.requestInvalidate();
		calculateResult(false);
		return consumed;
	}
	
	public function updateBlendCountText(): Void
	{
		textField.text = skyui.util.Translator.translateNested("$Select Dye {(" + activeCount + "/" + maxCount + ")}");
	}
	
	public function get maxCount(): Number
	{
		return _maxCount;
	}
	
	public function set maxCount(a_max: Number): Void
	{
		_maxCount = a_max;
		itemList.listState.maxCount = _maxCount;
		updateBlendCountText();
	}
	
	public function set consume(a_consume: Boolean): Void
	{
		_consume = a_consume;
	}
	
	public function calculateResult(a_broadcast: Boolean)
	{
		var aSum = 0;
		var rSum = 0;
		var gSum = 0;
		var bSum = 0;
		for(var i = 0; i < activeList.length; i++) {
			var activeEntry = activeList[i];
			aSum += (activeEntry.fillColor >>> 24 & 0xFF);
			rSum += (activeEntry.fillColor >>> 16 & 0xFF);
			gSum += (activeEntry.fillColor >>> 8 & 0xFF);
			bSum += (activeEntry.fillColor & 0xFF);
		}
		
		_color = ((aSum / activeList.length) << 24 | (rSum / activeList.length) << 16 | (gSum / activeList.length) << 8 | (bSum / activeList.length));
		setColor(_color);
		
		if(a_broadcast)
			dispatchEvent({type: "changeColor", color: _color});
	}
	
	public function setColor(a_color: Number): Void
	{
		var colorOverlay: Color = new Color(colorRect.fill);
		colorOverlay.setRGB(_color & 0x00FFFFFF);
		colorRect.fill._alpha = ((_color >>> 24) / 0xFF) * 100;
	}
	
	public function get entryList(): Array
	{
		return itemList.entryList;
	}
	
	public function get listHeight(): Number
	{
		return itemList.listHeight;
	}
		
	public function set listHeight(a_height: Number): Void
	{
		itemList.listHeight = a_height;
	}
}
