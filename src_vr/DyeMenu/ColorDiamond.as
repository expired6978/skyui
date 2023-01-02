class ColorDiamond extends MovieClip
{
	public var id: Number = -1;
	public var selectIndicator: MovieClip;
	public var focusIndicator: MovieClip;
	public var fill: MovieClip;
	
	private var _fillColor: Number = 0;
	private var _selected: Boolean = false;
	private var _focused: Boolean = false;
	
	function ColorDiamond()
	{
		selectIndicator._visible = false;
		focusIndicator._visible = false;
	}
	
	public function setColor(a_fillColor: Number)
	{
		_fillColor = a_fillColor;
		var colorOverlay: Color = new Color(fill);
		colorOverlay.setRGB(_fillColor & 0x00FFFFFF);
		fill._alpha = ((_fillColor >>> 24) / 0xFF) * 100;
	}
	
	public function setSelected(a_selected: Boolean)
	{
		_selected = a_selected;
		if(selectIndicator != undefined)
			selectIndicator._visible = _selected && !_focused;
		if(focusIndicator != undefined)
			focusIndicator._visible = _focused;
	}
	
	public function setFocused(a_focused: Boolean)
	{
		_focused = a_focused;
		if(selectIndicator != undefined)
			selectIndicator._visible = _selected && !_focused;
		if(focusIndicator != undefined)
			focusIndicator._visible = _focused;
	}
};
