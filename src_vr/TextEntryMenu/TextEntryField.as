import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.ui.InputDetails;
import gfx.ui.NavigationCode;
import gfx.controls.TextInput;
import Shared.GlobalFunc;

import skyui.components.ButtonPanel;
import skyui.defines.Input;

class TextEntryField extends MovieClip
{
	public var buttonPanel: ButtonPanel;
	public var TextInputInstance: TextInput;
	
	private var _acceptButton: Object;
	private var _cancelButton: Object;

	public var dispatchEvent: Function;
	public var dispatchQueue: Function;
	public var hasEventListener: Function;
	public var addEventListener: Function;
	public var removeEventListener: Function;
	public var removeAllEventListeners: Function;
	public var cleanUpEvents: Function;

	public function TextEntryField()
	{
		super();
		EventDispatcher.initialize(this);
	}
	
	public function onLoad()
	{
		super.onLoad();
		gfx.managers.FocusHandler.instance.setFocus(TextInputInstance.textField, 0);
		TextInputInstance.focused = true;
		Selection.setFocus(TextInputInstance.textField);
		Selection.setSelection(0,0);
	}

	public function handleInput(details: InputDetails, pathToFocus: Array): Boolean
	{		
		var bHandledInput: Boolean = false;
		if (GlobalFunc.IsKeyPressed(details)) {
			if(details.navEquivalent == NavigationCode.ENTER) {
				onAccept();
				bHandledInput = true;
			} else if(details.navEquivalent == NavigationCode.TAB) {
				onCancel();
				bHandledInput = true;
			}
		}
		
		if(bHandledInput) {
			return bHandledInput;
		} else {
			var nextClip = pathToFocus.shift();
			if (nextClip.handleInput(details, pathToFocus)) {
				return true;
			}
		}
		
		return false;
	}
	
	public function InitExtensions(): Void
	{
		skse.AllowTextInput(true);
		skse.SendModEvent("UITextEntryMenu_LoadMenu");
	}

	public function SetupButtons(): Void
	{
		buttonPanel.clearButtons();
		var acceptButton = buttonPanel.addButton({text: "$Accept", controls: _acceptButton});
		var cancelButton = buttonPanel.addButton({text: "$Cancel", controls: _cancelButton});
		acceptButton.addEventListener("click", this, "onAccept");
		cancelButton.addEventListener("click", this, "onCancel");
		buttonPanel.updateButtons(true);
	}
	
	public function updateButtons(bInstant: Boolean)
	{
		buttonPanel.updateButtons(bInstant);
	}

	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		if(a_platform == 0) {
			_acceptButton = Input.Enter;
			_cancelButton = Input.Tab;
		} else {
			_acceptButton = Input.Accept;
			_cancelButton = Input.Cancel;
		}
		buttonPanel.setPlatform(a_platform, a_bPS3Switch);
		SetupButtons();
	}

	public function GetValidEntry(): Boolean
	{
		return TextInputInstance.text.length > 0;
	}

	public function onAccept(): Void
	{
		if (GetValidEntry()) {
			skse.SendModEvent("UITextEntryMenu_TextChanged", TextInputInstance.text);
			skse.AllowTextInput(false);
			skse.SendModEvent("UITextEntryMenu_CloseMenu");
			//gfx.io.GameDelegate.call("buttonPress", [1]);
			skse.CloseMenu("CustomMenu");
		}
	}

	public function onCancel(): Void
	{
		skse.SendModEvent("UITextEntryMenu_TextChanged", "");
		skse.AllowTextInput(false);
		skse.SendModEvent("UITextEntryMenu_CloseMenu");
		//gfx.io.GameDelegate.call("buttonPress", [0]);
		skse.CloseMenu("CustomMenu");
	}
	
	/* Papyrus */
	public function setTextEntryMenuText(a_text: String): Void
	{
		TextInputInstance.text = a_text;
	}
}
