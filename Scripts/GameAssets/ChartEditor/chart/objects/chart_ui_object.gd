extends ChartUIDraggable

class_name ChartUIObject #Elements AND Events

#Data
@onready var refData:ChartObject
var renderedObjectsRef:ChartUIRenderedObjects
var step:float

func updateUI(data:ChartObject, elementsRef:ChartUIRenderedObjects, stepCrochet:float):
	refData = data
	renderedObjectsRef = elementsRef
	step = stepCrochet

func getDataType():
	return ChartObject
