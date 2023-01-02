import skyui.components.list.FilteredEnumeration;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;

import skyui.components.ButtonPanel;
import skyui.util.GlobalFunctions;
import skyui.defines.Input;

import gfx.events.EventDispatcher;
import gfx.managers.FocusHandler;
import gfx.ui.NavigationCode;
import gfx.ui.InputDetails;

import Shared.GlobalFunc;

class ImportDialog extends BasicTweenDialog
{
	private var _acceptButton: Object;
  	private var _cancelButton: Object;
	private var _toggleButton: Object;
	private var _selectButton: Object;
	
	/* CONTROLS */
	public var background: MovieClip;
	public var buttonPanel: ButtonPanel;
	public var importList: ImportList;
	public var importStaticList: ImportList;
	public var titleTextField: TextField;


	/* VARIABLES */
	public var alpha: Number = 30;
	public var titleText: String;
	public var importPath: String;
	
	public var destination: Array;
	public var source: Array;
	
	private var _platform: Number;
	private var _bPS3Switch: Boolean;

	function ImportDialog()
	{
		super();
		background.onRollOver = background.onRollOut = background.onPress = background.onRelease = function() {};
		background._alpha = alpha;
	}
	
	function onLoad()
	{
		super.onLoad();
		titleTextField.SetText(titleText);
		
		/*
		source = new Array();
		destination = new Array();
		
		source.push({name: "FemaleHeadNord", vertices: 996, morphable: true});
		source.push({name: "FemaleMouthHumanoidDefault", vertices: 141, morphable: true});
		source.push({name: "00HairFemaleSGpg0020", vertices: 5181, morphable: true});
		source.push({name: "00HairLineFemaleSGpg0020", vertices: 5181});
		source.push({name: "00HairlineFemaleSG2", vertices: 221});
		source.push({name: "FemaleEyesHumanIceBlue", vertices: 176, morphable: true});
		source.push({name: "00SGFemaleBrows11", vertices: 102, morphable: true});
		
		destination.push({name: "FemaleMouthHumanoidDefault", vertices: 141});
		destination.push({name: "00HairFemaleSPg121001", vertices: 6921});
		destination.push({name: "00HairLineFemaleSGpg121001", vertices: 6921});
		destination.push({name: "00HairlineFemaleSG2", vertices: 221});
		destination.push({name: "FemaleHeadNord", vertices: 996});
		destination.push({name: "FemaleEyesHuman1", vertices: 176});
		destination.push({name: "00SGFemaleBrows11", vertices: 102});
		*/
		
		// Pad remaining with undefined
		if(source.length < destination.length) {
			var diff = destination.length - source.length;
			for(var i = 0; i < diff; i++) {
				source.push({name: "$Undefined", vertices: 0, unused: true});
			}
		}
		
		matchParts(source, destination);
		
					
		importList.entryList = source;
		importStaticList.entryList = destination;
		
		importList.listState.pair = importStaticList;
		importStaticList.listState.pair = importList;
		
		importList.listEnumeration = new BasicEnumeration(importList.entryList);
		importStaticList.listEnumeration = new BasicEnumeration(importStaticList.entryList);		
		
		importStaticList.disableInput = true;
		importList.addEventListener("selectionChange", this, "onSelectionChange");
		importList.addEventListener("itemPress", this, "onItemPress");
		importList.addEventListener("shifted", this, "onItemShifted");
		
		importList.requestInvalidate();
		importStaticList.requestInvalidate();
		
		SetPlatform(_platform, _bPS3Switch);
	}
	
	public function matchParts(a_source: Array, a_destination: Array)
	{
		var matched: Array = new Array(Math.max(a_source.length, a_destination.length));
		var remaining: Array = new Array(Math.max(a_source.length, a_destination.length));
		var unmatched: Array = new Array(Math.max(a_source.length, a_destination.length));
		
		// Fill the remaining list
		for(var i = 0; i < a_source.length; i++)
			remaining[i] = a_source[i];
		for(var i = 0; i < a_destination.length; i++)
			unmatched[i] = a_destination[i];

		// Reverse iterate so splicing is fine
		for(var i = remaining.length - 1; i >= 0; i--) {
			for(var j = unmatched.length - 1; j >= 0; j--) {
				if(remaining[i].vertices == unmatched[j].vertices) { // Find matching vertices
					matched[j] = a_source[i];
					remaining.splice(i, 1); // Remove entries that were matched
					unmatched[j] = undefined; // Entry is matched, ignore for next pass
					break;
				}
			}
		}
	
		// Iterate remaining items and fill them in the unmatched areas
		for(var r = 0; r < remaining.length; r++) {
			for(var m = 0; m < matched.length; m++) {
				if(matched[m] == undefined && remaining[r] != undefined) { // No valid entry here, fill it with what's left
					matched[m] = remaining[r];
					break;
				}
			}
		}
		
		// Re-order based on matching
		for(var i = 0; i < a_source.length; i++)
			a_source[i] = matched[i];
			
		delete matched;
		delete remaining;
	}
		
	public function IsBoundKeyPressed(details: InputDetails, boundKey: Object, platform: Number): Boolean
	{
		return ((details.control && details.control == boundKey.name) || (details.skseKeycode && boundKey.name && boundKey.context && details.skseKeycode == GlobalFunctions.getMappedKey(boundKey.name, Number(boundKey.context), platform != 0)) || (details.skseKeycode && details.skseKeycode == boundKey.keyCode));
	}
	
	public function onItemPress(event): Void
	{		
		importList.listState.focusEntry = event.index;
		importStaticList.listState.focusEntry = event.index;
		
		importList.requestUpdate();
		importStaticList.requestUpdate();
		
		updateButtons();
	}
	
	public function onSelectionChange(event): Void
	{
		importStaticList.selectedIndex = event.index;
		importStaticList.scrollPosition = importList.scrollPosition;
		
		if(importStaticList.listState.focusEntry != importList.listState.focusEntry) {
			importStaticList.listState.focusEntry = importList.listState.focusEntry;
			importStaticList.requestUpdate();
		}
	}
	
	public function onItemShifted(event): Void
	{
		importStaticList.selectedIndex = event.index;
		importStaticList.scrollPosition = importList.scrollPosition;
		
		if(importStaticList.listState.focusEntry != importList.listState.focusEntry) {
			importStaticList.listState.focusEntry = importList.listState.focusEntry;
			importStaticList.requestUpdate();
		}
	}
	
	public function onSelectionPress(event): Void
	{
		var selected: Boolean = importList.listState.focusEntry != undefined && importList.listState.focusEntry >= 0;
		if(selected) {
			importList.selectedIndex = importList.listState.focusEntry;
			importStaticList.selectedIndex = importStaticList.listState.focusEntry;
			
			importList.listState.focusEntry = undefined;
			importStaticList.listState.focusEntry = undefined;
		} else {
			importList.listState.focusEntry = importList.selectedIndex;
			importStaticList.listState.focusEntry = importList.selectedIndex;
		}
		
		importList.requestUpdate();
		importStaticList.requestUpdate();		
		updateButtons();
	}
	
	public function onTogglePress(event): Void
	{
		var entryObject = importList.selectedEntry;
		var objectPair = importStaticList.selectedEntry;
		
		var isMorphable: Boolean = objectPair && (entryObject.morphable == true || objectPair.morphable == true);
		var isUnused: Boolean = objectPair && (entryObject.unused == true || objectPair.unused == true);
		
		if(isMorphable && !isUnused) {
			if(importList.selectedEntry.disabled == undefined)
				importList.selectedEntry.disabled = true;
			else
				importList.selectedEntry.disabled = !importList.selectedEntry.disabled;
		
			importList.requestUpdate();
			importStaticList.requestUpdate();
		}
	}
	
	// @GFx
	public function handleInput(details, pathToFocus): Boolean
	{		
		if (GlobalFunc.IsKeyPressed(details, false)) {
			if(details.navEquivalent == NavigationCode.ENTER || details.skseKeycode == GlobalFunctions.getMappedKey("Activate", Input.CONTEXT_GAMEPLAY, _platform != 0)) {
				onAcceptPress();
				return true;
			} else if(details.navEquivalent == NavigationCode.TAB || details.skseKeycode == GlobalFunctions.getMappedKey("Cancel", Input.CONTEXT_GAMEPLAY, _platform != 0)) {
				onCancelPress();
				return true;
			} else if(IsBoundKeyPressed(details, _selectButton, _platform)) {
				onSelectionPress();
				return true;
			} else if(IsBoundKeyPressed(details, _toggleButton, _platform)) {
				onTogglePress();
				return true;
			}

		}
		
		if(importList.handleInput(details, pathToFocus))
			return true;
		
		// Don't forward to higher level
		return true;
	}
	
	public function onDialogClosed(): Void
	{
		_global.skse.plugins.CharGen.ReleaseImportedHead();
	}
	
	private function onAcceptPress(): Void
	{
		var indices: Array = new Array();
		for(var i = 0; i < importStaticList.entryList.length; i++) {
			var matchedEntry: Object = importList.entryList[i];
			var pairedEntry: Object = importStaticList.entryList[i];
			
			var isMorphable: Boolean = pairedEntry && (matchedEntry.morphable == true || pairedEntry.morphable == true);
			var isUnused: Boolean = pairedEntry && (matchedEntry.unused == true || pairedEntry.unused == true);
			var isDisabled: Boolean = pairedEntry && (matchedEntry.disabled == true || pairedEntry.disabled == true);
			var isPaired: Boolean = pairedEntry.vertices == matchedEntry.vertices;
			
			indices.push((isMorphable && isPaired && !isUnused && !isDisabled) ? matchedEntry.gIndex : -1);
		}
		
		dispatchEvent({type: "accept", matches: indices});
		
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
			_toggleButton = Input.Wait;
			_selectButton = {keyCode: GlobalFunctions.getMappedKey("Toggle POV", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
		} else {
			_acceptButton = Input.Accept;
			_cancelButton = Input.Cancel;
			_toggleButton = {keyCode: GlobalFunctions.getMappedKey("Jump", Input.CONTEXT_GAMEPLAY, a_platform != 0)};
			_selectButton = Input.Wait;
		}
		
		updateButtons();
	}
	
	private function updateButtons()
	{
		buttonPanel.clearButtons();
		var acceptButton = buttonPanel.addButton({text: "$Accept", controls: _acceptButton});
		acceptButton.addEventListener("press", this, "onAcceptPress");
		var cancelButton = buttonPanel.addButton({text: "$Cancel", controls: _cancelButton});
		cancelButton.addEventListener("press", this, "onCancelPress");
		
		var toggleButton = buttonPanel.addButton({text: "$Toggle", controls: _toggleButton});
		toggleButton.addEventListener("press", this, "onTogglePress");

		var selected: Boolean = importList.listState.focusEntry != undefined && importList.listState.focusEntry >= 0;
		var selectButton = buttonPanel.addButton({text: selected ? "$Deselect" : "$Select", controls: _selectButton});
		selectButton.addEventListener("press", this, "onSelectionPress");
		
		buttonPanel.updateButtons();		
	}
}