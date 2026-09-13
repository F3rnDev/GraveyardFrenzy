extends Node

class_name Chart

var elements:Array[ChartElement] = []
var events:Array = [] #Can Contain ChartEvents/ChartEventGroups

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

#Existing can both be a chartEvent as a group
func merge2Events(draggedEvent:ChartEvent, existingEvent:ChartObject) -> ChartEventGroup:
	if existingEvent is ChartEvent:
		var newGroup:ChartEventGroup = ChartEventGroup.new()
		newGroup.position = existingEvent.position
		
		newGroup.linkedEvents.append(draggedEvent)
		newGroup.linkedEvents.append(existingEvent)
		
		events.erase(draggedEvent)
		events.erase(existingEvent)
		events.append(newGroup)
		
		return newGroup
	
	elif existingEvent is ChartEventGroup:
		existingEvent.linkedEvents.append(draggedEvent)
		events.erase(draggedEvent)
		
		return existingEvent as ChartEventGroup
	
	return null

#SplitEventFromGroup
func splitEventFromGroup(event:ChartEvent, group:ChartEventGroup):
	group.linkedEvents.erase(event)
	events.append(event)
	
	var newGroup = group
	
	if group.linkedEvents.size() == 1:
		var lastEvent = group.linkedEvents[0]
		events.erase(group)
		events.append(lastEvent)
		
		newGroup = lastEvent
	
	return newGroup

func groupEvents(): #Group all events by position
	var groupedEvents:Array = []
	var positionMap:Dictionary = {}
	
	#Populate positionMap
	for event in events:
		if not event.position in positionMap:
			positionMap[event.position] = [] as Array[ChartEvent]
		
		positionMap[event.position].append(event)
	
	#Set GroupList
	for pos in positionMap:
		var eventsAtPos:Array[ChartEvent] = positionMap[pos]
		
		if eventsAtPos.size() > 1:
			var newGroup = ChartEventGroup.new()
			newGroup.position = pos
			newGroup.linkedEvents = eventsAtPos
			
			groupedEvents.append(newGroup)
		else:
			groupedEvents.append(eventsAtPos[0])
	
	events = groupedEvents

func unpackEvents(): #Unpack events before saving
	var flatEvents: Array[ChartEvent] = []
	
	for event in events:
		if event is ChartEvent:
			flatEvents.append(event)
		
		elif event is ChartEventGroup:
			flatEvents.append_array(event.linkedEvents)
	
	events = flatEvents
