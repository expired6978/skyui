import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.Linear;

class ModeTab extends gfx.controls.RadioButton
{
	// GFx Functions
	public var tab: MovieClip;
	
	public var textField: TextField;
	
	function ModeTab()
	{
		super();
		textField = tab.textField;
	}
	
	function onLoad()
	{
		super.onLoad();
		this.addEventListener("rollOver", this, "onTabRollOver");
		this.addEventListener("rollOut", this, "onTabRollOut");
		this.addEventListener("releaseOutside", this, "onTabRollOut");
	}
	
	public function onTabRollOver(event): Void
	{
		TweenLite.to(tab, 0.5, {_y: 22, overwrite: OverwriteManager.AUTO, easing: Linear.easeNone});
	}
	
	public function onTabRollOut(event): Void
	{
		TweenLite.to(tab, 0.5, {_y: 0, overwrite: OverwriteManager.AUTO, easing: Linear.easeNone});
	}
}