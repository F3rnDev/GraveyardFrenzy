extends ChartObject
class_name ChartEvent

enum Types
{
	SetSection
}

var eventType:Types = Types.SetSection
var eventParams:Dictionary = {}

func getDict() -> Dictionary:
	var dict = super.getDict()
	
	dict["eventType"] = eventType
	dict["eventParams"] = eventParams
	
	return dict

func getUIType():
	return ChartUIEvent

func setNode(dict:Dictionary):
	super.setNode(dict)
	
	if "eventType" not in dict or "eventParams" not in dict:
		return
	
	eventType = dict["eventType"]
	eventParams = dict["eventParams"]
