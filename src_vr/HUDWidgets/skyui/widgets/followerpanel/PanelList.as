import gfx.events.EventDispatcher;

import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.Linear;

import skyui.widgets.followerpanel.PanelDefines;

class skyui.widgets.followerpanel.PanelList extends MovieClip
{
	public var widgetPath: String;
	private var paddingBottom: Number;
	
	private var mask: MovieClip;
	private var _actorPanel: MovieClip;
	
	/* PRIVATE VARIABLES */
	private var _actorArray: Array;
	
	private var _maxEntries: Number = 5;
	private var _fadeInDuration: Number = 0.25;
	private var _fadeOutDuration: Number = 0.75;
	private var _moveDuration: Number = 1.0;
	private var _removeDuration: Number = 15000;
	
	/* GFX */
	public var dispatchEvent: Function;
	public var addEventListener: Function;
	
	/* PUBLIC FUNCTIONS */
	public function PanelList()
	{
		super();
		EventDispatcher.initialize(this);
		_actorArray = new Array();
		setMask(mask);
	}
	
	public function get actors(): Array
	{
		return _actorArray;
	}
	
	public function get totalHeight(): Number
	{
		return _actorArray.length * _actorArray[0].background._height;
	}
	
	public function get maxHeight(): Number
	{
		return _actorArray[0].background._height * maxEntries;
	}
	
	public function removeActor(a_actor: Object)
	{
		var totalActors: Number = _actorArray.length;
		for(var i = 0; i < totalActors; i++)
		{
			if(_actorArray[i].formId == a_actor.formId) {
				_actorArray[i].remove();
				break;
			}
		}
	}
	
	public function addActor(a_actor: Object): MovieClip
	{
		if(_actorArray.length == 0) // Previously had no items, fadein
			dispatchEvent({type:"startFadeIn"});
			
		var a_name: String = "";
		if(a_actor.fullName != undefined)
			a_name = a_actor.fullName;
		else
			a_name = a_actor.actorBase.fullName;
		
		var initObject: Object = {index: _actorArray.length,
									formId: a_actor.formId,
									name: a_name,
									health: (a_actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current / a_actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum),
									magicka: (a_actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current / a_actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum),
									stamina: (a_actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current / a_actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum),
									fadeInDuration: this.fadeInDuration,
									fadeOutDuration: this.fadeOutDuration,
									moveDuration: this.moveDuration,
									removeDuration: this.removeDuration,
									widgetPath: this.widgetPath
								  };
								  
		var entry: MovieClip = attachMovie("PanelEntry", a_actor.formId, getNextHighestDepth(), initObject);
		_actorArray.push(entry);
		updateBackground();
		return entry;
	}
	
	// After the actor tweens out
	public function onActorRemoved(a_actorClip: MovieClip): Void
	{
		var removedActorClip: MovieClip = a_actorClip;
		var actorIdx: Number = removedActorClip.index;

		_actorArray.splice(actorIdx, 1);
		removedActorClip.removeMovieClip();
		
		if (_actorArray.length > 0){
			var Clip: MovieClip;

			for (var i: Number = actorIdx; i < _actorArray.length; i++) {
				Clip = _actorArray[i];
				Clip.updatePosition(i);
				updateBackground();
			}
		} else {
			dispatchEvent({type:"startFadeOut"});
		}
		
		updateBackground();
	}
	
	private function updateBackground()
	{
		TweenLite.to(mask, moveDuration, {_height: Math.min(totalHeight, maxHeight), overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		dispatchEvent({type:"updateBackground", duration: moveDuration, height: Math.min(totalHeight + paddingBottom, maxHeight + paddingBottom)});
		//TweenLite.to(_actorPanel.background, duration, {_height: Math.min(totalHeight + paddingBottom, maxHeight + paddingBottom), overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
	}
	
	public function get maxEntries(): Number
	{
		return _maxEntries;
	}
	
	public function get fadeInDuration(): Number
	{
		return _fadeInDuration;
	}
	
	public function get fadeOutDuration(): Number
	{
		return _fadeOutDuration;
	}
	
	public function get moveDuration(): Number
	{
		return _moveDuration;
	}
	
	public function get removeDuration(): Number
	{
		return _removeDuration;
	}
	
	public function set maxEntries(a_maxEntries: Number)
	{
		_maxEntries = a_maxEntries;
		updateBackground();
	}
	
	public function set fadeInDuration(a_fadeInDuration: Number)
	{
		_fadeInDuration = a_fadeInDuration;
		for(var i = 0; i < _actorArray.length; i++) {
			_actorArray[i].fadeInDuration = a_fadeInDuration;
		}
	}
	
	public function set fadeOutDuration(a_fadeOutDuration: Number)
	{
		_fadeOutDuration = a_fadeOutDuration;
		for(var i = 0; i < _actorArray.length; i++) {
			_actorArray[i].fadeOutDuration = a_fadeOutDuration;
		}
	}
	
	public function set moveDuration(a_moveDuration: Number)
	{
		_moveDuration = a_moveDuration;
		for(var i = 0; i < _actorArray.length; i++) {
			_actorArray[i].moveDuration = a_moveDuration;
		}
	}
	
	public function set removeDuration(a_removeDuration: Number)
	{
		_removeDuration = a_removeDuration;
		for(var i = 0; i < _actorArray.length; i++) {
			_actorArray[i].removeDuration = a_removeDuration;
		}
	}
}
