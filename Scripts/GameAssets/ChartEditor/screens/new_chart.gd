extends Control

@onready var titleAnim = $NewProject/LabelAnimations
@onready var songDataWindow = $SongData
@onready var diffWindow = $Difficulty
@onready var audioWindow = $SelectAudio

@onready var allSteps = [songDataWindow, diffWindow, audioWindow]

var currentStep:int = 0
var newProject:SongProject = SongProject.new()

signal cancelled
signal created(project:SongProject)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	titleAnim.play("appear")

func updateStep(step):
	currentStep += step
	
	if currentStep >= allSteps.size():
		created.emit(newProject)
		audioWindow.animations.play("disappear")
		titleAnim.play("disappear")
		return
	
	updateWindow()

func updateWindow():
	for stepID in range(allSteps.size()):
		var curAnim = "disappear"
		
		if stepID == currentStep:
			curAnim = "appear"
		
		allSteps[stepID].animations.play(curAnim)

#SONG DATA
func _on_song_data_cancel_btn_button_down() -> void:
	cancelled.emit()
	songDataWindow.animations.play("disappear")
	titleAnim.play("disappear")

func _on_song_data_close() -> void:
	if currentStep == 0:
		queue_free()

func _on_song_data_continued(songName, composer, charter, baseBpm) -> void:
	var songInfo = newProject.data
	
	songInfo.songName = songName
	songInfo.composer = composer
	songInfo.charter = charter
	songInfo.baseBpm = baseBpm
	
	updateStep(1)

#Difficulty
func _on_difficulty_return_btn_button_down() -> void:
	updateStep(-1)

func _on_difficulty_continued(songDiffs: Variant) -> void:
	var songInfo = newProject.data
	
	songInfo.availableDiffs = songDiffs
	
	for diff in songInfo.availableDiffs:
		newProject.charts[diff] = Chart.new()
	
	updateStep(1)

#Audio
func _on_audio_return_btn_button_down() -> void:
	updateStep(-1)

func _on_audio_continued(audioBytes: Variant) -> void:
	newProject.commonAudio = audioBytes
	#Update when putting the frenzy stuff >:P
	updateStep(1)
