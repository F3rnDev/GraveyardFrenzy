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

var songOver = false

#noteInputControl
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
var curSection
var isRunnerSection

#DEBUG
var noteAreaDebug = false
@export var physicsCollDebug = false

#LOAD SCENE
func _ready():
	var song = getSong()
	if song:
		loadSong(song[0], Difficulty.getFileDiff(song[1]))
	else:
		loadSong("Tutorial", Difficulty.getFileDiff("Normal"))
	
	$player/HealthPH.set_text("Health: " + str($player.health))
	
	if physicsCollDebug == true:
		get_tree().set_debug_collisions_hint(physicsCollDebug)

func getSong():	
	var sceneManager = self.get_parent()
	var songProperties
	
	if sceneManager.has_method("getSongProperties"):
		songProperties = sceneManager.getSongProperties()
	
	return songProperties

func loadSong(songToLoad, diff):
	curSong = $Song.Song.new().loadSong(songToLoad, diff)
	
	if curSong != null:
		var path = "res://Assets/Songs/" + curSong.songName + "/" + curSong.songName
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
		
		if $Conductor.songLeft == 0 and !$Conductor/Song.playing and !songOver:
			endSong()
		
		if Input.is_action_just_pressed("Confirm") and songOver:
			var overWorld = load("res://Nodes/Scenes/overworld_state.tscn")
			self.get_parent().switchScene(overWorld, self)
		
		chartElementAction()
#END

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

func setRunnerSection(set):
	isRunnerSection = set
	
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
	$"Placeholder Grp/Accuracy".text = "Accuracy: " + str(snapped(curAccuracy, 0.1)) + "%"
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
	
	var fullCombo = ""
	
	if missedNotes.size() == 0:
		$WinScreen/RankValue.text += " (FC)"
		fullCombo = "FC"
	
	var song = getSong()
	if song:
		SongRating.setSongRating(song[0], song[1], SongRating.getRating(curAccuracy)+fullCombo)
#END

#UPDATE UI IF PLAYER IS HIT BY OBSTACLE
func _on_player_hit():
	$player/HealthPH.set_text("Health: " + str($player.health))
#END

func debugCollision():
	noteAreaDebug = !noteAreaDebug
	
	$NoteGrp/NoteStrum.setDebug(noteAreaDebug)
	
	for note in $NoteGrp/RenderedNotes.get_children():
		if note.has_method("setDebug"):
			note.setDebug(noteAreaDebug)
