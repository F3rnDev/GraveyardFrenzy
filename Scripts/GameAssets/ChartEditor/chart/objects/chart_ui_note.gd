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
	#Set hold info
	holdNoteLine.visible = noteData.holdAmount > 0.0
	holdNoteEnd.visible = noteData.holdAmount > 0.0
	
	#Set Color Rect Size
	selectRect.size.x = holdNoteEnd.position.x + holdNoteEnd.size.x

func _input(event: InputEvent) -> void:
	super._input(event)
	
	if Input.is_action_just_pressed("RightMouseClick"):
		#OpenPopup, to edit or delete :D
		return
