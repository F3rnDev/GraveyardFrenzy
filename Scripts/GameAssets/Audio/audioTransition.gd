extends AudioStreamPlayer

@export var defaultAudioStream:AudioStream
var defaultAudioPos = 0.0

var activeAudio = self

func _ready():
	if defaultAudioStream != null:
		stream = defaultAudioStream
		play()

func playSongAudio(songName):
	defaultAudioPos = get_playback_position()
	
	var songPath = "res://Assets/Audio/Songs/" + songName + "/" + songName
	var songFile = FileSystem.getAudioFile(songPath)
	var songStream = load(songFile)

	createTransition(songStream, 0.0)

func playDefaultAudio():
	if defaultAudioStream == null:
		return
	
	createTransition(defaultAudioStream, defaultAudioPos)

func createTransition(audioStream, position):
	var audio01Tween = get_tree().create_tween()
	var audio02Tween = get_tree().create_tween()
	
	if activeAudio == self:
		$"Audio 02".stream = audioStream
		$"Audio 02".play(position)
		
		audio01Tween.tween_property(self, "volume_db", -80.0, 2.0)
		audio02Tween.tween_property($"Audio 02", "volume_db", 0.0, 2.0)
		
		activeAudio = $"Audio 02"
	else:
		stream = audioStream
		play(position)
		
		audio01Tween.tween_property(self, "volume_db", 0.0, 2.0)
		audio02Tween.tween_property($"Audio 02", "volume_db", -80.0, 2.0)
		
		activeAudio = self
