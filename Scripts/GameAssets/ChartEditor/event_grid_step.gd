extends Button

class_name EventGridStep

@export var inEditor = false

#0 = upLane, 1 = downLane
signal btnEntered(pos:Vector2)
signal btnExited()
signal btnPressed(pos:Vector2)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if inEditor:
		queue_free()

func _on_mouse_entered() -> void:
	btnEntered.emit(global_position)

func _on_mouse_exited() -> void:
	btnExited.emit()

func _on_button_down() -> void:
	btnPressed.emit(global_position)
