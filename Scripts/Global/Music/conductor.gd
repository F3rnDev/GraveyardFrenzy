extends Node

var bpm = 120

var crochet = (60.0 / bpm)
var stepCrochet = crochet/4.0
var offset = 0

var songPos = 0
var songLength = 0
var songLeft = 0

var curBeat = 0
var lastBeat = -1
var lastStep = -1
var curStep = 0

signal beatHit(position)
signal stepHit(position)

func _ready():
	setBpm(bpm)

func playSong(restart):
	lastBeat = -1
	lastStep = -1
	curStep = floor((songPos) / stepCrochet)
	curBeat = floor(curStep/4)
	
	if $Song.playing:
		$Song.stop()
	else:
		$Song.play()
		if !restart and floor(songPos) < floor($Song.stream.get_length()):
			$Song.seek(songPos)

func setBpm(newBpm):
	bpm = newBpm
	crochet = (60.0 / bpm)
	stepCrochet = crochet/4.0

func setSong(path, fileLoaded = true):
	if fileLoaded:
		var filePath = FileSystem.getAudioFile(path)
		$Song.stream = load(filePath)
	else:	
		$Song.stream = Audio.getAudio(path)
	
	songLength = $Song.stream.get_length()

func _process(delta):
	if $Song.playing:
		var songTime = $Song.get_playback_position() + AudioServer.get_time_since_last_mix()
		songTime -= AudioServer.get_output_latency()
		songPos = (float)((songTime) - offset)
		
		songLeft = songLength - $Song.get_playback_position()
		
		updateBeat()

func updateBeat():
	curStep = floor((songPos) / stepCrochet)
	
	if lastStep < curStep:
		lastStep = curStep
		emit_signal("stepHit", curStep)
		curBeat = floor(curStep/4)
		
		if lastBeat < curBeat:
			emit_signal("beatHit", curBeat)
			lastBeat = curBeat
	
	
	
