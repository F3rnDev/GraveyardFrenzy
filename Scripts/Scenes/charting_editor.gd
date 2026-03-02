extends Control

@onready var conductor = $Conductor
@onready var conductorSong = $Conductor/Song
@onready var noteGrid = $NoteGrp/NoteGrid
@onready var strumBar = $NoteGrp/StrumBar

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

func _input(event: InputEvent) -> void:
	#ChangeChartPos based on scroll
	if Input.is_action_just_pressed("WheelUp"):
		moveChart(1.0)
	elif Input.is_action_just_pressed("WheelDown"):
		moveChart(-1.0)
	
	#Change to a button
	if Input.is_action_just_pressed("Confirm"):
		conductor.playSong(false)

#reset position if the song position is out of bounds
func canMoveChart(newPos:float) -> bool:
	if newPos < 0 or newPos >= conductorSong.stream.get_length():
		return false
	
	return true

#Drag Strum Bar
func moveChart(direction):
	var curStep = floor(conductor.songPos / conductor.stepCrochet)
	curStep += direction
	
	var newPos = curStep * conductor.stepCrochet
	if !canMoveChart(newPos):
		return
	
	conductor.songPos = newPos

func _on_strum_bar_started_grab() -> void:
	if strumBar.isMouseDragging:
		conductorSong.stop()

func _on_strum_bar_move_grab(direction: Variant) -> void:
	moveChart(direction)

#Beat animations
func _on_conductor_beat_hit(position: Variant) -> void:
	pass
