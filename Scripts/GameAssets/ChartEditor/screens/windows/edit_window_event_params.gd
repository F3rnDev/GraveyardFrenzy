extends EditWindowParams

@onready var paramsUI = $MainContainer/Parameters
@onready var params = {
	ChartEvent.Types.SetSection: [$MainContainer/Parameters/ChangeSection, $MainContainer/Parameters/newSection]
}

#Fields
## Set Section
@onready var newSection = $MainContainer/Parameters/newSection #Controls the section the game will change to (Runner/Rhythm for example)

func setParams(Objects:Array):
	super.setParams(Objects)
	
	if objectsRef.is_empty():
		return
	
	clearUI()
	var firstEvent:ChartEvent = objectsRef[0] if objectsRef[0] is not ChartEventGroup else objectsRef[0].selectedEvent
	var eventType:ChartEvent.Types = firstEvent.eventType
	
	if eventType in params:
		enableGroup(params[eventType])
	
	match eventType:
		ChartEvent.Types.SetSection:
			newSection.select(EventParams.getParam(firstEvent, EventParams.ParameterKey.SECTION_ID))

func clearUI():
	visible = true
	
	for param in paramsUI.get_children():
		param.visible = false

func enableGroup(group:Array):
	for item in group:
		item.visible = true

#define param:
func _on_new_section_item_selected(index: int) -> void:
	for event in objectsRef:
		if event is not ChartEvent and event is not ChartEventGroup:
			return
		
		var targetEvent = event
		if event is ChartEventGroup:
			targetEvent = event.selectedEvent
		
		EventParams.setParam(targetEvent, EventParams.ParameterKey.SECTION_ID, index)
