extends Node2D

@export_category("Dependencies")
@export var gameplay:GameplayScene
@export var elementControl:Node2D

#Inputs
var justPressed = []
var pressed = []
var justReleased = []

#Note processing
#One for each lane, holds the note object
var beingProcessed = [null, null]
var beingHold = [null, null]

func _unhandled_input(event: InputEvent) -> void:
	setInput()
	checkNoteHit()
	processNoteHold()
	
	#Handle other animations and such, if needed
	gameplay.playerInputAnimation(justPressed.find(not null))

func _physics_process(delta: float) -> void:
	for holdNote in beingHold:
		if holdNote != null:
			updateHoldHit(holdNote)

func setInput():
	justPressed = [Input.is_action_just_pressed("StrumUp"),
	Input.is_action_just_pressed("StrumDown")]

	pressed = [Input.is_action_pressed("StrumUp"),
	Input.is_action_pressed("StrumDown")]

	justReleased = [Input.is_action_just_released("StrumUp"),
	Input.is_action_just_released("StrumDown")]

#NoteHIT
func checkNoteHit():
	for element in elementControl.activeElements:
		if element is not GameNote:
			continue
		
		var isProcessed = beingProcessed[element.elementRef.lane] != null
		var isHold = beingHold[element.elementRef.lane] != null
		var inJudgement = element.isOverlappingJudgment(gameplay.noteStrum.getJudgment())
		if inJudgement and !isProcessed and !isHold and element not in elementControl.missedNotes:
			processHit(element)
	
	beingProcessed = [null, null]

#Normal hit
func processHit(note:GameNote):
	beingProcessed[note.elementRef.lane] = note
	noteHit(note)

func noteHit(note:GameNote):
	if !justPressed[note.elementRef.lane]:
		return
	
	if note.elementRef.holdAmount <= 0.0:
		gameplay.updateOnNoteHit(note)
		gameplay.noteHit(note, false)
		elementControl.queueNoteForRemoval(note)
	else:
		gameplay.noteHit(note, true)
		beingHold[note.elementRef.lane] = note

#HoldHitAndRelease
func processNoteHold():
	for note in beingHold:
		if note != null:
			processHoldRelease(note)

func processHoldRelease(note:GameNote):
	if !justReleased[note.elementRef.lane]:
		return
	
	var judgementLine = gameplay.noteStrum.getJudgment()
	var canRelease = note.isOverlappingHoldJudgment(judgementLine)
	
	if canRelease:
		gameplay.updateOnHoldRelease(note)
		elementControl.queueNoteForRemoval(note)
	else:
		elementControl.missNote(note)
	
	beingHold[note.elementRef.lane] = null
 
func updateHoldHit(note:GameNote):
	if !pressed[note.elementRef.lane]:
		return
	
	var curStrum = note.elementRef.position
	var songPos = gameplay.conductor.songPos
	var newHold = note.elementRef.holdAmount - (songPos - curStrum)
	
	note.updateHoldHit(newHold)
	
	var judgementLine = gameplay.noteStrum.getJudgment()
	var canRelease = note.isOverlappingHoldJudgment(judgementLine)
	
	if newHold < 0.0 and !canRelease:
		beingHold[note.elementRef.lane] = null
		elementControl.missNote(note)
		return
	
	gameplay.updateOnHoldHit(note)
