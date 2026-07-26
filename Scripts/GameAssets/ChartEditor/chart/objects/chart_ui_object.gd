extends ChartUIDraggable

class_name ChartUIObject #Elements AND Events

#Data
@onready var refData:ChartObject
var renderedObjectsRef:ChartUIRenderedObjects

func updateUI(data:ChartObject, elementsRef:ChartUIRenderedObjects):
	refData = data
	renderedObjectsRef = elementsRef

func getDataType():
	return ChartObject
