extends Control

signal mouseDrag(isDragging)

func _on_strum_bar_button_down() -> void:
	mouseDrag.emit(true)

func _on_strum_bar_button_up() -> void:
	mouseDrag.emit(false)
