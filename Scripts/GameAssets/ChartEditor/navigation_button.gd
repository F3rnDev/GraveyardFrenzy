extends MenuButton

class_name NavigationUIButton

@export var marginX:float = 20.0
@export var marginY:float = 32.0

signal selected(id)

func _ready() -> void:
	get_popup().id_pressed.connect(_selected_option)

func _on_pressed() -> void:
	var popup = get_popup()
	
	#Set size
	var xSize = popup.get_contents_minimum_size().x + marginX
	var ySize = marginY * item_count
	popup.size = Vector2i(xSize, ySize)

func _selected_option(id:int):
	selected.emit(id)
