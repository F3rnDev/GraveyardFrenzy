extends Node

@export var rendElements:ChartUIRenderedObjects

var currentTaskId = -1

func addTask(f: Callable, fResult: Callable, params: Dictionary):
	if currentTaskId != -1:
		if not WorkerThreadPool.is_task_completed(currentTaskId):
			return
	
	currentTaskId = WorkerThreadPool.add_task(
		func():
			var result_data = f.call(params)
			fResult.call_deferred(result_data)
	)

func calculateDrag(params:Dictionary):
	var dragOffsetResult:Dictionary = setDragOffsets(params)
	var filledPositionsResult:Dictionary = setFilledPositions(params)
	
	var result:Dictionary = {
		"dragOffsetResult": dragOffsetResult,
		"filledPositionsResult": filledPositionsResult
	}
	
	return result

func setDragOffsets(params:Dictionary) -> Dictionary:
	#Set variables
	var selectedObjects = params["selectedObjects"]
	var updateHold = params["updateHold"]
	var mouseSongPos = params["mouseSongPos"]
	
	var finalDict = {"canDragVertical": true}
	
	var dragOffsets = {}
	var lastLane = null
	for data in selectedObjects:
		var lane = data.lane if "lane" in data else 2
		
		if data is ChartNote and updateHold:
			var noteEnd = data.position + data.holdAmount
			var snappedHold = snapped(noteEnd, params["conductor"].stepCrochet)
			dragOffsets[data] = snappedHold - mouseSongPos
			continue
		
		var snappedObjectPos = snapped(data.position, params["conductor"].stepCrochet)
		dragOffsets[data] = snappedObjectPos - mouseSongPos
		
		if data is ChartEvent:
			continue
		
		if lastLane != lane and lastLane != null:
			finalDict["canDragVertical"] = false
		
		lastLane = lane
	
	finalDict["dragOffsets"] = dragOffsets
	
	return finalDict

func setFilledPositions(params:Dictionary) -> Dictionary:
	#Set variables
	var renderedChart = params["renderedChart"]
	var selectedObjects = params["selectedObjects"]
	var conductor = params["conductor"]
	
	var filledPositions:Dictionary = {}
	
	#Elements
	for element in renderedChart.elements:
		if element in selectedObjects:
			continue
		
		var gridPos = Vector2(element.position, element.lane)
		filledPositions[gridPos] = element
		
		if element is ChartNote and element.holdAmount > 0.0:
			var currentHoldOffset = conductor.stepCrochet
			
			while currentHoldOffset <= element.holdAmount:
				var snappedX = snapped(element.position + currentHoldOffset, conductor.stepCrochet)
				var holdGridPos = Vector2(snappedX, element.lane)
				filledPositions[holdGridPos] = element
				
				currentHoldOffset += conductor.stepCrochet
	
	#Events
	for event in renderedChart.events:
		if event in selectedObjects:
			continue
		
		var gridPos = Vector2(event.position, 2)
		filledPositions[gridPos] = event
	
	return filledPositions
