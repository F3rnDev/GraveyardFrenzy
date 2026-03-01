extends HBoxContainer

@onready var gridStep = preload("res://Nodes/GameAssets/Chart_Editor/note_grid_step.tscn")

@export var stepSize:float = 60.0
@export var gridDir:float = -1.0

var initPos:float

func _ready() -> void:
	initPos = global_position.x

func setGrid(cond:Conductor):
	var allSteps = floor((cond.songLength) / cond.stepCrochet)
	
	for step in allSteps:
		var gridStepInstance = gridStep.instantiate()
		add_child(gridStepInstance)
		
		gridStepInstance.setStep(step)

func setGridPos(cond:Conductor):
	var xPos = ((cond.songPos / cond.stepCrochet) * (stepSize))
	
	global_position.x = (xPos * gridDir) + initPos
