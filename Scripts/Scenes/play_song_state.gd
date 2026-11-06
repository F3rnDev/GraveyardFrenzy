extends Node2D

class_name GameplayScene

## ONREADY
@onready var player: CharacterBody2D = $player
@onready var camera: Camera2D = $Camera2D
@onready var stage: Node2D = $stage

#Conductor
@onready var conductor: Conductor = $Conductor
@onready var conductorSong: AudioStreamPlayer = $Conductor/Song

#NoteGroup
@onready var elementGrp: Node2D = $ElementGrp
@onready var elementSpawner: Node2D = $ElementGrp/ElementSpawner
@onready var elementControl: Node2D = $ElementGrp/ElementControl
@onready var elementInput: Node2D = $ElementGrp/ElementInput
@onready var noteStrum: Node2D = $ElementGrp/NoteStrum

#EventTrigger
@onready var eventTrigger: Node = $EventTrigger

#UI
@onready var gameplayUI = $UIGrp
@onready var bloodSplater: ColorRect = $CanvasLayer/bloodSplater
@onready var progressBar = $UIGrp/ProgressBar
@onready var comboCounter = $UIGrp/ComboCounter
@onready var popupRating = preload("res://Nodes/GameAssets/Gameplay/popup_note.tscn")

#Menus
@onready var pauseMenu: Control = $CanvasLayer/pauseMenu
@onready var gameOverScreen: Control = $CanvasLayer/gameOver

#Win screen (PLACEHOLDER), WILL BE A SCENE >:D
@onready var winScreen: CanvasLayer = $WinScreen
@onready var rankValue: Label = $WinScreen/RankValue

#Audio
@onready var noteHoldHitSound: AudioStreamPlayer = $Audio/NoteHoldHitSound
@onready var noteMissSound: AudioStreamPlayer = $Audio/MissNoteSound
@onready var noteHitSounds: AudioStreamPlayer = $Audio/NoteHitSounds
## END

@export_category("Gameplay")
@export var objectBaseSize:float = 64.0 #Has to have the same value as the chart editor
@export var noteSpeed:float = 1.0
#Heal mechanic (PLACEHOLDER, CHANGE TS PLS)
@export var healAmount = 20 #Amount off notes you need to hit after getting a heal
var healNotes = 0 #save amount of notesHit at the moment you lost health

@export_category("GameOver")
var isGameOver = false
@export var slowDownTime = 3.0

@export_category("Debug")
@export_file("*.frzp") var debugProjectPath:String
@export var debugDiff:String = "hard"
@export var physicsCollDebug = false
var noteAreaDebug = false
var debugNoteTiming = false

@export_category("Discord")
@export var discInfo:DiscordInfo

#SongParams
var project:SongProject
var curDiff:String = "normal"

var isRunnerSection = false
var songOver = false

#Calculate Acc
var curAccuracy = 0
var notesHit = 0
var totalNotesPlayed = 0
var noteCombo = 0

#DiscordRPC
func setRPCInfo(songStr):
	if SceneManager.instance != null:
		discInfo.state = songStr
		SceneManager.instance.updateDiscordRPCInfo(discInfo)

#LOAD SCENE
func setParams(params:Dictionary):
	project = SongLoader.loadSongProject(params["song"])
	curDiff = params["diff"]
	
	loadSong()
	setRPCInfo("%s | %s"%[project.data.songName, curDiff.capitalize()])

func _ready() -> void:
	if SceneManager.instance == null:
		project = SongLoader.loadSongProject(debugProjectPath)
		curDiff = debugDiff
		loadSong()
	
	get_tree().set_debug_collisions_hint(physicsCollDebug)
	
	flashScreen(false)
	
	pauseMenu.canPause = true

func loadSong():
	if project == null:
		return
	
	#Set conductor
	conductor.NewSetSong(project.commonAudio)
	conductor.setBpm(project.data.baseBpm)
	
	#Make a countdown here :D
	#Idea is to create a timer and set its wait time do conductor.crochet
	#For every timer.timeout decrease the countdown var (give a 3, 2, 1, GO)
	conductor.playSong(false) 
	
	#Set UI
	progressBar.setSongTime(conductor.songLength)
	
	elementSpawner.setChartToRender(project.charts[curDiff])
	eventTrigger.setEventsToTrigger(project.charts[curDiff])

#END

#PHYSICS
func _physics_process(_delta):
	if project == null:
		return
	
	if conductor.songLeft < 1 and !conductorSong.playing and !songOver:
		endSong()
#END

#GO TO SCENES
func changeScene(scenePath):
	if SceneManager.instance != null:
		SceneManager.instance.switchScene(scenePath)
	else:
		print("Error changing scene: Scene Manager is not present")
#END

#RUNNER SECTION
#Will change this (new section type)
func setRunnerSection(isRunner:bool):
	isRunnerSection = isRunner
	
	if isRunnerSection:
		var tween = create_tween()
		tween.tween_property(noteStrum, "modulate:a", 0, 0.2)
	else:
		var tween = create_tween()
		tween.tween_property(noteStrum, "modulate:a", 1, 0.2)
	
	player.setRunnin(isRunnerSection)
	comboCounter.setRunnerSection(isRunnerSection)

#Input
func _input(event):
	#Restarting and overworld stuff
	#WILL CHANGE (PLACEHOLDER) :D
	if Input.is_action_just_pressed("Confirm") and songOver:
		changeScene("res://Nodes/Scenes/overworld_state.tscn")
	elif Input.is_action_just_pressed("Confirm") and isGameOver:
		changeScene("res://Nodes/Scenes/play_state.tscn")
	
	debugInput(event)

func debugInput(event):
	#Show judgement
	var justPressed = event.is_pressed() and not event.is_echo()
	if Input.is_physical_key_pressed(KEY_F1) and justPressed:
		debugCollision()
		debugNoteTiming = !debugNoteTiming
	
	#gameOver
	if Input.is_physical_key_pressed(KEY_R):
		gameOver()
#END

#Animations and UI Stuff
#DO THIS ON THE PLAYER ITSELF :D STOOOOOP NOOOOOOOO OOOOOH MYYYY GOOOOD
func playerInputAnimation(curPressed):
	if curPressed != -1 and !isRunnerSection:
		player.setNoHitAnim(curPressed, noteStrum)

#Note Actions
func updateOnNoteHit(note:GameNote):
	updateOnHit(note)
	player.setHitAnim(note.elementRef.lane, noteStrum)

func updateOnHoldHit(note:GameNote):
	updateOnHit(note, true)

func updateOnHold(note:GameNote):
	player.setHitAnim(note.elementRef.lane, noteStrum, true)
	
	var finalPos = 1.5 if note.elementRef.lane == 1 else -1.5
	elementGrp.rotateStrum(finalPos)
	
	camera.zoomCamera()

func updateOnHoldRelease(note:GameNote):
	updateOnHit(note, true, true)
	
	player.setHitAnim(note.elementRef.lane, noteStrum)
	elementGrp.rotateStrum(0.0)
	camera.zoomCamera(Vector2(1.0, 1.0))

func updateOnMiss(note:GameNote):
	if note.elementRef.holdAmount > 0.0:
		noteHoldHitSound.stopAudio()
		elementGrp.rotateStrum(0.0)
		camera.zoomCamera(Vector2(1.0, 1.0))
		noteStrum.removeHoldParticle(note.elementRef.lane)
	
	calculateSongAccuracy(note.elementRef.holdAmount > 0.0)
	
	setHealNotes(0)
	
	noteCombo = 0
	comboCounter.updateCounter(noteCombo)
	
	#Player animation
	player.setMissAnimation()
	
	#Play miss sound
	noteMissSound.pitch_scale = randf_range(0.8, 1.2)
	noteMissSound.play()

func updateOnHit(note:GameNote, isHold = false, isHoldRelease = false):
	var strumTime = note.elementRef.position if !isHoldRelease else note.elementRef.position + note.elementRef.holdAmount
	var noteLane = note.elementRef.lane
	
	var timing = (strumTime - conductor.songPos) * 1000
	var rating = NoteRating.getRating(abs(timing))
	
	setNoteScore(rating, isHold)
	popupNoteScore(noteLane, rating, timing)
	
	healPlayer()
	
	noteCombo += 1
	comboCounter.updateCounter(noteCombo)
	
	#Spawn hit particle
	if isHold:
		if !isHoldRelease:
			noteStrum.spawnHoldParticle(noteLane, rating)
			noteHoldHitSound.playAudio()
		else:
			noteStrum.removeHoldParticle(noteLane)
			noteHoldHitSound.stopAudio()
	
	noteStrum.playHit(noteLane, rating == NoteRating.Ratings.Perfect, isHoldRelease)
	camera.shake(camera.ShakeTypes.NOTEHIT, 18.0, 2.0)
	
	noteHitSounds.playAudio(noteLane)

func popupNoteScore(noteLane, rating, timing):
	var popupInstance:PopupScore = popupRating.instantiate()
	
	#Get lane pos
	var laneObj:AnimatedSprite2D = noteStrum.get_child(noteLane)
	var lanePos = laneObj.global_position
	
	#SetPos and spawn
	gameplayUI.add_child(popupInstance)
	popupInstance.setPopup(lanePos, rating, timing, debugNoteTiming)

func setNoteScore(rating, isHold = false):
	match rating:
		NoteRating.Ratings.Perfect:
			if !isHold: notesHit += 1
			else: notesHit += 0.5
		NoteRating.Ratings.Good:
			if !isHold: notesHit += 0.5
			else: notesHit += 0.3
		NoteRating.Ratings.Bad:
			if !isHold: notesHit += 0.3
			else: notesHit += 0.1
	
	calculateSongAccuracy(isHold)

func calculateSongAccuracy(isHold = false):
	if !isHold:
		totalNotesPlayed += 1
	else:
		totalNotesPlayed += 0.5
	
	curAccuracy = (notesHit / totalNotesPlayed) * 100
	
	progressBar.setSongUIData(curAccuracy, elementControl.missedNotes.size())
#END

#SONG CALCULATIONS
func getObjectPos(songXPos:float):
	var xPos = ((songXPos / conductor.stepCrochet) * (objectBaseSize))
	return xPos

func getObjectSongPos(objXPos:float) -> float:
	var xPos = objXPos
	var songPos = (xPos / objectBaseSize) * conductor.stepCrochet
	return songPos
#END

#END SONG
func endSong():
	songOver = true
	winScreen.visible = true
	rankValue.text = SongRating.getRating(curAccuracy)
	bloodSplater.material.set_shader_parameter("cutoff", 0)
	
	var fullCombo = ""
	
	if elementControl.missedNotes.size() == 0:
		rankValue.text += " (FC)"
		fullCombo = "FC"
	
	#SET THE NEW RATING
#END

func debugCollision():
	noteAreaDebug = !noteAreaDebug
	
	noteStrum.setDebug(noteAreaDebug)
	
	for note in elementControl.get_children():
		if note.has_method("setDebug"):
			note.setDebug(noteAreaDebug)

#ON PLAYER HIT
func _on_player_hurt() -> void:
	if isGameOver:
		return
	
	camera.shake()
	setHealNotes(0)
	flashScreen(true)
	
	if player.health <= 0:
		gameOver()

func flashScreen(hurt:bool):
	if hurt:
		bloodSplater.material.set_shader_parameter("cutoff", 0.7)
	
	var tweenAmount = 0.0 if player.health > 1 else 0.6
	var tween = create_tween()
	tween.tween_property(bloodSplater, "material:shader_parameter/cutoff", tweenAmount, 1.0)
#END

#HEAL Player
func healPlayer():
	healNotes += 1
	
	if healNotes >= healAmount and player.health < 3:
		setHealNotes(0)
		player.addOrSubHealth(1)
		flashScreen(false)

func setHealNotes(value):
	healNotes = value
#END

#GameOver
func gameOver():
	if isGameOver:
		return
	
	pauseMenu.canPause = false
	isGameOver = true
	
	#slow down music
	var pitchTween = create_tween()
	pitchTween.tween_property(conductorSong, "pitch_scale", 0.1, slowDownTime)
	
	#slow down ground
	var groundTween = create_tween()
	groundTween.tween_property(stage, "groundSpeed", 0.0, slowDownTime)
	
	#fade notes
	var noteTween = create_tween()
	noteTween.tween_property(elementGrp, "modulate:a", 0.0, slowDownTime)
	
	#fade UI
	var uiTween = create_tween()
	uiTween.tween_property(gameplayUI, "modulate:a", 0.0, slowDownTime)
	
	#fade screen flash
	var bloodTween = create_tween()
	bloodTween.tween_property(bloodSplater, "material:shader_parameter/cutoff", 0.0, slowDownTime)
	
	#control player
	player.killPlayer()
	
	await get_tree().create_timer(slowDownTime).timeout
	
	conductorSong.stop()
	gameOverScreen.visible = true
#END

#Pause music when pausing game
func _on_pause_menu_pause() -> void:
	if !songOver:
		conductor.playSong(false)

func _on_conductor_beat_hit(_position: Variant) -> void:
	progressBar.playBob()
	progressBar.updateSongTime(conductor.songPos)
	
	comboCounter.playBop()
