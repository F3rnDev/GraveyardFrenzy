extends Control

class_name ChartEditorWindow

@onready var title = $Header/WindowTitle
@onready var dragBtn = $Header/WindowDragBtn
@onready var exitBtn = $Header/WindowControl/ExitScreen
@onready var minimizeBtn = $Header/WindowControl/Minimize
@onready var animations = $Animate

@export var windowTitle:String = ""
@export var canExit:bool = true
@export var canMinimize:bool = true
@export var canDrag:bool = true

var dragging = false
var mousePosOffset = Vector2(0.0, 0.0)

@export var deleteAfterClose = true #Delete after the window is closed
@export var hiddenInReady = false #stay hidden after creating

@export var contentRef:Control #The content of the instance

var minimized = false

signal close

func _ready() -> void:
	dragBtn.visible = canDrag
	exitBtn.visible = canExit
	minimizeBtn.visible = canMinimize
	title.text = windowTitle
	
	if !canExit and !canMinimize:
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	if hiddenInReady:
		visible = false
		return
	
	animations.play("appear")

func _process(delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - mousePosOffset

func _on_window_drag_btn_button_down() -> void:
	dragging = true
	mousePosOffset = get_global_mouse_position() - global_position

func _on_window_drag_btn_button_up() -> void:
	dragging = false

func _on_exit_screen_button_down() -> void:
	animations.play("disappear")

func _on_minimize_button_down() -> void:
	minimized = !minimized
	
	if minimized:
		animations.play("minimize")
	else:
		animations.play("unminimize")

func _on_animate_animation_finished(anim_name: StringName) -> void:
	if anim_name == "disappear":
		close.emit()
		
		if deleteAfterClose:
			queue_free()
		else:
			visible = false

func _on_animate_current_animation_changed(name: String) -> void:
	if name == "appear":
		visible = true
