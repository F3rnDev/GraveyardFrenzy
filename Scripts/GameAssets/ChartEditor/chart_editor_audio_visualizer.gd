extends VBoxContainer

class_name ChartEditorAudioSelector

@onready var audioPlayer:AudioStreamPlayer = $Audio
@onready var musicProgress: HBoxContainer = $SongPreview
@onready var audioButtonOsc: Button = $DefaultAudioPanel

var loadedAudio:AudioStream
var lastAudioPos:float = 0.0

signal changedAudio(newAudioBytes, path)

func loadAudio(audio:AudioStream):
	lastAudioPos = 0.0
	
	loadedAudio = audio
	audioPlayer.stream = loadedAudio
	
	musicProgress.setSongMaxLen(loadedAudio.get_length())
	audioButtonOsc.text = ""

func _process(delta: float) -> void:
	if loadedAudio == null: return
	
	var currentPos = audioPlayer.get_playback_position() if audioPlayer.playing else lastAudioPos
	musicProgress.updateSongProgress(currentPos)
	
	if currentPos != lastAudioPos:
		lastAudioPos = currentPos

#Play/Stop Song
func playSong():
	if loadedAudio == null:
		return
	
	musicProgress.setPauseIcon()
	audioPlayer.play(lastAudioPos)

func stopSong():
	if loadedAudio == null:
		return
	
	musicProgress.setPlayIcon()
	
	if audioPlayer.playing:
		lastAudioPos = audioPlayer.get_playback_position()
	
	audioPlayer.stop()

#Selecting a song
func loadFile(path:String):
	if audioPlayer.playing: stopSong()
	
	var file = FileAccess.open(path, FileAccess.READ)
	var audioBytes = file.get_buffer(file.get_length())
	
	var audioStream:AudioStreamMP3 = AudioStreamMP3.new()
	var fileBytes = FileAccess.get_file_as_bytes(path)
	audioStream.data = fileBytes
	
	loadAudio(audioStream)
	
	changedAudio.emit(audioBytes, path)

func _on_song_preview_play() -> void:
	if !audioPlayer.playing:
		playSong()
	else:
		stopSong()

func _on_song_preview_stop() -> void:
	stopSong()

func _on_song_preview_set_pos(pos: float) -> void:
	lastAudioPos = pos

func _on_audio_select_file_file_selected(path: String) -> void:
	loadFile(path)
