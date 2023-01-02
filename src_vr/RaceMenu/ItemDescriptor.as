import com.greensock.TweenLite;
import com.greensock.plugins.TweenPlugin;
import com.greensock.plugins.AutoAlphaPlugin;
import com.greensock.OverwriteManager;
import com.greensock.easing.Linear;

class ItemDescriptor extends MovieClip
{
	public var background: MovieClip;
	public var textField: TextField;
	public var fadeOutTween: TweenLite;
	public var fadeDelay: Number = 1.0;
	
	public function ItemDescriptor()
	{
		super();
		textField.autoSize = "left";
	}
		
	public function setText(a_text: String, a_fadeDelay: Number): Void
	{
		textField.text = a_text;
		background._width = textField._x + textField.textWidth + 20;
		if(a_fadeDelay)
			fadeDelay = a_fadeDelay;
		else
			fadeDelay = 1.0;
	}
	
	public function fadeOut(): Void
	{
		TweenLite.to(this, 1.0, {delay: fadeDelay, autoAlpha: 0, overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
	}
	
	public function toggle(a_toggle: Boolean): Void
	{
		this._visible = this.enabled = a_toggle;
		TweenLite.killTweensOf(this, false, {_alpha:true, autoAlpha:true});
		if(a_toggle) {
			_alpha = 100;
		} else {
			_alpha = 0;
		}
	}
}