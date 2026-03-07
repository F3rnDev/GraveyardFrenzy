extends HBoxContainer

@onready var gridStep = preload("res://Nodes/GameAssets/ChartEditor/note_grid_step.tscn")
@onready var gridSeparator = preload("res://Nodes/GameAssets/ChartEditor/note_grid_separator.tscn")

@export var stepSize:float = 60.0
@export var gridDir:float = -1.0

var initPos:float

#GetNote
signal previewNoteAdd(pos:Vector2)
signal previewNoteRemove()

func _ready() -> void:
	initPos = global_position.x

func setGrid(cond:Conductor):
	var allSteps = floor((cond.songLength) / cond.stepCrochet)
	
	for step in allSteps:
		var gridStepInstance:NoteGridStep = gridStep.instantiate()
		add_child(gridStepInstance)
		
		gridStepInstance.btnEntered.connect(enteredButton)
		gridStepInstance.btnExited.connect(exitedButton)
		gridStepInstance.setStep(step)

func setGridPos(cond:Conductor):
	var xPos = ((cond.songPos / cond.stepCrochet) * (stepSize))
	
	global_position.x = (xPos * gridDir) + initPos

func enteredButton(pos:Vector2):
	previewNoteAdd.emit(pos)

func exitedButton():
	previewNoteRemove.emit()
