Scriptname RaceMenuPlugin extends RaceMenuBase

string Property NINODE_NPC = "NPC" AutoReadOnly
string Property NINODE_HEAD = "NPC Head [Head]" AutoReadOnly
string Property NINODE_LEFT_BREAST = "NPC L Breast" AutoReadOnly
string Property NINODE_RIGHT_BREAST = "NPC R Breast" AutoReadOnly
string Property NINODE_LEFT_BUTT = "NPC L Butt" AutoReadOnly
string Property NINODE_RIGHT_BUTT = "NPC R Butt" AutoReadOnly
string Property NINODE_LEFT_BREAST_FORWARD = "NPC L Breast01" AutoReadOnly
string Property NINODE_RIGHT_BREAST_FORWARD = "NPC R Breast01" AutoReadOnly
string Property NINODE_LEFT_BICEP = "NPC L UpperarmTwist1 [LUt1]" AutoReadOnly
string Property NINODE_RIGHT_BICEP = "NPC R UpperarmTwist1 [RUt1]" AutoReadOnly
string Property NINODE_LEFT_BICEP_2 = "NPC L UpperarmTwist2 [LUt2]" AutoReadOnly
string Property NINODE_RIGHT_BICEP_2 = "NPC R UpperarmTwist2 [RUt2]" AutoReadOnly

; Custom Properties
float _height = 1.0
float _head = 1.0
float _leftBreast = 1.0
float _rightBreast = 1.0
float _leftBreastF = 1.0
float _rightBreastF = 1.0
float _leftButt = 1.0
float _rightButt = 1.0
float _rightBicep = 1.0
float _leftBicep = 1.0
float _rightBicep2 = 1.0
float _leftBicep2 = 1.0

bool hasInitialized = false ; For one time init, used for loading data inside OnGameLoad instead of Init (Unsafe)

Event OnStartup()
	parent.OnStartup()
	RegisterForModEvent("RSM_RequestNodeSave", "OnSaveScales")
EndEvent

Event OnSaveScales(string eventName, string strArg, float numArg, Form formArg)
	SavePlayerNodeScales(_playerActor)
EndEvent

Event OnReloadSettings(Actor player, ActorBase playerBase)
	If !hasInitialized ; Init script values from current player
		SavePlayerNodeScales(player)
		hasInitialized = true
	Else
		LoadPlayerNodeScales(player)
	Endif
EndEvent

Function LoadPlayerNodeScales(Actor player)
	Normalize()
	NetImmerse.SetNodeScale(player, NINODE_NPC, _height, false)
	NetImmerse.SetNodeScale(player, NINODE_HEAD, _head, false)
	NetImmerse.SetNodeScale(player, NINODE_LEFT_BREAST, _leftBreast, false)
	NetImmerse.SetNodeScale(player, NINODE_RIGHT_BREAST, _rightBreast, false)
	NetImmerse.SetNodeScale(player, NINODE_LEFT_BICEP, _leftBicep, false)
	NetImmerse.SetNodeScale(player, NINODE_RIGHT_BICEP, _rightBicep, false)
	NetImmerse.SetNodeScale(player, NINODE_LEFT_BICEP_2, _leftBicep2, false)
	NetImmerse.SetNodeScale(player, NINODE_RIGHT_BICEP_2, _rightBicep2, false)
	NetImmerse.SetNodeScale(player, NINODE_NPC, _height, true)
	NetImmerse.SetNodeScale(player, NINODE_HEAD, _head, true)
	NetImmerse.SetNodeScale(player, NINODE_LEFT_BREAST, _leftBreast, true)
	NetImmerse.SetNodeScale(player, NINODE_RIGHT_BREAST, _rightBreast, true)
	NetImmerse.SetNodeScale(player, NINODE_LEFT_BUTT, _leftButt, true)
	NetImmerse.SetNodeScale(player, NINODE_RIGHT_BUTT, _rightButt, true)
	NetImmerse.SetNodeScale(player, NINODE_LEFT_BREAST_FORWARD, _leftBreastF, true)
	NetImmerse.SetNodeScale(player, NINODE_RIGHT_BREAST_FORWARD, _rightBreastF, true)
	NetImmerse.SetNodeScale(player, NINODE_LEFT_BICEP, _leftBicep, true)
	NetImmerse.SetNodeScale(player, NINODE_RIGHT_BICEP, _rightBicep, true)
	NetImmerse.SetNodeScale(player, NINODE_LEFT_BICEP_2, _leftBicep, true)
	NetImmerse.SetNodeScale(player, NINODE_RIGHT_BICEP_2, _rightBicep, true)
EndFunction

Event On3DLoaded(ObjectReference akRef)
	OnReloadSettings(_playerActor, _playerActorBase)
EndEvent

Event OnCellLoaded(ObjectReference akRef)
	LoadPlayerNodeScales(_playerActor)
EndEvent

; Add Custom Warpaint here
Event OnWarpaintRequest()
	AddWarpaint("$Beauty Mark 01", "Actors\\Character\\Character Assets\\TintMasks\\BeautyMark_01.dds")
	AddWarpaint("$Beauty Mark 02", "Actors\\Character\\Character Assets\\TintMasks\\BeautyMark_02.dds")
	AddWarpaint("$Beauty Mark 03", "Actors\\Character\\Character Assets\\TintMasks\\BeautyMark_03.dds")
	AddWarpaint("$Dragon Tattoo 01", "Actors\\Character\\Character Assets\\TintMasks\\DragonTattoo_01.dds")
EndEvent

Function Normalize()
	if _height == 0
		_height = 1
	Endif
	if _head == 0
		_head = 1
	Endif
	if _leftBreast == 0
		_leftBreast = 1
	Endif
	if _rightBreast == 0
		_rightBreast = 1
	Endif
	if _leftBreastF == 0
		_leftBreastF = 1
	Endif
	if _rightBreastF == 0
		_rightBreastF = 1
	Endif
	if _leftButt == 0
		_leftButt = 1
	Endif
	if _rightButt == 0
		_rightButt = 1
	Endif
	if _leftBicep == 0
		_leftBicep = 1
	Endif
	if _rightBicep == 0
		_rightBicep = 1
	Endif
	if _leftBicep2 == 0
		_leftBicep2 = 1
	Endif
	if _rightBicep2 == 0
		_rightBicep2 = 1
	Endif
EndFunction

Function SavePlayerNodeScales(Actor player)
	If NetImmerse.HasNode(player, NINODE_NPC, false)
		_height = NetImmerse.GetNodeScale(player, NINODE_NPC, false)
	Else
		_height = 1.0
	Endif
	If NetImmerse.HasNode(player, NINODE_HEAD, false)
		_head = NetImmerse.GetNodeScale(player, NINODE_HEAD, false)
	Else
		_head = 1.0
	Endif
	If NetImmerse.HasNode(player, NINODE_LEFT_BREAST, false)
		_leftBreast = NetImmerse.GetNodeScale(player, NINODE_LEFT_BREAST, false)
	Else
		_leftBreast = 1.0
	Endif
	If NetImmerse.HasNode(player, NINODE_RIGHT_BREAST, false)
		_rightBreast = NetImmerse.GetNodeScale(player, NINODE_RIGHT_BREAST, false)
	Else
		_rightBreast = 1.0
	Endif
	If NetImmerse.HasNode(player, NINODE_LEFT_BREAST_FORWARD, false)
		_leftBreastF = NetImmerse.GetNodeScale(player, NINODE_LEFT_BREAST_FORWARD, false)
	Else
		_leftBreastF = 1.0
	Endif
	If NetImmerse.HasNode(player, NINODE_RIGHT_BREAST_FORWARD, false)
		_rightBreastF = NetImmerse.GetNodeScale(player, NINODE_RIGHT_BREAST_FORWARD, false)
	Else
		_rightBreastF = 1.0
	Endif
	If NetImmerse.HasNode(player, NINODE_LEFT_BUTT, false)
		_leftButt = NetImmerse.GetNodeScale(player, NINODE_LEFT_BUTT, false)
	Else
		_leftButt = 1.0
	Endif
	If NetImmerse.HasNode(player, NINODE_RIGHT_BUTT, false)
		_rightButt = NetImmerse.GetNodeScale(player, NINODE_RIGHT_BUTT, false)
	Else
		_rightButt = 1.0
	Endif
	If NetImmerse.HasNode(player, NINODE_LEFT_BICEP, false)
		_leftBicep = NetImmerse.GetNodeScale(player, NINODE_LEFT_BICEP, false)
	Else
		_leftBicep = 1.0
	Endif
	If NetImmerse.HasNode(player, NINODE_RIGHT_BICEP, false)
		_rightBicep = NetImmerse.GetNodeScale(player, NINODE_RIGHT_BICEP, false)
	Else
		_rightBicep = 1.0
	Endif
	If NetImmerse.HasNode(player, NINODE_LEFT_BICEP_2, false)
		_leftBicep2 = NetImmerse.GetNodeScale(player, NINODE_LEFT_BICEP_2, false)
	Else
		_leftBicep2 = 1.0
	Endif
	If NetImmerse.HasNode(player, NINODE_RIGHT_BICEP_2, false)
		_rightBicep2 = NetImmerse.GetNodeScale(player, NINODE_RIGHT_BICEP_2, false)
	Else
		_rightBicep2 = 1.0
	Endif
	Normalize()
EndFunction

Event OnInitializeMenu(Actor player, ActorBase playerBase)
	SavePlayerNodeScales(player)
EndEvent

Event OnResetMenu(Actor player, ActorBase playerBase)
	_height = 1.0
	_head = 1.0
	_leftBreast = 1.0
	_rightBreast = 1.0
	_leftBreastF = 1.0
	_rightBreastF = 1.0
	_leftButt = 1.0
	_rightButt = 1.0
	_rightBicep = 1.0
	_leftBicep = 1.0
	_rightBicep2 = 1.0
	_leftBicep2 = 1.0
	LoadPlayerNodeScales(player)
EndEvent

; Add Custom sliders here
Event OnSliderRequest(Actor player, ActorBase playerBase, Race actorRace, bool isFemale)
	AddSlider("$Height", CATEGORY_BODY, "ChangeHeight", 0.25, 2.00, 0.01, _height)

	If NetImmerse.HasNode(player, NINODE_HEAD, false)
		AddSlider("$Head", CATEGORY_BODY, "ChangeHeadSize", 0.01, 3.00, 0.01, _head)
	Endif

	If isFemale == true		
		If NetImmerse.HasNode(player, NINODE_LEFT_BREAST, false)
			AddSlider("$Left Breast", CATEGORY_BODY, "ChangeLeftBreast", 0.1, 3.00, 0.01, _leftBreast)
		Endif
		If NetImmerse.HasNode(player, NINODE_RIGHT_BREAST, false)
			AddSlider("$Right Breast", CATEGORY_BODY, "ChangeRightBreast", 0.1, 3.00, 0.01, _rightBreast)
		Endif
		If NetImmerse.HasNode(player, NINODE_LEFT_BREAST_FORWARD, false)
			AddSlider("$Left Breast Curve", CATEGORY_BODY, "ChangeLeftBreastCurve", 0.1, 3.00, 0.01, _leftBreastF)
		Endif
		If NetImmerse.HasNode(player, NINODE_RIGHT_BREAST_FORWARD, false)
			AddSlider("$Right Breast Curve", CATEGORY_BODY, "ChangeRightBreastCurve", 0.1, 3.00, 0.01, _rightBreastF)
		Endif
		If NetImmerse.HasNode(player, NINODE_LEFT_BUTT, false)
			AddSlider("$Left Glute", CATEGORY_BODY, "ChangeLeftButt", 0.1, 3.00, 0.01, _leftButt)
		Endif
		If NetImmerse.HasNode(player, NINODE_RIGHT_BUTT, false)
			AddSlider("$Right Glute", CATEGORY_BODY, "ChangeRightButt", 0.1, 3.00, 0.01, _rightButt)
		Endif
	Endif

	AddSlider("$Left Biceps", CATEGORY_BODY, "ChangeLeftBiceps", 0.1, 2.00, 0.01, _leftBicep)
	AddSlider("$Right Biceps", CATEGORY_BODY, "ChangeRightBiceps", 0.1, 2.00, 0.01, _rightBicep)

	AddSlider("$Left Biceps 2", CATEGORY_BODY, "ChangeLeftBiceps2", 0.1, 2.00, 0.01, _leftBicep2)
	AddSlider("$Right Biceps 2", CATEGORY_BODY, "ChangeRightBiceps2", 0.1, 2.00, 0.01, _rightBicep2)
EndEvent

Event OnSliderChanged(string callback, float value)
	If callback == "ChangeHeight"
		_height = value
		NetImmerse.SetNodeScale(_playerActor, NINODE_NPC, _height, false)
		NetImmerse.SetNodeScale(_playerActor, NINODE_NPC, _height, true)
	ElseIf callback == "ChangeHeadSize"
		_head = value
		NetImmerse.SetNodeScale(_playerActor, NINODE_HEAD, _head, false)
		NetImmerse.SetNodeScale(_playerActor, NINODE_HEAD, _head, true)
	Elseif callback == "ChangeLeftBreast"
		_leftBreast = value
		NetImmerse.SetNodeScale(_playerActor, NINODE_LEFT_BREAST, _leftBreast, false)
		NetImmerse.SetNodeScale(_playerActor, NINODE_LEFT_BREAST, _leftBreast, true)
	Elseif callback == "ChangeRightBreast"
		_rightBreast = value
		NetImmerse.SetNodeScale(_playerActor, NINODE_RIGHT_BREAST, _rightBreast, false)
		NetImmerse.SetNodeScale(_playerActor, NINODE_RIGHT_BREAST, _rightBreast, true)
	Elseif callback == "ChangeLeftBreastCurve"
		_leftBreastF = value
		NetImmerse.SetNodeScale(_playerActor, NINODE_LEFT_BREAST_FORWARD, _leftBreastF, false)
		NetImmerse.SetNodeScale(_playerActor, NINODE_LEFT_BREAST_FORWARD, _leftBreastF, true)
	Elseif callback == "ChangeRightBreastCurve"
		_rightBreastF = value
		NetImmerse.SetNodeScale(_playerActor, NINODE_RIGHT_BREAST_FORWARD, _rightBreastF, false)
		NetImmerse.SetNodeScale(_playerActor, NINODE_RIGHT_BREAST_FORWARD, _rightBreastF, true)
	Elseif callback == "ChangeLeftButt"
		_leftButt = value
		NetImmerse.SetNodeScale(_playerActor, NINODE_LEFT_BUTT, _leftButt, false)
		NetImmerse.SetNodeScale(_playerActor, NINODE_LEFT_BUTT, _leftButt, true)
	Elseif callback == "ChangeRightButt"
		_rightButt = value
		NetImmerse.SetNodeScale(_playerActor, NINODE_RIGHT_BUTT, _rightButt, false)
		NetImmerse.SetNodeScale(_playerActor, NINODE_RIGHT_BUTT, _rightButt, true)
	Elseif callback == "ChangeLeftBiceps"
		_leftBicep = value
		NetImmerse.SetNodeScale(_playerActor, NINODE_LEFT_BICEP, _leftBicep, false)
		NetImmerse.SetNodeScale(_playerActor, NINODE_LEFT_BICEP, _leftBicep, true)
	Elseif callback == "ChangeRightBiceps"
		_rightBicep = value
		NetImmerse.SetNodeScale(_playerActor, NINODE_RIGHT_BICEP, _rightBicep, false)
		NetImmerse.SetNodeScale(_playerActor, NINODE_RIGHT_BICEP, _rightBicep, true)
	Elseif callback == "ChangeLeftBiceps2"
		_leftBicep2 = value
		NetImmerse.SetNodeScale(_playerActor, NINODE_LEFT_BICEP_2, _leftBicep2, false)
		NetImmerse.SetNodeScale(_playerActor, NINODE_LEFT_BICEP_2, _leftBicep2, true)
	Elseif callback == "ChangeRightBiceps2"
		_rightBicep2 = value
		NetImmerse.SetNodeScale(_playerActor, NINODE_RIGHT_BICEP_2, _rightBicep2, false)
		NetImmerse.SetNodeScale(_playerActor, NINODE_RIGHT_BICEP_2, _rightBicep2, true)
	Endif
EndEvent