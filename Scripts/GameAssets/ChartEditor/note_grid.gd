extends HBoxContainer

@onready var gridStep = preload("res://Nodes/GameAssets/Chart_Editor/note_grid_step.tscn")

@export var stepSize:float = 80.0
@export var gridDir:float = -1.0

var stepSeparation:float = 2.0

func _ready() -> void:
	stepSeparation = get_theme_constant("separation")

func setGrid(cond:Conductor):
	var allSteps = floor((cond.songLength) / cond.stepCrochet)
	
	for step in allSteps:
		var gridStepInstance = gridStep.instantiate()
		add_child(gridStepInstance)

func setGridPos(cond:Conductor):
	var xPos = ((cond.songPos / cond.stepCrochet) * (stepSize+stepSeparation))
	
	position.x = xPos * gridDir
