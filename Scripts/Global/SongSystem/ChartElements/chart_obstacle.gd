extends ChartElement

class_name ChartObstacle

enum ObsTypes
{
	Cactus
}

var obstacleType:ObsTypes = ObsTypes.Cactus
var obstacleParams:Dictionary = {}

func _init() -> void:
	elementType = Types.Obs

func getDict() -> Dictionary:
	var dict = super.getDict()
	
	dict["obstacleType"] = obstacleType
	dict["obstacleParams"] = obstacleParams
	
	return dict

func setNode(dict:Dictionary):
	super.setNode(dict)
	
	obstacleType = dict["obstacleType"]
	obstacleParams = dict["obstacleParams"]
