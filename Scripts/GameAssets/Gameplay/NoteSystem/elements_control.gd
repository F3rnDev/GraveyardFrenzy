extends Node2D
#CONTROLS THE MISSING/DELETION AND INPUT OF THE NOTES
@export var gameplay:GameplayScene

var activeElements:Array[GameElement] = []
var elementsToRemove:Array[GameElement] = []

var missedNotes:Array[GameElement] = []

func addElement(elementObj:GameElement):
	add_child(elementObj)
	activeElements.append(elementObj)

func _physics_process(delta: float) -> void:
	var songPos = gameplay.getObjectPos(gameplay.conductor.songPos)
	
	for element in activeElements:
		removeCheck(element)
		
		if element is GameNote:
			missCheck(element)
	
	if elementsToRemove.size() > 0:
		removeElements()

#RemoveElement
func removeCheck(element:GameElement):
	if element.global_position.x < -1000.0:
		queueNoteForRemoval(element)

func queueNoteForRemoval(element):
	elementsToRemove.append(element)

func removeElements():
	# Sort in descending order so higher indices are removed first
	elementsToRemove.sort() 
	elementsToRemove.reverse()
	
	for element in elementsToRemove:
		activeElements.erase(element)
		element.queue_free()
	
	elementsToRemove.clear()
#END

#MISS NOTES
func missCheck(note:GameNote):
	var lessPosition = note.global_position.x < gameplay.noteStrum.global_position.x
	var inJudment = note.isOverlappingJudgment(gameplay.noteStrum.getJudgment())
	if lessPosition and !inJudment and !missedNotes.has(note):
		missNote(note)

func missNote(note:GameNote):
	missedNotes.append(note)
	note.missNote()
	
	gameplay.updateOnMiss(note)

func getMissedNotes():
	return missedNotes.size()
