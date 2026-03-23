extends ColorRect

@export var noteGrid:NoteGridUI
@export var renderedElements:ChartUIRenderedElements
#@export var renderedEvents

var active = false

var selecting = false
var initMousePos:Vector2

func startSelection():
	var noteGridRect = noteGrid.get_rect()
	if noteGridRect.has_point(get_global_mouse_position()):
		return
	
	initMousePos = get_global_mouse_position()
	
	global_position = initMousePos
	selecting = true

func updateSelection():
	var endMousePos = get_global_mouse_position()
	global_position.x = min(initMousePos.x, endMousePos.x)
	global_position.y = min(initMousePos.y, endMousePos.y)
	
	size.x = abs(endMousePos.x - initMousePos.x)
	size.y = abs(endMousePos.y - initMousePos.y)

func select():
	selecting = false
	
	var selectingNotes:Array = []
	var selectionRect = get_rect()
	for element in renderedElements.get_children():
		if selectionRect.has_point(element.global_position):
			selectingNotes.append(element)
	
	renderedElements.selectElementDrag(selectingNotes)
	
	size = Vector2.ZERO

func _input(event: InputEvent) -> void:
	if !active:
		return
	
	if Input.is_action_just_pressed("LeftMouseClick"):
		startSelection()
	
	if !selecting:
		return
	
	if Input.is_action_just_released("LeftMouseClick"):
		select()
	
	if Input.is_action_pressed("LeftMouseClick"):
		updateSelection()
