extends ChartUIObject

class_name ChartUINote

@onready var noteData:ChartNote = ChartNote.new()

#HoldNote
@onready var holdNoteLine = $HoldLine
@onready var holdNoteEnd = $HoldEnd

func setData(noteDict:Dictionary):
	var noteDataDict = noteData.getDict()
	
	for param in noteDict.keys():
		noteDataDict[param] = noteDict[param]
	
	noteData.setNode(noteDataDict)
	
	updateUI()

func updateUI():
	#Set hold visibility
	holdNoteLine.visible = noteData.holdAmount > 0.0
	holdNoteEnd.visible = noteData.holdAmount > 0.0

func updateHold(hold:float, stepSize:float):
	#Update Hold Position and Size
	holdNoteEnd.position.x = hold
	holdNoteLine.position.x = stepSize
	holdNoteLine.size.x = hold - stepSize
	
	#Set Color Rect Size
	selectRect.size.x = holdNoteEnd.position.x + holdNoteEnd.size.x

func _input(event: InputEvent) -> void:
	super._input(event)
	
	if Input.is_action_just_pressed("RightMouseClick"):
		#OpenPopup, to edit or delete :D
		return
