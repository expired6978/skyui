import gfx.events.EventDispatcher;
import skyui.components.list.BasicEnumeration;
import skyui.components.list.ScrollingList;

class MeshWindow extends MovableWindow
{
	public var meshList: MeshList;
	public var bLoadedAssets: Boolean = false;
		
	static var colors: Array = [
		0xffffff, 0xff0000, 0x0000ff, 0x00ff00, 
		0xff00ff, 0xffff00, 0x00ffff, 0x79f2f2, 
		0xe58473, 0xe673da, 0x57d936, 0xcc3d00, 
		0x5233cc, 0xcc9466, 0xbf001d, 0xb8bf30, 
		0x8c007e, 0x466d8c, 0x287300, 0x397359, 
		0x453973, 0x662e00, 0x050066, 0x665e1a, 
		0x663342, 0x59332d, 0x4c000b, 0x40103b, 
		0x33240d, 0x20330d, 0x0d1633, 0x1a332f
	];
	
	function MeshWindow()
	{
		super();
		meshList.disableSelection = meshList.disableInput = true;
	}
	
	function onLoad()
	{
		super.onLoad();		
		
		meshList.listEnumeration = new BasicEnumeration(meshList.entryList);
		
		meshList.addEventListener("itemPressVisibility", this, "onItemPressVisibility");
		meshList.addEventListener("itemPressWireframe", this, "onItemPressWireframe");
		meshList.addEventListener("itemPressLock", this, "onItemPressLock");
		meshList.addEventListener("itemPressAux", this, "onItemPressAux");
		meshList.addEventListener("selectionChange", this, "onSelectionChange");
		meshList.addEventListener("statusRollOver", this, "onStatusChange");
		/*
		meshList.entryList.push({text: "Test1", visible: true, wireframe: true, locked: false, wfColor: 0xFFFFFFFF, morphable: true, enabled: true});
		meshList.entryList.push({text: "Test2", visible: true, wireframe: false, locked: false, wfColor: 0xFFFFFFFF, morphable: true, enabled: true});
		meshList.entryList.push({text: "Test3", visible: false, wireframe: true, locked: false, wfColor: 0xFFFFFFFF, morphable: true, enabled: true});
		meshList.entryList.push({text: "Test4", visible: true, wireframe: false, locked: true, wfColor: 0xFFFFFFFF, morphable: true, enabled: true});
		meshList.entryList.push({text: "Test5", visible: true, wireframe: false, locked: true, wfColor: 0xFFFFFFFF, morphable: false, enabled: true});
		meshList.entryList.push({text: "Test4", visible: true, wireframe: false, locked: true, wfColor: 0xFFFFFFFF, morphable: true, enabled: true});
		meshList.entryList.push({text: "Test4", visible: true, wireframe: false, locked: true, wfColor: 0xFFFFFFFF, morphable: true, enabled: true});
		meshList.entryList.push({text: "Test4", visible: true, wireframe: false, locked: true, wfColor: 0xFFFFFFFF, morphable: true, enabled: true});
		meshList.entryList.push({text: "Test4", visible: true, wireframe: false, locked: true, wfColor: 0xFFFFFFFF, morphable: true, enabled: true});
		meshList.entryList.push({text: "Test4", visible: true, wireframe: false, locked: true, wfColor: 0xFFFFFFFF, morphable: true, enabled: true});
		meshList.entryList.push({text: "Test4", visible: true, wireframe: false, locked: true, wfColor: 0xFFFFFFFF, morphable: true, enabled: true});
		meshList.entryList.push({text: "Test4", visible: true, wireframe: false, locked: true, wfColor: 0xFFFFFFFF, morphable: true, enabled: true});
		meshList.entryList.push({text: "Test4", visible: true, wireframe: false, locked: true, wfColor: 0xFFFFFFFF, morphable: true, enabled: true});
		*/
		meshList.requestInvalidate();
	}
	
	public function loadAssets()
	{
		if(bLoadedAssets)
			return true;
			
		meshList.disableSelection = meshList.disableInput = false;
		meshList.entryList = _global.skse.plugins.CharGen.GetMeshes();
		meshList.listEnumeration = new BasicEnumeration(meshList.entryList);
		meshList.requestInvalidate();
		bLoadedAssets = true;
		return true;
	}
	
	public function unloadAssets()
	{
		if(!bLoadedAssets)
			return false;
			
		meshList.disableSelection = meshList.disableInput = true;
		meshList.entryList.splice(0, meshList.entryList.length);
		meshList.requestInvalidate();
		bLoadedAssets = false;
		return true;
	}
	
	public function GetInternalMeshes(): Array
	{
		return meshList.entryList;
	}
	
	private function onItemPressVisibility(event: Object): Void
	{
		var pressedEntry: Object = meshList.entryList[event.index];
		if(pressedEntry) {
			pressedEntry.visible = !pressedEntry.visible;
			
			if(_global.skse.plugins.CharGen.SetMeshData)
				_global.skse.plugins.CharGen.SetMeshData(pressedEntry.meshIndex, pressedEntry);
			
			meshList.requestUpdate();
		}
	}
	
	private function onItemPressWireframe(event: Object): Void
	{
		var pressedEntry: Object = meshList.entryList[event.index];
		if(pressedEntry) {
			pressedEntry.wireframe = !pressedEntry.wireframe;
			
			if(_global.skse.plugins.CharGen.SetMeshData)
				_global.skse.plugins.CharGen.SetMeshData(pressedEntry.meshIndex, pressedEntry);
			
			meshList.requestUpdate();
		}
	}
	
	private function onItemPressLock(event: Object): Void
	{
		var pressedEntry: Object = meshList.entryList[event.index];
		if(pressedEntry) {
			pressedEntry.locked = !pressedEntry.locked;
			//if(pressedEntry.locked == false)
				//forceInverseLock(pressedEntry.meshIndex);
			
			if(_global.skse.plugins.CharGen.SetMeshData)
				_global.skse.plugins.CharGen.SetMeshData(pressedEntry.meshIndex, pressedEntry);
			
			meshList.requestUpdate();
		}
	}
	
	private function forceInverseLock(a_index: Number)
	{
		for(var i = 0; i < meshList.entryList.length; i++) {
			var other: Object = meshList.entryList[i];
			if(other.meshIndex == a_index)
				continue;
			
			if(other.locked == false) {
				other.locked = true;
				_global.skse.plugins.CharGen.SetMeshData(other.meshIndex, other);
			}
		}
	}
	
	private function onItemPressAux(event: Object): Void
	{
		var pressedEntry: Object = meshList.entryList[event.index];
		if(pressedEntry) {
			var randIndex: Number = Math.floor(Math.random() * colors.length);
			pressedEntry.wfColor = (0xFF000000 >>> 0) | (colors[randIndex] >>> 0);
			
			if(_global.skse.plugins.CharGen.SetMeshData)
				_global.skse.plugins.CharGen.SetMeshData(pressedEntry.meshIndex, pressedEntry);
			
			meshList.requestUpdate();
		}
	}
	
	private function onSelectionChange(event: Object): Void
	{
		var selectedEntry: Object = meshList.entryList[event.index];
		meshList.listState.selectedEntry = selectedEntry;
		meshList.requestUpdate();
	}
	
	private function onStatusChange(event: Object): Void
	{
		var selectedEntry: Object = meshList.entryList[event.index];
		switch(event.status) {
			case 0:
			_parent._parent.setStatusText("$Toggle Visibility");
			break;
			case 1:
			_parent._parent.setStatusText("$Toggle Wireframe");
			break;
			case 2:
			_parent._parent.setStatusText("$Toggle Editability");
			break;
			case 3:
			_parent._parent.setStatusText("$Cycle Wireframe Color");
			break;
		}
	}
}
