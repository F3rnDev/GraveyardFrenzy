extends Control

class_name ChartUIRenderedObjects

#Object Groups
@onready var elements = $Elements
@onready var inputHandler = $InputHandler
@onready var elementThread = $RendElementsThread

#ObjectMap
@onready var instanceMap = {
	"ChartUINote": preload("res://Nodes/GameAssets/ChartEditor/Chart/Objects/chart_ui_note.tscn"),
	"ChartUIObstacle": preload("res://Nodes/GameAssets/ChartEditor/Chart/Objects/chart_ui_obstacle.tscn"),
	"ChartUIEvent": preload("res://Nodes/GameAssets/ChartEditor/Chart/Objects/chart_ui_event.tscn"),
	"ChartUIEventGroup": preload("res://Nodes/GameAssets/ChartEditor/Chart/Objects/chart_ui_event_group.tscn")
}

@onready var initPos = global_position.x

var selectedObjects:Array = []
var copiedObjects:Array = []

var lastObjectData:ChartObject

#Drag
var dragOffsets = {}
var updateHold = false
var canDragVertical = false

var draggedNode:ChartUIDraggable = null
var isDraggingNodes:bool = false

var filledPositions = {}

#Dependencies
@export var chartEditor:Control
@export var conductor:Conductor
@export var noteGrid:NoteGridUI
@export var eventGrid:EventGridUI
@export var gridInfo:GridInfo
@export var elementSelectUI:ElementTypeSelectUI

enum CreationType{
	PASTED,
	LOADED,
	ADDED,
	MERGED
}

#Some optimization
var lastSongPos = 0.0

@onready var renderedChart:Chart = Chart.new()
var activeObjects: Dictionary = {}

#Group events
var pendingEventMerges:Dictionary = {}

signal chartChanged
signal changedSelection
signal openEditWindow

func _ready() -> void:
	global_position = noteGrid.global_position
	setChartPos()

func _process(delta: float) -> void:
	
	#RENDER AND SET CHART POSITIONS
	if lastSongPos != conductor.songPos:
		setChartPos()
		renderObjects()
		lastSongPos = conductor.songPos
	
	#HANDLE DRAG INPUT
	if isDraggingNodes:
		dragObject(draggedNode)

func loadChart(chart:Chart):
	clearObjects()
	renderedChart = chart
	renderedChart.groupEvents()

	chartChanged.emit()
	renderObjects()

func renderObjects():
	for element in renderedChart.elements:
		var pos = getObjectPos(element.position, element.lane)
		var hold = 0.0 if element is ChartObstacle else getNotePixelsFromDuration(element.holdAmount)
		
		if outsideViewport(pos, hold):
			if element in activeObjects:
				removeObject(element)
			
			continue
		
		if not element in activeObjects:
			renderObject(element, CreationType.LOADED)
	
	for event in renderedChart.events:
		var pos = getObjectPos(event.position)
		
		if outsideViewport(pos):
			if event in activeObjects:
				removeObject(event)
			
			continue
		
		if not event in activeObjects:
			renderObject(event, CreationType.LOADED)

func outsideViewport(pos: Vector2, width: float = 0.0) -> bool:
	var viewportSize = get_viewport_rect().size
	var realPos = pos.x + global_position.x
	
	var outsideLeft = (realPos + width + gridInfo.stepSize) < 0.0
	var outsideRight = realPos - gridInfo.stepSize > (viewportSize.x)
	
	return outsideLeft or outsideRight

func removeObject(object):
	var uiNode:ChartUIObject = activeObjects[object]
	
	if is_instance_valid(uiNode):
		uiNode.queue_free()
	
	activeObjects.erase(object)

func renderObject(objectData, type:CreationType):
	var object: ChartUIObject = objectData.getUIType().new()
	
	if object:
		addObject(object, objectData, type)

func clearObjects():
	for object in activeObjects.keys():
		removeObject(object)

func getChart():
	renderedChart.unpackEvents()
	
	renderedChart.elements.sort_custom(func(a,b): return a.position < b.position)
	renderedChart.events.sort_custom(func(a,b): return a.position < b.position)
	
	return renderedChart

#Add objects to scene
func addObject(object:ChartUIObject, data:ChartObject, creationType:CreationType):
	#Create instance
	var objectType = object.get_script().get_global_name()
	var objectToInstance = instanceMap[objectType]
	
	var instance:ChartUIObject = objectToInstance.instantiate()
	
	#setSignals
	instance.selected.connect(selectObject)
	instance.startDragging.connect(startDrag)
	instance.endDragging.connect(endDrag)
	if instance is ChartUIEventGroup:
		instance.unmerge.connect(unmergeEvent)
	
	#Add object
	elements.add_child(instance)
	activeObjects[data] = instance
	
	#Set Object Position
	var lane = data.lane if "lane" in data else -1
	var pos = getObjectPos(data.position, lane)
	instance.setPositionLocal(pos)
	
	#Set object UI and reference
	instance.refData = data
	instance.updateUI(data, self, conductor.stepCrochet)
	
	#Drag and select
	if creationType == CreationType.ADDED:
		selectObject(instance, true)
		instance.startDrag()
	
	if creationType == CreationType.MERGED:
		selectObject(instance, true)
	
	#Paste objects (allow player to move pasted instances)
	if creationType == CreationType.PASTED:
		instance.setSelected(true)
		
		if data not in selectedObjects:
			selectedObjects.append(data)
	
	if data in selectedObjects:
		instance.setSelected(true)
	
	#emit signal if chart was changed
	if creationType != CreationType.LOADED:
		chartChanged.emit()

#SELECT
func selectObject(object:ChartUIObject, created=false):
	if !Input.is_action_pressed("ChartMultSelect") or created:
		unselectObjects()
	
	if object.refData not in selectedObjects:
		selectedObjects.append(object.refData)
	
	object.setSelected(true)
	
	#close event groups if necessary
	if selectedObjects.size() > 1:
		closeAllActiveEventGroups()
	
	lastObjectData = object.refData
	
	changedSelection.emit()

func selectObjectDrag(objects:Array):
	unselectObjects()
	
	for object in objects:
		if object.refData not in selectedObjects:
			selectedObjects.append(object.refData)
		
		object.setSelected(true)
	
	#close event groups if necessary
	if selectedObjects.size() > 1:
		closeAllActiveEventGroups()
	
	changedSelection.emit()

func closeAllActiveEventGroups():
	for data in activeObjects:
		var node = activeObjects[data]
		if node is ChartUIEventGroup:
			node.animateEventContainer(false)

func unselectObjects():
	for data in activeObjects:
		var object = activeObjects[data]
		object.setSelected(false)
	
	selectedObjects.clear()
	
	if isDraggingNodes:
		endDrag()
	
	changedSelection.emit()

#DRAG
#SetStartDrag
func startDrag(leaderObject:ChartUIObject):
	dragOffsets.clear()
	
	draggedNode = leaderObject
	
	#Get Mouse chartPos
	var MousePosX = noteGrid.get_local_mouse_position().x
	var mouseSongPos = max(0.0, snapped(getObjectSongPos(MousePosX), conductor.stepCrochet))
	
	updateHold = Input.is_action_pressed("ChartMultSelect")
	
	var threadDict = {
		"selectedObjects": selectedObjects,
		"updateHold": updateHold,
		"mouseSongPos": mouseSongPos,
		"renderedChart": renderedChart,
		"conductor": conductor
	}
	elementThread.addTask(elementThread.calculateDrag, setDrag, threadDict)

func setDrag(result:Dictionary):
	canDragVertical = result["dragOffsetResult"]["canDragVertical"]
	dragOffsets =  result["dragOffsetResult"]["dragOffsets"]
	filledPositions = result["filledPositionsResult"]
	
	#START DRAGGING
	isDraggingNodes = true

func endDrag():
	isDraggingNodes = false
	draggedNode = null
	dragOffsets.clear()
	
	chartChanged.emit()
	
	#ChartChanged
	changedSelection.emit()
	
	#Update grouping
	if pendingEventMerges.is_empty():
		return
	
	mergeEvent()

func mergeEvent():
	for draggedEvent in pendingEventMerges:
		var existingEvent = pendingEventMerges[draggedEvent]
		
		if is_instance_valid(draggedEvent) and is_instance_valid(existingEvent):
			var newGroup:ChartEventGroup = renderedChart.merge2Events(draggedEvent, existingEvent)
		
			if draggedEvent in activeObjects: removeObject(draggedEvent)
			if existingEvent in activeObjects: removeObject(existingEvent)
			
			renderObject(newGroup, CreationType.MERGED)
	
	pendingEventMerges.clear()

func unmergeEvent(eventNode:ChartUIEvent, group:ChartUIEventGroup):
	var eventData:ChartEvent = eventNode.refData
	var groupData:ChartEventGroup = group.refData
	
	var newGroup = renderedChart.splitEventFromGroup(eventData, groupData)
	
	if newGroup is ChartEventGroup:
		group.updateUI(newGroup, self, conductor.stepCrochet)
	elif newGroup is ChartEvent:
		removeObject(groupData)
		renderObject(newGroup, CreationType.LOADED)
	
	var MousePosX = noteGrid.get_local_mouse_position().x
	var mouseSongPos = max(0.0, snapped(getObjectSongPos(MousePosX), conductor.stepCrochet))
	
	eventData.position = mouseSongPos
	
	renderObject(eventData, CreationType.ADDED)

func dragObject(object):
	if !object:
		return
	
	if object.refData not in dragOffsets:
		var MousePosX = noteGrid.get_local_mouse_position().x
		var mouseSongPos = max(0.0, snapped(getObjectSongPos(MousePosX), conductor.stepCrochet))
		
		dragOffsets[object.refData] = object.refData.position - mouseSongPos
	
	if updateHold:
		updateNoteHold()
	else:
		moveObject(object)

#UpdateGraphics
func updateActiveObjects():
	for data in selectedObjects:
		setUIObject(data)

func setUIObject(data:ChartObject):
	#Despawn/Spawn note if in limits
	var pos = getObjectPos(data.position, data.lane if "lane" in data else -1)
	var hold = getNotePixelsFromDuration(data.holdAmount) if "holdAmount" in data else 0.0
	
	if outsideViewport(pos, hold):
		if data in activeObjects:
			removeObject(data)
		
		return
	
	if not data in activeObjects:
		renderObject(data, CreationType.LOADED)
	
	#MoveNoteIfInActiveNotes
	if data in activeObjects:
		var node:ChartUIObject = activeObjects[data]
		var lane = data.lane if "lane" in data else -1
		var newPos = getObjectPos(data.position, lane)
		
		node.setPositionLocal(newPos)
		node.updateUI(data, self, conductor.stepCrochet)

#UPDATENOTE HOLD
func updateNoteHold():
	for data in selectedObjects:
		if data is not ChartNote:
			continue
		
		var gridPos = Vector2(data.position, data.lane)
		if !gridPos in filledPositions:
			filledPositions[gridPos] = data
		
		var hold = setNoteHold(data)
	
		if !canSetHold(hold, data):
			continue
		
		#SetData
		data.holdAmount = hold
		
		#UpdateUI
		setUIObject(data)

func setNoteHold(data):
	var mousePosX = noteGrid.get_local_mouse_position().x
	var mouseSongPosX = getObjectSongPos(mousePosX)
	
	var targetEndTime = mouseSongPosX + dragOffsets[data]
	var rawMoveTime = targetEndTime - data.position
	
	var minSnap = conductor.stepCrochet
	return max(0.0, snapped(rawMoveTime, minSnap))

func canSetHold(hold:float, data:ChartNote) -> bool:
	#Is colliding with the end of the song
	if data.position + hold > conductor.songLength - conductor.stepCrochet:
		return false
	
	#Is colliding with another note
	var minSnap = conductor.stepCrochet
	var currentTime = data.position + minSnap
	var endTime = data.position + hold
	
	while currentTime <= endTime:
		var snappedTime = snapped(currentTime, minSnap)
		
		var pos = Vector2(snappedTime, data.lane)
		if pos in filledPositions:
			return false
		
		currentTime += minSnap
	
	return true

#MOVE Object
func moveObject(object):
	var targetTime = moveHorizontal(object.refData)
	var targetLane = moveVertical(object.refData)
	var isAllowedToMove = canMove(targetTime, targetLane)
	var isAllowedToMerge = !pendingEventMerges.is_empty() and selectedObjects.size() == 1
	
	if !isAllowedToMove and !isAllowedToMerge:
		return
	
	if object is ChartUIEvent:
		object.changeMergeStatus(isAllowedToMove)
	
	#MoveNote
	for data in selectedObjects:
		if data not in dragOffsets:
			return
		
		data.position = targetTime + dragOffsets[data]
		
		if "lane" in data and canDragVertical:
			data.lane = targetLane
		
		setUIObject(data)

func moveHorizontal(object:ChartObject) -> float:
	#GetPosition
	var mousePosX = noteGrid.get_local_mouse_position().x
	var mouseSongPos = getObjectSongPos(mousePosX)
	
	return max(0.0, snapped(mouseSongPos, conductor.stepCrochet))

func moveVertical(object:ChartObject) -> float:
	if !canDragVertical:
		return object.lane if object is ChartElement else -1
	
	var spacing = noteGrid.stepSpacing
	var header = noteGrid.stepMarkerHeight + spacing
	var mousePosY = noteGrid.get_local_mouse_position().y - header
	
	var mouseLane = floor(mousePosY / gridInfo.stepSize)
	
	return int(clamp(mouseLane, 0, gridInfo.laneAmnt - 1))

func canMove(moveX:float, moveY:float) -> bool:
	#Check mouse
	var viewport = get_viewport()
	var mouse_pos = viewport.get_mouse_position()
	if !viewport.get_visible_rect().has_point(mouse_pos):
		return false
	
	pendingEventMerges.clear()
	for data in selectedObjects:
		#Set future positions
		var offset = dragOffsets.get(data, 0.0)
		
		var futureTime = moveX + offset
		var futureLane = moveY
		
		if !canDragVertical or data is not ChartElement:
			futureLane = data.lane if "lane" in data else 2
		
		#Check collision
		var existing = objectColliding(futureTime, futureLane, data)
		if existing != null:
			if data is ChartEvent and (existing is ChartEvent or existing is ChartEventGroup) and data not in pendingEventMerges:
				pendingEventMerges[data] = existing
			
			return false
		
		#SetLimits
		if futureTime < 0:
			return false
		
		var holdEnd = 0.0 if data is not ChartNote else data.holdAmount
		if futureTime + holdEnd >= conductor.songLength - conductor.stepCrochet:
			return false
	
	return true

func isObjectColliding(songPos:float, lane:float, object:ChartObject) -> bool:
	if objectColliding(songPos, lane, object) != null:
		return true
	
	return false

func objectColliding(songPos:float, lane:float, object:ChartObject) -> ChartObject:
	#Check if object is not colliding with another object
	if Vector2(songPos, lane) in filledPositions:
		return filledPositions[Vector2(songPos, lane)]
	
	#Check if HOLD is not colliding with another object
	if object is ChartNote:
		var minSnap = conductor.stepCrochet
		var currentTime = songPos + minSnap
		var endTime = songPos + object.holdAmount
		
		while currentTime <= endTime:
			var snappedTime = snapped(currentTime, minSnap)
			
			var pos = Vector2(snappedTime, lane)
			if pos in filledPositions:
				return filledPositions[pos]
			
			currentTime += minSnap
	
	return null

#Chart/Song Positions
func getObjectPos(songXPos, lane:int = -1):
	var xPos = ((songXPos / conductor.stepCrochet) * (gridInfo.stepSize))
	var yPos = 0.0
	
	if lane != -1:
		var spacing = noteGrid.stepSpacing
		var header = noteGrid.stepMarkerHeight + spacing
		var laneSize = gridInfo.stepSize + spacing
		
		yPos = (header + (lane * laneSize))
	else:
		yPos = eventGrid.global_position.y - noteGrid.global_position.y
	
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

#SIGNALS
func _on_note_grid_add_note(pos: Vector2) -> void:
	# check section info and stuff, decide if a note or obstacle
	var element
	match elementSelectUI.currentType:
		ChartElement.Types.Note:
			element = ChartUINote.new()
		ChartElement.Types.Obs:
			element = ChartUIObstacle.new()
	
	var finalPos = pos - Vector2(global_position.x, noteGrid.global_position.y)
	
	#Set Data
	var data = element.getDataType().new()
	data.position = getObjectSongPos(finalPos.x)
	data.lane = floor((finalPos.y) / gridInfo.stepSize)
	
	#Add to Chart
	renderedChart.elements.append(data)
	
	renderObject(data, CreationType.ADDED)

func _on_event_grid_add_event(pos: Vector2) -> void:
	var finalPos = pos - Vector2(global_position.x, noteGrid.global_position.y)
	
	#Set Data
	var data = ChartEvent.new()
	data.position = getObjectSongPos(finalPos.x)
	
	#Add to Chart
	renderedChart.events.append(data)
	
	renderObject(data, CreationType.ADDED)
