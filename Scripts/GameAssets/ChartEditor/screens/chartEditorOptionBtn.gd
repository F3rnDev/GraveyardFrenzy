extends OptionButton

class_name ChartEditorOptionButton

@export var maxHeight:float = 200.0
@export var marginY:float = 20.0

func _on_pressed(updatePos:bool = false) -> void:
	var popup = get_popup()
	
	popup.reset_size()
	var naturalHeight = popup.get_contents_minimum_size().y + marginY
		
	#Set size
	var xSize = size.x
	popup.size = Vector2i(xSize, naturalHeight)
	popup.max_size.y = maxHeight
