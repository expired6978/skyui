import gfx.managers.FocusHandler;
import gfx.events.EventDispatcher;

class DialogTweenManager
{
	
  /* PRIVATE VARIABLES */
  
	// There can only be one open dialog at a time.
	private static var _activeDialog: BasicTweenDialog;
	private static var _previousFocus: Object;
	private static var _closeCallback: Function;
	
	private static var _target: Object;
	private static var _handleInput: Function;
	private static var _SetPlatform: Function;
	
  /* PUBLIC FUNCTIONS */
	
	public static function open(a_target: MovieClip, a_linkageID: String, a_init: Object): MovieClip
	{
		if (_activeDialog)
			close();
		
		_previousFocus = FocusHandler.instance.getFocus(0);

		_activeDialog = BasicTweenDialog(a_target.attachMovie(a_linkageID, "dialog", a_target.getNextHighestDepth(), a_init));
		FocusHandler.instance.setFocus(_activeDialog, 0);
		
		_target = a_target;
		_handleInput = a_target.handleInput;
		_SetPlatform = a_target.SetPlatform;
		
		a_target.SetPlatform = function(a_platform: Number, a_bPS3Switch: Boolean): Void
		{
			_SetPlatform(a_platform, a_bPS3Switch);
			_activeDialog.SetPlatform(a_platform, a_bPS3Switch);
		}
		
		_activeDialog.openDialog();
		
		return _activeDialog;
	}
	
	public static function close(): Void
	{
		FocusHandler.instance.setFocus(_previousFocus, 0);
		
		_target.handleInput = _handleInput;
		_target.SetPlatform = _SetPlatform;
		
		_handleInput = null;
		_SetPlatform = null;
		_target = null;
		
		_activeDialog.closeDialog();
		_activeDialog = null;
	}
}