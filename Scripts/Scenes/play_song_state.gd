extends Node2D

class_name PlayState

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
func setRPCInfo(curSong):
	if SceneManager.instance != null:
		discInfo.state = curSong
		SceneManager.instance.updateDiscordRPCInfo(discInfo)

#LOAD SCENE
func _ready():
	var song = getSong()
	if !song:
		song = ["Tutorial", "Normal"]
	
	loadSong(song[0], Difficulty.getFileDiff(song[1]))
	
	if physicsCollDebug == true:
		get_tree().set_debug_collisions_hint(physicsCollDebug)
	
	flashScreen(false)
	
	$CanvasLayer/pauseMenu.canPause = true
	
	setRPCInfo(song[0] + " | " + song[1])

func getSong():	
	var songProperties
	
	if SceneManager.instance != null and SceneManager.instance.has_method("getSongProperties"):
		songProperties = SceneManager.instance.getSongProperties()
	
	return songProperties

func loadSong(songToLoad, diff):
	curSong = $Song.Song.new().loadSong(songToLoad, diff)
	
	if curSong != null:
		var path = "res://Assets/Audio/Songs/" + curSong.songName + "/" + curSong.songName
		$Conductor.setSong(path)
		$Conductor.setBpm(curSong.bpm)
		getAllSongNotes()
		$Conductor.playSong(false)
		$"Placeholder Grp/ProgressBar".max_value = $Conductor.songLength

func getAllSongNotes():
	for section in curSong.notes:
		for note in section.sectionNotes:
			unspawnNotes.append([note, section.runnerSection]) #put this in the json
	
	addChartElement()
#END

#ADD NOTES
func addChartElement():
	for note in unspawnNotes:
		if noteArray.size() < maxNotes:
			
			if !note[1]:
				addNote(note[0])
			else:
				addObs(note[0])
			
			noteArray.append(note[0])
			
		else:
			break
	
	#delete Da Note
	for note in noteArray:
		if unspawnNotes[0].find(note) != -1:
			unspawnNotes.remove_at(unspawnNotes[0].find(note))

func addNote(note):
	var noteLoad = preload("res://Nodes/GameAssets/Gameplay/NoteSystem/note.tscn")
			
	var instance = noteLoad.instantiate()
	instance.position.x = 3000
	instance.z_index = 1
	instance.position.y = $NoteGrp/NoteStrum.position.y + (note[1] * $NoteGrp/NoteStrum/StrumDown.position.y)
	instance.setDebug(noteAreaDebug)
	instance.play("default")
	
	$NoteGrp/RenderedNotes.add_child(instance)

func addObs(obs):
	var instance = preload("res://Nodes/GameAssets/Gameplay/NoteSystem/obstacle.tscn").instantiate()
	instance.position.x = 3000
	instance.z_index = 1
	instance.position.y = $NoteGrp/NoteStrum.position.y + (obs[1] * $NoteGrp/NoteStrum/StrumDown.position.y) + 10
	instance.play("default")

	if obs[1] == 0:
		instance.frame = 1;
	else:
		instance.frame = 0;

	$NoteGrp/RenderedNotes.add_child(instance)
#END

#PHYSICS
func _physics_process(_delta):
	playerInput()
	calculateSongSection()
	
	if curSong != null:
		if noteArray.size() < maxNotes and unspawnNotes.size() > 0:
			addChartElement()
		
		setSongLeft()
		
		if $Conductor.songLeft < 1 and !$Conductor/Song.playing and !songOver:
			endSong()
		
		if Input.is_action_just_pressed("Confirm") and songOver:
			goToOverworld()
		
		if Input.is_action_just_pressed("Confirm") and isGameOver:
			restartLevel()
		
		chartElementAction()
		playerInputAnimation()
		
		#DEBUG gameOver
		if Input.is_physical_key_pressed(KEY_R):
			gameOver()
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
func calculateSongSection():
	var curSection = floor(($Conductor.songPos / $Conductor.stepCrochet) / 16)
	
	if curSection >= curSong.notes.size() - 1:
		return

	var isThisSectionRunner = curSong.notes[curSection].runnerSection
	var isNextSectionRunner = curSong.notes[curSection + 1].runnerSection

	var transitionToRunner = isNextSectionRunner and int($Conductor.curStep) % 16 <= 12
	var transitionToRhythm = !isNextSectionRunner and int($Conductor.curStep) % 16 <= 12
	var transitionToNextSection = int($Conductor.curStep) % 16 <= 10

	if transitionToRunner or (isThisSectionRunner and transitionToNextSection):
		setRunnerSection(true)
	elif transitionToRhythm or (!isThisSectionRunner and transitionToNextSection):
		setRunnerSection(false)

func setRunnerSection(setSection):
	isRunnerSection = setSection
	
	if isRunnerSection:
		$player.setRunnin(true)
		var tween = create_tween()
		tween.tween_property($NoteGrp/NoteStrum, "modulate:a", 0, 0.2)
	else:
		$player.setRunnin(false)
		var tween = create_tween()
		tween.tween_property($NoteGrp/NoteStrum, "modulate:a", 1, 0.2)
#END

#GET INPUT
func _input(event):
	var justPressed = event.is_pressed() and not event.is_echo()
	if Input.is_physical_key_pressed(KEY_F1) and justPressed:
		debugCollision()

func playerInput():
	#gameInput
	just_pressed = [Input.is_action_just_pressed("StrumUp"), 
	Input.is_action_just_pressed("StrumDown")]

	pressed = [Input.is_action_pressed("StrumUp"), 
	Input.is_action_pressed("StrumDown")]

	just_released = [Input.is_action_just_released("StrumUp"), 
	Input.is_action_just_released("StrumDown")]

func playerInputAnimation():
	#AnimatePlayer If HePressed
	var curPressed = just_pressed.find(true)
	if curPressed != -1 and !isRunnerSection:
		$player.setNoHitAnim(curPressed, $NoteGrp/NoteStrum)
#END

func setSongLeft():
	$"Placeholder Grp/ProgressBar".value = $Conductor.songPos
	
	var songSeconds = str(int($Conductor.songLeft) % 60).pad_zeros(2)
	var songMinutes = str(int($Conductor.songLeft) / 60).pad_zeros(2)
	
	$"Placeholder Grp/ProgressBar/Label".text = songMinutes + ":" + songSeconds

#CHARTACTION
func chartElementAction():	
	for noteIndex in range(noteArray.size()):
		move(noteIndex)
		
		if !isGameOver:
			removeCheck(noteIndex)
			noteControl(noteIndex)
	
	if notesToRemove.size() > 0:
		removeNotes()
	
	noteInJudgement = [false, false]
	
#END

#REMOVE QUEUED NOTES
func removeNotes():
	# Sort in descending order so higher indices are removed first
	notesToRemove.sort() 
	notesToRemove.reverse()
	
	for noteIndex in notesToRemove:
		var noteNode = $NoteGrp/RenderedNotes.get_child(noteIndex)
		noteArray.remove_at(noteIndex)
		noteNode.queue_free()
	
	notesToRemove.clear()
#END

#MOVE
func move(elementId):
	var note = noteArray[elementId]
	var strumTime = note[0]
	var notePos = ((strumTime - GetXFromSongBeat()) * noteSpeed) + $NoteGrp/NoteStrum.position.x
	
	#update note position
	var noteNode = $NoteGrp/RenderedNotes.get_child(elementId)
	noteNode.position.x = notePos
	
	if note[2] > 0:
		var holdEnd = noteNode.getHoldEnd()
		holdEnd.visible = true
		holdEnd.global_position.y = noteNode.global_position.y
		holdEnd.global_position.x = notePos + note[2]
		noteNode.setHold()
#END

#SET NOTE CONTROL (If it can be hit, and if it can miss)
func noteControl(elementId):
	var noteNode = $NoteGrp/RenderedNotes.get_child(elementId)
	var noteLane = noteArray[elementId][1]
	var overlapingStrum = judgementCheck(elementId)
	
	#check Miss
	missCheck(elementId, overlapingStrum)
	
	#check if there's not another note being processed
	if noteInJudgement[noteLane]:
		return
	
	#process that the note canBeHit, if everything is ok
	if overlapingStrum and !missedNotes.has(noteNode):
		noteInJudgement[noteLane] = true
		canBeHit(elementId)

func judgementCheck(elementId):
	var noteNode = $NoteGrp/RenderedNotes.get_child(elementId)
	
	var judgementLine = $NoteGrp/NoteStrum.getJudgment()
	var noteJudgement = noteNode.getJudgment() if noteNode.has_method("getJudgment") else null

	return noteJudgement != null and judgementLine.intersects(noteJudgement)

func missCheck(elementId, overlap):
	var noteNode = $NoteGrp/RenderedNotes.get_child(elementId)
	
	if noteNode.has_method("getHoldEnd") and noteNode.position.x < $NoteGrp/NoteStrum.position.x and !overlap and !missedNotes.has(noteNode):
		noteMiss(noteNode, elementId, noteNode.getHoldEnd())
#END

#REMOVE NOTE IF TOO FAR
func removeCheck(elementId):
	var note = noteArray[elementId]
	var strumTime = note[0]
	var notePos = ((strumTime - GetXFromSongBeat()) * noteSpeed) + $NoteGrp/NoteStrum.position.x
	
	if notePos < -1000:
		queueNoteForRemoval(elementId)
#END

#NOTE HIT
func canBeHit(noteIndex):
	var note = noteArray[noteIndex][1]
	
	if noteArray[noteIndex][2] == 0:
		normalHit(noteIndex, note, false)
	else:
		getHoldInput(noteIndex, note)

func getHoldInput(noteIndex, noteData):
	if activateHold[noteData]:
		holdHit(noteIndex, noteData)
		holdRelease(noteIndex, noteData)
	else:
		normalHit(noteIndex, noteData, true)

func normalHit(noteIndex, noteData, isHold):
	var noteNode = $NoteGrp/RenderedNotes.get_child(noteIndex)
	var hit = false
	
	if just_pressed[noteData]:
		hit = true
	
	if !isHold and hit:
		noteHit(noteArray[noteIndex][0])
		queueNoteForRemoval(noteIndex)
		
		#animatePlayer
		$player.setHitAnim(noteData, $NoteGrp/NoteStrum)
	elif isHold and hit:
		noteHit(noteArray[noteIndex][0], true)
		activateHold[noteData] = true

func holdHit(noteIndex, noteData):
	var noteNode = $NoteGrp/RenderedNotes.get_child(noteIndex)
	
	if pressed[noteData]:
		#updateStrumData
		var curStrum = noteArray[noteIndex][0]
		noteArray[noteIndex][0] = GetXFromSongBeat()
		noteArray[noteIndex][2] -= (noteArray[noteIndex][0] - curStrum)
		
		#updateNode
		noteNode.position.x = $NoteGrp/NoteStrum.position.x
		noteNode.getHoldEnd().global_position.x = noteNode.position.x + noteArray[noteIndex][2]
		noteNode.modulate.a = 0.2
		noteNode.setHold()
		
		#animatePlayer
		$player.setHitAnim(noteData, $NoteGrp/NoteStrum, true)

func holdRelease(noteIndex, noteData):
	var noteNode = $NoteGrp/RenderedNotes.get_child(noteIndex)
	var holdEndNode = noteNode.getHoldEnd()
	var noteDiff = holdEndNode.global_position.x - noteNode.position.x
	var canRelease = false
	
	#checkCollisionInHold
	var judmentLine = $NoteGrp/NoteStrum.getJudgment()
	var noteJudment = noteNode.getHoldJudgment() if noteNode.has_method("getHoldJudgment") else null
	
	if noteJudment != null and judmentLine.intersects(noteJudment):
		canRelease = true
	
	#updateInfo
	if just_released[noteData] and canRelease or noteDiff < -50:
		noteHit(noteArray[noteIndex][0] + noteArray[noteIndex][2], true)
		activateHold[noteData] = false
		queueNoteForRemoval(noteIndex)
		
		#animatePlayer
		$player.setHitAnim(noteData, $NoteGrp/NoteStrum)
		
	elif just_released[noteData] and !canRelease:
		noteMiss(noteNode, noteIndex, holdEndNode)
		activateHold[noteData] = false
#END

#MISS AND REMOVE NOTE
func noteMiss(note, noteIndex, holdEnd):
	missedNotes.append(note)
	note.modulate.a = 0.3
	var isHold = false
	
	if noteArray[noteIndex][2] > 0:
		isHold = true
		holdEnd.modulate.a = 0.3
		note.getHold().modulate.a = 0.3
	
	calculateSongAccuracy(isHold)
	
	setHealNotes(0)

func queueNoteForRemoval(noteIndex):
	notesToRemove.append(noteIndex)
#END

#PROCESS HIT, AND GIVE RATING (UPDATE ACC)
func noteHit(strumTime, isHold = false):
	var timing = (GetSongPosFromX(strumTime) - $Conductor.songPos) * 1000
	var timingAbs = abs(timing)
	var noteRating
	
	if timingAbs > 100:
		noteRating = "bad";
	elif timingAbs > 40:
		noteRating = "good";
	else:
		noteRating = "perfect";
	
	popupNoteScore(noteRating, timing, isHold)
	
	showTiming(timing, noteRating)
	
	healPlayer()

func showTiming(timing, rating):
	var textColor = Color.WHITE
	var timingDesc = ""
	var timingText = str(snapped(abs(timing), 0.01))
	
	#DEFINE TEXT COLOR
	match rating:
		"bad":
			textColor = Color.RED
		"good":
			textColor = Color.YELLOW
		"perfect":
			textColor = Color.GREEN
	
	#CHECK IF TIMING IS EARLY OR LATE
	if timing > 60:
		timingDesc = "\n(too early)"
	elif timing < -60:
		timingDesc = "\n(too late)"
	else:
		""
	
	#UPDATE TEXT
	$"Placeholder Grp/Score/Timing".text = timingText + " ms" + timingDesc
	$"Placeholder Grp/Score/Timing".set("theme_override_colors/font_color", textColor)

func popupNoteScore(rating, timing, isHold = false):
	#update the scoreGraphic, still a placeholder
	$"Placeholder Grp/Score".text = rating[0].to_upper() + rating.substr(1,-1)
	
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
	updateSongStats()
#END

#SONG CALCULATIONS
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
	
	var song = getSong()
	if song:
		SongRating.setSongRating(song[0], song[1], SongRating.getRating(curAccuracy)+fullCombo)
#END

#END

func updateSongStats():
	$"Placeholder Grp/SongStats".text = "Accuracy: " + str(snapped(curAccuracy, 0.1)) + "% | Misses: " + str(missedNotes.size())

func debugCollision():
	noteAreaDebug = !noteAreaDebug
	
	$NoteGrp/NoteStrum.setDebug(noteAreaDebug)
	
	for note in $NoteGrp/RenderedNotes.get_children():
		if note.has_method("setDebug"):
			note.setDebug(noteAreaDebug)


#ON PLAYER HIT
func _on_player_hit() -> void:
	if isGameOver:
		return
	
	$Camera2D.shake()
	setHealNotes(0)
	flashScreen(true)
	
	if $player.health <= 0:
		gameOver()

func flashScreen(hit:bool):
	if hit:
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
		var ui = $"Placeholder Grp"
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
	$Conductor.playSong(false)
