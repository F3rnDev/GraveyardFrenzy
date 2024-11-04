extends Node3D

class_name OverworldRef

var inMenu = false
var selectedSong = ""

static var instance

var selectedDiff

func _ready():
	instance = self
	resetDiff()
	resetSongUI()

func _process(delta):
	if inMenu:
		controlUI()

func controlUI():	
	if Input.is_action_just_pressed("Exit"):
		closeSongUI()
	
	if Input.is_action_just_pressed("Right"):
		changeDiff(1)
	elif Input.is_action_just_pressed("Left"):
		changeDiff(-1)
	
	if Input.is_action_just_pressed("Confirm"):
		goToPlayState()

func changeDiff(change):
	selectedDiff += change
	
	if selectedDiff < 0:
		selectedDiff = Difficulty.getAllDiffs().size()-1
	elif selectedDiff > Difficulty.getAllDiffs().size()-1:
		selectedDiff = 0
	
	$CanvasLayer/Control/bg/SongDiff.text = Difficulty.getAllDiffs()[selectedDiff]
	
	getRank()

func resetDiff():
	selectedDiff = Difficulty.getAllDiffs().find("Normal")

func closeSongUI():
	inMenu = false
	if $BackgroundMusic.songEndTime != null:
		$BackgroundMusic.setAudio($BackgroundMusic.defaultAudio)
	
	var tween = $CanvasLayer/Control.create_tween()
	tween.tween_property($CanvasLayer/Control, "position", Vector2(500, 0), 0.5).set_trans(Tween.TRANS_SINE)

func resetSongUI():
	$CanvasLayer/Control.position = Vector2(500, 0)

func openSongUI(songName, songAuthor, songRange):
	var songPath = "res://Assets/Songs/" + songName + "/" + songName
	var songFile = FileSystem.getAudioFile(songPath)
	$BackgroundMusic.setAudio(Audio.getAudio(songFile), songRange)
	
	$CanvasLayer/Control/bg/SongName.text = songName
	$CanvasLayer/Control/bg/SongAuthor.text = "Composed by: " + songAuthor
	selectedSong = songName
	
	resetDiff()
	changeDiff(0)
	inMenu = true
	
	var tween = $CanvasLayer/Control.create_tween()
	tween.tween_property($CanvasLayer/Control, "position", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_SINE)

func goToPlayState():
	var songName = selectedSong
	var songDiff = $CanvasLayer/Control/bg/SongDiff.text
	
	var playState = load("res://Nodes/Scenes/play_state.tscn")
	
	var sceneManager = self.get_parent()
	sceneManager.setSongProperties(songName, songDiff)
	sceneManager.switchScene(playState, self)

func getRank():
	var placeholder = $"CanvasLayer/Control/bg/Placeholder Rank Image/Placeholder"
	placeholder.text = "Placeholder Rank Image: " + SongRating.getSongRating(selectedSong, Difficulty.getAllDiffs()[selectedDiff])

func _on_diff_right_button_button_down():
	changeDiff(1)

func _on_diff_left_button_button_down():
	changeDiff(-1)

func _on_play_song_button_down():
	goToPlayState()
