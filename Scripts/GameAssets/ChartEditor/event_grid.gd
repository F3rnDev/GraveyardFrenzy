extends HBoxContainer

class_name EventGridUI

#Step
var gridStep = preload("res://Nodes/GameAssets/ChartEditor/event_grid_step.tscn")

@onready var initPos = global_position.x

#Dependencies
@export var conductor:Conductor
@export var gridInfo:GridInfo

#Signals
signal previewEventAdd(pos:Vector2)
signal previewEventRemove()
signal addEvent(pos:Vector2)

func _process(delta: float) -> void:
	setGridPos()

func clearGrid():
	for step in get_children():
		step.queue_free()

func setGrid():
	clearGrid()
	
	var allSteps = floor((conductor.songLength) / conductor.stepCrochet)
	
	for step in allSteps:
		var gridStepInstance:EventGridStep = gridStep.instantiate()
		add_child(gridStepInstance)
		
		gridStepInstance.btnEntered.connect(enteredButton)
		gridStepInstance.btnExited.connect(exitedButton)
		gridStepInstance.btnPressed.connect(pressedButton)

func setGridPos():
	var xPos = ((conductor.songPos / conductor.stepCrochet) * (gridInfo.stepSize))
	
	global_position.x = (xPos * gridInfo.gridDir) + initPos

func enteredButton(pos:Vector2):
	previewEventAdd.emit(pos)

func exitedButton():
	previewEventRemove.emit()

func pressedButton(pos:Vector2):
	addEvent.emit(pos)
