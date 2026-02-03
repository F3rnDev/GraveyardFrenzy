extends Node2D

#debug control
@export var debugStageData:StageData
@export var debug:bool = false

var stageData:StageData

#ground
var groundOffset := 0.0
@export var groundSpeed := 5.0

# Called when the node enters the scene tree for the first time.
func _ready():
	if debug:
		stageData = debugStageData
		setStage()

func _process(delta):
	groundOffset += groundSpeed * delta
	$ground/groundTexture.material.set_shader_parameter("offset", groundOffset)

func setStage():
	if stageData.background != null:
		$bgTexture.texture = stageData.background
	
	if stageData.ground != null:
		$ground/groundTexture.texture = stageData.ground

func getStage(_stageKey): #this func will get the stage file and load. MAKE A STAGE FILE SYSTEM
	pass
