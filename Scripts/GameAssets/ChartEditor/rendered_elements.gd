extends Control

class_name ChartUIRenderedElements

@onready var uiNote = preload("res://Nodes/GameAssets/ChartEditor/chart_ui_note.tscn")

@onready var initPos = global_position.x

var selectedElements:Array = []

var lastObsData:ChartObstacle = null

#Drag
var dragOffsets = {}
var updateHold = false
var canDragVertical = false

#Dependencies
@export var conductor:Conductor
@export var noteGrid:NoteGridUI

func _process(delta: float) -> void:
	setChartPos()

func loadChart():
	pass

func addNote(pos:Vector2):
	var noteInstance:ChartUINote = uiNote.instantiate()
	
	#setSignals
	noteInstance.noteSelected.connect(selectElement)
	noteInstance.noteDragging.connect(dragElement)
	noteInstance.startNoteDragging.connect(startDrag)
	
	#Set Position
	var actualXPos = (initPos - global_position.x) + pos.x
	noteInstance.global_position = Vector2(actualXPos, pos.y)
	
	#Set Note Data
	var noteData = ChartNote.new()
	
	noteData.position = getElementSongPos(noteInstance.position.x)
	
	var noteLaneYPos = (pos.y - noteGrid.global_position.y)
	noteData.lane = floor(noteLaneYPos / noteGrid.stepSize)
	
	noteData.holdAmount = 0.0
	
	add_child(noteInstance)
	noteInstance.setNote(noteData)
	
	#Drag and select
	selectNote(noteInstance, true)
	noteInstance.startNoteDrag()

#SELECT
func selectElement(element):
	if element is ChartUINote:
		selectNote(element)

func selectElementDrag(elements:Array):
	unselectElements()
	
	for element in elements:
		if element is ChartUINote:
			element.setSelected(true)
		
		selectedElements.append(element)

func selectNote(note:ChartUINote, created=false):
	if !Input.is_action_pressed("ChartMultSelect") or created:
		unselectElements()
	
	note.setSelected(true)
	
	if selectedElements.find(note) == -1:
		selectedElements.append(note)

func unselectElements():
	for element in get_children():
		element.setSelected(false)
	
	selectedElements.clear()

#DRAG
func startDrag():
	dragOffsets.clear()
	var localMouse = noteGrid.get_local_mouse_position()
	
	canDragVertical = true
	var lastLane = null
	
	updateHold = Input.is_action_pressed("ChartMultSelect")
	
	for element in selectedElements:
		if element is ChartUINote and updateHold:
			var currentHold = element.holdNoteEnd.position.x
			var noteEnd = element.position.x + currentHold
			dragOffsets[element] = Vector2(noteEnd - localMouse.x, element.position.y - localMouse.y)
			continue
		
		dragOffsets[element] = element.position - localMouse
		var noteLaneYPos = (element.position.y - noteGrid.global_position.y)
		var lane = floor(noteLaneYPos / noteGrid.stepSize)
		
		if lastLane != lane and lastLane != null:
			canDragVertical = false
		
		lastLane = lane

func dragElement(element):
	if updateHold:
		updateElementHold(element)
		return
	
	moveElement(element)

#UPDATENOTE HOLD
func updateElementHold(element):
	for curElement in selectedElements:
		if curElement is not ChartUINote:
			continue
		
		var moveX = setNoteHold(curElement)
	
		if moveX < 0.0 or !canSetHold(moveX, curElement):
			continue
		
		curElement.holdNoteEnd.position.x = moveX
		curElement.holdNoteLine.position.x = noteGrid.stepSize
		curElement.holdNoteLine.size.x = moveX - noteGrid.stepSize
		
		var noteData:ChartNote = curElement.noteData
		noteData.holdAmount = getNoteDurationFromPixels(moveX)
		
		curElement.setNote(noteData)

func setNoteHold(element):
	#GetXPosition
	var mousePosX = noteGrid.get_local_mouse_position().x
	var targetEndPos = mousePosX + dragOffsets[element].x
	var rawMoveX = targetEndPos - element.position.x
	
	return max(0, round(rawMoveX / noteGrid.stepSize) * noteGrid.stepSize)

func canSetHold(moveX:float, element:ChartUINote) -> bool:
	var startX = element.position.x
	var endX = startX + moveX
	
	#Check if not colliding with another note
	for otherElement in get_children():
		if otherElement == element:
			continue
		
		var otherPos = otherElement.position
		
		if abs(otherPos.y - element.position.y) > 1.0:
			continue
		
		if otherPos.x > startX and otherPos.x <= endX:
			return false
	
	return true

#MOVE ELEMENT
func moveElement(element):
	var moveX = moveElementHorizontal(element)
	var moveY = moveElementVertical(element)
	
	if !canMoveElement(moveX, moveY):
		return
	
	#MoveNote
	for curElement in selectedElements:
		curElement.position.x += moveX
		curElement.position.y = moveY if canDragVertical else curElement.position.y
		
		#Update elementInfo
		if curElement is ChartUINote:
			var noteData = curElement.noteData
			noteData.position = getElementSongPos(curElement.position.x)
	
			var noteLaneYPos = (curElement.global_position.y - noteGrid.global_position.y)
			noteData.lane = floor(noteLaneYPos / noteGrid.stepSize)
			
			curElement.setNote(noteData)

func moveElementVertical(element) -> float:
	if !canDragVertical:
		return 0.0
	
	var spacing = noteGrid.stepSpacing
	var header = noteGrid.stepMarkerHeight + spacing
	var laneSize = noteGrid.stepSize + spacing
	
	var mousePosY = noteGrid.get_local_mouse_position().y
	var targetY = (mousePosY + dragOffsets[element].x) - header
	
	var laneAmnt = 2
	var laneIndex = clamp(round(targetY / laneSize), 0, laneAmnt - 1)
	
	var snappedLocalY = header + (laneIndex * laneSize)
	return snappedLocalY + noteGrid.global_position.y

func moveElementHorizontal(element) -> float:
	#GetXPosition
	var mousePosX = noteGrid.get_local_mouse_position().x
	var targetX = mousePosX + dragOffsets[element].x
	var relativeX = targetX - noteGrid.initPos
	
	#Calculate X moveDelta
	var step = round(relativeX / noteGrid.stepSize)
	var snappedPos = (step * noteGrid.stepSize) + noteGrid.initPos
	
	return snappedPos - element.position.x

func canMoveElement(moveX:float, moveY:float) -> bool:
	for element in selectedElements:
		var futureX = element.position.x + moveX
		var futureEndX = futureX
		
		if element is ChartUINote:
				var elementHoldPixels = element.holdNoteEnd.position.x
				futureEndX = futureX + elementHoldPixels
		
		var futureY = moveY
		if !canDragVertical:
			futureY = element.position.y
		
		#SetLimits
		if getElementSongPos(futureX) < 0:
			return false
		
		if getElementSongPos(futureX) >= conductor.songLength - conductor.stepCrochet:
			return false
		
		#Check if not colliding with another note
		for otherElement in get_children():
			if otherElement in selectedElements:
				continue
			
			var otherEndX = otherElement.position.x
			
			if otherElement is ChartUINote:
				var otherHoldPixels = otherElement.holdNoteEnd.position.x
				otherEndX = otherElement.position.x + otherHoldPixels
			
			var distanceY = abs(otherElement.position.y - futureY)
			
			if futureX <= otherEndX and futureEndX >= otherElement.position.x and distanceY < 1.0:
				return false
	
	return true

#Chart/Song Positions
func getElementSongPos(noteXPos:float) -> float:
	var xPos = noteXPos - noteGrid.initPos
	var songPos = (xPos / noteGrid.stepSize) * conductor.stepCrochet
	return songPos

func getNoteDurationFromPixels(pixelDist: float) -> float:
	return (pixelDist / noteGrid.stepSize) * conductor.stepCrochet

func setChartPos():
	var xPos = ((conductor.songPos / conductor.stepCrochet) * (noteGrid.stepSize))
	
	global_position.x = (xPos * noteGrid.gridDir) + initPos

#KeyBoard Shortcuts / Additional Inputs
func _input(event: InputEvent) -> void:
	clickOutside()
	deleteNotes()

func deleteNotes():
	if !(Input.is_action_just_pressed("Delete") and selectedElements.size() > 0):
		return
	
	for element in selectedElements:
		element.queue_free()
	
	selectedElements.clear()

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
		unselectElements()
