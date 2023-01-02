import gfx.events.EventDispatcher;

class TextCategoryButtons extends MovieClip
{
	public var buttonLeft: MovieClip;
	public var buttonRight: MovieClip;
	
	public var triggerLeft: MovieClip;
	public var triggerRight: MovieClip;
	
	public var background: MovieClip;
	
	public var dispatchEvent: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	
	public var categoryList: TextCategoryList;
	
	function TextCategoryButtons()
	{
		super();
		
		categoryList = _parent.slidingCategoryList.categoryList;
		
		Mouse.addListener(this);
		
		buttonRight._alpha = buttonLeft._alpha = 40;
		
		EventDispatcher.initialize(this);
		
		triggerLeft.onRollOver = function()
		{
			_parent.buttonLeft._alpha = 100;
		}
		
		triggerLeft.onRollOut = function()
		{
			_parent.buttonLeft._alpha = 40;
		}
		triggerLeft.onReleaseOutside = triggerLeft.onRollOut;

		triggerLeft.onPress = function()
		{
			_parent.dispatchEvent({type: "pressLeft"});
		}
		
		triggerRight.onRollOver = function()
		{
			_parent.buttonRight._alpha = 100;
		}
		
		triggerRight.onRollOut = function()
		{
			_parent.buttonRight._alpha = 40;
		}
		triggerRight.onReleaseOutside = triggerRight.onRollOut;

		triggerRight.onPress = function()
		{
			_parent.dispatchEvent({type: "pressRight"});
		}
	}	
	
	private function onMouseWheel(a_delta: Number): Void
	{
		if (categoryList.disableInput)
			return;
			
		for (var target = Mouse.getTopMostEntity(); target && target != undefined; target = target._parent) {
			if (target == this || target == categoryList || target == categoryList.background || target == this.background) {
				if (a_delta < 0) {
					categoryList.moveSelectionRight(false);
					break;
				} else {
					categoryList.moveSelectionLeft(false);
					break;
				}
			}
		}
	}
}