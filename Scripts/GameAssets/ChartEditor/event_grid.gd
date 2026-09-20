extends ChartEditorGrid

class_name EventGridUI

#Step
var gridStep = preload("res://Nodes/GameAssets/ChartEditor/event_grid_step.tscn")

#Signals
signal previewEventAdd(pos:Vector2)
signal previewEventRemove()
signal addEvent(pos:Vector2)

func renderGridStep(stepID:int, stepPos:float):
	var gridStepInstance:EventGridStep
	
	if not nodePool.is_empty():
		gridStepInstance = nodePool.pop_back()
		gridStepInstance.visible = true
	else:
		gridStepInstance = gridStep.instantiate()
		add_child(gridStepInstance)
		
		gridStepInstance.btnEntered.connect(enteredButton)
		gridStepInstance.btnExited.connect(exitedButton)
		gridStepInstance.btnPressed.connect(pressedButton)
	
	gridStepInstance.setXPos(stepPos)
	activeSteps[stepID] = gridStepInstance

func enteredButton(pos:Vector2):
	previewEventAdd.emit(pos)

func exitedButton():
	previewEventRemove.emit()

func pressedButton(pos:Vector2):
	addEvent.emit(pos)
