extends TextureRect

func _ready() -> void:
	setVisible(false)

func setPosition(pos:Vector2):
	global_position = pos

func setVisible(isVisible:bool):
	visible = isVisible

func _on_note_grid_preview_note_add(pos: Vector2) -> void:
	setPosition(pos)
	setVisible(true)

func _on_note_grid_preview_note_remove() -> void:
	setVisible(false)
