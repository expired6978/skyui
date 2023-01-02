import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.Linear;

import skyui.widgets.followerpanel.PanelDefines;

class skyui.widgets.followerpanel.PanelEntry extends MovieClip
{
	/* STAGE ELEMENTS */
	private var background: MovieClip;
	private var NameField: TextField;
	private var HealthMeter: MovieClip;
	private var MagickaMeter: MovieClip;
	private var StaminaMeter: MovieClip;
	
	/* PRIVATE VARIABLES */
	private var _meterLoader: MovieClipLoader;
	
	private var _healthMeter: MovieClip;
	private var _magickaMeter: MovieClip;
	private var _staminaMeter: MovieClip;
	
	private var index: Number;
	private var formId: Number = 0;
	private var name: String = "";
	private var health: Number = 0;
	private var magicka: Number = 0;
	private var stamina: Number = 0;
	
	public var fadeInDuration: Number = 0.25;
	public var fadeOutDuration: Number = 0.75;
	public var moveDuration: Number = 1.00;
	
	public var widgetPath: String = "";
	
	private var _tweenLite: TweenLite = null;
	private var _removing: Boolean = false;
	
	private var _intervalId: Number;
	private var _updateInterval: Number = 15000;
	
	public function PanelEntry()
	{
		super();
		_meterLoader = new MovieClipLoader();
		_meterLoader.addListener(this);
		
		NameField.text = name;
		NameField.textAutoSize = "shrink";
		
		_healthMeter = HealthMeter.createEmptyMovieClip("meterHealth", getNextHighestDepth());
		_magickaMeter = MagickaMeter.createEmptyMovieClip("meterMagicka", getNextHighestDepth());
		_staminaMeter = StaminaMeter.createEmptyMovieClip("meterStamina", getNextHighestDepth());
		
		_meterLoader.loadClip(widgetPath + "skyui/meter.swf", _healthMeter);
		_meterLoader.loadClip(widgetPath + "skyui/meter.swf", _magickaMeter);
		_meterLoader.loadClip(widgetPath + "skyui/meter.swf", _staminaMeter);
		
		_y = index * background._height;		
		TweenLite.from(this, fadeInDuration, {_alpha: 0, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
		
		_intervalId = setInterval(this, "onUpdateInterval", _updateInterval);
	}
	
	public function set removeDuration(a_duration: Number)
	{
		_updateInterval = a_duration;
		resetTimer();
	}
	
	private function onLoadInit(a_clip: MovieClip): Void
	{
		if(a_clip == _healthMeter) {
			a_clip.widget.initNumbers(background._width, 20, 0x561818, 0xDF2020, 0xFF3232, health);
			a_clip.widget.initStrings("right");
			a_clip.widget.initCommit();
			a_clip.widget._visible = true;
			a_clip._visible = true;
		} else if(a_clip == _magickaMeter) {
			a_clip.widget.initNumbers(background._width, 20, 0x0C016D, 0x284BD7, 0x3366FF, magicka);
			a_clip.widget.initStrings("right");
			a_clip.widget.initCommit();
			a_clip.widget._visible = true;
			a_clip._visible = true;
		} else if(a_clip == _staminaMeter) {
			a_clip.widget.initNumbers(background._width, 20, 0x003300, 0x339966, 0x009900, stamina);
			a_clip.widget.initStrings("right");
			a_clip.widget.initCommit();
			a_clip.widget._visible = true;
			a_clip._visible = true;
		}
	}
	private function onLoadError(a_clip: MovieClip, errorCode: String): Void
	{
		if(a_clip == _healthMeter) {
			skse.Log("Failed to load health meter: " + errorCode);
		} else if(a_clip == _magickaMeter) {
			skse.Log("Failed to load magicka meter: " + errorCode);
		} else if(a_clip == _staminaMeter) {
			skse.Log("Failed to load stamina meter: " + errorCode);
		}
	}
	
	public function updatePosition(a_newIndex): Void
	{
		index = a_newIndex;

		TweenLite.to(this, moveDuration, {_y:  index * background._height, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
	}
	
	public function update(a_actor: Object): Void
	{
		if(_removing) {
			//trace("Restoring: " + a_actor.actorBase.fullName);
			restore();
		}
		
		var healthPercent: Number = (a_actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current / a_actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum);
		var magickaPercent: Number = (a_actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current / a_actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum);
		var staminaPercent: Number = (a_actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current / a_actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum);
		
		//trace("Updating " + a_actor.actorBase.fullName + " Health: " + healthPercent + " Magicka: " + magickaPercent + " Stamina: " + staminaPercent);
		
		resetTimer();
		
		_healthMeter.widget.setPercent(healthPercent, false);
		_magickaMeter.widget.setPercent(magickaPercent, false);
		_staminaMeter.widget.setPercent(staminaPercent, false);
		
		if(a_actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current <= 0)
			_healthMeter.widget.startFlash();
		if(a_actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current <= 0)
			_magickaMeter.widget.startFlash();
		if(a_actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current <= 0)
			_staminaMeter.widget.startFlash();
	}
		
	public function restore(): Void
	{
		if(_removing) {
			if(_tweenLite) {
				_tweenLite.kill();
				_tweenLite = TweenLite.to(this, fadeOutDuration, {_alpha: 100, easing: Linear.easeNone});
			}
			_removing = false;
		}
	}

	public function remove(): Void
	{
		_removing = true;
		_tweenLite = TweenLite.to(this, fadeOutDuration, {_alpha: 0, onCompleteScope: _parent, onComplete: _parent.onActorRemoved, onCompleteParams: [this], overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
	}
	
	public function resetTimer()
	{
		clearInterval(_intervalId);
		_intervalId = setInterval(this, "onUpdateInterval", _updateInterval);
	}
	
	public function onUpdateInterval()
	{
		if(!_removing)
			remove();
	}
}

