class HudExtension extends MovieClip
{
	public function HudExtension()
	{
		/*
			Runtime Magic starts here!

			I (Mardoxx), in my infinite wisdom thought that no one would ever, EVER want to load an swf beneath SkyUI's widgets,
				so I wrote this in to SkyUI's WidgetLoader class:

					// -16384 places the WidgetContainer beneath all elements which were added to the stage in Flash.
					_widgetContainer = _root.createEmptyMovieClip("WidgetContainer", -16384);

				So the order on the stage would be (with increasing depth, i.e. lowest to highest):
					WidgetContainer
					HUDMovieBaseInstance

				with nothing being able to load below WidgetContainer.

				What we do here is override _root.createEmptyMovieClip and branch off when it tries to create "WidgetContainer"
					forcing it to load to a higher depth.

				Order of creation of movieclips is as follows (with increasing time i.e. first loaded to last):
					HUDMovieBaseInstance (intrinsic)
					MeterContainer (hudextensions.dll)
					WidgetContainer (SkyUI -- optional)

				We swap HUDMovieBaseInstance with MeterContainer, so the meters render below the hud [1]
				When (if) WidgetContainer is loaded it would now load above everything else, so we swap this with HUDMovieBaseInstance [2]
				so the the order depth becomes (with increasing depth):
					MeterContainer
					WidgetContainer
					HUDMovieBaseInstance

			Lesson learned, perhaps?
		*/

		var createEmptyMovieClipFn: Function = _root["createEmptyMovieClip"];
		_root["createEmptyMovieClip"] = function (name: String, depth: Number)
										{ 
											if (name == "WidgetContainer")
											{
												var newDepth: Number = _root.getNextHighestDepth();
												var createdMc: MovieClip = createEmptyMovieClipFn.apply(_root, [name, newDepth]);
												// [2]
												createdMc.swapDepths(_root["HUDMovieBaseInstance"]);
												// unregister
												_root["createEmptyMovieClip"] = createEmptyMovieClipFn;
												return createdMc;
											}

											return createEmptyMovieClipFn.apply(this, [name, depth]);
										}
	}
	
	public function onLoad(): Void
	{
		// [1]
		var floatingContainer: MovieClip = _root.createEmptyMovieClip("FloatingContainer", _root.getNextHighestDepth());
		_root["HUDMovieBaseInstance"].swapDepths(_root["FloatingContainer"]);
		this._parent["floatingWidgets"].initialize(floatingContainer);
	}
}