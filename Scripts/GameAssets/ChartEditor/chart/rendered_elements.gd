extends Control

class_name ChartUIRenderedObjects

@onready var uiNote = preload("res://Nodes/GameAssets/ChartEditor/Chart/Objects/chart_ui_note.tscn")
@onready var uiEvent = preload("res://Nodes/GameAssets/ChartEditor/Chart/Objects/chart_ui_event.tscn")
@onready var uiObstacle = preload("res://Nodes/GameAssets/ChartEditor/Chart/Objects/chart_ui_obstacle.tscn")

@onready var initPos = global_position.x

var selectedObjects:Array = []

var lastNoteType:ChartNote.NoteTypes = ChartNote.NoteTypes.Normal
var lastObsType:ChartObstacle.ObsTypes = ChartObstacle.ObsTypes.Cactus
var lastEventType:ChartEvent.Types = ChartEvent.Types.Runner

#Drag
var dragOffsets = {}
var updateHold = false
var canDragVertical = false

var filledPositions = {}

#Dependencies
@export var conductor:Conductor
@export var noteGrid:NoteGridUI
@export var eventGrid:EventGridUI
@export var gridInfo:GridInfo
@export var elementSelectUI:ElementTypeSelectUI

func _process(delta: float) -> void:
	setChartPos()

func loadChart(chart:Chart):
	clearChart()
	
	for element in chart.elements:
		var pos = getElementPos(element.position, element.lane)
		var object
		
		if element.elementType == ChartElement.Types.Note:
			object = ChartUINote.new()
		elif element.elementType == ChartElement.Types.Obs:
			object = ChartUIObstacle.new()
		
		addObject(pos, object, element.getDict())
	
	for event in chart.events:
		var pos = getEventPos(event.position)
		
		addObject(pos, ChartUIEvent.new(), event.getDict())

func clearChart():
	for object in get_children():
		object.queue_free()

func getChart():
	var curChart:Chart = Chart.new()
	
	for object in get_children():
		if object is ChartUINote:
			curChart.elements.append(object.noteData)
		elif object is ChartUIObstacle:
			curChart.elements.append(object.obsData)
		elif object is ChartUIEvent:
			curChart.events.append(object.eventData)
	
	curChart.elements.sort_custom(func(a,b): return a.position < b.position)
	curChart.events.sort_custom(func(a,b): return a.position < b.position)
	
	return curChart

func addObject(pos:Vector2, object:ChartUIObject, previousData:Dictionary = {}):
	var objectToInstance = uiNote
	if object is ChartUIEvent:
		objectToInstance = uiEvent
	elif object is ChartUIObstacle:
		objectToInstance = uiObstacle
	
	var instance:ChartUIObject = objectToInstance.instantiate()
	
	#setSignals
	instance.selected.connect(selectObject)
	instance.dragging.connect(dragObject)
	instance.startDragging.connect(startDrag)
	
	#Set Position
	var selXPos = (initPos - global_position.x) + pos.x
	
	if !previousData.is_empty():
		selXPos = initPos + pos.x
	
	instance.setPositionGlobal(Vector2(selXPos, pos.y))
	
	add_child(instance)
	
	#Set Data
	var dict = {}
	
	if previousData.is_empty():
		dict["position"] = getObjectSongPos(instance.position.x)
		
		if object is not ChartUIEvent:
			dict["lane"] = floor((pos.y - noteGrid.global_position.y) / gridInfo.stepSize)
	else:
		dict = previousData
	
	instance.setData(dict)
	
	#Set Hold, if it has any
	if object is ChartUINote and dict.has("holdAmount") and dict["holdAmount"] > 0.0:
		var hold = getNotePixelsFromDuration(dict["holdAmount"])
		instance.updateHold(hold, gridInfo.stepSize)
	
	#Drag and select
	if previousData.is_empty():
		instance.isHovered = true
		selectObject(instance, true)
		instance.startDrag()

#SELECT
func selectObject(object:ChartUIObject, created=false):
	if !Input.is_action_pressed("ChartMultSelect") or created:
		unselectObjects()
	
	object.setSelected(true)
	
	if selectedObjects.find(object) == -1:
		selectedObjects.append(object)
	
	#Set last object Data
	if object is ChartUINote:
		lastNoteType = object.noteData.noteType
	elif object is ChartUIObstacle:
		lastObsType = object.obsData.obstacleType
	elif object is ChartUIEvent:
		lastEventType = object.eventData.eventType

func selectObjectDrag(objects:Array):
	unselectObjects()
	
	for object in objects:
		object.setSelected(true)
		selectedObjects.append(object)

func unselectObjects():
	for object in get_children():
		object.setSelected(false)
	
	selectedObjects.clear()

#DRAG
func startDrag():
	dragOffsets.clear()
	var localMouse = noteGrid.get_local_mouse_position()
	
	canDragVertical = true
	var lastLane = null
	
	updateHold = Input.is_action_pressed("ChartMultSelect")
	
	for object in selectedObjects:
		if object is ChartUINote and updateHold:
			var currentHold = object.holdNoteEnd.position.x
			var noteEnd = object.position.x + currentHold
			dragOffsets[object] = Vector2(noteEnd - localMouse.x, object.position.y - localMouse.y)
			continue
		
		dragOffsets[object] = object.position - localMouse
		
		if object is ChartUIEvent:
			continue
		
		var noteLaneYPos = (object.position.y - noteGrid.global_position.y)
		var lane = floor(noteLaneYPos / gridInfo.stepSize)
		
		if lastLane != lane and lastLane != null:
			canDragVertical = false
		
		lastLane = lane
	
	filledPositions.clear()
	for object:TextureRect in get_children():
		if selectedObjects.has(object):
			continue
		
		filledPositions[object.position] = true
		
		if object is ChartUINote:
			var holdDuration = object.holdNoteEnd.position.x / gridInfo.stepSize
			
			for holdPos in range(holdDuration):
				var holdX = gridInfo.stepSize * (holdPos + 1)
				var newPos = Vector2(object.position.x + holdX, object.position.y)
				filledPositions[newPos] = true

func dragObject(object):
	if updateHold:
		updateNoteHold(object)
		return
	
	moveObject(object)

#UPDATENOTE HOLD
func updateNoteHold(note):
	for object in selectedObjects:
		if !object.position in filledPositions:
			filledPositions[object.position] = true
		
		if object is not ChartUINote:
			continue
		
		var hold = setNoteHold(object)
	
		if !canSetHold(hold, object):
			continue
		
		#SetData
		var dict = {}
		dict["holdAmount"] = getNoteDurationFromPixels(hold)
		object.setData(dict)
		
		#SetHold
		object.updateHold(hold, gridInfo.stepSize)

func setNoteHold(element):
	var mousePosX = noteGrid.get_local_mouse_position().x
	var targetEndPos = mousePosX + dragOffsets[element].x
	var rawMoveX = targetEndPos - element.position.x
	
	return max(0, round(rawMoveX / gridInfo.stepSize) * gridInfo.stepSize)

func canSetHold(moveX:float, note:ChartUINote) -> bool:
	var startX = note.position.x
	var holdDuration = moveX / gridInfo.stepSize
	
	if getObjectSongPos(startX + moveX) > conductor.songLength - conductor.stepCrochet:
		return false
	
	for holdPos in range(holdDuration):
		var holdX = gridInfo.stepSize * (holdPos + 1)
		var newPos = Vector2(startX + holdX, note.position.y)
		if newPos in filledPositions:
			print(newPos.x, " and ", conductor.songLength)
			return false
	
	return true

#MOVE Object
func moveObject(object):
	var moveX = moveHorizontal(object)
	var moveY = moveVertical(object)
	
	if !canMove(moveX, moveY):
		return
	
	#MoveNote
	for curObject in selectedObjects:
		curObject.position.x += moveX
		
		if curObject is not ChartUIEvent:
			curObject.position.y = moveY if canDragVertical else curObject.position.y
		
		#Update Info
		var dict = {}
		dict["position"] = getObjectSongPos(curObject.position.x)
		
		if curObject is not ChartUIEvent:
			dict["lane"] = floor((curObject.global_position.y - noteGrid.global_position.y) / gridInfo.stepSize)
		
		curObject.setData(dict)

func moveVertical(element) -> float:
	if !canDragVertical:
		return 0.0
	
	var spacing = noteGrid.stepSpacing
	var header = noteGrid.stepMarkerHeight + spacing
	var laneSize = gridInfo.stepSize + spacing
	
	var mousePosY = noteGrid.get_local_mouse_position().y
	var targetY = (mousePosY + dragOffsets[element].x) - header
	var laneIndex = clamp(round(targetY / laneSize), 0, gridInfo.laneAmnt - 1)
	
	var snappedLocalY = header + (laneIndex * laneSize)
	return snappedLocalY + noteGrid.global_position.y

func moveHorizontal(element) -> float:
	#GetXPosition
	var mousePosX = noteGrid.get_local_mouse_position().x
	var targetX = mousePosX + dragOffsets[element].x
	var relativeX = targetX - noteGrid.initPos
	
	#Calculate X moveDelta
	var step = round(relativeX / gridInfo.stepSize)
	var snappedPos = (step * gridInfo.stepSize) + noteGrid.initPos
	
	return snappedPos - element.position.x

func canMove(moveX:float, moveY:float) -> bool:
	for object in selectedObjects:
		#Set future positions
		var futureX = object.position.x + moveX
		var futureY = moveY
		if !canDragVertical or object is ChartUIEvent:
			futureY = object.position.y
		
		#Check if object is not colliding with another object
		if Vector2(futureX, futureY) in filledPositions:
			return false
		
		#Check if HOLD is not colliding with another object
		var holdEndPos = 0.0
		if object is ChartUINote:
			holdEndPos = object.holdNoteEnd.position.x
			var holdDuration = holdEndPos / gridInfo.stepSize
			
			for holdPos in range(holdDuration):
				var holdX = gridInfo.stepSize * (holdPos + 1)
				var newPos = Vector2(futureX + holdX, futureY)
				if newPos in filledPositions:
					return false
		
		#SetLimits
		if getObjectSongPos(futureX) < 0:
			return false
		
		if getObjectSongPos(futureX + holdEndPos) >= conductor.songLength - conductor.stepCrochet:
			return false
	
	return true

#Chart/Song Positions
func getElementPos(songXPos, lane):
	#SetXPos
	var xPos = ((songXPos / conductor.stepCrochet) * (gridInfo.stepSize))
	
	#SetYPos
	var spacing = noteGrid.stepSpacing
	var header = noteGrid.stepMarkerHeight + spacing
	var laneSize = gridInfo.stepSize + spacing
	
	var yPos = (header + (lane * laneSize)) + noteGrid.global_position.y
	
	return Vector2(xPos + noteGrid.initPos, yPos)

func getEventPos(songXPos):
	#SetXPos
	var xPos = ((songXPos / conductor.stepCrochet) * (gridInfo.stepSize))
	var yPos = eventGrid.global_position.y
	
	return Vector2(xPos + noteGrid.initPos, yPos)

func getObjectSongPos(noteXPos:float) -> float:
	var xPos = noteXPos - noteGrid.initPos
	var songPos = (xPos / gridInfo.stepSize) * conductor.stepCrochet
	return songPos

func getNotePixelsFromDuration(noteHold:float) -> float:
	return (noteHold * gridInfo.stepSize) / conductor.stepCrochet

func getNoteDurationFromPixels(pixelDist: float) -> float:
	return (pixelDist / gridInfo.stepSize) * conductor.stepCrochet

func setChartPos():
	var xPos = ((conductor.songPos / conductor.stepCrochet) * (gridInfo.stepSize))
	
	global_position.x = (xPos * gridInfo.gridDir) + initPos

#KeyBoard Shortcuts / Additional Inputs
func _input(event: InputEvent) -> void:
	clickOutside()
	deleteObjects()

func deleteObjects():
	if !(Input.is_action_just_pressed("Delete") and selectedObjects.size() > 0):
		return
	
	for element in selectedObjects:
		element.queue_free()
	
	selectedObjects.clear()

func clickOutside():
	if !Input.is_action_pressed("LeftMouseClick"):
		return
	
	var canUnselect = []
	for element in get_children():
		if !element.isHovered and !element.isDragging:
			canUnselect.append(true)
		else:
			canUnselect.append(false)
	
	if canUnselect.find(false) == -1:
		unselectObjects()

#SIGNALS
func _on_note_grid_add_note(pos: Vector2) -> void:
	# check section info and stuff, decide if a note or obstacle
	var element
	match elementSelectUI.currentType:
		ChartElement.Types.Note:
			element = ChartUINote.new()
		ChartElement.Types.Obs:
			element = ChartUIObstacle.new()
	
	addObject(pos, element)

func _on_event_grid_add_event(pos: Vector2) -> void:
	addObject(pos, ChartUIEvent.new())
