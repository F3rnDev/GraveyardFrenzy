extends AudioStreamPlayer

@export var defaultAudio:AudioStream
var defAudioPos #get the position of the default audio

var songEndTime

@onready var dummyPlayer = AudioStreamPlayer.new()
var fading = false

var queueSong = null

func _ready():
	add_child(dummyPlayer)
	
	if defaultAudio != null:
		stream = defaultAudio
		play()

func _process(delta):
	if fading:
		volume_db -= 30*delta
		dummyPlayer.volume_db += 30*delta
		
		if dummyPlayer.volume_db >= 0 or queueSong != null:
			volume_db = dummyPlayer.volume_db
			dummyPlayer.volume_db = -60
			
			stream = dummyPlayer.stream
			play(dummyPlayer.get_playback_position())
			
			dummyPlayer.stop()
			fading = false
	
	if queueSong != null and !fading:
		setAudio(queueSong[0], queueSong[1])
		queueSong = null
	
	if playing and songEndTime != null and get_playback_position() >= songEndTime:
		setAudio(defaultAudio)

func setAudio(stream, range = null):
	if fading:
		queueSong = [stream, range]
		return
	
	songEndTime = null
	
	dummyPlayer.volume_db = -60
	dummyPlayer.stream = stream
	dummyPlayer.play()
	
	fading = true
	
	if stream != defaultAudio and self.stream == defaultAudio:
		defAudioPos = get_playback_position()
	else:
		dummyPlayer.seek(defAudioPos)
	
	if range:
		dummyPlayer.seek(range[0])
		songEndTime = range[1]
