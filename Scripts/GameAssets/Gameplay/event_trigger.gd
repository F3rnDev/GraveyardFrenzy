extends Node

@export_category("Dependencies")
@export var gameplay:GameplayScene

var chartRef:Chart = null
var untriggeredEvents:Array[ChartEvent] = []

func setEventsToTrigger(chart:Chart):
	chartRef = chart
	
	for event in chartRef.events:
		untriggeredEvents.append(event)
	
	untriggeredEvents.sort_custom(func(a, b):
		return a.position < b.position
	)

func _physics_process(delta: float) -> void:
	if chartRef == null or untriggeredEvents.is_empty():
		return
	
	checkEvents()

func checkEvents():
	var curSongTime = gameplay.conductor.songPos
	
	while not untriggeredEvents.is_empty():
		var event:ChartEvent = untriggeredEvents[0]
		
		if event.position <= curSongTime:
			untriggeredEvents.pop_front()
			triggerEvent(event)
		else:
			break

func triggerEvent(event:ChartEvent):
	match event.eventType:
		ChartEvent.Types.SetSection:
			tgrSetSection(event)

func tgrSetSection(event:ChartEvent):
	var sectionType = EventParams.getParam(event, EventParams.ParameterKey.SECTION_ID)
	
	#Change in the future, after adding other types of sections
	gameplay.setRunnerSection(sectionType == 1.0)
