extends ChartUIObject

class_name ChartUIEvent

@onready var eventData:ChartEvent = ChartEvent.new()

#Set
func setData(eventDict:Dictionary):
	var eventDataDict = eventData.getDict()
	
	for param in eventDict.keys():
		eventDataDict[param] = eventDict[param]
	
	eventData.setNode(eventDataDict)
	
	updateUI()

func updateUI():
	pass
