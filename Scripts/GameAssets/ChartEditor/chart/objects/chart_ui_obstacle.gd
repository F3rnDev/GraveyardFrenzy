extends ChartUIObject

class_name ChartUIObstacle

@onready var obsData:ChartObstacle = ChartObstacle.new()

func setData(obsDict:Dictionary):
	var obsDataDict = obsData.getDict()
	
	for param in obsDict.keys():
		obsDataDict[param] = obsDict[param]
	
	obsData.setNode(obsDataDict)
	
	updateUI()

func updateUI():
	pass
