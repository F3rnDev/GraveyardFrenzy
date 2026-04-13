extends ColorRect

@export var strumBar:StrumBar

@export var noteGrid:NoteGridUI
@export var eventGrid:EventGridUI
@export var renderedElements:ChartUIRenderedObjects

var active = false

var selecting = false
var initMousePos:Vector2

func startSelection():
	var noteGridRect = noteGrid.get_rect()
	var isInNoteGrid = noteGridRect.has_point(get_global_mouse_position())
	
	var eventGridRect = eventGrid.get_rect()
	var isInEventGrid = eventGridRect.has_point(get_global_mouse_position())
	
	if isInNoteGrid or isInEventGrid or strumBar.mouseInStrum:
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
	for object in renderedElements.get_children():
		if selectionRect.has_point(object.global_position):
			selectingNotes.append(object)
	
	renderedElements.selectObjectDrag(selectingNotes)
	
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
