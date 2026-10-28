extends Node2D

@export_category("Dependencies")
@export var gameplay:GameplayScene

@onready var noteObj = preload("res://Nodes/GameAssets/Gameplay/NoteSystem/note.tscn")
@onready var obstacleObj = preload("res://Nodes/GameAssets/Gameplay/NoteSystem/obstacle.tscn")

var chartRef:Chart = null
var unspawnElements:Array[ChartElement] = []

var spawnLaneYPosition:Array[float] = []

@export_category("Variables")
@export var spawnSecondLimit:float = 5.0

func setChartToRender(chart:Chart):
	chartRef = chart
	
	for element in chartRef.elements:
		unspawnElements.append(element)
	
	unspawnElements.sort_custom(func(a, b):
		return a.position < b.position
	)
	
	updateLanePositions()

func updateLanePositions():
	spawnLaneYPosition = [
		gameplay.noteStrum.position.y,
		gameplay.noteStrum.getStrumDownYPosLocal()
	]

func _physics_process(_delta: float) -> void:
	if chartRef == null or unspawnElements.is_empty():
		return
	
	renderElements()

func renderElements():
	var curSongTime = gameplay.conductor.songPos
	
	while not unspawnElements.is_empty():
		var element:ChartElement = unspawnElements[0]
		
		if element.position - curSongTime <= spawnSecondLimit:
			unspawnElements.pop_front()
			spawnElement(element)
		else:
			break

func spawnElement(element:ChartElement):
	var instance:GameElement
	
	var xPos = gameplay.getObjectPos(element.position)
	var yPos = spawnLaneYPosition[element.lane]
	
	if element is ChartNote:
		instance = noteObj.instantiate()
	elif element is ChartObstacle:
		instance = obstacleObj.instantiate()
		yPos += 10.0 #Put it on the ground
		instance.setObstacleType("cactus")
	
	instance.setup(gameplay, element, xPos, yPos, 1.0, gameplay.noteStrum.position.x)
	gameplay.renderedElements.addElement(instance)
