extends Control

@onready var audioSelectDialog = $AudioSelectFile

@onready var dragAndDropCommon = $AudioContainer/ImportAudioBtn
@onready var audioPreviewCommon = $AudioContainer/MusicBar

var commonAudio:PackedByteArray

signal continued(audioBytes:PackedByteArray)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_window().files_dropped.connect(_on_files_dropped)

func _on_import_audio_btn_button_down() -> void:
	audioSelectDialog.visible = true

func _on_files_dropped(files: PackedStringArray):
	if !get_parent().visible or files.size() > 1:
		return
	
	var curFile = files[0]
	if curFile.get_extension().to_lower() not in ["mp3", "wav", "ogg"]:
		return
	
	loadFile(curFile)

func _on_audio_select_file_file_selected(path: String) -> void:
	loadFile(path)

func loadFile(path:String):
	var file = FileAccess.open(path, FileAccess.READ)
	var audioBytes = file.get_buffer(file.get_length())
	commonAudio = audioBytes
	
	dragAndDropCommon.text = "Loaded file at: \n" + path
	
	var audioStream:AudioStreamMP3 = AudioStreamMP3.new()
	var fileBytes = FileAccess.get_file_as_bytes(path)
	audioStream.data = fileBytes
	
	audioPreviewCommon.setSongPreview(audioStream)

func _on_audio_return_btn_button_down() -> void:
	audioPreviewCommon.stopSong()

func _on_audio_continue_btn_button_down() -> void:
	if commonAudio == null:
		return
	
	audioPreviewCommon.stopSong()
	continued.emit(commonAudio)
