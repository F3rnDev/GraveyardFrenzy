class_name ObstacleParams

#No parameters, for now lol

#PUT NEW PARAMETERS IN THE KEY ENUM
#USE CTRL+SHIFT+F IF A PARAMETER HAS TO BE CHANGED (BE CAREFULL!!!)
enum ParameterKey {}

#TO SET A NEW SCHEMA, FOLLOW THE FOLLOWING STANDARD:
#	XObstacleType: {XParameterKey: {value_default, value_type}}
const Schemas = {}

static func setParam(obstacle: ChartObstacle, key: ParameterKey, value):
	var dictKey = ParameterKey.keys()[key]
	obstacle.obstacleParams[dictKey] = value

static func getParam(obstacle: ChartObstacle, key: ParameterKey):
	var dictKey = ParameterKey.keys()[key]
	if obstacle.obstacleParams.has(dictKey):
		return obstacle.obstacleParams[dictKey]
	
	var schema = Schemas.get(obstacle.obstacleType, {})
	if schema.has(key):
		return schema[key]["default"]
	
	return null
