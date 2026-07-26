extends OptionButton

@export var marginY:float = 38.0

# Called when the node enters the scene tree for the first time.
func setOptions(availableDiffs:Array):
	clear()
	
	for diffID in range(availableDiffs.size()):
		add_item(availableDiffs[diffID].capitalize(), diffID)

func _on_pressed() -> void:
	var popup = get_popup()
	var popup_height = marginY * item_count
	
	var new_pos = global_position
	new_pos.y -= popup_height
	
	popup.position = Vector2i(new_pos)
	
	#Set size
	var xSize = size.x
	popup.size = Vector2i(xSize, popup_height)
