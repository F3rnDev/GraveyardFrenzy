extends VBoxContainer

class_name EditWindow

@export var windowDownBorder:float = 50.0
@export var windowRef:ChartEditorWindow

#Fields
@onready var normalInfo = $NormalInfo
@onready var params = $Params

@onready var songPos = $NormalInfo/songPos
@onready var lane = $NormalInfo/lane
@onready var holdAmount = $NormalInfo/holdAmount
@onready var noteType = $NormalInfo/noteType
@onready var obstacleType = $NormalInfo/obstacleType
@onready var eventType = $NormalInfo/eventType

@onready var obstacleParams = $Params/ObstacleParams
@onready var eventParams = $Params/EventParams

#Labels
@onready var songPosLabel: Label = $NormalInfo/SongPosLabel


#Types
@onready var typeMap = {
	"ChartObject": ChartObject,
	"ChartNote": ChartNote,
	"ChartObstacle": ChartObstacle,
	"ChartEvent": ChartEvent
}

@onready var typeGroups = {
	ChartObject: [$NormalInfo/SongPosLabel, songPos],
	ChartElement: [$NormalInfo/LaneLabel, lane],
	ChartNote: [$NormalInfo/HoldAmountLabel, holdAmount, $NormalInfo/NoteTypeLabel, noteType],
	ChartObstacle: [$NormalInfo/ObstacleTypeLabel, obstacleType, $Params/ObstacleParams],
	ChartEvent: [$NormalInfo/EventTypeLabel, eventType, $Params/EventParams]
}

@onready var typeCalls = {
	ChartObject: setChartObjectValues,
	ChartElement: setChartElementValues,
	ChartNote: setChartNoteValues,
	ChartObstacle: setChartObstacleValues,
	ChartEvent: setChartEventValues
}

#Ref
var selectedObjectsRef:Array
var conductorRef:Conductor

#LogicVars
var lastSongPosVal:float = 0.0
var songPosBounds:Dictionary = {"min": 0.0, "max": 0.0}

var lastHoldAmountVal:float = 0.0
var holdAmountBounds:Dictionary = {"min": 0.0, "max": 0.0}

signal updatedValue

func setReference(ref:Array, condRef:Conductor):
	selectedObjectsRef = ref
	conductorRef = condRef
	
	setActiveFields()

#Get Object Type
func getSelectedObjectType():
	var objectTypes = []
	var curObjectType:String = ""
	
	for object in selectedObjectsRef:
		curObjectType = object.get_script().get_global_name()
		
		if curObjectType not in objectTypes:
			objectTypes.append(curObjectType)
		
		if objectTypes.size() > 1:
			return "ChartObject"
	
	return curObjectType

#Activate Fields
func setActiveFields():
	disableFields()
	
	var objectTypeString = getSelectedObjectType()
	
	if objectTypeString == "":
		resizeWindow()
		return
	
	if objectTypeString not in typeMap:
		return
	
	var objectType = typeMap[objectTypeString].new()
	
	for type in typeGroups.keys():
		if is_instance_of(objectType, type):
			enableGroup(typeGroups[type])
			
			if typeCalls.has(type):
				typeCalls[type].call()
	
	var windowType = objectTypeString.replace("Chart", "").to_upper()
	windowRef.title.text = "EDIT " + windowType
	resizeWindow()

#Helper functions
func relativeField(field:SpinBox, isRelative:bool):
	field.allow_greater = isRelative
	field.allow_lesser = isRelative
	field.prefix = "+" if isRelative else ""
	
	field.min_value = -100000 if isRelative else 0.0
	field.max_value = 100000

func setObjectPosBounds():
	songPosBounds["min"] = INF
	songPosBounds["max"] = -INF
	for obj in selectedObjectsRef:
		if obj.position < songPosBounds["min"]: songPosBounds["min"] = obj.position
		if obj.position > songPosBounds["max"]: songPosBounds["max"] = obj.position

func setObjectHoldBounds():
	holdAmountBounds["min"] = INF
	holdAmountBounds["max"] = -INF
	for obj in selectedObjectsRef:
		var holdVal: float = obj.holdAmount if "holdAmount" in obj else 0.0
		var holdEnd: float = obj.position + holdVal
		
		if holdVal < holdAmountBounds["min"]: holdAmountBounds["min"] = holdVal
		if holdEnd > holdAmountBounds["max"]: holdAmountBounds["max"] = holdEnd

func setTypeSelector(field:OptionButton, types:Array, objectType:String):
	field.clear()
	field.disabled = false
	
	if selectedObjectsRef.size() <= 0:
		return
	
	for type in types:
		field.add_item(type)
	
	var firstType = selectedObjectsRef[0].get(objectType)
	var multValues = false
	for object in selectedObjectsRef:
		var type = object.get(objectType)
		if firstType != type:
			multValues = true
			break
	
	if multValues:
		field.add_item("Multiple")
		var multiple_index: int = field.get_item_count() - 1
		field.select(multiple_index)
		field.disabled = true
	else:
		field.select(firstType)

#Set Values
#Every field will have a different logic to it
func setChartObjectValues(): #Controls the object position
	lastSongPosVal = 0.0
	
	var useRelPosition = selectedObjectsRef.size() > 1
	relativeField(songPos, useRelPosition)
	
	if useRelPosition:
		songPos.set_value_no_signal(0.0)
		setObjectPosBounds()
	else:
		songPos.set_value_no_signal(selectedObjectsRef[0].position)

func setChartElementValues(): #Controls the object lane
	var lastLane = null
	lane.editable = true
	
	for element:ChartElement in selectedObjectsRef:
		if element.lane != lastLane and lastLane != null:
			lane.get_line_edit().text = "Multiple"
			lane.editable = false
			break
		
		lastLane = element.lane
	
	if lane.editable:
		lane.value = lastLane
		lane.get_line_edit().text = str(lastLane)

func setChartNoteValues(): #Controls the holdAmnt and noteTypes
	#Hold Amount
	lastHoldAmountVal = 0.0
	
	var useRelPosition = selectedObjectsRef.size() > 1
	relativeField(holdAmount, useRelPosition)
	
	if useRelPosition:
		holdAmount.set_value_no_signal(0.0)
		setObjectHoldBounds()
	else:
		holdAmount.set_value_no_signal(selectedObjectsRef[0].holdAmount)
	
	#Note Type
	var allTypes = ChartNote.NoteTypes.keys()
	setTypeSelector(noteType, allTypes, "noteType")

func setChartObstacleValues():
	var allTypes = ChartObstacle.ObsTypes.keys()
	setTypeSelector(obstacleType, allTypes, "obstacleType")
	
	if obstacleType.disabled:
		return
	
	setChartObstacleParams()

func setChartEventValues():
	var allTypes = ChartEvent.Types.keys()
	setTypeSelector(eventType, allTypes, "eventType")
	
	if eventType.disabled:
		return
	
	setChartEventParams()

func setChartObstacleParams():
	obstacleParams.setParams(selectedObjectsRef)

func setChartEventParams():
	eventParams.setParams(selectedObjectsRef)

#Enable/Disable fields
func enableGroup(group:Array):
	for item in group:
		item.visible = true

func disableFields():
	#normalInfo
	for item in normalInfo.get_children():
		item.visible = false
	
	#params
	for item in params.get_children():
		item.visible = false

#ResizeWindow
func resizeWindow():
	var new_height = get_combined_minimum_size().y
	
	get_parent().size.y = new_height + windowDownBorder
	size.y = new_height + windowDownBorder

#Actions when updating values
#SONG POSITION
func _on_song_pos_value_changed(value: float) -> void:
	if selectedObjectsRef.size() <= 0:
		return
	
	var songEnd = conductorRef.songLength - conductorRef.stepCrochet
	
	#SINGLE SELECTION
	if selectedObjectsRef.size() == 1:
		var object = selectedObjectsRef[0]
		var pos = clampf(value, 0.0, songEnd)
		
		if pos != value:
			songPos.set_value_no_signal(object.position)
			return
		
		object.position = pos
		updatedValue.emit()
		return
	
	#MULT SELECTION
	var relativeVal = value - lastSongPosVal
	var minBound = songPosBounds["min"] + relativeVal < 0.0
	var maxBound = songPosBounds["max"] + relativeVal > songEnd
	
	if minBound or maxBound:
		songPos.set_value_no_signal(lastSongPosVal)
		return
	
	for object in selectedObjectsRef:
		object.position += relativeVal
	
	songPosBounds["min"] += relativeVal
	songPosBounds["max"] += relativeVal
	
	updatedValue.emit()
	songPos.prefix = "" if value < 0 else "+"
	lastSongPosVal = value

#NOTE LANE
func _on_lane_value_changed(value: float) -> void:
	if selectedObjectsRef.size() <= 0:
		return
	
	for obj in selectedObjectsRef:
		obj.lane = value
	
	updatedValue.emit()

#NOTE HOLD
func _on_hold_amount_value_changed(value: float) -> void:
	if selectedObjectsRef.size() <= 0:
		return
	
	var songEnd = conductorRef.songLength - conductorRef.stepCrochet
	
	#SINGLE SELECTION
	if selectedObjectsRef.size() == 1:
		var object = selectedObjectsRef[0]
		var songHoldEnd = max(0.0, songEnd - object.position)
		
		var hold = clampf(value, 0.0, songHoldEnd)
		
		if hold != value:
			songPos.set_value_no_signal(object.holdAmount)
			return
		
		object.holdAmount = hold
		updatedValue.emit()
		return
	
	#MULT SELECTION
	var relativeVal = value - lastHoldAmountVal
	var minBound = holdAmountBounds["min"] + relativeVal < 0.0
	var maxBound = holdAmountBounds["max"] + relativeVal > songEnd
	
	if minBound or maxBound:
		holdAmount.set_value_no_signal(lastHoldAmountVal)
		return
	
	for object in selectedObjectsRef:
		object.holdAmount += relativeVal
	
	holdAmountBounds["min"] += relativeVal
	holdAmountBounds["max"] += relativeVal
	
	updatedValue.emit()
	holdAmount.prefix = "" if value < 0 else "+"
	lastHoldAmountVal = value

#TYPES
func setType(index:int, objType:String, paramCall:Variant = null):
	if selectedObjectsRef.size() <= 0:
		return
	
	for object in selectedObjectsRef:
		object.set(objType, index)
	
	if paramCall != null and paramCall is Callable:
		paramCall.call()
	
	updatedValue.emit()

func _on_note_type_item_selected(index: int) -> void:
	setType(index, "noteType")

func _on_obstacle_type_item_selected(index: int) -> void:
	setType(index, "obstacleType", setChartObstacleParams)

func _on_event_type_item_selected(index: int) -> void:
	setType(index, "eventType", setChartEventParams)
