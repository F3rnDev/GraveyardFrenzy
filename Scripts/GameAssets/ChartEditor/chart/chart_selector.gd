extends ColorRect

@export var strumBar:StrumBar

@export var noteGrid:NoteGridUI
@export var eventGrid:EventGridUI
@export var renderedElements:ChartUIRenderedObjects

@onready var selector = $Selector

var active = false

var selecting = false
var initMousePos:Vector2

func startSelection():
	initMousePos = get_global_mouse_position()
	
	selector.global_position = initMousePos
	selecting = true

func updateSelection():
	var endMousePos = get_global_mouse_position()
	selector.global_position.x = min(initMousePos.x, endMousePos.x)
	selector.global_position.y = min(initMousePos.y, endMousePos.y)
	
	selector.size.x = abs(endMousePos.x - initMousePos.x)
	selector.size.y = abs(endMousePos.y - initMousePos.y)

func select():
	selecting = false
	
	var selectingNotes:Array = []
	var selectionRect = selector.get_rect()
	for object in renderedElements.get_children():
		if selectionRect.has_point(object.global_position):
			selectingNotes.append(object)
	
	renderedElements.selectObjectDrag(selectingNotes)
	
	selector.size = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
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
