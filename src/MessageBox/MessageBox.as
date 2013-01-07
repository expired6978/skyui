﻿import gfx.io.GameDelegate;
import gfx.controls.Button;
import skse;

class MessageBox extends MovieClip
{
	static var WIDTH_MARGIN: Number = 20;
	static var HEIGHT_MARGIN: Number = 30;
	static var MESSAGE_TO_BUTTON_SPACER: Number = 10;
	static var SELECTION_INDICATOR_WIDTH: Number = 25;
	
  /* Stage Elements */
	var MessageText: TextField;
	
	var Divider: MovieClip;
	var Background_mc: MovieClip;
	var MessageContainer: MovieClip;
	
  /* Private Variables */
	var ButtonContainer: MovieClip;
	var DefaultTextFormat: TextFormat;
	
	var Message: TextField;
	var MessageButtons: Array;
	
	var proxyMenu: MovieClip;
	
	
	function MessageBox()
	{
		super();
		MessageContainer = _root.MessageMenu;
		Message = MessageText;
		Message.noTranslate = true;
		MessageButtons = new Array();
		ButtonContainer = undefined;
		DefaultTextFormat = Message.getTextFormat();
		Key.addListener(this);
		GameDelegate.addCallBack("setMessageText", this, "SetMessage");
		GameDelegate.addCallBack("setButtons", this, "setupButtons");
	}
	
	function setupButtons()
	{
		if (undefined != ButtonContainer) 
		{
			ButtonContainer.removeMovieClip();
			ButtonContainer = undefined;
		}
		MessageButtons.length = 0; // This truncates the array to 0
		var controllerOrConsole: Boolean = arguments[0];
		if (arguments.length > 1) 
		{
			ButtonContainer = createEmptyMovieClip("Buttons", getNextHighestDepth());
			var buttonXOffset: Number = 0;
			
			for (var i: Number = 1; i < arguments.length; i++){
				if (arguments[i] == " ")
					continue;
				var buttonIdx: Number = i - 1;
				var button: Button = Button(ButtonContainer.attachMovie("MessageBoxButton", "Button" + buttonIdx, ButtonContainer.getNextHighestDepth()));
				var buttonText: TextField = button.ButtonText;
				buttonText.autoSize = "center";
				buttonText.verticalAlign = "center";
				buttonText.verticalAutoSize = "center";
				buttonText.html = true;
				buttonText.SetText(arguments[i], true);
				button.SelectionIndicatorHolder.SelectionIndicator._width = buttonText._width + MessageBox.SELECTION_INDICATOR_WIDTH;
				button.SelectionIndicatorHolder.SelectionIndicator._y = buttonText._y + buttonText._height / 2;
				button._x = buttonXOffset + button._width / 2;
				buttonXOffset = buttonXOffset + (button._width + MessageBox.SELECTION_INDICATOR_WIDTH);
				MessageButtons.push(button);
			}
			InitButtons();
			ResetDimensions();
			
			if (controllerOrConsole) 
				Selection.setFocus(MessageButtons[0]);
		}
	}

	function InitButtons()
	{
		for (var i: Number = 0; i < MessageButtons.length; i++) {
			MessageButtons[i].handlePress = function () {};
			MessageButtons[i].addEventListener("press", ClickCallback);
			MessageButtons[i].addEventListener("focusIn", FocusCallback);
			MessageButtons[i].ButtonText.noTranslate = true;
		}
	}

	function SetMessage(aText, abHTML)
	{
		Message.autoSize = "center";
		Message.setTextFormat(DefaultTextFormat);
		Message.setNewTextFormat(DefaultTextFormat);
		Message.html = abHTML;
		if (abHTML) 
		{
			Message.htmlText = aText;
		}
		else 
		{
			Message.SetText(aText);
		}
		ResetDimensions();
		ProcessMessage(aText);
	}
	
	function ProcessMessage(aText)
	{
		if(aText.slice(0, 2) == "$$" && aText.slice(aText.length-2, aText.length) == "$$")
		{
			var command: String = aText.slice(2, aText.length-2);
			var key = command.slice(0, command.indexOf("="));
			if (key == undefined)
				return;
				
			var val = command.slice(command.indexOf("=") + 1);
			if (val == undefined)
				return;
				
			if(key.toLowerCase() == "loadmovie")
			{
				MessageContainer._visible = false;
				MessageContainer.enabled = false;
				
				proxyMenu = _root.createEmptyMovieClip(val, _root.getNextHighestDepth());
				proxyMenu.loadMovie(val + ".swf");
			}
		}
	}

	function ResetDimensions()
	{
		PositionElements();
		var parentBounds: Object = getBounds(_parent);
		var __reg2: Number = Stage.height * 0.85 - parentBounds.yMax;
		if (__reg2 < 0) {
			Message.autoSize = false;
			var extraHeight: Number = __reg2 * 100 / _yscale;
			Message._height = Message._height + extraHeight;
			PositionElements();
		}
	}

	function PositionElements()
	{
		var background: MovieClip = Background_mc;
		var maxLineWidth: Number = 0;
		
		for (var i: Number = 0; i < Message.numLines; i++)
			maxLineWidth = Math.max(maxLineWidth, Message.getLineMetrics(i).width);
		
		var buttonContainerWidth = 0;
		var buttonContainerHeight = 0;
		if (ButtonContainer != undefined) {
			buttonContainerWidth = ButtonContainer._width;
			buttonContainerHeight = ButtonContainer._height;
		}
		background._width = Math.max(maxLineWidth + 60, buttonContainerWidth + MessageBox.WIDTH_MARGIN * 2);
		background._height = Message._height + buttonContainerHeight + MessageBox.HEIGHT_MARGIN * 2 + MessageBox.MESSAGE_TO_BUTTON_SPACER;
		Message._y = (0 - background._height) / 2 + MessageBox.HEIGHT_MARGIN;
		ButtonContainer._y = background._height / 2 - MessageBox.HEIGHT_MARGIN - ButtonContainer._height / 2;
		ButtonContainer._x = (0 - ButtonContainer._width) / 2;
		Divider._width = background._width - MessageBox.WIDTH_MARGIN * 2;
		Divider._y = ButtonContainer._y - ButtonContainer._height / 2 - MessageBox.MESSAGE_TO_BUTTON_SPACER / 2;
	}

	function ClickCallback(aEvent)
	{
		GameDelegate.call("buttonPress", [Number(aEvent.target._name.substr(-1))]);
	}

	function FocusCallback(aEvent)
	{
		GameDelegate.call("PlaySound", ["UIMenuFocus"]);
	}

	function onKeyDown()
	{
		if (Key.getCode() == 89 && MessageButtons[0].ButtonText.text == "Yes") {
			GameDelegate.call("buttonPress", [0]);
			return;
		}
		if (Key.getCode() == 78 && MessageButtons[1].ButtonText.text == "No") {
			GameDelegate.call("buttonPress", [1]);
			return;
		}
		if (Key.getCode() == 65 && MessageButtons[2].ButtonText.text == "Yes to All") {
			GameDelegate.call("buttonPress", [2]);
		}
	}

	function SetPlatform(aiPlatform: Number, abPS3Switch: Boolean)
	{
		if (aiPlatform != 0 && MessageButtons.length > 0) {
			Selection.setFocus(MessageButtons[0]);
		}
		
		if(proxyMenu) {
			proxyMenu.SetPlatform(aiPlatform, abPS3Switch);
		}
	}

}
