import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.Linear;

import skyui.widgets.followerpanel.PanelDefines;
import skyui.widgets.WidgetBase;

class skyui.widgets.followerpanel.ActorPanel extends WidgetBase
{	
	/* CONSTANTS */
	static private var ACTOR_FADE_IN_DURATION: Number = 0.25;
	static private var ACTOR_FADE_OUT_DURATION: Number = 0.75;
	static private var ACTOR_MOVE_DURATION: Number = 1.00;
	static private var ACTOR_REMOVE_DURATION: Number = 15000;
	static private var ACTOR_MAX_ENTRIES: Number = 5;
	static private var ACTOR_ENTRY_PADDING: Number = 10;
	
	/* STAGE ELEMENTS */
	private var content: MovieClip;
	private var background: MovieClip;
	private var panelList: MovieClip;

	/* PUBLIC VARIABLES */
	public var updateInterval: Number = 150;
	public var widgetPath: String = "";

	/* PRIVATE VARIABLES */
	private var _actorList: Array;
	private var _intervalId: Number;
	
	// TEST CODE
	//public var _tempList: Array;

	public function ActorPanel()
	{
		super();
		panelList = content.list;
		background = content.background;
		_actorList = new Array();
		//_tempList = new Array(); // TEST CODE
	}
	
	// TEST CODE
	public function onLoad()
	{
		panelList.fadeInDuration = ACTOR_FADE_IN_DURATION;
		panelList.fadeOutDuration = ACTOR_FADE_OUT_DURATION;
		panelList.moveDuration = ACTOR_MOVE_DURATION;
		panelList.removeDuration = ACTOR_REMOVE_DURATION;
		panelList.maxEntries = ACTOR_MAX_ENTRIES;
		panelList.paddingBottom = ACTOR_ENTRY_PADDING;
		panelList.widgetPath = _root.widgetLoaderContainer.widgetLoader._rootPath + "widgets/";
		panelList.addEventListener("startFadeIn", this, "onFadeIn");
		panelList.addEventListener("startFadeOut", this, "onFadeOut");
		panelList.addEventListener("updateBackground", this, "onUpdateBackground");
		/*
		var actor = {actorBase: {fullName: "Jack"}, formType: 1, formId: 1, actorValues: [{base: 0, current: 0, maximum: 0},
												  {base: 10, current: 1, maximum: 0},
												  {base: 10, current: 2, maximum: 0},
												  {base: 10, current: 3, maximum: 0},
												  {base: 10, current: 4, maximum: 0},
												  {base: 10, current: 5, maximum: 0},
												  {base: 10, current: 6, maximum: 0},
												  {base: 10, current: 7, maximum: 0},
												  {base: 10, current: 8, maximum: 0},
												  {base: 10, current: 9, maximum: 0},
												  {base: 10, current: 10, maximum: 0},
												  {base: 10, current: 11, maximum: 0},
												  {base: 10, current: 12, maximum: 0},
												  {base: 10, current: 13, maximum: 0},
												  {base: 10, current: 14, maximum: 0},
												  {base: 10, current: 15, maximum: 0},
												  {base: 10, current: 16, maximum: 0},
												  {base: 10, current: 17, maximum: 0},
												  {base: 10, current: 18, maximum: 0},
												  {base: 10, current: 19, maximum: 0},
												  {base: 10, current: 20, maximum: 0},
												  {base: 10, current: 21, maximum: 0},
												  {base: 100, current: 22, maximum: 100},
												  {base: 100, current: 23, maximum: 100},
												  {base: 100, current: 24, maximum: 100},
												  {base: 100, current: 25, maximum: 100},
												  {base: 100, current: 26, maximum: 100},
												  {base: 100, current: 27, maximum: 100},
												  {base: 100, current: 28, maximum: 100},
												  {base: 100, current: 29, maximum: 100},
												  {base: 100, current: 30, maximum: 100},
												  {base: 100, current: 31, maximum: 100}]};
		addSingleActor(actor);
		
		_tempList.push([{id: PanelDefines.ACTORVALUE_HEALTH, current: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].base},
						{id: PanelDefines.ACTORVALUE_MAGICKA, current: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].base},
						{id: PanelDefines.ACTORVALUE_STAMINA, current: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].base}]);
		
		actor = copyObject(actor);
		actor.actorBase.fullName = "Joe";
		actor.formId = 10;
		actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum = 100;
		actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum = 100;
		actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum = 100;
		
		addSingleActor(actor);
		
		_tempList.push([{id: PanelDefines.ACTORVALUE_HEALTH, current: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].base},
						{id: PanelDefines.ACTORVALUE_MAGICKA, current: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].base},
						{id: PanelDefines.ACTORVALUE_STAMINA, current: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].base}]);
		
		actor = copyObject(actor);
		actor.actorBase.fullName = "Jim";
		actor.formId = 11;
		actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum = 100;
		actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum = 100;
		actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum = 100;
		
		addSingleActor(actor);
		
		_tempList.push([{id: PanelDefines.ACTORVALUE_HEALTH, current: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].base},
						{id: PanelDefines.ACTORVALUE_MAGICKA, current: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].base},
						{id: PanelDefines.ACTORVALUE_STAMINA, current: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].base}]);
		
		actor = copyObject(actor);
		actor.actorBase.fullName = "Jerry";
		actor.formId = 12;
		actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum = 100;
		actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum = 100;
		actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum = 100;
		
		addSingleActor(actor);
		
		_tempList.push([{id: PanelDefines.ACTORVALUE_HEALTH, current: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].base},
						{id: PanelDefines.ACTORVALUE_MAGICKA, current: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].base},
						{id: PanelDefines.ACTORVALUE_STAMINA, current: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].base}]);
		
		actor = copyObject(actor);
		actor.actorBase.fullName = "Sally";
		actor.formId = 13;
		actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum = 100;
		actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum = 100;
		actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum = 100;
		
		addSingleActor(actor);
		
		_tempList.push([{id: PanelDefines.ACTORVALUE_HEALTH, current: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].base},
						{id: PanelDefines.ACTORVALUE_MAGICKA, current: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].base},
						{id: PanelDefines.ACTORVALUE_STAMINA, current: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].base}]);
		actor = copyObject(actor);
		actor.actorBase.fullName = "Wally";
		actor.formId = 14;
		actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum = 100;
		actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum = 100;
		actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current = 100 * Math.random();
		actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum = 100;
		
		addSingleActor(actor);
		
		_tempList.push([{id: PanelDefines.ACTORVALUE_HEALTH, current: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_HEALTH].base},
						{id: PanelDefines.ACTORVALUE_MAGICKA, current: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_MAGICKA].base},
						{id: PanelDefines.ACTORVALUE_STAMINA, current: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].current, maximum: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].maximum, base: actor.actorValues[PanelDefines.ACTORVALUE_STAMINA].base}]);
		

		setInterval(this, "timeoutChange", 1000);
		//setInterval(this, "timeoutRemove", 10000);*/
	}
	
	public function onUpdateInterval()
	{
		var totalActors = _actorList.length;
		for(var i = 0; i < totalActors; i++) {
			// Request new values
			var actorValues = new Array();
			//var actorValues = _tempList[i];// TEST CODE
			skse.RequestActorValues(_actorList[i].formId >>> 0, 
									[PanelDefines.ACTORVALUE_HEALTH, 
									 PanelDefines.ACTORVALUE_MAGICKA,
									 PanelDefines.ACTORVALUE_STAMINA],
									actorValues);
			
			// Get the old values
			var oldValues = [_actorList[i].actorValues[PanelDefines.ACTORVALUE_HEALTH],
							_actorList[i].actorValues[PanelDefines.ACTORVALUE_MAGICKA],
							_actorList[i].actorValues[PanelDefines.ACTORVALUE_STAMINA]];
			
			var changed: Boolean = false;
			for(var s = 0; s < oldValues.length; s++)
			{
				// Replace changed values
				if(oldValues[s].current != actorValues[s].current || oldValues[s].maximum != actorValues[s].maximum || oldValues[s].base != actorValues[s].base) {
					var index: Number = actorValues[s].id;
					_actorList[i].actorValues[index].current = actorValues[s].current;
					_actorList[i].actorValues[index].maximum = actorValues[s].maximum;
					_actorList[i].actorValues[index].base = actorValues[s].base;
					changed = true;
				}
			}
			
			// One of our actor values changed
			if(changed)
			{
				var totalShown: Number = panelList.actors.length;
				
				var updated: Boolean = false;
				for(var n = 0; n < totalShown; n++)
				{
					// Actor is already shown
					if((_actorList[i].formId >>> 0) == (panelList.actors[n].formId >>> 0)) {
						//skse.Log("Updating: " + _actorList[i].actorBase.fullName + " C:" + (actorValues[0].current|0) + " " + (actorValues[1].current|0) + " " + (actorValues[2].current|0) + " M:" + (actorValues[0].maximum|0) + " " + (actorValues[1].maximum|0) + " " + (actorValues[2].maximum|0) + " B:" + (actorValues[0].base|0) + " " + (actorValues[1].base|0) + " " + (actorValues[2].base|0));
						panelList.actors[n].update(_actorList[i]);
						updated = true;
						break;
					}
				}
				
				// Not in our list, add them
				if(!updated) {
					//skse.Log("Added: " + _actorList[i].actorBase.fullName);
					panelList.addActor(_actorList[i]);
				}
			}
		}
	}
	
	// TEST CODE
	/*private function timeoutChange()
	{
		var index: Number = (_actorList.length * Math.random())|0;
		_tempList[index][0].current = (100 * Math.random())|0;
		_tempList[index][1].current = (100 * Math.random())|0;
		_tempList[index][2].current = (100 * Math.random())|0;
	}*/
	
	public function onFadeIn()
	{
		gotoAndPlay("FadeIn");
	}
	
	public function onFadeOut()
	{
		gotoAndPlay("FadeOut");
	}
	
	public function onUpdateBackground(event: Object)
	{
		TweenLite.to(background, event.duration, {_height: event.height, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
	}

	/* PAPYRUS FUNCTIONS */
	public function addPanelActors(a_form: Object)
	{
		if(a_form.formType == PanelDefines.FORMTYPE_LIST)
		{
			skse.ExtendForm(a_form.formId >>> 0, a_form, true, false);
			var totalForms: Number = a_form.forms.length;
			for(var i = 0; i < totalForms; i++) {
				addSingleActor(a_form.forms[i]);
			}
		} else {
			addSingleActor(a_form);
		}
	}
	
	public function addSingleActor(a_form: Object)
	{
		if(a_form == undefined || a_form.formId == undefined || a_form.formId == 0) {
			skse.Log("Error, undefined formId");
			return;
		}
		
		skse.ExtendForm(a_form.formId >>> 0, a_form, true, false);
		if(a_form.actorBase == undefined || a_form.actorBase.formId == undefined  || a_form.actorBase.formId == 0) {
			skse.Log("Error, bad actor");
			return;
		}
		
		skse.ExtendForm(a_form.actorBase.formId >>> 0, a_form.actorBase, true, false);
		
		// We're about to add our first actor, start polling
		if(_actorList.length == 0) {
			clearInterval(_intervalId);
			_intervalId = setInterval(this, "onUpdateInterval", updateInterval);
		}
		
		_actorList.push(a_form);
	}
	
	public function removePanelActors(a_form: Object)
	{
		if(a_form.formType == PanelDefines.FORMTYPE_LIST)
		{
			var totalForms: Number = a_form.forms.length;
			for(var i = 0; i < totalForms; i++) {
				removeSingleActor(a_form.forms[i]);
			}
		} else {
			removeSingleActor(a_form);
		}
	}
	
	public function removeSingleActor(a_form: Object)
	{
		var totalActors: Number = _actorList.length;
		for(var i = 0; i < totalActors; i++) {
			if((_actorList[i].formId >>> 0) == (a_form.formId >>> 0)) {
				panelList.removeActor(a_form);
				_actorList.splice(i, 1);
			}
		}
		
		// No actors left, kill the update
		if(_actorList.length == 0) {
			clearInterval(_intervalId);
		}
	}
	
	public function setScale(a_scale: Number)
	{
		_xscale = a_scale;
		_yscale = a_scale;
	}
		
	public function setEntryCount(a_entries: Number)
	{
		if(a_entries > 0) {
			panelList.maxEntries = a_entries;
		}
	}
	
	public function setFadeInDuration(a_fadeInDuration: Number)
	{
		panelList.fadeInDuration = a_fadeInDuration;
	}
	
	public function setFadeOutDuration(a_fadeOutDuration: Number)
	{
		panelList.fadeOutDuration = a_fadeOutDuration;
	}
	
	public function setMoveDuration(a_moveDuration: Number)
	{
		panelList.moveDuration = a_moveDuration;
	}
	
	public function setRemoveDuration(a_removeDuration: Number)
	{
		panelList.removeDuration = a_removeDuration;
	}

	/* PRIVATE FUNCTIONS */
	/*function copyObject(obj)
	{
	   var i;
	   var o;
	
	   o = new Object()
	
	   for(i in obj)
	   {
		  if(obj[i] instanceof Object)
		  {
			  o[i] = copyObject(obj[i]);
		  }
		  else
		  {
			  o[i] = i;
		  }
	   }
	
	   return(o);
	}*/
}

