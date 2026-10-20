extends VBoxContainer

class_name AudioWindow

@onready var normalSelector = $AudioVisualizer

@export var windowRef:ChartEditorWindow

var chartEditorRef:ChartEditor

func setAudios(editor:ChartEditor):
	chartEditorRef = editor
	
	loadAudio()

func loadAudio():
	var newStream:AudioStreamMP3 = AudioStreamMP3.new()
	newStream.data = chartEditorRef.songProject.commonAudio
	
	normalSelector.loadAudio(newStream)

func setNewAudio(newAudioBytes, path, elementsOutside = null):
	if elementsOutside != null:
		chartEditorRef.removeElementsOutside(elementsOutside)
	
	chartEditorRef.updateAudio(newAudioBytes)
	
	NotificationManager.popupMessage(NotificationMessage.Types.Success, "Loaded file at: " + path)

func _on_audio_visualizer_changed_audio(newAudioBytes: Variant, path: Variant) -> void:
	var elementsOutside = chartEditorRef.getElementsOutside(newAudioBytes)
	if !elementsOutside.is_empty():
		var warn = NotificationManager.popupWarning(NotificationManager.WarningTypes.ChartNoteDeletion, elementsOutside)
		warn.cancelled.connect(loadAudio)
		warn.confirmed.connect(setNewAudio.bind(newAudioBytes, path, elementsOutside))
		return
	
	setNewAudio(newAudioBytes, path)
