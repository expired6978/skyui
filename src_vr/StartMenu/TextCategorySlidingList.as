import gfx.events.EventDispatcher;
import com.greensock.TweenLite;
import com.greensock.OverwriteManager;
import com.greensock.easing.Linear;

class TextCategorySlidingList extends MovieClip
{
	public var categoryList: TextCategoryList;
	
	function TextCategorySlidingList()
	{
		super();
		EventDispatcher.initialize(this);
		
		categoryList.onInvalidate = function()
		{
			_parent.updatePosition();
		}
	}
	
	function onLoad()
	{
		super.onLoad();
		
		categoryList.addEventListener("selectionChange", this, "onCategoryChange");
	}
	
	public function updatePosition()
	{
		var clipData: Array = categoryList.getClipData();
		TweenLite.to(categoryList, 0.25, {_x: (categoryList.background._width / 2 - clipData[1] / 2 - clipData[0]), overwrite: OverwriteManager.NONE, easing: Linear.easeNone});
	}
	
	public function onCategoryChange(event: Object)
	{
		updatePosition();
	}
}