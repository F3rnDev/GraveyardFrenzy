extends Label

@onready var totalTimeLabel = $TotalTime

var curTime:float = 0.0
var songLength:float = 0.0

func updateCurTime(time):
	curTime = time
	updateUIText()

func updateSongLen(time):
	songLength = time
	updateUIText()

func updateUIText():
	text = getTimeStr(curTime) + "/"
	totalTimeLabel.text = getTimeStr(songLength)

func getTimeStr(time):
	var total_seconds = max(0, int(time))
	
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	
	return "%02d:%02d" % [minutes, seconds]
