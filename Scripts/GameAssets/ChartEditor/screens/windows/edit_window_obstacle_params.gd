extends EditWindowParams

func setParams(Objects:Array):
	super.setParams(Objects)
	
	if objectsRef.is_empty():
		return
	
	visible = true
	var obsType = objectsRef[0].obstacleType
	
	match obsType:
		ChartObstacle.ObsTypes.Cactus:
			visible = false
