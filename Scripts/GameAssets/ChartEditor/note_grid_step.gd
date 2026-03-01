extends VBoxContainer

@export var inScene = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if inScene:
		queue_free()
