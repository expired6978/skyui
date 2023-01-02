import gfx.events.EventDispatcher;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;

import skyui.components.ButtonPanel;
import skyui.util.GlobalFunctions;
import skyui.defines.Input;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.Linear;

class CameraEditor extends MovieClip
{
	public var bottomBar: BottomBar;
	public var navPanel: ButtonPanel;
	
	private var BOTTOMBAR_SHOWN_Y = 949;
	private var BOTTOMBAR_HIDDEN_Y = 1099;
	
	private var _startRotation: Number = 0;
	private var _currentRotation: Number = 0;
	private var _secondary: Boolean = false;
	
	public var movementRate: Number = 5.0;
	
	public var Lock: Function;
		
	/* CONTROLS */
	private var _platform: Number;
	private var _acceptControl: Object;
	private var _activateControl: Object;
	private var _cancelControl: Object;
	private var _rateControl: Array;
	private var _udlrControl: Array;
	private var _lrControl: Array;
	private var _udControl: Array;
	
	private var _upControl: Object;
	private var _downControl: Object;
	private var _leftControl: Object;
	private var _rightControl: Object;
	private var _modifierControl: Object;
		
	private var _initCameraPos: Object;
	private var _initPlayerPos: Object;
	
	private var _zoomVector: Object;
	private var _moveVector: Object;
	
	function CameraEditor()
	{
		super();

		Mouse.addListener(this);
		EventDispatcher.initialize(this);
		
		navPanel = bottomBar.buttonPanel;
				
		bottomBar._y = BOTTOMBAR_HIDDEN_Y;
	}
	
	function onLoad()
	{
		super.onLoad();		
		bottomBar.hidePlayerInfo();
	}
	
	function InitExtensions()
	{
		BOTTOMBAR_SHOWN_Y = Stage["originalRect"].height - bottomBar._height;
		BOTTOMBAR_HIDDEN_Y = Stage["originalRect"].height + bottomBar._height;
		
		var rotation:Array = _global.skse.plugins.CharGen.GetPlayerRotation();
		_startRotation = Math.acos(rotation[0]);
		_currentRotation = 0;
		bottomBar.positionBackground();
	}
	
	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		_platform = a_platform;
		bottomBar.setPlatform(a_platform, a_bPS3Switch);
		
		_activateControl = Input.Accept;
		
		if(_platform == 0) {
			_cancelControl = {name: "Tween Menu", context: Input.CONTEXT_GAMEPLAY};
		} else {
			_cancelControl = Input.Cancel;
		}
		
		_acceptControl = {keyCode: GlobalFunctions.getMappedKey("Ready Weapon", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		_upControl = {keyCode: GlobalFunctions.getMappedKey("Up", Input.CONTEXT_MENUMODE, a_platform != 0)};
		_downControl = {keyCode: GlobalFunctions.getMappedKey("Down", Input.CONTEXT_MENUMODE, a_platform != 0)};
		_leftControl = {keyCode: GlobalFunctions.getMappedKey("Left", Input.CONTEXT_MENUMODE, a_platform != 0)};
		_rightControl = {keyCode: GlobalFunctions.getMappedKey("Right", Input.CONTEXT_MENUMODE, a_platform != 0)};
		_udlrControl = [_upControl, _downControl, _leftControl, _rightControl];
		_lrControl = [_leftControl, _rightControl];
		_udControl = [_upControl, _downControl];
		_rateControl = [_activateControl, _cancelControl];
		_modifierControl = {keyCode: GlobalFunctions.getMappedKey("Sprint", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		
		var leftEdge = Stage.visibleRect.x + Stage.safeRect.x;
		var rightEdge = Stage.visibleRect.x + Stage.visibleRect.width - Stage.safeRect.x;
		bottomBar.positionElements(leftEdge, rightEdge);
		
		updateBottomBar();
	}
	
	private function updateBottomBar(): Void
	{
		navPanel.clearButtons();
		navPanel.addButton({text: "$Done", controls: _acceptControl}).addEventListener("click", this._parent, "onDoneClicked");
		
		if(!_secondary)
			navPanel.addButton({text: "$Secondary", controls: _modifierControl});
		else
			navPanel.addButton({text: "$Primary", controls: _modifierControl});
		
		if(!_secondary)
			navPanel.addButton({text: "$Move Camera", controls: _udlrControl});
			
		if(_secondary) {
			navPanel.addButton({text: "$Zoom", controls: _udControl});
			navPanel.addButton({text: "$Rotate", controls: _lrControl});
		}
		
		navPanel.addButton({text: skyui.util.Translator.translateNested("$Rate ({" + movementRate +"})"), controls: _rateControl});
		
		navPanel.updateButtons(true);		
	}
	
	public function ShowAll(bShowAll: Boolean): Void
	{
		ShowBottomBar(bShowAll);
		if(bShowAll) {
			TweenLite.to(this, 0.5, {autoAlpha: 100, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			TweenLite.to(this, 0.5, {autoAlpha: 0, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
		
		enabled = bShowAll;
	}
		
	public function ShowBottomBar(bShowBottomBar: Boolean): Void
	{
		if(bShowBottomBar) {
			TweenLite.to(bottomBar, 0.5, {autoAlpha: 100, _y: BOTTOMBAR_SHOWN_Y, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		} else {
			TweenLite.to(bottomBar, 0.5, {autoAlpha: 0, _y: BOTTOMBAR_HIDDEN_Y, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		}
	}
	
	public function IsBoundKeyPressed(details: InputDetails, boundKey: Object, platform: Number): Boolean
	{
		return ((details.control && details.control == boundKey.name) || (details.skseKeycode && boundKey.name && boundKey.context && details.skseKeycode == GlobalFunctions.getMappedKey(boundKey.name, Number(boundKey.context), platform != 0)) || (details.skseKeycode && details.skseKeycode == boundKey.keyCode));
	}
	
	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		if (details.skseKeycode == _modifierControl.keyCode) {
			_secondary = (details.value == "keyDown" || details.value == "keyHold");
			updateBottomBar(true);
			return true;
		}
		
		if(!_initCameraPos)
			_initCameraPos = _global.skse.plugins.CharGen.GetRaceSexCameraPos();
		if(!_initPlayerPos) {
			_initPlayerPos = _global.skse.plugins.CharGen.GetPlayerPosition();
		
			var xDiff = _initCameraPos.x - _initPlayerPos.x;
			var yDiff = _initCameraPos.y - _initPlayerPos.y;
			
			var vectorLen = Math.sqrt(Math.pow(xDiff, 2) + Math.pow(yDiff, 2));
			var xDiffNorm = xDiff/vectorLen;
			var yDiffNorm = yDiff/vectorLen;
			
			_zoomVector = {x: xDiffNorm, y: yDiffNorm};
			_moveVector = {x: yDiffNorm, y: -xDiffNorm};
		}
		
		var keyState = (details.value == "keyDown" || details.value == "keyHold");
		if((details.navEquivalent == NavigationCode.ENTER || details.skseKeycode == GlobalFunctions.getMappedKey("Activate", Input.CONTEXT_GAMEPLAY, _platform != 0)) && keyState) {
			movementRate += 0.5;
			updateBottomBar(true);
			return true;
		}
		else if((details.navEquivalent == NavigationCode.TAB || details.skseKeycode == GlobalFunctions.getMappedKey("Cancel", Input.CONTEXT_GAMEPLAY, _platform != 0)) && keyState) {
			movementRate -= 0.5;
			if(movementRate < 0.5)
				movementRate = 0.5;
			updateBottomBar(true);
			return true;
		}
		else if (details.navEquivalent === NavigationCode.RIGHT) 
		{
			if (keyState) {
				if(!_secondary) { // Move Right
					var pos:Object = _global.skse.plugins.CharGen.GetRaceSexCameraPos();
					if(pos) {
						//pos.y -= movementRate;
						pos.x -= _moveVector.x * movementRate;
						pos.y -= _moveVector.y * movementRate;
						_global.skse.plugins.CharGen.SetRaceSexCameraPos(pos);
					}
				} else { // Rotate Right
					currentRotation += movementRate;
				}
			}
			return true;
		}
		else if (details.navEquivalent === NavigationCode.LEFT)
		{
			if (keyState) {
				if(!_secondary) { // Move Left
					var pos:Object = _global.skse.plugins.CharGen.GetRaceSexCameraPos();
					if(pos) {
						//pos.y += movementRate;
						pos.x += _moveVector.x * movementRate;
						pos.y += _moveVector.y * movementRate;
						_global.skse.plugins.CharGen.SetRaceSexCameraPos(pos);
					}
				} else { // Rotate Left
					currentRotation -= movementRate;
				}
			}
			return true;
		}
		else if (details.navEquivalent === NavigationCode.UP) 
		{
			if (keyState) {
				if(!_secondary) { // Move up
					var pos:Object = _global.skse.plugins.CharGen.GetRaceSexCameraPos();
					if(pos) {
						pos.z += movementRate;
						_global.skse.plugins.CharGen.SetRaceSexCameraPos(pos);
					}
				} else { // Zoom In
					var pos:Object = _global.skse.plugins.CharGen.GetRaceSexCameraPos();
					if(pos) {
						//pos.x += movementRate;
						pos.x -= _zoomVector.x * movementRate;
						pos.y -= _zoomVector.y * movementRate;
						_global.skse.plugins.CharGen.SetRaceSexCameraPos(pos);
					}
				}
			}
			return true;
		}
		else if (details.navEquivalent === NavigationCode.DOWN) 
		{
			if (keyState) {
				if(!_secondary) { // Move Down
					var pos:Object = _global.skse.plugins.CharGen.GetRaceSexCameraPos();
					if(pos) {
						pos.z -= movementRate;
						_global.skse.plugins.CharGen.SetRaceSexCameraPos(pos);
					}
				} else { // Zoom Out
					var pos:Object = _global.skse.plugins.CharGen.GetRaceSexCameraPos();
					if(pos) {
						//pos.x -= movementRate;
						pos.x += _zoomVector.x * movementRate;
						pos.y += _zoomVector.y * movementRate;
						_global.skse.plugins.CharGen.SetRaceSexCameraPos(pos);
					}
				}
			}
			return true;
		}
		
		return false;
	}
	
	public function get currentRotation(): Number // Degrees
	{
		return _currentRotation * 180 / Math.PI;
	}
		
	public function set currentRotation(a_number:Number) // Degrees
	{
		_currentRotation = a_number * Math.PI / 180;
		
		if(_global.skse.plugins.CharGen.SetPlayerRotation) {
			var rotation: Array =
				[Math.cos(_currentRotation+_startRotation),	-Math.sin(_currentRotation+_startRotation),	0,
				 Math.sin(_currentRotation+_startRotation),	 Math.cos(_currentRotation+_startRotation),	0,
				 				 			 0,			 				 	 0,	1];
			_global.skse.plugins.CharGen.SetPlayerRotation(rotation);
		}
	}
}
