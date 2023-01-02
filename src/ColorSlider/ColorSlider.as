import flash.geom.Matrix;
import flash.display.BitmapData;

import skyui.util.ColorFunctions;

class ColorSlider extends skyui.components.Slider
{
	private var _colorOverlay: MovieClip;
	private var _hueColors: Array;
	private var _satColors: Array;
	private var _valColors: Array;

	public function ColorSlider()
	{
		super();
		_hueColors = [0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000, 0x000000];
		_satColors = [0x000000, 0x000000];
		_valColors = [0x000000, 0xFFFFFF];
	}

	private var _hsvType: String;
	public function get hsvType(): String { return _hsvType; }
	public function set hsvType(a_hsvType: String): Void
	{
		if (_hsvType == a_hsvType)
			return;

		_hsvType = a_hsvType;

		minimum = 0;
		maximum = (_hsvType == "hue") ? 360 : 100;
	}

	public function setColor(a_hsv: Array): Void
	{
		if (_hsvType == "hue") {
			var pureColors: Array = [0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF, 0xFF0000];
			_hueColors.splice(0);

			var color: Array;
			for (var i: Number = 0; i < pureColors.length; i++) {
				color = ColorFunctions.hexToHsv(pureColors[i]);
				color[1] = a_hsv[1];
				color[2] = a_hsv[2];
				_hueColors.push(ColorFunctions.hsvToHex(color));
			}
		} else if (_hsvType == "sat") {
			_satColors = [ColorFunctions.hsvToHex([a_hsv[0], 0, a_hsv[2]]), ColorFunctions.hsvToHex([a_hsv[0], 100, a_hsv[2]])]
		} else {
			_valColors = [0x000000, ColorFunctions.hsvToHex([a_hsv[0], a_hsv[1], 100])];
		}

		drawGradient();
	}
	
  /* PRIVATE FUNCTIONS */

	private function configUI(): Void
	{
		super.configUI();

		offsetLeft = leftArrow._width;
		offsetRight = rightArrow._width;

		_colorOverlay = track.colorOverlay;

		drawGradient();

		liveDragging = true;
	}

	private function drawGradient(): Void
	{
		if (_colorOverlay == undefined)
			return;

		var colors: Array = [];
		var alphas: Array = [];
		var ratios: Array = [];
		var matrix: Matrix;

		var width: Number = _colorOverlay.background._width;
		var height: Number = _colorOverlay.background._height;

		if (_colorOverlay.gradient == undefined)
			_colorOverlay.background._visible = false;
		else
			_colorOverlay.gradient.removeMovieClip();

		matrix = new Matrix();
		matrix.createGradientBox(width, height);

		switch(_hsvType) {
			case "hue":
				colors = _hueColors;
				alphas = [100, 100, 100, 100, 100, 100, 100];
				ratios = [0, 42.5, 85, 127.5, 170, 212.5, 255];
				break;

			case "sat":
				colors = _satColors;
				alphas = [100, 100];
				ratios = [0, 255];
				break;

			case "val":
				colors = _valColors;
				alphas = [100, 100];
				ratios = [0, 255];
				break;
		}

		var gradient: MovieClip = _colorOverlay.createEmptyMovieClip("gradient", _colorOverlay.getNextHighestDepth());
		gradient.beginGradientFill("linear", colors, alphas, ratios, matrix);
		gradient.moveTo(0, 0);
		gradient.lineTo(0, height);
		gradient.lineTo(width, height);
		gradient.lineTo(width, 0);
		gradient.lineTo(0, 0);
		gradient.endFill();
	}
}