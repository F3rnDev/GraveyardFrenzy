extends Node3D

class_name OverworldScene

@onready var player = $player3D

var selectedStage:OverworldStage = null

@export var discInfo:DiscordInfo

func _ready():
	getRank()
	setRPCInfo()

func setRPCInfo():
	if SceneManager.instance != null:
		SceneManager.instance.updateDiscordRPCInfo(discInfo)

func openSongUI(stage:OverworldStage):
	selectedStage = stage
	$CanvasLayer/pauseMenu.canPause = false
	player.stopMovement = true

func closeSongUI():
	selectedStage = null
	$CanvasLayer/pauseMenu.canPause = true
	player.stopMovement = false

func goToPlayState(songPath:String, diff:String):
	if SceneManager.instance == null:
		return
	
	var playState = "res://Nodes/Scenes/play_state.tscn"
	var params = {"song": songPath, "diff": diff}
	
	SceneManager.instance.switchScene(playState, params)

func setDebugMode(debug:bool):
	player.visible = !debug
	player.stopMovement = debug

func getRank():
	pass
#	var placeholder = $"CanvasLayer/Control/bg/Placeholder Rank Image/Placeholder"
#	placeholder.text = "Placeholder Rank Image: " + SongRating.getSongRating(selectedSong, Difficulty.getAllDiffs()[selectedDiff])
	
	#var fullRank = SongRating.getSongRating(selectedSong, Difficulty.getAllDiffs()[selectedDiff])
	#
	#var RankingObj = $"CanvasLayer/Control/bg/SongRatings/SongRanking(Prototype)"
	#var FCMedalObj = $"CanvasLayer/Control/bg/SongRatings/FC medal/Sprite"
	#var NotCompletedObj = $"CanvasLayer/Control/bg/SongRatings/NotCompleted"
	#
	#var rank = fullRank
	#FCMedalObj.stop()
	#
	##Check if you have a rank
	#if fullRank == "":
		#NotCompletedObj.visible = true
		#FCMedalObj.visible = false
	#else:
		#NotCompletedObj.visible = false
		#FCMedalObj.visible = true
	#
	##Check if that rank is a FC
	#if "FC" in fullRank:
		#rank = fullRank.split("FC")[0]
		#FCMedalObj.play("HasFC")
	#else:
		#FCMedalObj.play("NoFC")
	#
	#RankingObj.text = rank
