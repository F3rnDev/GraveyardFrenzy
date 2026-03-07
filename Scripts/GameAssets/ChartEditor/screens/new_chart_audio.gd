extends Control

@onready var audioSelectDialog = $AudioSelectFile

@onready var dragAndDropCommon = $AudioContainer/ImportAudioBtn
@onready var audioPreviewCommon = $AudioContainer/MusicBar

var commonAudio:PackedByteArray

signal continued(audioBytes:PackedByteArray)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_import_audio_btn_button_down() -> void:
	audioSelectDialog.visible = true

func _on_audio_select_file_file_selected(path: String) -> void:
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
