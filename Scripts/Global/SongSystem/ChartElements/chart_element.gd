class_name ChartElement

enum Lanes
{
	LaneUp,
	LaneDown
}

enum Types
{
	Note,
	Obs
}

var elementType:Types = Types.Note
var position:float = 0.0
var lane:Lanes = Lanes.LaneUp

func getDict():
	return {
		"elementType": elementType,
		"position": position,
		"lane": lane
	}

func setNode(dict:Dictionary):
	elementType = dict["elementType"]
	position = dict["position"]
	lane = dict["lane"]
