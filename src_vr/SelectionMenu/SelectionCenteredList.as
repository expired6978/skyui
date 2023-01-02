class SelectionCenteredList extends Shared.CenteredScrollingList
{
	var selectStates: Array = ["None", "Selected"];
	function SelectionCenteredList()
	{
		super();
	}
	
	function SetEntryText(aEntryClip: MovieClip, aEntryObject: Object): Void
	{
		if (aEntryObject.text == undefined) {
			aEntryClip.textField.SetText(" ");
		} else {
			aEntryClip.textField.SetText(aEntryObject.text);
			var maxLength = 35;
			if (aEntryClip.textField.text.length > maxLength) 
				aEntryClip.textField.SetText(aEntryClip.textField.text.substr(0, maxLength - 3) + "...");
		}
		aEntryClip.textField.textAutoSize = "shrink";
		if (iPlatform == 0) {
			aEntryClip._alpha = aEntryObject == selectedEntry ? 100 : 60;
		} else {
			var iAlphaMulti: Number = 8;
			if (aEntryClip.clipIndex < iNumTopHalfEntries) 
				aEntryClip._alpha = 60 - iAlphaMulti * (iNumTopHalfEntries - aEntryClip.clipIndex);
			else if (aEntryClip.clipIndex > iNumTopHalfEntries) 
				aEntryClip._alpha = 60 - iAlphaMulti * (aEntryClip.clipIndex - iNumTopHalfEntries);
			else
				aEntryClip._alpha = 100;
		}
		if (aEntryObject == undefined || aEntryObject.selectState == -1)
			aEntryClip.SelectIndictor.gotoAndStop(selectStates[0]);
		else {
			aEntryClip.SelectIndictor.gotoAndStop(selectStates[aEntryObject.selectState]);
		}
	}
		
	function InvalidateData(): Void
	{
		entryList.sort(doABCSort);
		super.InvalidateData();
	}

	function doABCSort(aObj1, aObj2)
	{
		if (aObj1.text < aObj2.text)
			return -1;
		else if (aObj1.text > aObj2.text) 
			return 1;
			
		return 0;
	}

	function onMouseWheel(delta)
	{
		if (delta >= 1)
			moveSelectionUp();
		else if (delta <= -1)
			moveSelectionDown();
	}
}


