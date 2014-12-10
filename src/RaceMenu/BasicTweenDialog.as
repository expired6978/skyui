﻿import gfx.events.EventDispatcher;
import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;
import com.greensock.OverwriteManager;
import com.greensock.easing.Linear;

class BasicTweenDialog extends MovieClip
{	
  /* CONSTANTS */
  
	public static var OPEN = 0;
	public static var CLOSED = 1;
	public static var OPENING = 2;
	public static var CLOSING = 3;
	
	
  /* PRIVATE VARIABLES */
	
	private var _dialogState: Number = -1;	
	
  /* INITIALIZATION */
	
	public function BasicTweenDialog()
	{
		TweenPlugin.activate([AutoAlphaPlugin]);
		EventDispatcher.initialize(this);
		Mouse.addListener(this);
	}
	

  /* PUBLIC FUNCTIONS */
  
	// @mixin by EventDispatcher
	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;
	
	public function openDialog(): Void
	{
		setDialogState(OPENING);
		TweenLite.from(this, 0.4, {autoAlpha: 0, overwrite: "all", easing: Linear.easeNone, onComplete: fadedInFunc, onCompleteParams:[this]});
	}
	
	public function closeDialog(): Void
	{
		setDialogState(CLOSING);
		TweenLite.to(this, 0.4, {autoAlpha: 0, overwrite: "all", easing: Linear.easeNone, onComplete: fadedOutFunc, onCompleteParams:[this]});
	}
	
	public var onDialogOpening: Function;
	public var onDialogOpen: Function;
	public var onDialogClosing: Function;
	public var onDialogClosed: Function;
	public var SetPlatform: Function;
	
  /* PRIVATE FUNCTIONS */
	
	private function setDialogState(a_newState: Number): Void
	{
		if (_dialogState == a_newState)
			return;
			
		_dialogState = a_newState;
		
		if (a_newState == OPENING) {
			if (onDialogOpening)
				onDialogOpening();
			dispatchEvent({type: "dialogOpening"});
			
		} else if (a_newState == OPEN) {
			if (onDialogOpen)
				onDialogOpen();
			dispatchEvent({type: "dialogOpen"});

		} else if (a_newState == CLOSING) {
			if (onDialogClosing)
				onDialogClosing();
			dispatchEvent({type: "dialogClosing"});

		} else if (a_newState == CLOSED) {
			if (onDialogClosed)
				onDialogClosed();
			dispatchEvent({type: "dialogClosed"});
			
			removeAllEventListeners();
			this.removeMovieClip();
		}
	}
	
	private function fadedInFunc(param)
	{
		param.setDialogState(BasicTweenDialog.OPEN);
	}
	
	private function fadedOutFunc(param)
	{
		param.setDialogState(BasicTweenDialog.CLOSED);
	}
}