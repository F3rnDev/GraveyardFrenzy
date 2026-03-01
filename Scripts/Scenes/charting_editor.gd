extends Control

@onready var conductor = $Conductor
@onready var conductorSong = $Conductor/Song
@onready var noteGrid = $NoteGrp/NoteGrid
@onready var strumBar = $NoteGrp/StrumBar

#Drag Strum bar
var isMouseDragging = false
var dragStartMousePos = 0.0
var dragAmnt = 0.0
var mousePos

@export_category("Drag")
@export var mouseDragDistanceRight = 500.0
@export var mouseDragDistanceLeft = 500.0
@export var minDragInterval = 0.05
@export var maxDragInterval = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadChart()

#Get Path after selecting the song
func loadChart(path:String = "res://Assets/Audio/Songs/Tutorial/Tutorial"):
	conductor.setSong(path)
	conductor.setBpm(120)
	
	noteGrid.setGrid(conductor)

func _process(delta: float) -> void:
	noteGrid.setGridPos(conductor)
	
	if isMouseDragging:
		dragChart(delta)
	
	resetSongPos()

func _input(event: InputEvent) -> void:
	#Change to a button
	if Input.is_action_just_pressed("Confirm"):
		conductor.playSong(false)

#reset position if the song position is out of bounds
func resetSongPos():
	if conductor.songPos < 0:
		conductor.songPos = 0

	if conductor.songPos >= conductorSong.stream.get_length():
		conductor.songPos = conductorSong.stream.get_length()

#DRAG Chart
func dragChart(delta):
	#GetPos and direction
	var mousePos = floor((get_global_mouse_position().x - dragStartMousePos))
	var dragDir = sign(mousePos)
	
	#GetDragInterval
	var curDragDistance = mouseDragDistanceRight
	if dragDir == -1:
		curDragDistance = mouseDragDistanceLeft
	
	var t = clamp(abs(mousePos) / curDragDistance, 0.0, 1.0)
	var dragInterval = lerp(maxDragInterval, minDragInterval, t)
	
	#UpdateDrag
	dragAmnt += delta
	
	if dragAmnt >= dragInterval:
		dragAmnt = 0.0
		
		var curStep = floor(conductor.songPos / conductor.stepCrochet)
		curStep += dragDir
		
		conductor.songPos = curStep * conductor.stepCrochet

func _on_strum_bar_mouse_drag(isDragging: Variant) -> void:
	isMouseDragging = isDragging
	if isMouseDragging:
		dragStartMousePos = get_global_mouse_position().x
		conductorSong.stop()
