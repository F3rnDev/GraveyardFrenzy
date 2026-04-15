extends Node

class_name Chart

var elements:Array[ChartElement] = []
var events:Array[ChartEvent] = []

func getDict() -> Dictionary:
	return {
		"elements": elements.map(func(element): return element.getDict()),
		"events": events.map(func(event): return event.getDict())
	}

func setNode(dict:Dictionary):
	elements.clear()
	events.clear()
	
	for elementData in dict["elements"]:
		match int(elementData["elementType"]):
			ChartElement.Types.Note:
				var note:ChartNote = ChartNote.new()
				note.setNode(elementData)
				elements.append(note)
			ChartElement.Types.Obs:
				var obstacle:ChartObstacle = ChartObstacle.new()
				obstacle.setNode(elementData)
				elements.append(obstacle)
			_:
				push_error("Unknown element type: " + str(elementData["elementType"]))
	
	for eventData in dict["events"]:
		var event:ChartEvent = ChartEvent.new()
		event.setNode(eventData)
		events.append(event)
