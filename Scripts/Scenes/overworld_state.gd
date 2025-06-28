extends Node3D

class_name OverworldRef

var inMenu = false
var selectedSong = ""

static var instance

var selectedDiff

var debugCamera

func _ready():
	instance = self
	resetDiff()
	resetSongUI()
	getRank()
	
	DiscordManager.setData({
		"details":"In Overworld",
		"state": "Prototype Area",
		"large_image": "area_prototype",
		"small_image": "char_skelly",
		"large_image_text": "Prototype Area",
		"small_image_text": "Playing as: Skeleton"
	})

func _process(delta):
	if inMenu:
		controlUI()
	
	$player3D.visible = !$OverworldCamera.debugCamera
	$player3D.stopMovement = $OverworldCamera.debugCamera

func controlUI():	
	if Input.is_action_just_pressed("Exit"):
		closeSongUI()
	
	if CInput.checkInput("Right", "justPressed"):
		changeDiff(1)
	elif CInput.checkInput("Left", "justPressed"):
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
	$CanvasLayer/pauseMenu.canPause = true
	
	if $BackgroundMusic.dummyPlayer.stream != $BackgroundMusic.defaultAudio:
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
	
	$CanvasLayer/pauseMenu.canPause = false
	
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
#	var placeholder = $"CanvasLayer/Control/bg/Placeholder Rank Image/Placeholder"
#	placeholder.text = "Placeholder Rank Image: " + SongRating.getSongRating(selectedSong, Difficulty.getAllDiffs()[selectedDiff])
	
	var fullRank = SongRating.getSongRating(selectedSong, Difficulty.getAllDiffs()[selectedDiff])
	
	var RankingObj = $"CanvasLayer/Control/bg/SongRatings/SongRanking(Prototype)"
	var FCMedalObj = $"CanvasLayer/Control/bg/SongRatings/FC medal/Sprite"
	var NotCompletedObj = $"CanvasLayer/Control/bg/SongRatings/NotCompleted"
	
	var rank = fullRank
	FCMedalObj.stop()
	
	#Check if you have a rank
	if fullRank == "":
		NotCompletedObj.visible = true
		FCMedalObj.visible = false
	else:
		NotCompletedObj.visible = false
		FCMedalObj.visible = true
	
	#Check if that rank is a FC
	if "FC" in fullRank:
		rank = fullRank.split("FC")[0]
		FCMedalObj.play("HasFC")
	else:
		FCMedalObj.play("NoFC")
	
	RankingObj.text = rank

func _on_diff_right_button_button_down():
	changeDiff(1)

func _on_diff_left_button_button_down():
	changeDiff(-1)

func _on_play_song_button_down():
	goToPlayState()
