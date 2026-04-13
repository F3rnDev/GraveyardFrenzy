class_name ChartEvent

enum Types
{
	Runner
}

var position:float = 0.0
var eventType:Types = Types.Runner
var eventParams:Dictionary = {}

func getDict() -> Dictionary:
	return {
		"position": position,
		"eventType": eventType,
		"eventParams": eventParams
	}

func setNode(dict:Dictionary):
	position = dict["position"]
	eventType = dict["eventType"]
	eventParams = dict["eventParams"]
