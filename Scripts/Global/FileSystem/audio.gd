extends Node

class_name Audio

static func getAudio(path) -> AudioStream:
	var audioToPlay
		
	match path.get_extension():
		"mp3":
			audioToPlay = AudioStreamMP3.new()
			var data = FileAccess.get_file_as_bytes(path)
			audioToPlay.data = data
		"wav":
			audioToPlay = AudioStreamWAV.new()
			var data = FileAccess.get_file_as_bytes(path)
			audioToPlay.data = data
		"ogg":
			audioToPlay = AudioStreamOggVorbis.new()
			audioToPlay.load_from_file(path)
	
	return audioToPlay
