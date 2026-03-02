extends Control

signal startedGrab()
signal moveGrab(direction)

#Drag Strum bar
var isMouseDragging = false
var dragStartMousePos = 0.0
var dragAmnt = 0.0

@export var mouseDragDistanceRight = 500.0
@export var mouseDragDistanceLeft = 500.0
@export var minDragInterval = 0.05
@export var maxDragInterval = 1.0

func dragChart(delta):
	#GetPos and direction
	var mousePos = floor((get_global_mouse_position().x - dragStartMousePos))
	var dragDir = sign(mousePos)
	
	#GetDragInterval
	var curDragDistance = mouseDragDistanceRight
	if dragDir == -1:
		curDragDistance = mouseDragDistanceLeft
	
	var t = clamp(abs(mousePos) / curDragDistance, 0.0, 1.0)
	var dragInterval = lerp(maxDragInterval, minDragInterval, t)
	
	#UpdateDrag
	dragAmnt += delta
	
	if dragAmnt >= dragInterval:
		dragAmnt = 0.0
		moveGrab.emit(dragDir)

func _on_strum_bar_button_down() -> void:
	dragStartMousePos = get_global_mouse_position().x
	isMouseDragging = true
	startedGrab.emit()

func _on_strum_bar_button_up() -> void:
	isMouseDragging = false
	startedGrab.emit()
