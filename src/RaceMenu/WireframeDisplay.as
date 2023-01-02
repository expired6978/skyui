import gfx.events.EventDispatcher;

class WireframeDisplay extends gfx.core.UIComponent
{
	public var foreground: MovieClip;
	public var background: MovieClip;
	public var wireframe: MovieClip;
	
	public var editorData: Object;
	public var buttonCount: Number = 0;
	public var paddingTop: Number = 25;
	public var paddingBottom: Number = 25;
	public var paddingLeft: Number = 25;
	public var paddingRight: Number = 25;
	
	private var _dragOffset: Object;
	private var _secondary: Boolean = false;
	
	public var bLoadedAssets: Boolean = false;
	
	public var disableInput: Boolean = false;
			
	// GFx Functions
	public var dispatchEvent: Function;
	public var addEventListener: Function;
	
	function WireframeDisplay()
	{
		super();
		_imageLoader = new MovieClipLoader();
		_imageLoader.addListener(this);
		Mouse.addListener(this);
		EventDispatcher.initialize(this);
	}
	
	function onLoad()
	{
		super.onLoad();		
		EventDispatcher.initialize(background);
		background.addEventListener("press", this, "beginDrag");
		background.addEventListener("scroll", this, "onScrollWheel");
		background.onPress = function(controllerIdx, keyboardOrMouse, button)
		{
			if (this.disabled) 
				return undefined;
		
			dispatchEvent({type: "press", controllerIdx: controllerIdx, button: button});
		}
	}
	
	public function loadAssets(): Boolean
	{
		if(bLoadedAssets) // Already loaded
			return true;
		
		if(_global.skse.plugins.CharGen.CreateMorphEditor) {
			editorData = _global.skse.plugins.CharGen.CreateMorphEditor();
			
			wireframe = foreground.createEmptyMovieClip("wireframe", foreground.getNextHighestDepth());
			_imageLoader.loadClip("img://headMesh", wireframe);
			bLoadedAssets = true;
			return true;
		}
		
		return false;
	}
		
	public function unloadAssets(): Boolean
	{
		if(!bLoadedAssets) // Nothing to unload
			return false;
			
		if(wireframe) {
			wireframe.removeMovieClip();
			wireframe = null;
		}
		
		if(_global.skse.plugins.CharGen.ReleaseMorphEditor) {
			_global.skse.plugins.CharGen.ReleaseMorphEditor();
			bLoadedAssets = false;
			return true;
		}
		
		return false;
	}
	
	private function calculateBackground()
	{
		background._width = paddingLeft + foreground._width + paddingRight;
		background._height = paddingTop + foreground._height + paddingBottom;
		foreground._x = paddingLeft - background._width / 2;
		foreground._y = paddingTop - background._height / 2;
	}	
	
	private function onLoadInit(a_clip: MovieClip): Void
	{
		EventDispatcher.initialize(a_clip);
		
		/*var orig = {x: Stage["originalRect"]["width"], y: Stage["originalRect"]["height"]};
		var res = Stage["translateToScreen"](orig);
		
		var rx:Number = res.x / orig.x;
		var ry:Number = res.y / orig.y;
		var ratio:Number = rx < ry ? rx : ry;*/
		
		// I don't know why it decided to mess with this?
		foreground._width = 32;
		foreground._height = 32;
		
		a_clip._width = editorData.width;
		a_clip._height = editorData.height;
		
		foreground.fixedWidth = editorData.width;
		foreground.fixedHeight = editorData.height;
		
		foreground["doHoverMesh"] = function()
		{
			var width: Number = this.fixedWidth;
			var height: Number = this.fixedHeight;
			var x: Number = Math.max(0, Math.min(_xmouse, width));
			var y: Number = Math.max(0, Math.min(_ymouse, height));
			
			_global.skse.plugins.CharGen.DoHoverMesh(x, y);
		}
				
		foreground["doRotateMesh"] = function()
		{
			var width: Number = this.fixedWidth;
			var height: Number = this.fixedHeight;
			var x: Number = Math.max(0, Math.min(_xmouse, width));
			var y: Number = Math.max(0, Math.min(_ymouse, height));
			
			this.doHoverMesh(x, y);
			_global.skse.plugins.CharGen.DoRotateMesh(x, y);
		}
		foreground["endRotateMesh"] = function(mouseIdx:Number, keyboardOrMouse:Number, buttonIdx:Number)
		{
			if(this.painting) // Don't interrupt existing action
				return undefined;
			if(buttonIdx != 1) // Right mouse only
				return undefined;
			
			this.rotating = false;
			this.onMouseMove = this.doHoverMesh;
			this.onReleaseAux = null;
			this.onReleaseOutsideAux = null;
			
			_parent.dispatchEvent({type: "endRotating"});
			
			_global.skse.plugins.CharGen.EndRotateMesh();
		}
		foreground["endRotateMeshAux"] = function(keyboardOrMouse:Number, buttonIdx:Number)
		{
			return this.endRotateMesh(0, keyboardOrMouse, buttonIdx);
		}
		foreground["doPanMesh"] = function()
		{
			var width: Number = this.fixedWidth;
			var height: Number = this.fixedHeight;
			var x: Number = Math.max(0, Math.min(_xmouse, width));
			var y: Number = Math.max(0, Math.min(_ymouse, height));
			
			this.doHoverMesh(x, y);
			_global.skse.plugins.CharGen.DoPanMesh(x, y);
		}
		foreground["endPanMesh"] = function(mouseIdx:Number, keyboardOrMouse:Number, buttonIdx:Number)
		{
			if(this.painting) // Don't interrupt existing action
				return undefined;
			if(buttonIdx != 1) // Right mouse only
				return undefined;
			
			this.panning = false;
			this.onMouseMove = this.doHoverMesh;
			this.onReleaseAux = null;
			this.onReleaseOutsideAux = null;
			
			_parent.dispatchEvent({type: "endPanning"});
			
			_global.skse.plugins.CharGen.EndPanMesh();
		}
		foreground["endPanMeshAux"] = function(keyboardOrMouse:Number, buttonIdx:Number)
		{
			return this.endPanMesh(0, keyboardOrMouse, buttonIdx);
		}
		foreground["beginRotateMesh"] = function(mouseIdx:Number, keyboardOrMouse:Number, buttonIdx:Number)
		{
			if(this.painting) // Don't interrupt existing action
				return undefined;
			if(buttonIdx != 1) // Right mouse only
				return undefined;
			
			if(!_parent.secondary) {
				this.rotating = true;
				this.onMouseMove = this.doRotateMesh;
				this.onReleaseAux = this.endRotateMesh;
				this.onReleaseOutsideAux = this.endRotateMeshAux;
				
				_parent.dispatchEvent({type: "beginRotating"});
				
				var width: Number = this.fixedWidth;
				var height: Number = this.fixedHeight;
				var x: Number = Math.max(0, Math.min(_xmouse, width));
				var y: Number = Math.max(0, Math.min(_ymouse, height));
				
				_global.skse.plugins.CharGen.BeginRotateMesh(x, y);
			} else {
				this.panning = true;
				this.onMouseMove = this.doPanMesh;
				this.onReleaseAux = this.endPanMesh;
				this.onReleaseOutsideAux = this.endPanMeshAux;
				
				_parent.dispatchEvent({type: "beginPanning"});
				
				var width: Number = this.fixedWidth;
				var height: Number = this.fixedHeight;
				var x: Number = Math.max(0, Math.min(_xmouse, width));
				var y: Number = Math.max(0, Math.min(_ymouse, height));
				
				_global.skse.plugins.CharGen.BeginPanMesh(x, y);
			}
			
		}
		foreground["onPressAux"] = foreground["beginRotateMesh"];
		
		foreground["doPaintMesh"] = function()
		{
			var width: Number = this.fixedWidth;
			var height: Number = this.fixedHeight;
			var x: Number = Math.max(0, Math.min(_xmouse, width));
			var y: Number = Math.max(0, Math.min(_ymouse, height));
			
			this.doHoverMesh(x,y);
			_global.skse.plugins.CharGen.DoPaintMesh(x, y);
		}
		foreground["endPaintMesh"] = function(mouseIdx:Number, keyboardOrMouse:Number, buttonIdx:Number)
		{
			if(this.rotating || this.panning) // Don't interrupt existing action
				return undefined;
				
			this.painting = false;
			this.onMouseMove = this.doHoverMesh;
			this.onRelease = null;
			this.onReleaseOutside = null;
			_parent.dispatchEvent({type: "endPainting"});
			
			_global.skse.plugins.CharGen.EndPaintMesh();
		}
		foreground["beginPaintMesh"] = function(mouseIdx:Number, keyboardOrMouse:Number, buttonIdx:Number)
		{
			if(this.rotating || this.panning) // Don't interrupt existing action
				return undefined;
			if(this.onMouseMove != this.doHoverMesh) // Don't interrupt existing action
				return undefined;
				
			var width: Number = this.fixedWidth;
			var height: Number = this.fixedHeight;
			var x: Number = Math.max(0, Math.min(_xmouse, width));
			var y: Number = Math.max(0, Math.min(_ymouse, height));
			
			if(_global.skse.plugins.CharGen.BeginPaintMesh(x, y)) {
				this.painting = true;
				this.onMouseMove = this.doPaintMesh;
				this.onRelease = this.endPaintMesh;
				this.onReleaseOutside = this.onRelease;
				_parent.dispatchEvent({type: "beginPainting"});
			} else {
				_parent.background.onPress(mouseIdx, keyboardOrMouse, buttonIdx);
			}
		}
		foreground["onMouseMove"] = foreground["doHoverMesh"];
		foreground["onPress"] = foreground["beginPaintMesh"];
		calculateBackground();
	}
		
	// @GFx	
	private function onMouseWheel(a_delta: Number): Void
	{
		if (disableInput)
			return;
			
		for (var target = Mouse.getTopMostEntity(); target && target != undefined; target = target._parent) {
			if (target == this) {
				if (a_delta < 0) {
					_global.skse.plugins.CharGen.SetMeshCameraRadius(_global.skse.plugins.CharGen.GetMeshCameraRadius() + 1);
				} else if (a_delta > 0) {
					_global.skse.plugins.CharGen.SetMeshCameraRadius(_global.skse.plugins.CharGen.GetMeshCameraRadius() - 1);
				}
				
				calculateBackground();
			}
		}
	}
	
	public function set secondary(a_secondary: Boolean)
	{
		_secondary = a_secondary;
	}
	
	public function get secondary(): Boolean
	{
		return _secondary;
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