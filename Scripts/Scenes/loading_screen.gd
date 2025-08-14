extends CanvasLayer

class_name LoadingScreen

signal loaded(path:String)
@onready var progressBar = $HBoxContainer/ProgressBar

var loadPath:String

func load(path:String):
	loadPath = path
	ResourceLoader.load_threaded_request(path)

func _process(delta: float) -> void:
	if not loadPath:
		return
	
	var progress = []
	ResourceLoader.load_threaded_get_status(loadPath, progress)
	
	progressBar.value = progress[0]*100
	
	if progress[0] == 1:
		loaded.emit(loadPath)
		call_deferred("queue_free")
