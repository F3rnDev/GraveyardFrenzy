extends NotificationWarning

@onready var itemTree: Tree = $Panel/window/VBoxContainer/Tree

func setData(notes:Dictionary):
	itemTree.clear()
	
	itemTree.set_column_title(0, "Difficulty")
	itemTree.set_column_title(1, "Notes")
	itemTree.set_column_title_alignment(0,HORIZONTAL_ALIGNMENT_LEFT)
	itemTree.set_column_title_alignment(1,HORIZONTAL_ALIGNMENT_LEFT)
	
	var root = itemTree.create_item()
	
	for diff in notes.keys():
		var noteAmnt = str(notes[diff].size())
		
		var row = itemTree.create_item(root)
		row.set_text(0, diff.capitalize())
		row.set_text(1, noteAmnt)

func _on_confirm_btn_button_down() -> void:
	confirmed.emit()

func _on_cancel_btn_button_down() -> void:
	cancelled.emit()
