class DepthManager
{
	private var _depthArray: Array;

	public function DepthManager()
	{
		_depthArray = new Array();
	}

	public function onClipRemove(a_mc): Void
	{
		_depthArray.push(a_mc.getDepth());
	}

	public function onGetNextHighestDepth(): Number
	{
		if (_depthArray.length > 0)
		{
			return Number(_depthArray.pop());
		}

		return -1;
	}

	public static function InitDepthManager(a_mc: MovieClip): DepthManager
	{
		if (a_mc.depthManager != null)
			return a_mc.depthManager;

		a_mc.depthManager = new DepthManager(a_mc);

		var getNextHighestDepthFn: Function = a_mc["getNextHighestDepth"];
		a_mc["getNextHighestDepth"] = function () { 
											var freeDepth: Number = this.depthManager.onGetNextHighestDepth();
											if (freeDepth < 0)
												freeDepth = getNextHighestDepthFn.apply(this, null);
											return freeDepth;
										}

		var attachMovieFn: Function = a_mc["attachMovie"];
		a_mc["attachMovie"] = function (id: String, name: String, depth: Number, initObject: Object) {
									var attachedMc = attachMovieFn.apply(a_mc, [id, name, depth, initObject]);

									var removeMovieClipFn = attachedMc["removeMovieClip"];
									attachedMc["removeMovieClip"] = function () {
																			this._parent.depthManager.onClipRemove(this);
																			removeMovieClipFn.apply(this, null);
																		}

									return attachedMc;
								}
	}
}