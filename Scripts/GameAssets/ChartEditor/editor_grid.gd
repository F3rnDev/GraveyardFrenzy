extends Control

class_name ChartEditorGrid

var initPos:float

#Dependencies
@export_category("Dependencies")
@export var conductor:Conductor
@export var gridInfo:GridInfo

#RenderGrid
var activeSteps:Dictionary = {}
var nodePool: Array = []
var lastSongPos:float = 0.0

func _ready() -> void:
	initPos = global_position.x

func _process(delta: float) -> void:
	if lastSongPos != conductor.songPos:
		lastSongPos = conductor.songPos
		
		setGridPos()
		renderGrid()

func clearGrid():
	for step in get_children():
		step.queue_free()
	
	nodePool.clear()
	activeSteps.clear()

func setGrid():
	clearGrid()
	renderGrid()

func renderGrid():
	var viewportWidth = get_viewport_rect().size.x
	
	var localLeft = -global_position.x - gridInfo.stepSize
	var localRight = -global_position.x + viewportWidth + gridInfo.stepSize
	
	var totalSteps = int(floor((conductor.songLength) / conductor.stepCrochet))
	var firstStep = max(0, int(floor(localLeft / gridInfo.stepSize)))
	var lastStep = min(totalSteps - 1, int(ceil(localRight / gridInfo.stepSize)))
	
	#Recycle
	for stepID in activeSteps.keys():
		if stepID < firstStep or stepID > lastStep:
			recycleGridStep(stepID) 
	
	#Add
	for stepID in range(firstStep, lastStep + 1):
		if stepID not in activeSteps:
			var stepPos = stepID * gridInfo.stepSize
			renderGridStep(stepID, stepPos)

func renderGridStep(stepID:int, stepPos:float):
	pass #Does nothing :D

func recycleGridStep(step):
	var stepNode = activeSteps[step]
	
	if is_instance_valid(stepNode):
		stepNode.visible = false
		nodePool.append(stepNode)
	
	activeSteps.erase(step)

func setGridPos():
	var xPos = ((conductor.songPos / conductor.stepCrochet) * (gridInfo.stepSize))
	
	global_position.x = (xPos * gridInfo.gridDir) + initPos
