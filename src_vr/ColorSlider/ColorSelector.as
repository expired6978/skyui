import gfx.core.UIComponent;

import skyui.util.ColorFunctions;

class ColorSelector extends UIComponent
{
  /* STAGE ELEMENTS */
	public var sliderHue: ColorSlider;
	public var sliderSat: ColorSlider;
	public var sliderVal: ColorSlider;
	public var currentColor: MovieClip;

  /* PRIVATE VARIABLES */

	private var _hsv: Array;
	private var _colorTimer: Number;

	public function ColorSelector()
	{
		super();

		_hsv = [0, 0, 0];
	}

	public function configUI(): Void
	{
		super.configUI();

		sliderHue.hsvType = "hue";
		sliderSat.hsvType = "sat";
		sliderVal.hsvType = "val";

		sliderHue.addEventListener("change", this, "onHueSliderChange");
		sliderSat.addEventListener("change", this, "onSatSliderChange");
		sliderVal.addEventListener("change", this, "onValSliderChange");

		//setColor(0xFF0000);
	}

	public function setColor(a_hex: Number): Void
	{
		_hsv = ColorFunctions.hexToHsv(a_hex);

		sliderHue.value = _hsv[0];
		sliderSat.value = _hsv[1];
		sliderVal.value = _hsv[2];

		sliderHue.setColor(_hsv);
		sliderSat.setColor(_hsv);
		sliderVal.setColor(_hsv);

		var colorOverlay: Color = new Color(currentColor);
		colorOverlay.setRGB(a_hex);
	}

	public function onHueSliderChange(a_event: Object): Void
	{
		var newHue: Number = a_event.target.value;
		_hsv[0] = newHue;

		sliderSat.setColor(_hsv);
		sliderVal.setColor(_hsv);

		var colorOverlay: Color = new Color(currentColor);
		colorOverlay.setRGB(ColorFunctions.hsvToHex(_hsv));
	}

	public function onSatSliderChange(a_event: Object): Void
	{
		var newSat: Number = a_event.target.value;
		_hsv[1] = newSat;

		sliderHue.setColor(_hsv);
		sliderVal.setColor(_hsv);

		var colorOverlay: Color = new Color(currentColor);
		colorOverlay.setRGB(ColorFunctions.hsvToHex(_hsv));
	}

	public function onValSliderChange(a_event: Object): Void
	{
		var newVal: Number = a_event.target.value;
		_hsv[2] = newVal;

		sliderHue.setColor(_hsv);
		sliderSat.setColor(_hsv);

		var colorOverlay: Color = new Color(currentColor);
		colorOverlay.setRGB(ColorFunctions.hsvToHex(_hsv));
	}
}