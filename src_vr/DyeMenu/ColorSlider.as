import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

class ColorSlider extends gfx.controls.Slider
{
	function ColorSlider()
	{
		super();
	}

	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{
		var previous: Number = this.value;
		var keyState = details.value == "keyDown" || details.value == "keyHold";
		if (details.navEquivalent === NavigationCode.RIGHT) 
		{
			if (keyState) 
			{
				value = value + _snapInterval;
				if(value != previous)
					dispatchEventAndSound({type: "change"});
			}
		}
		else if (details.navEquivalent === NavigationCode.LEFT) 
		{
			if (keyState) 
			{
				value = value - _snapInterval;
				if(value != previous)
					dispatchEventAndSound({type: "change"});
			}
		}
		else if (details.navEquivalent === NavigationCode.GAMEPAD_R2) 
		{
			if (keyState) 
			{
				value = value + 10;
				if(value != previous)
					dispatchEventAndSound({type: "change"});
			}
		}
		else if (details.navEquivalent === NavigationCode.GAMEPAD_L2) 
		{
			if (keyState) 
			{
				value = value - 10;
				if(value != previous)
					dispatchEventAndSound({type: "change"});
			}
		}
		else if (details.navEquivalent === NavigationCode.GAMEPAD_L1)
		{
			if (keyState) 
			{
				value = this.minimum;
				if(value != previous)
					dispatchEventAndSound({type: "change"});
			}
		}
		else if (details.navEquivalent === NavigationCode.GAMEPAD_R1)
		{
			if (keyState) 
			{
				value = this.maximum;
				if(value != previous)
					dispatchEventAndSound({type: "change"});
			}
		}
		else 
		{
			return false;
		}
		return true;
	}
}