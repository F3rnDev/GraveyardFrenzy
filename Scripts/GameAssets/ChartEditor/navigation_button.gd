extends MenuButton

class_name NavigationUIButton

@export var marginX:float = 20.0
@export var marginY:float = 32.0

signal selected(id)

func _ready() -> void:
	get_popup().id_pressed.connect(_selected_option)

func setShortcut(itemID:int, actionStr:String):
	var id = get_popup().get_item_index(itemID)
	
	if id == -1:
		return
	
	var action = InputEventAction.new()
	action.action = actionStr
	
	var popupShortcut = Shortcut.new()
	popupShortcut.events.append(action)
	
	get_popup().set_item_shortcut(id, popupShortcut, true)

func _on_pressed() -> void:
	var popup = get_popup()
	
	#Set size
	var xSize = popup.get_contents_minimum_size().x + marginX
	var ySize = popup.get_contents_minimum_size().y + marginY
	popup.size = Vector2i(xSize, ySize)

func _selected_option(id:int):
	selected.emit(id)
