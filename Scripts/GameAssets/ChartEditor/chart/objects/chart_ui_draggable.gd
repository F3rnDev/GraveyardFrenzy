extends TextureRect

class_name ChartUIDraggable

var isGuiInput = false

#Select
@onready var selectRect = $SelectHint
var isSelected = false

#Drag
var mouseDragStart:Vector2
var dragThreshold = 6.0

#Signals
signal selected()
signal startDragging()
signal endDragging()

#Animation
var startScale = Vector2.ZERO

func _ready() -> void:
	setSelected(false)
	startCreateAnimation()

func startCreateAnimation():
	createAnimation(self)

func createAnimation(rect:TextureRect):
	var mat = rect.material as ShaderMaterial
	if not mat:
		return
	
	mat.set_shader_parameter("texture_scale", 0.0)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(mat, "shader_parameter/texture_scale", 1.0, 0.2)

func setSelected(selected:bool):
	isSelected = selected
	selectRect.visible = selected

func setPositionGlobal(pos:Vector2): #When creating the object
	global_position = pos

func setPositionLocal(pos:Vector2):
	position = pos

#Allows player to drag the created object
func _input(event: InputEvent) -> void:
	if isSelected and Input.is_action_just_released("LeftMouseClick"):
		endDrag()
	
	if isGuiInput or !isSelected:
		return
	
	processInput()

func _gui_input(event: InputEvent) -> void:
	isGuiInput = true
	processInput()

func processInput():
	select()
	
	if isSelected and Input.is_action_just_pressed("LeftMouseClick"):
		startDrag()

#DRAG
func startDrag():
	mouseDragStart = get_global_mouse_position()
	
	startDragging.emit(self)

func endDrag():
	endDragging.emit()

#Select
func select():
	if Input.is_action_just_pressed("LeftMouseClick") and !isSelected:
		selected.emit(self)
