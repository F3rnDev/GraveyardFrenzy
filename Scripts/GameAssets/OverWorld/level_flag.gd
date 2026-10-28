extends Node3D

class_name OverworldStage

@export var overworldRef:OverworldScene

@onready var flagPole = $stageViewport/Flag/flag
@onready var flagBase = $stageViewport/Flag/base
@onready var flagUI = $stageViewport/Flag/SelectSongUI

@export_file("*.frzp") var songPath:String

var enteredArea = false

# Called when the node enters the scene tree for the first time.
func _ready():
	flagPole.play("default")
	flagBase.play("default")
	checkSongClear()
	setMetadata()

func setMetadata():
	flagUI.setData(SongLoader.getSongData(songPath))

#PLACEHOLDER FUNCTIONALITY
func checkSongClear():
	pass
	#var clearedSong = false
	#for diff in Difficulty.getAllDiffs():
		#var diffId = Difficulty.getAllDiffs().find(diff)
		#var rating = SongRating.getSongRating(songName, Difficulty.getAllDiffs()[diffId])
		#
		#if rating != "":
			#clearedSong = true
			#break
	#
	#if !clearedSong:
		#flagPole.visible = false

func _input(_event: InputEvent) -> void:
	if !enteredArea: return
	
	if Input.is_action_just_pressed("Confirm"):
		confirmedStage()
	
	if overworldRef.selectedStage != self: return
	
	if Input.is_action_just_pressed("Exit"):
		overworldRef.closeSongUI()
		flagUI.hideExtras()
	
	if CInput.checkInput("Right", "justPressed"):
		flagUI.changeDiff(1)
	elif CInput.checkInput("Left", "justPressed"):
		flagUI.changeDiff(-1)

func confirmedStage():
	if overworldRef.selectedStage == null:
		overworldRef.openSongUI(self)
		flagUI.displayExtras()
	elif overworldRef.selectedStage == self:
		var curDiff = flagUI.songMetadata.availableDiffs[flagUI.selectedDiff]
		overworldRef.goToPlayState(songPath, curDiff)

func _on_area_area_entered(area):
	if area.get_parent().is_in_group("player"):
		enteredArea = true
		flagUI.displayName()

func _on_area_area_exited(_area):
	enteredArea = false
	flagUI.hideName()
