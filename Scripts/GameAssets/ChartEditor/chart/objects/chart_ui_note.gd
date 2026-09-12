extends ChartUIObject

class_name ChartUINote

#HoldNote
@onready var holdNoteLine = $HoldLine
@onready var holdNoteEnd = $HoldEnd

func getDataType():
	return ChartNote

func startCreateAnimation():
	createAnimation(self)
	createAnimation(holdNoteLine)
	createAnimation(holdNoteEnd)

func updateUI(data:ChartObject, elementsRef:ChartUIRenderedObjects, stepCrochet:float):
	super.updateUI(data, elementsRef, stepCrochet)
	
	#Set hold visibility
	holdNoteLine.visible = data.holdAmount > stepCrochet
	holdNoteEnd.visible = data.holdAmount > 0.0
	
	var hold = elementsRef.getNotePixelsFromDuration(data.holdAmount)
	var stepSize = elementsRef.gridInfo.stepSize
	
	#Update Hold Position and Size
	holdNoteEnd.position.x = hold
	holdNoteLine.position.x = stepSize
	holdNoteLine.size.x = hold - stepSize
	
	#Set Color Rect Size
	selectRect.size.x = holdNoteEnd.position.x + holdNoteEnd.size.x
	selectRect.size.y = size.y
