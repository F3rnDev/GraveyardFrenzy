extends ChartObject

class_name ChartEventGroup

var linkedEvents:Array[ChartEvent] = []
var selectedEvent:ChartEvent = null

func getUIType():
	return ChartUIEventGroup

func onPositionChanged(value):
	for event in linkedEvents:
		if is_instance_valid(event):
			event.position = value
