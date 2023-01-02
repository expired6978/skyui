import flash.geom.Transform;
import flash.geom.ColorTransform;
import flash.geom.Matrix;

import skyui.util.ColorFunctions;

class ColorPicker extends MovieClip
{
	var hueBar: MovieClip;
	var saturationBar: MovieClip;
	var valueBar: MovieClip;
	var resultBox: MovieClip;
	
	public function ColorPicker()
	{
		super();
		
		hueBar = drawHueGradient(360, 20);		
		saturationBar = drawSaturationGradient(360, 20);
		saturationBar._y = 25;
		valueBar = drawValueGradient(360, 20);
		valueBar._y = 50;
		resultBox = drawResult(50, 50);
		resultBox._y = 75;
		resultBox._x = 360/2;
		
		
		setColor(0xFF0000);
	}
	
	function onLoad()
	{
		setInterval(this, "timeout", 1000);
	}
	
	function timeout()
	{
		setColor(0xFFFFFF * Math.random());
	}
	
	public function setColor(color: Number)
	{
		var hsv = ColorFunctions.hexToHsv(color);
		var fullSat = ColorFunctions.hsvToHex([hsv[0], 100, hsv[2]]);
		var fullValue = ColorFunctions.hsvToHex([hsv[0], hsv[1], 100]);	
		
		hueBar.valueClip._alpha = 100 - hsv[2];
		hueBar.saturationClip._alpha = 100 - hsv[1];
		
		saturationBar.valueClip._alpha = 100 - hsv[2];
		valueBar.saturationClip._alpha = 100 - hsv[1];
		
		setClipColor(saturationBar.colorClip, fullSat);
		setClipColor(valueBar.colorClip, fullValue);
		
		setClipColor(resultBox, color);
	}
	
	private function setClipColor(sourceClip: MovieClip, color: Number)
	{
		var tf: Transform = new Transform(sourceClip);
		var colorTf: ColorTransform = new ColorTransform();
		colorTf.rgb = color;
		tf.colorTransform = colorTf;
	}
	
	private function drawResult(w: Number, h: Number): MovieClip
	{
		var matrix = new Matrix();
		var resultClip = this.createEmptyMovieClip("result", this.getNextHighestDepth());
		matrix.createBox(w, h);
		resultClip.beginFill(0x000000);
		resultClip.moveTo(0,0);
		resultClip.lineTo(w, 0);
		resultClip.lineTo(w, h);
		resultClip.lineTo(0, h);
		resultClip.lineTo(0, 0);
		resultClip.endFill();
		return resultClip;
	}
	
	private function drawHueGradient(w: Number, h: Number): MovieClip
	{		
		var hueGradient = this.createEmptyMovieClip("hueGradient", this.getNextHighestDepth());
		
		var colors: Array = [0xFF0000, 0xFFFF00, 0x00FF00, 0x00FFFF, 0x0000FF, 0xFF00FF, 0xFF0000];
		var alphas: Array = [100,      100,      100,      100,	 	 100, 	   100,		 100];
		var ratios: Array = [0,        43,       85,       128,      170,      213,      255];
		var matrix: Matrix = new Matrix();
				
		var hueClip = hueGradient.createEmptyMovieClip("hueClip", hueGradient.getNextHighestDepth());
		
		matrix.createGradientBox(w, h);
		hueClip.beginGradientFill("linear", colors, alphas, ratios, matrix);
		hueClip.moveTo(0,0);
		hueClip.lineTo(w, 0);
		hueClip.lineTo(w, h);
		hueClip.lineTo(0, h);
		hueClip.lineTo(0, 0);
		hueClip.endFill();
		
		matrix = new Matrix();
		var valueClip = hueGradient.createEmptyMovieClip("valueClip", hueGradient.getNextHighestDepth());
		matrix.createBox(w, h);
		valueClip.beginFill(0x000000);
		valueClip.moveTo(0,0);
		valueClip.lineTo(w, 0);
		valueClip.lineTo(w, h);
		valueClip.lineTo(0, h);
		valueClip.lineTo(0, 0);
		valueClip.endFill();
		
		matrix = new Matrix();
		var saturationClip = hueGradient.createEmptyMovieClip("saturationClip", hueGradient.getNextHighestDepth());
		matrix.createBox(w, h);
		saturationClip.beginFill(0xFFFFFF);
		saturationClip.moveTo(0,0);
		saturationClip.lineTo(w, 0);
		saturationClip.lineTo(w, h);
		saturationClip.lineTo(0, h);
		saturationClip.lineTo(0, 0);
		saturationClip.endFill();
		
		return hueGradient;
	}
	
	private function drawSaturationGradient(w: Number, h: Number): MovieClip
	{
		var valueGradient = this.createEmptyMovieClip("saturationGradient", this.getNextHighestDepth());
		
		var matrix: Matrix = new Matrix();
		var color = valueGradient.createEmptyMovieClip("colorClip", valueGradient.getNextHighestDepth());
		matrix.createBox(w, h);
		color.beginFill(0x000000, 100);
		color.moveTo(0,0);
		color.lineTo(w, 0);
		color.lineTo(w, h);
		color.lineTo(0, h);
		color.lineTo(0, 0);
		color.endFill();
		
		var colors: Array = [0xFFFFFF, 0x00];
		var alphas: Array = [100,      0];
		var ratios: Array = [0,        255];
		matrix = new Matrix();

		var gradient = valueGradient.createEmptyMovieClip("gradientClip", valueGradient.getNextHighestDepth());
		
		matrix.createGradientBox(w, h);
		gradient.beginGradientFill("linear", colors, alphas, ratios, matrix);
		gradient.moveTo(0,0);
		gradient.lineTo(w, 0);
		gradient.lineTo(w, h);
		gradient.lineTo(0, h);
		gradient.lineTo(0, 0);
		gradient.endFill();
		
		matrix = new Matrix();
		var valueClip = valueGradient.createEmptyMovieClip("valueClip", valueGradient.getNextHighestDepth());
		matrix.createBox(w, h);
		valueClip.beginFill(0x000000);
		valueClip.moveTo(0,0);
		valueClip.lineTo(w, 0);
		valueClip.lineTo(w, h);
		valueClip.lineTo(0, h);
		valueClip.lineTo(0, 0);
		valueClip.endFill();
		return valueGradient;
	}
	
	private function drawValueGradient(w: Number, h: Number): MovieClip
	{		
		var lightnessGradient = this.createEmptyMovieClip("valueGradient", this.getNextHighestDepth());
		
		var matrix: Matrix = new Matrix();
		var color = lightnessGradient.createEmptyMovieClip("colorClip", lightnessGradient.getNextHighestDepth());
		matrix.createBox(w, h);
		color.beginFill(0x000000, 100);
		color.moveTo(0,0);
		color.lineTo(w, 0);
		color.lineTo(w, h);
		color.lineTo(0, h);
		color.lineTo(0, 0);
		color.endFill();
		
		matrix = new Matrix();
		var saturationClip = lightnessGradient.createEmptyMovieClip("saturationClip", lightnessGradient.getNextHighestDepth());
		matrix.createBox(w, h);
		saturationClip.beginFill(0xFFFFFF);
		saturationClip.moveTo(0,0);
		saturationClip.lineTo(w, 0);
		saturationClip.lineTo(w, h);
		saturationClip.lineTo(0, h);
		saturationClip.lineTo(0, 0);
		saturationClip.endFill();
		
		var colors: Array = [0x000000, 0x00];
		var alphas: Array = [100,      0];
		var ratios: Array = [0,        255];
		matrix = new Matrix();

		var gradient = lightnessGradient.createEmptyMovieClip("gradientClip", lightnessGradient.getNextHighestDepth());
		
		matrix.createGradientBox(w, h);
		gradient.beginGradientFill("linear", colors, alphas, ratios, matrix);
		gradient.moveTo(0,0);
		gradient.lineTo(w, 0);
		gradient.lineTo(w, h);
		gradient.lineTo(0, h);
		gradient.lineTo(0, 0);
		gradient.endFill();
		return lightnessGradient;
	}
}

