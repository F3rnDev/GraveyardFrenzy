extends ChartUIObject

class_name ChartUIEventGroup

@onready var eventContainer = $ScrollContainer/EventContainer
@onready var scrollContainer = $ScrollContainer

@onready var chartUIEvent = preload("res://Nodes/GameAssets/ChartEditor/Chart/Objects/chart_ui_event.tscn")

#EventContainer animation
#Cont stands for container
var contInitSize:float
var contAnimTrans:Tween.TransitionType = Tween.TRANS_EXPO
var contAnimDuration = 0.2

#Drag offset
var dragOffset = null
var draggedEvent:ChartUIEvent = null

signal unmerge(event:ChartUIEvent, parent:ChartUIEventGroup)

func _ready() -> void:
	super._ready()
	
	contInitSize = scrollContainer.size.y
	scrollContainer.size.y = 0.0

func _process(delta: float) -> void:
	if draggedEvent != null and canUnmerge():
		unmerge.emit(draggedEvent, self)

func canUnmerge() -> bool:
	var mousePosX = renderedObjectsRef.noteGrid.get_local_mouse_position().x
	var songPos = renderedObjectsRef.getObjectSongPos(mousePosX)
	
	if abs(songPos - dragOffset) >= renderedObjectsRef.conductor.stepCrochet:
		return true
	
	return false

#Draggable stuff
func startDrag():
	super.startDrag()
	
	if !hasMultipleSelection():
		animateEventContainer(false)

func endDrag():
	super.endDrag()
	
	if !hasMultipleSelection():
		animateEventContainer(true)

func getDataType():
	return ChartEventGroup

func hasMultipleSelection() -> bool:
	if renderedObjectsRef != null:
		return renderedObjectsRef.selectedObjects.size() > 1
	return false

func setSelected(selected:bool):
	super.setSelected(selected)
	
	if hasMultipleSelection():
		animateEventContainer(false)
		return
	
	unselectEvents()
	animateEventContainer(selected)

func animateEventContainer(selected:bool):
	var sizeValue = contInitSize if selected else 0.0
	var ease = Tween.EASE_IN if selected else Tween.EASE_OUT
	
	var tween = create_tween()
	tween.set_trans(contAnimTrans)
	tween.set_ease(ease)
	
	tween.tween_property(scrollContainer, "size:y", sizeValue, contAnimDuration)

func updateUI(data:ChartObject, elementsRef:ChartUIRenderedObjects, stepCrochet:float):
	super.updateUI(data, elementsRef, stepCrochet)
	
	refreshItems()

func refreshItems():
	cleanItems()
	
	for event in refData.linkedEvents:
		addItem(event)

func cleanItems():
	for event in eventContainer.get_children():
		event.queue_free()

func addItem(event):
	var instance:ChartUIEvent = chartUIEvent.instantiate()
	instance.selected.connect(selectEvent)
	instance.startDragging.connect(startEventDrag)
	instance.endDragging.connect(endEventDrag)
	
	eventContainer.add_child(instance)
	instance.updateUI(event, renderedObjectsRef, step)

#CHILD CONTROL
func unselectEvents():
	for eventUI in eventContainer.get_children():
		eventUI.setSelected(false)

func selectEvent(object:ChartUIObject):
	unselectEvents()
	
	#DONT ALLOW SELECTING IF YOU'RE DRAGGING MULTIPLE NODES
	if hasMultipleSelection():
		return
	
	object.setSelected(true)

func startEventDrag(object:ChartUIObject):
	draggedEvent = object
	
	var mousePosX = renderedObjectsRef.noteGrid.get_local_mouse_position().x
	dragOffset = renderedObjectsRef.getObjectSongPos(mousePosX)

func endEventDrag():
	draggedEvent = null
	dragOffset = null

#func startDragEvent
#if mouse has its value greater than the limits, unmerge :D (Create signal later)
