extends Node2D

#debug control
@export var debugStageData:StageData
@export var debug:bool = false

var stageData:StageData

# Called when the node enters the scene tree for the first time.
func _ready():
	if debug:
		stageData = debugStageData
		setStage()
	
	print($bgTexture.texture)

func setStage():
	if stageData.background != null:
		$bgTexture.texture = stageData.background
	
	if stageData.ground != null:
		$ground/groundTexture.texture = stageData.ground

func getStage(stageKey): #this func will get the stage file and load. MAKE A STAGE FILE SYSTEM
	pass
