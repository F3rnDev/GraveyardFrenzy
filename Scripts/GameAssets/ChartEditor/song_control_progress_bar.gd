extends ColorRect

@export var conductor:Conductor
@export var rendElements:ChartUIRenderedObjects

@export var objMinWidth:float = 2.0
@export var objHeight:float = 8.0
@export var lanes:float = 3.0

@onready var noteMesh = $noteMesh
@onready var obsMesh = $obstacleMesh
@onready var eventMesh = $eventMesh

func _ready() -> void:
	rendElements.chartChanged.connect(updateMinimap)

func updateMinimap():
	if not conductor or not rendElements or not rendElements.renderedChart:
		return
	
	if conductor.songLength <= 0.0:
		return
	
	var sizeXFactor = size.x / conductor.songLength
	var laneFactor = size.y / lanes
	
	var notesData = []
	var obsData = []
	var eventsData = []
	for element in rendElements.renderedChart.elements:
		if element is ChartNote:
			notesData.append(element)
		else:
			obsData.append(element)
	for event in rendElements.renderedChart.events:
		eventsData.append(event)
	
	setMultimesh(noteMesh.multimesh, notesData, sizeXFactor, laneFactor, Color.RED)
	setMultimesh(obsMesh.multimesh, obsData, sizeXFactor, laneFactor, Color.WHITE)
	setMultimesh(eventMesh.multimesh, eventsData, sizeXFactor, laneFactor, Color.RED)

func setMultimesh(mm:MultiMesh, objects:Array, sizeXFactor:float, laneFactor:float, baseColor:Color):
	mm.instance_count = objects.size()
	
	for id in range(objects.size()):
		#GetValues
		var object = objects[id]
		var pos = object.position
		var lane = object.lane if "lane" in object else 2
		var duration = object.holdAmount if "holdAmount" in object else 0.0
		
		#GetPositions
		var xPos = pos * sizeXFactor
		var yPos = (lane * laneFactor) + (objHeight / 2.0)
		var xWidth = max(objMinWidth, duration * sizeXFactor)
		
		xPos += xWidth / 2.0
		
		#CreateTransform
		var transform = Transform2D()
		transform = transform.scaled(Vector2(xWidth, objHeight))
		transform.origin = Vector2(xPos, yPos)
		
		#SetMultimesh
		mm.set_instance_transform_2d(id, transform)
		mm.set_instance_color(id, baseColor)
