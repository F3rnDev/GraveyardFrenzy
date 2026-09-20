extends ChartEditorGrid

class_name NoteGridUI

@onready var gridStep = preload("res://Nodes/GameAssets/ChartEditor/note_grid_step.tscn")
@onready var gridSeparator = preload("res://Nodes/GameAssets/ChartEditor/note_grid_separator.tscn")

@export var stepMarkerHeight:float = 32.0
@export var stepSpacing:float = 4.0

#GetNote
signal previewNoteAdd(pos:Vector2)
signal previewNoteRemove()

#Add note
signal addNote(pos:Vector2)

func renderGridStep(stepID:int, stepPos:float):
	var gridStepInstance:NoteGridStep
	
	if not nodePool.is_empty():
		gridStepInstance = nodePool.pop_back()
		gridStepInstance.visible = true
	else:
		gridStepInstance = gridStep.instantiate()
		add_child(gridStepInstance)
		
		gridStepInstance.btnEntered.connect(enteredButton)
		gridStepInstance.btnExited.connect(exitedButton)
		gridStepInstance.btnPressed.connect(pressedButton)
	
	gridStepInstance.setStep(stepID, gridInfo.stepSize)
	gridStepInstance.setXPos(stepPos)
	activeSteps[stepID] = gridStepInstance

func enteredButton(pos:Vector2):
	previewNoteAdd.emit(pos)

func exitedButton():
	previewNoteRemove.emit()

func pressedButton(pos:Vector2):
	addNote.emit(pos)
