import skyui.components.list.FilteredEnumeration;
import skyui.components.list.ScrollingList;
import skyui.filter.SortFilter;
import skyui.components.ButtonPanel;
import skyui.util.GlobalFunctions;
import skyui.defines.Input;

import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import Shared.GlobalFunc;

class FileViewerDialog extends BasicTweenDialog
{
	private var _acceptButton: Object;
  	private var _cancelButton: Object;
	private var _backButton: Object;
	private var _textButton: Object;
	
	/* CONTROLS */
	public var fileInput: FileInput;
	public var background: MovieClip;
	public var pathTextField: TextField;
	public var titleTextField: TextField;
	public var buttonPanel: ButtonPanel;
	public var fileList: FileList;
	private var _sortFilter: SortFilter;

	/* VARIABLES */
	public var titleText: String;
	public var defaultText: String;
	
	public var disableInput: Boolean;
	
	public var path: String;
	public var patterns: Array;
	public var alpha: Number = 30;
	
	private var _rootPath: String;
	private var _platform: Number;
	private var _bPS3Switch: Boolean;
	
	public var currentLevel: Object;
	public var bTextEntryMode: Boolean = false;

	function FileViewerDialog()
	{
		super();
		background.onRollOver = background.onRollOut = background.onPress = background.onRelease = function() {};
		background._alpha = alpha;
		
		_sortFilter = new SortFilter();
	}
	
	function onLoad()
	{
		super.onLoad();
		pathTextField.SetText(path);
		titleTextField.SetText(titleText);
		fileInput.text = defaultText;
		fileInput.isDisabled = disableInput;
		
		fileInput.addEventListener("inputStart", this, "onInputStart");
		fileInput.addEventListener("inputEnd", this, "onInputEnd");
		
		SetPlatform(_platform, _bPS3Switch);
		
		_sortFilter.setSortBy(["directory", "name"], [Array.DESCENDING | Array.NUMERIC, Array.NUMERIC]);
		
		_rootPath = path;
		currentLevel = {path: path, parent: null};
		
		fileList.addEventListener("itemPress", this, "onItemPress");
		fileList.addEventListener("selectionChange", this, "onSelectionChange");
		
		fileList.entryList = _global.skse.plugins.CharGen.GetExternalFiles(path, patterns);		
		var listEnumeration = new FilteredEnumeration(fileList.entryList);
		listEnumeration.addFilter(_sortFilter);
		fileList.listEnumeration = listEnumeration;
		fileList.requestInvalidate();
	}
	
	public function onInputStart()
	{
		bTextEntryMode = true;
	}
	
	public function onInputEnd()
	{
		bTextEntryMode = false;
	}
	
	public function IsBoundKeyPressed(details: InputDetails, boundKey: Object, platform: Number): Boolean
	{
		return ((details.control && details.control == boundKey.name) || (details.skseKeycode && boundKey.name && boundKey.context && details.skseKeycode == GlobalFunctions.getMappedKey(boundKey.name, Number(boundKey.context), platform != 0)) || (details.skseKeycode && details.skseKeycode == boundKey.keyCode));
	}
		
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{
		if(bTextEntryMode) {
			if (GlobalFunc.IsKeyPressed(details)) {
				if(details.navEquivalent == NavigationCode.ENTER || details.navEquivalent == NavigationCode.TAB) {
					fileInput.endInput();
					return true;
				}
				if(_textButton && IsBoundKeyPressed(details, _textButton, _platform)) {
					 fileInput.endInput();
					 return true;
				}
			}
			return true;
		}
		
		if(fileList.handleInput(details, pathToFocus) && fileList.selectedEntry)
			return true;
		
		if (GlobalFunc.IsKeyPressed(details)) {
			if(details.navEquivalent == NavigationCode.ENTER || details.skseKeycode == GlobalFunctions.getMappedKey("Activate", Input.CONTEXT_GAMEPLAY, _platform != 0)) {
				onAcceptPress();
				return true;
			} else if(details.navEquivalent == NavigationCode.TAB || details.skseKeycode == GlobalFunctions.getMappedKey("Cancel", Input.CONTEXT_GAMEPLAY, _platform != 0)) {
				onCancelPress();
				return true;
			} else if(IsBoundKeyPressed(details, _backButton, _platform)) {
				onBackPress();
				return true;
			} else if(_textButton && IsBoundKeyPressed(details, _textButton, _platform)) {
				fileInput.startInput();
				return true;
			}
		}
		
		// Don't forward to higher level
		return true;
	}
	
	private function updatePathText(): Void
	{
		pathTextField.SetText(currentLevel.path);
	}
	
	private function onBackPress(): Void
	{
		if(currentLevel.parent) {
			currentLevel = currentLevel.parent;
			loadPath(currentLevel.path);
			updatePathText();
			updateButtons();
		}
	}
	
	private function loadPath(a_path: String): Void
	{
		var nextLevel = _global.skse.plugins.CharGen.GetExternalFiles(a_path, patterns);
		fileList.entryList.splice(0, fileList.entryList.length);
		for(var i = 0; i < nextLevel.length; i++)
			fileList.entryList.push(nextLevel[i]);
		fileList.requestInvalidate();
	}
	
	private function onItemPress(event): Void
	{
		var selectedEntry = fileList.entryList[event.index];		
		if(selectedEntry.directory) {
			currentLevel = {path: selectedEntry.path, parent: currentLevel};
			loadPath(currentLevel.path);
			updatePathText();
			updateButtons();
		} else {
			if(selectedEntry)
				fileInput.text = selectedEntry.name;
			onAcceptPress();
		}
	}
	
	private function onSelectionChange(event): Void
	{
		var selectedEntry = fileList.entryList[event.index];
		if(selectedEntry) {
			if(fileInput.isDisabled)
				fileInput.text = selectedEntry.name;
			
			dispatchEvent({type: "selectionChanged", directoryPath: currentLevel.path, input: fileInput.text, directory: selectedEntry.directory});
		}
	}
	
	private function onAcceptPress(): Void
	{
		dispatchEvent({type: "accept", directoryPath: currentLevel.path, input: fileInput.text});
		DialogTweenManager.close();
	}
		
	private function onCancelPress(): Void
	{
		DialogTweenManager.close();
	}
	
	public function SetPlatform(a_platform: Number, a_bPS3Switch: Boolean): Void
	{
		buttonPanel.setPlatform(a_platform, a_bPS3Switch);
		
		_platform = a_platform;
		
		if(_platform == 0) {
			_acceptButton = Input.Accept;
			_cancelButton = {name: "Tween Menu", context: Input.CONTEXT_GAMEPLAY};
			_backButton = Input.Wait;
			_textButton = undefined;
		} else {
			_acceptButton = Input.Accept;
			_cancelButton = Input.Cancel;
			_backButton = Input.Wait;
			_textButton = {keyCode: GlobalFunctions.getMappedKey("Jump", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		}
		
		updateButtons();
	}
	
	private function updateButtons()
	{
		buttonPanel.clearButtons();
		var acceptButton = buttonPanel.addButton({text: "$Accept", controls: _acceptButton});
		acceptButton.addEventListener("press", this, "onAcceptPress");
		if(currentLevel.parent) {
			var backButton = buttonPanel.addButton({text: "$Back", controls: _backButton});
			backButton.addEventListener("press", this, "onBackPress");
		}
		if(_textButton)
			buttonPanel.addButton({text: "$Edit", controls: _textButton});

		var cancelButton = buttonPanel.addButton({text: "$Cancel", controls: _cancelButton});
		cancelButton.addEventListener("press", this, "onCancelPress");
		buttonPanel.updateButtons();
	}
}