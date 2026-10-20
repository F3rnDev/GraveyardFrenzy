extends Control

@onready var diffTree = $DiffTree

signal continued(songDiffs)

func _on_difficulty_continue_btn_button_down() -> void:
	var chartDiff = diffTree.getChartDiffs()
	
	#Check if empty
	if chartDiff.is_empty():
		NotificationManager.popupMessage(NotificationMessage.Types.Error, "You need to select at least one difficulty")
		return
	
	continued.emit(chartDiff)
