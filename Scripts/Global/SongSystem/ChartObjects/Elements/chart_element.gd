extends ChartObject

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
var lane:Lanes = Lanes.LaneUp

func getDict():
	var dict = super.getDict()
	
	dict["elementType"] = elementType
	dict["lane"] = lane
	
	return dict

func setNode(dict:Dictionary):
	super.setNode(dict)
	
	elementType = dict["elementType"]
	lane = dict["lane"]
