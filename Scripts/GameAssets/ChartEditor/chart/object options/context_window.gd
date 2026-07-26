extends Panel

class_name ChartObjectContext

@onready var content = $Content

signal selectedOption(childID)

var curOptions:Array[Button] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curOptions = getOptions()
	global_position = get_global_mouse_position()
	setSignals()

#CLICKED SIGNAL
func setSignals():
	for optionID in curOptions.size():
		var option = curOptions[optionID]
		option.pressed.connect(clickedOption.bind(optionID))

func clickedOption(childID):
	selectedOption.emit(childID)
	queue_free()

#SET OPTIONS
func setOption(optionID:int, inactive:bool):
	var option:Button = curOptions[optionID]
	option.disabled = inactive

func getOptions() -> Array[Button]:
	var options:Array[Button] = []
	
	for child in content.get_children():
		if child is Button:
			options.append(child)
	
	return options

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and !get_rect().has_point(get_global_mouse_position()):
		queue_free()
