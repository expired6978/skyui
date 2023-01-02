import gfx.events.EventDispatcher;

class MovableWindow extends gfx.core.UIComponent
{
	public var background: MovieClip;
		
	private var _dragOffset: Object;
				
	// GFx Functions
	public var dispatchEvent: Function;
	public var addEventListener: Function;
		
	function MovableWindow()
	{
		super();
		Mouse.addListener(this);
		EventDispatcher.initialize(this);
		EventDispatcher.initialize(background);
	}
	
	function onLoad()
	{
		super.onLoad();
		
		background.addEventListener("press", this, "beginDrag");
		background.onPress = function(controllerIdx, keyboardOrMouse, button)
		{
			if (this.disabled) 
				return undefined;
		
			dispatchEvent({type: "press", controllerIdx: controllerIdx, button: button});
		}
	}
	
	// Move background
	private function beginDrag(event)
	{
		onMouseMove = doDrag;
		onMouseUp = endDrag;
		
		_dragOffset = {x: _xmouse, y: _ymouse};
		
		dispatchEvent({type: event.type, controllerIdx: event.controllerIdx, button: event.button});
	}

	private function doDrag()
	{
		var diffX = _xmouse - _dragOffset.x;
		var diffY = _ymouse - _dragOffset.y;
		
		_x += diffX;
		_y += diffY;
	}

	private function endDrag()
	{
		delete onMouseUp;
		delete onMouseMove;
	}
}
