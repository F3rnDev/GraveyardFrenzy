extends RefCounted
class_name ChartObject

var position:float = 0.0:
	set(value):
		position = value
		onPositionChanged(value)

func getDict() -> Dictionary:
	return {
		"position": position,
	}

func getUIType():
	return ChartUIObject

func setNode(dict:Dictionary):
	position = dict["position"]

func duplicate() -> Object:
	var copy = get_script().new()
	for prop in get_property_list():
		var prop_name: String = prop["name"]
		var prop_usage: int = prop["usage"]
		
		if prop_usage and PROPERTY_USAGE_SCRIPT_VARIABLE:
			var value = get(prop_name)
			if value is Array or value is Dictionary:
				copy.set(prop_name, value.duplicate(true))
			else:
				copy.set(prop_name, value)
				
	return copy

func onPositionChanged(value):
	pass #DO NOTHING
