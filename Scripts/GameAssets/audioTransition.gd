extends Node

@export var defaultAudio:AudioStream

var curAudio = -1
var songEndTime

func _ready():
	setAudio(defaultAudio, null, true)

func _process(delta):
	var audioToChange = get_child(curAudio)
	
	if audioToChange.playing and songEndTime != null and audioToChange.get_playback_position() >= songEndTime:
		setAudio(defaultAudio)

func setAudio(stream, range = null, firstAudio = false):
	songEndTime = null
	
	curAudio = getCurAudio(curAudio + 1)
	var audioToChange = get_child(curAudio)
	
	var lastAudioPos
	if stream == defaultAudio:
		lastAudioPos = audioToChange.get_playback_position()
	
	audioToChange.stream = stream
	audioToChange.play()
	
	if range:
		audioToChange.seek(range[0])
		songEndTime = range[1]
	
	if lastAudioPos:
		audioToChange.seek(lastAudioPos)
	
	if !firstAudio:
		audioToChange.volume_db = -80
		audioTransition(audioToChange)

func getCurAudio(change):
	if change > 1: change = 0
	elif change < 0: change = 1
	
	return change

func audioTransition(audioPlayer):
	var fadeOutAudio = get_child(getCurAudio(curAudio + 1))
	
	var fadeIn = create_tween()
	fadeIn.tween_property(audioPlayer, "volume_db", 0, 2)
	
	var fadeOut = create_tween()
	fadeOut.tween_property(fadeOutAudio, "volume_db", -80, 2)
