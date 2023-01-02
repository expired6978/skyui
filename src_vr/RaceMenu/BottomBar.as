import gfx.io.GameDelegate;
import Components.Meter;

import skyui.components.ButtonPanel;
import skyui.defines.Inventory;


class BottomBar extends MovieClip
{
	#include "../version.as"
	
  /* PRIVATE VARIABLES */	
  	
	
  /* STAGE ELEMENTS */

	public var playerInfo: MovieClip;
	public var background: MovieClip;
	
  /* PROPERTIES */
  
	public var buttonPanel: ButtonPanel;
	
	
  /* INITIALIZATION */

	public function BottomBar()
	{
		super();
	}
	
	
  /* PUBLIC FUNCTIONS */

	public function positionElements(a_leftOffset: Number, a_rightOffset: Number): Void
	{
		buttonPanel._x = a_leftOffset;
		buttonPanel.updateButtons(true);
		//playerInfo._x = a_rightOffset - playerInfo._width;
	}
	
	public function positionBackground(): Void
	{
		// Position and scale the bottom bar manually		
		var minXY: Object = {x: Stage.visibleRect.x, y: Stage.visibleRect.y};
		globalToLocal(minXY);
		background._xscale = Stage.width / 1280 * 100;
		background._x = minXY.x;
	}

	public function showPlayerInfo(): Void
	{
		playerInfo._alpha = 100;
	}

	public function hidePlayerInfo(): Void
	{
		playerInfo._alpha = 0;
	}

	public function setPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		Stage.scaleMode = "showAll";
		buttonPanel.setPlatform(a_platform, a_bPS3Switch);
	}

  /* PRIVATE FUNCTIONS */
}
