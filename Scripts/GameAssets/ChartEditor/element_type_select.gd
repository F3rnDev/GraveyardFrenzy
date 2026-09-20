extends HBoxContainer

class_name ElementTypeSelectUI

var currentType:ChartElement.Types = ChartElement.Types.Note

func _on_note_toggled(toggled_on: bool) -> void:
	if toggled_on:
		currentType = ChartElement.Types.Note

func _on_obstacle_toggled(toggled_on: bool) -> void:
	if toggled_on:
		currentType = ChartElement.Types.Obs
