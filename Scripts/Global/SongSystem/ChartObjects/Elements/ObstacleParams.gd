class_name ObstacleParams

#No parameters, for now lol

#PUT NEW PARAMETERS IN THE KEY ENUM
#USE CTRL+SHIFT+F IF A PARAMETER HAS TO BE CHANGED (BE CAREFULL!!!)
enum ParameterKey {}

#TO SET A NEW SCHEMA, FOLLOW THE FOLLOWING STANDARD:
#	XEventType: {XParameterKey: {value_default, value_type}}
const Schemas = {}

static func setParam(obstacle: ChartObstacle, key: ParameterKey, value):
	obstacle.obstacleParams[key] = value

static func getParam(obstacle: ChartObstacle, key: ParameterKey):
	if obstacle.obstacleParams.has(key):
		return obstacle.obstacleParams[key]
	
	var schema = Schemas.get(obstacle.obstacleType, {})
	if schema.has(key):
		return schema[key]["default"]
	
	return null
