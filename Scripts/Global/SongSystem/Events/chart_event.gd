class_name ChartEvent

enum Types
{
	Runner
}

var eventType:Types = Types.Runner
var eventParams:Dictionary = {}

func getDict() -> Dictionary:
	return {
		"eventType": eventType,
		"eventParams": eventParams
	}

func setNode(dict:Dictionary):
	eventType = dict["eventType"]
	eventParams = dict["eventParams"]
