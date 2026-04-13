extends TextureRect

class_name ChartUIObject #Elements AND Events

#Hovered
var isHovered = true

#Select
@onready var selectRect = $SelectHint
var isSelected = false

#Drag
var mouseDragStart:Vector2
var isDragging = false
var dragThreshold = 6.0

#Signals
signal selected(note:ChartUINote)
signal startDragging(note:ChartUINote)
signal dragging()

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func setSelected(selected:bool):
	isSelected = selected
	selectRect.visible = selected

func setPositionGlobal(pos:Vector2): #When creating the object
	global_position = pos

func setPositionLocal(pos:Vector2):
	position = pos

func _input(event: InputEvent) -> void:
	if !isHovered and !isDragging:
		return
	
	if !isSelected and isDragging:
		isDragging = false
	
	if isSelected and Input.is_action_just_pressed("LeftMouseClick"):
		startDrag()
	elif isSelected and Input.is_action_pressed("LeftMouseClick"):
		checkDrag()
	
	select()

#DRAG
func startDrag():
	mouseDragStart = get_global_mouse_position()
	isDragging = false
	
	startDragging.emit()

func checkDrag():
	var mousePos = get_global_mouse_position()

	if !isDragging:
		if mousePos.distance_to(mouseDragStart) > dragThreshold:
			isDragging = true
	
	drag()

func drag():
	if isDragging:
		var mousePos = get_global_mouse_position()
		dragging.emit(self)

#Select
func select():
	if Input.is_action_just_released("LeftMouseClick") and !isDragging:
		selected.emit(self)

#Signals
func _on_mouse_entered() -> void:
	isHovered = true

func _on_mouse_exited() -> void:
	isHovered = false
