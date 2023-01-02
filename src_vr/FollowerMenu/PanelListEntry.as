import skyui.components.list.BasicList;
import skyui.components.list.BasicListEntry;
import skyui.components.list.ListState;

import skyui.defines.Actor;

class PanelListEntry extends MovieClip
{
	/* STAGE ELEMENTS */
	private var background: MovieClip;
	private var NameField: TextField;
	private var HealthMeter: MovieClip;
	private var MagickaMeter: MovieClip;
	private var StaminaMeter: MovieClip;
	
	private var _meterLoader: MovieClipLoader;
	private var _healthMeter: MovieClip;
	private var _magickaMeter: MovieClip;
	private var _staminaMeter: MovieClip;
	
	private var healthPercent: Number;
	private var magickaPercent: Number;
	private var staminaPercent: Number;
	
	/* PRIVATE VARIABLES */	
	public function PanelListEntry()
	{
		super();
		
		_meterLoader = new MovieClipLoader();
		_meterLoader.addListener(this);
		
		NameField.textAutoSize = "shrink";
		
		_healthMeter = HealthMeter.createEmptyMovieClip("meterHealth", getNextHighestDepth());
		_magickaMeter = MagickaMeter.createEmptyMovieClip("meterMagicka", getNextHighestDepth());
		_staminaMeter = StaminaMeter.createEmptyMovieClip("meterStamina", getNextHighestDepth());
		
		_meterLoader.loadClip("extension_assets/meter.swf", _healthMeter);
		_meterLoader.loadClip("extension_assets/meter.swf", _magickaMeter);
		_meterLoader.loadClip("extension_assets/meter.swf", _staminaMeter);
	}
		
	private function onLoadInit(a_clip: MovieClip): Void
	{
		if(a_clip == _healthMeter) {
			a_clip.widget.initNumbers(background._width, 20, 0x561818, 0xDF2020, 0xFF3232, healthPercent);
			a_clip.widget.initStrings("right");
			a_clip.widget.initCommit();
			a_clip.widget._visible = true;
			a_clip._visible = true;
		} else if(a_clip == _magickaMeter) {
			a_clip.widget.initNumbers(background._width, 20, 0x0C016D, 0x284BD7, 0x3366FF, magickaPercent);
			a_clip.widget.initStrings("right");
			a_clip.widget.initCommit();
			a_clip.widget._visible = true;
			a_clip._visible = true;
		} else if(a_clip == _staminaMeter) {
			a_clip.widget.initNumbers(background._width, 20, 0x003300, 0x339966, 0x009900, staminaPercent);
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
	
	public function setEntry(a_entryObject: Object, a_state: ListState): Void
	{
		var a_actor = a_entryObject.actor;
		
		if(a_actor.fullName != undefined)
			NameField.text = a_actor.fullName;
		else
			NameField.text = a_actor.actorBase.fullName;
		
		healthPercent = (a_actor.actorValues[Actor.AV_HEALTH].current / a_actor.actorValues[Actor.AV_HEALTH].maximum);
		magickaPercent = (a_actor.actorValues[Actor.AV_MAGICKA].current / a_actor.actorValues[Actor.AV_MAGICKA].maximum);
		staminaPercent = (a_actor.actorValues[Actor.AV_STAMINA].current / a_actor.actorValues[Actor.AV_STAMINA].maximum);
		
		_healthMeter.widget.setPercent(healthPercent, false);
		_magickaMeter.widget.setPercent(magickaPercent, false);
		_staminaMeter.widget.setPercent(staminaPercent, false);
	}
}

