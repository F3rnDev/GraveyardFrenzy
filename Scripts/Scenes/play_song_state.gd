extends Node2D

class_name GameplayScene

#Dependencies
@onready var conductor: Conductor = $Conductor
@onready var noteGrp: Node2D = $NoteGrp
@onready var elementSpawner: Node2D = $NoteGrp/ElementSpawner
@onready var renderedElements: Node2D = $NoteGrp/ElementControl
@onready var noteStrum: Node2D = $NoteGrp/NoteStrum

#UI
@onready var gameplayUI = $UIGrp
@onready var progressBar = $UIGrp/ProgressBar
@onready var comboCounter = $UIGrp/ComboCounter
@onready var popupRating = preload("res://Nodes/GameAssets/Gameplay/popup_note.tscn")
var debugNoteTiming = false

#ExportVariables
@export_category("Gameplay Variables")
@export var objectBaseSize:float = 64.0 #Has to have the same value as the chart editor

@export_category("Debug")
@export_file("*.frzp") var debugProjectPath:String
@export var debugDiff:String = "hard"

#SongParams
var project:SongProject
var curDiff:String = "normal"
var noteArray = []
var notesToRemove = []
var curSong

var unspawnNotes = []
@export var maxNotes = 32 #Maximum notes that can spawn

var missedNotes = []

@export var noteSpeed:float = 1.0

var curAccuracy = 0
var notesHit = 0
var totalNotesPlayed = 0

var healNotes = 0 #save amount of notesHit at the moment you lost health
@export var healAmount = 20 #Amount off notes you need to hit after getting a heal

var songOver = false

#Combo
var noteCombo = 0 #Represents the amount of notes hit in succession

#noteInputControl, 2 lanes btw :D
var noteInJudgement = [false, false]
var activateHold = [false, false]

#player Rythm Input
var just_pressed = [Input.is_action_just_pressed("StrumUp"), 
Input.is_action_just_pressed("StrumDown")]

var pressed = [Input.is_action_pressed("StrumUp"), 
Input.is_action_pressed("StrumDown")]

var just_released = [Input.is_action_just_released("StrumUp"), 
Input.is_action_just_released("StrumDown")]

#Runner mechanic
var isRunnerSection

#gameOver
var isGameOver = false
@export var slowDownTime = 3.0

#DEBUG
var noteAreaDebug = false
@export var physicsCollDebug = false

#DiscordRPC
@export var discInfo:DiscordInfo

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
	
	$CanvasLayer/pauseMenu.canPause = true

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
	
	#Set notes to spawn
	elementSpawner.setChartToRender(project.charts[curDiff])

#END

#PHYSICS
func _physics_process(_delta):
	if project != null:
		if $Conductor.songLeft < 1 and !$Conductor/Song.playing and !songOver:
			endSong()
#END

#GO TO SCENES
func goToOverworld():
	if SceneManager.instance != null: 
		var overWorld = "res://Nodes/Scenes/overworld_state.tscn"
		SceneManager.instance.switchScene(overWorld)
	else:
		print("Error changing scene: Scene Manager is not present")

func restartLevel():
	if SceneManager.instance != null: 
		var restart = "res://Nodes/Scenes/play_state.tscn"
		SceneManager.instance.switchScene(restart)
	else:
		print("Error changing scene: Scene Manager is not present")

#RUNNER SECTION CODE
#func calculateSongSection():
	#var curSection = floor(($Conductor.songPos / $Conductor.stepCrochet) / 16)
	#
	#if curSection >= curSong.notes.size() - 1:
		#return
#
	#var isThisSectionRunner = curSong.notes[curSection].runnerSection
	#var isNextSectionRunner = curSong.notes[curSection + 1].runnerSection
#
	#var transitionToRunner = isNextSectionRunner and int($Conductor.curStep) % 16 <= 12
	#var transitionToRhythm = !isNextSectionRunner and int($Conductor.curStep) % 16 <= 12
	#var transitionToNextSection = int($Conductor.curStep) % 16 <= 10
#
	#if transitionToRunner or (isThisSectionRunner and transitionToNextSection):
		#setRunnerSection(true)
	#elif transitionToRhythm or (!isThisSectionRunner and transitionToNextSection):
		#setRunnerSection(false)

#func setRunnerSection(setSection):
	#isRunnerSection = setSection
	#
	#if isRunnerSection:
		#var tween = create_tween()
		#tween.tween_property($NoteGrp/NoteStrum, "modulate:a", 0, 0.2)
	#else:
		#var tween = create_tween()
		#tween.tween_property($NoteGrp/NoteStrum, "modulate:a", 1, 0.2)
	#
	#$player.setRunnin(isRunnerSection)
	#comboCounter.setRunnerSection(isRunnerSection)
#END

#Input
func _input(event):
	var justPressed = event.is_pressed() and not event.is_echo()
	if Input.is_physical_key_pressed(KEY_F1) and justPressed:
		debugCollision()
		debugNoteTiming = !debugNoteTiming
	
	#Restarting and overworld stuff
	#WILL CHANGE (PLACEHOLDER) :D
	if Input.is_action_just_pressed("Confirm") and songOver:
		goToOverworld()
	elif Input.is_action_just_pressed("Confirm") and isGameOver:
		restartLevel()
	
	#DEBUG gameOver
	if Input.is_physical_key_pressed(KEY_R):
		gameOver()
#END

#Animations and UI Stuff
func playerInputAnimation(curPressed):
	if curPressed != -1 and !isRunnerSection:
		$player.setNoHitAnim(curPressed, $NoteGrp/NoteStrum)

func updateOnNoteHit(note:GameNote):
	#animatePlayer
	$player.setHitAnim(note.elementRef.lane, $NoteGrp/NoteStrum)

func updateOnHoldHit(note:GameNote):
	#animatePlayer
	$player.setHitAnim(note.elementRef.lane, $NoteGrp/NoteStrum, true)
	
	#Rotate strum
	var rotationTween:Tween = create_tween()
	var finalPos = 2.0
	if note.elementRef.lane == 1:
		finalPos *= -1
		
	rotationTween.tween_property($NoteGrp, "rotation_degrees", finalPos, 0.2)
	
	#Camera tween
	var cameraTween:Tween = create_tween()
	var cameraFinal = Vector2(1.01, 1.01)
	cameraTween.tween_property($Camera2D, "zoom", cameraFinal, 0.2)

func updateOnHoldRelease(note:GameNote):
	noteHit(note, true, true)
	
	#animatePlayer
	$player.setHitAnim(note.elementRef.lane, $NoteGrp/NoteStrum)
	
	#Reset hold rotation
	var rotationTween:Tween = create_tween()
	rotationTween.tween_property($NoteGrp, "rotation_degrees", 0, 0.2)
	
	#Reset camera
	var cameraTween:Tween = create_tween()
	var cameraFinal = Vector2(1.0, 1.0)
	cameraTween.tween_property($Camera2D, "zoom", cameraFinal, 0.2)
	
	await rotationTween.finished

func updateOnMiss(note:GameNote):
	if note.elementRef.holdAmount > 0.0:
		#Stop Hold Audio
		$Audio/NoteHoldHitSound.stopAudio()
		
		#Reset hold rotation
		var rotationTween:Tween = create_tween()
		rotationTween.tween_property($NoteGrp, "rotation_degrees", 0, 0.2)
		
		#Reset camera
		var cameraTween:Tween = create_tween()
		var cameraFinal = Vector2(1.0, 1.0)
		cameraTween.tween_property($Camera2D, "zoom", cameraFinal, 0.2)
		
		#removeHoldParticle
		$NoteGrp/NoteStrum.removeHoldParticle(note.elementRef.lane)
	
	calculateSongAccuracy(note.elementRef.holdAmount > 0.0)
	
	setHealNotes(0)
	
	noteCombo = 0
	comboCounter.updateCounter(noteCombo)
	
	#Player animation
	$player.playMissAnimation()
	
	#Play miss sound
	$Audio/MissNoteSound.pitch_scale = randf_range(0.8, 1.2)
	$Audio/MissNoteSound.play()

#PROCESS HIT, AND GIVE RATING (UPDATE ACC)
func noteHit(note:GameNote, isHold = false, isHoldRelease = false):
	var strumTime = note.elementRef.position if !isHoldRelease else note.elementRef.position + note.elementRef.holdAmount
	var noteLane = note.elementRef.lane
	
	var timing = (strumTime - $Conductor.songPos) * 1000
	var timingAbs = abs(timing)
	var noteRating
	
	if timingAbs > 100:
		noteRating = "bad";
	elif timingAbs > 40:
		noteRating = "good";
	else:
		noteRating = "perfect";
	
	setNoteScore(noteRating, timing, isHold)
	popupNoteScore(noteLane, noteRating, timing)
	
	healPlayer()
	
	noteCombo += 1
	comboCounter.updateCounter(noteCombo)
	
	#Spawn hit particle
	if isHold:
		if !isHoldRelease:
			$NoteGrp/NoteStrum.spawnHoldParticle(noteLane, noteRating)
			
			#Stop Hold Audio
			$Audio/NoteHoldHitSound.playAudio()
		else:
			$NoteGrp/NoteStrum.removeHoldParticle(noteLane)
			
			#Stop Hold Audio
			$Audio/NoteHoldHitSound.stopAudio()
	
	$NoteGrp/NoteStrum.playHit(noteLane, noteRating == "perfect", isHoldRelease)
	$Camera2D.shake($Camera2D.ShakeTypes.NOTEHIT, 18.0, 2.0)
	
	$Audio/NoteHitSounds.playAudio(noteLane)

func popupNoteScore(noteLane, rating, timing):
	var popupInstance:PopupScore = popupRating.instantiate()
	
	#Get lane pos
	var laneObj:AnimatedSprite2D = $NoteGrp/NoteStrum.get_child(noteLane)
	var lanePos = laneObj.global_position
	
	#SetPos and spawn
	gameplayUI.add_child(popupInstance)
	popupInstance.setPopup(lanePos, rating, timing, debugNoteTiming)

func setNoteScore(rating, _timing, isHold = false):
	match rating:
		"bad":
			if !isHold: notesHit += 0.3
			else: notesHit += 0.1
		"good":
			if !isHold: notesHit += 0.5
			else: notesHit += 0.3
		"perfect":
			if !isHold: notesHit += 1
			else: notesHit += 0.5
	
	calculateSongAccuracy(isHold)

func calculateSongAccuracy(isHold = false):
	if !isHold:
		totalNotesPlayed += 1
	else:
		totalNotesPlayed += 0.5
	
	curAccuracy = (notesHit / totalNotesPlayed) * 100
	
	progressBar.setSongUIData(curAccuracy, missedNotes.size())
#END

#SONG CALCULATIONS
func getObjectPos(songXPos:float):
	var xPos = ((songXPos / conductor.stepCrochet) * (objectBaseSize))
	return xPos

func getObjectSongPos(objXPos:float) -> float:
	var xPos = objXPos
	var songPos = (xPos / objectBaseSize) * conductor.stepCrochet
	return songPos

func GetXFromSongBeat():
	return ($Conductor.songPos / $Conductor.stepCrochet) * 60

func GetSongPosFromX(xVal):
	return (xVal * $Conductor.stepCrochet) / 60

func GetSongBeat(val):
	return (val * $Conductor.stepCrochet)
#END

#END SONG
func endSong():
	songOver = true
	$WinScreen.visible = true
	$WinScreen/RankValue.text = SongRating.getRating(curAccuracy)
	$CanvasLayer/bloodSplater.material.set_shader_parameter("cutoff", 0)
	
	var fullCombo = ""
	
	if missedNotes.size() == 0:
		$WinScreen/RankValue.text += " (FC)"
		fullCombo = "FC"
	
	#var song = getSong()
	#if song:
		#SongRating.setSongRating(song[0], song[1], SongRating.getRating(curAccuracy)+fullCombo)
#END

#END
func debugCollision():
	noteAreaDebug = !noteAreaDebug
	
	$NoteGrp/NoteStrum.setDebug(noteAreaDebug)
	
	for note in $NoteGrp/ElementControl.get_children():
		if note.has_method("setDebug"):
			note.setDebug(noteAreaDebug)


#ON PLAYER HIT
func _on_player_hurt() -> void:
	if isGameOver:
		return
	
	$Camera2D.shake()
	setHealNotes(0)
	flashScreen(true)
	
	if $player.health <= 0:
		gameOver()

func flashScreen(hurt:bool):
	if hurt:
		$CanvasLayer/bloodSplater.material.set_shader_parameter("cutoff", 0.7)
	
	var tweenAmount = 0.0 if $player.health > 1 else 0.6
	var tween = create_tween()
	tween.tween_property($CanvasLayer/bloodSplater, "material:shader_parameter/cutoff", tweenAmount, 1.0)
#END

#HEAL Player
func healPlayer():
	healNotes += 1
	
	if healNotes >= healAmount and $player.health < 3:
		setHealNotes(0)
		$player.addOrSubHealth(1)
		flashScreen(false)

func setHealNotes(value):
	healNotes = value

#END

#GameOver
func gameOver():
	if !isGameOver:
		$CanvasLayer/pauseMenu.canPause = false
		isGameOver = true
		
		#slow down music
		var pitchTween = create_tween()
		pitchTween.tween_property($Conductor/Song, "pitch_scale", 0.1, slowDownTime)
		
		#slow down ground
		var stage = $stage
		var groundTween = create_tween()
		groundTween.tween_property(stage, "groundSpeed", 0.0, slowDownTime)
		
		#fade notes
		var notes = $NoteGrp
		var noteTween = create_tween()
		noteTween.tween_property(notes, "modulate:a", 0.0, slowDownTime)
		
		#fade UI
		var ui = $UIGrp
		var uiTween = create_tween()
		uiTween.tween_property(ui, "modulate:a", 0.0, slowDownTime)
		
		#fade screen flash
		var bloodSplater = $CanvasLayer/bloodSplater
		var bloodTween = create_tween()
		bloodTween.tween_property(bloodSplater, "material:shader_parameter/cutoff", 0.0, slowDownTime)
		
		#control player
		$player.killPlayer()
		
		await get_tree().create_timer(slowDownTime).timeout
		
		$Conductor/Song.stop()
		showGameOverText()

func showGameOverText():
	$CanvasLayer/gameOver.visible = true

#END

#Pause music when pausing game
func _on_pause_menu_pause() -> void:
	if !songOver:
		$Conductor.playSong(false)

func _on_conductor_beat_hit(_position: Variant) -> void:
	progressBar.playBob()
	progressBar.updateSongTime($Conductor.songPos)
	
	comboCounter.playBop()
