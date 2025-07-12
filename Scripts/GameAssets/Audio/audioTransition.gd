extends AudioStreamPlayer

func _ready():
	var songArray = FileSystem.getFolderNames("res://Assets/Audio/Songs")
	
	for song in songArray:
		var songPath = "res://Assets/Audio/Songs/" + song + "/" + song
		var songFile = FileSystem.getAudioFile(songPath)
		var songStream = load(songFile)
		
		stream.set_clip_count(stream.get_clip_count() + 1)
		stream.set_clip_name(stream.get_clip_count()-1, song)
		stream.set_clip_stream(stream.get_clip_count()-1, songStream)
		stream.set_clip_auto_advance(stream.get_clip_count()-1, 1)
		stream.set_clip_auto_advance_next_clip(stream.get_clip_count()-1, 0)
	
	play()

func playSongAudio(songName):
	get_stream_playback().switch_to_clip_by_name(songName)

func playDefaultAudio():
	get_stream_playback().switch_to_clip(0)
