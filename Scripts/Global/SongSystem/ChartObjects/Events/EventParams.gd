class_name EventParams

#PUT NEW PARAMETERS IN THE KEY ENUM
#USE CTRL+SHIFT+F IF A PARAMETER HAS TO BE CHANGED (BE CAREFULL!!!)
enum ParameterKey {
	SECTION_ID
}

#TO SET A NEW SCHEMA, FOLLOW THE FOLLOWING STANDARD:
#	XEventType: {XParameterKey: {value_default, value_type}}
const Schemas = {
	ChartEvent.Types.SetSection: {
		ParameterKey.SECTION_ID: {"default": 0, "type": TYPE_INT}
	}
}

static func setParam(event: ChartEvent, key: ParameterKey, value):
	event.eventParams[key] = value

static func getParam(event: ChartEvent, key: ParameterKey):
	if event.eventParams.has(key):
		return event.eventParams[key]
	
	var schema = Schemas.get(event.eventType, {})
	if schema.has(key):
		return schema[key]["default"]
	
	return null
