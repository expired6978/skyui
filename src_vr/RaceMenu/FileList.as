class FileList extends skyui.components.list.ScrollingList
{
	public var entryHeight: Number = 25;
	public var isAutoUnselect: Boolean = true;
	
	public function FileList()
	{
		super();
	}
	
	public function set entryList(a_list: Array): Void
	{
		_entryList = a_list;
	}
	
	public function moveSelectionUp(a_bScrollPage: Boolean): Void
	{
		if (!disableSelection && !a_bScrollPage) {
			if (_selectedIndex == -1) {
				selectDefaultIndex(false);
			} else if (getSelectedListEnumIndex() >= scrollDelta) {
				doSetSelectedIndex(getListEnumRelativeIndex(-scrollDelta), SELECT_KEYBOARD);
				isMouseDrivenNav = false;
			} else {
				doSetSelectedIndex(-1, SELECT_MOUSE);
			}
		} else if (a_bScrollPage) {
			var t = scrollPosition - _listIndex;
			scrollPosition = t > 0 ? t : 0;
			doSetSelectedIndex(-1, SELECT_MOUSE);
		} else {
			scrollPosition = scrollPosition - scrollDelta;
		}
	}
	
	public function moveSelectionDown(a_bScrollPage: Boolean): Void
	{
		if (!disableSelection && !a_bScrollPage) {
			if (_selectedIndex == -1) {
				selectDefaultIndex(true);
			} else if (getSelectedListEnumIndex() < getListEnumSize() - scrollDelta) {
				doSetSelectedIndex(getListEnumRelativeIndex(scrollDelta), SELECT_KEYBOARD);
				isMouseDrivenNav = false;
			} else {
				doSetSelectedIndex(-1, SELECT_MOUSE);
			}
		} else if (a_bScrollPage) {
			var t = scrollPosition + _listIndex;
			scrollPosition = t < _maxScrollPosition ? t : _maxScrollPosition;
			doSetSelectedIndex(-1, SELECT_MOUSE);
		} else {
			scrollPosition = scrollPosition + scrollDelta;
		}
	}
}
