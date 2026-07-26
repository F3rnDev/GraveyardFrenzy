extends Node

@onready var contextWindow = preload("res://Nodes/GameAssets/ChartEditor/Chart/Object Options/objectWindow.tscn")

#IMPORTANT VARIABLES
@onready var rendElements:ChartUIRenderedObjects = get_parent()
@onready var chartEditor = rendElements.chartEditor
@onready var selectedObjects = rendElements.selectedObjects
@onready var copiedObjects = rendElements.copiedObjects
@onready var conductor = rendElements.conductor

#KeyBoard Shortcuts / Additional Inputs
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		shortcuts()
		return
	
	if !chartEditor.blackScreen.visible:
		openContextWindow()

#Context Window
func openContextWindow():
	if !Input.is_action_just_pressed("RightMouseClick"):
		return
	
	var instance:ChartObjectWindow = contextWindow.instantiate()
	instance.selectedOption.connect(selectContextOption)
	chartEditor.add_child(instance)
	
	var inactiveOptions = instance.getInactiveOptions(selectedObjects, copiedObjects)
	for option in inactiveOptions:
		instance.setOption(option, true)

#Shortcuts
func shortcuts():
	var chartID = "Chart"
	#CheckAction
	for optionID in ChartObjectWindow.OPTIONS.values():
		var optionKey = ChartObjectWindow.OPTIONS.keys()[optionID]
		var option = optionKey.capitalize()
		
		if Input.is_action_just_pressed("Chart" + option):
			selectContextOption(optionID)

#ContextMenu (Do different things depending on what was selected)
func selectContextOption(optionID):
	match optionID:
		ChartObjectWindow.OPTIONS.EDIT:
			pass#Open edit info
		ChartObjectWindow.OPTIONS.CUT:
			cutObjects()
		ChartObjectWindow.OPTIONS.COPY:
			copyObjects()
		ChartObjectWindow.OPTIONS.PASTE:
			pasteObjects()
		ChartObjectWindow.OPTIONS.DELETE:
			deleteObjects()
		ChartObjectWindow.OPTIONS.SELECTALL:
			selectAllObjects()

#CONTEXT FUNCTIONS
func cutObjects():
	copyObjects()
	deleteObjects()

func copyObjects():
	if selectedObjects.is_empty():
		return
	
	copiedObjects.clear()
	
	var originData = selectedObjects[0]
	var originTime = originData.position
	for data in selectedObjects:
		if data.position < originTime:
			originTime = data.position
	
	for data in selectedObjects:
		var newData = data.duplicate()
		newData.position = data.position - originTime
		copiedObjects.append(newData)

func pasteObjects():
	if copiedObjects.is_empty():
		return
	
	rendElements.unselectObjects()
	var threadDict = {
		"renderedChart": rendElements.renderedChart,
		"selectedObjects": rendElements.selectedObjects,
		"conductor": rendElements.conductor
	}
	
	rendElements.elementThread.addTask(rendElements.elementThread.setFilledPositions, continuePaste, threadDict)

func continuePaste(result:Dictionary):
	rendElements.filledPositions = result
	
	var step = floor(conductor.songPos / conductor.stepCrochet)
	var pasteOrigin = step * conductor.stepCrochet
	
	for objectData in copiedObjects:
		var finalPos = objectData.position + pasteOrigin
		var lane = 2 if "lane" not in objectData else objectData.lane
		
		#No need to paste, if it is outside the chart
		if finalPos >= conductor.songLength - conductor.stepCrochet:
			#Display an error like message saying (object out of bounds)
			continue
		
		var existing = rendElements.objectColliding(finalPos, lane, objectData)
		if existing != null:
			deleteObjectPaste(existing)
		
		#GetDict
		var newData = objectData.duplicate()
		newData.position = finalPos
		
		if newData is ChartElement:
			rendElements.renderedChart.elements.append(newData)
		elif newData is ChartEvent or newData is ChartEventGroup:
			rendElements.renderedChart.events.append(newData)
		
		rendElements.renderObject(newData, rendElements.CreationType.PASTED)

func deleteObjectPaste(object):
	if object is ChartElement:
		rendElements.renderedChart.elements.erase(object)
	elif object is ChartEvent or object is ChartEventGroup:
		rendElements.renderedChart.events.erase(object)
	
	if object in rendElements.activeObjects:
		var node = rendElements.activeObjects[object]
		node.queue_free()
		
		rendElements.activeObjects.erase(object)

func deleteObjects():
	if selectedObjects.is_empty():
		return
	
	for data in selectedObjects:
		if data is ChartElement:
			rendElements.renderedChart.elements.erase(data)
		elif data is ChartEvent or data is ChartEventGroup:
			rendElements.renderedChart.events.erase(data)
		
		if data in rendElements.activeObjects:
			var node = rendElements.activeObjects[data]
			node.queue_free()
			
			rendElements.activeObjects.erase(data)
	
	selectedObjects.clear()
	
	rendElements.chartChanged.emit()

func selectAllObjects():
	rendElements.unselectObjects()
	
	#Select Notes
	for element in rendElements.renderedChart.elements:
		if element not in selectedObjects:
			selectedObjects.append(element)
		
		if element in rendElements.activeObjects:
			var node = rendElements.activeObjects[element]
			node.setSelected(true)
	
	#Selecct events
	for event in rendElements.renderedChart.events:
		if event not in selectedObjects:
			selectedObjects.append(event)
		
		if event in rendElements.activeObjects:
			var node = rendElements.activeObjects[event]
			node.setSelected(true)
