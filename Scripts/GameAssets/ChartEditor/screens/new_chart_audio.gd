extends Control

@onready var audioSelector = $AudioVisualizer

var commonAudio:PackedByteArray

signal continued(audioBytes:PackedByteArray)

func _on_audio_return_btn_button_down() -> void:
	audioSelector.stopSong()

func _on_audio_visualizer_changed_audio(newAudioBytes: Variant, path: Variant) -> void:
	commonAudio = newAudioBytes
	NotificationManager.popupMessage(NotificationMessage.Types.Success, "Loaded file at: " + path)

func _on_audio_continue_btn_button_down() -> void:
	if commonAudio.is_empty():
		return
	
	#Also see the remix version here
	
	audioSelector.stopSong()
	continued.emit(commonAudio)
