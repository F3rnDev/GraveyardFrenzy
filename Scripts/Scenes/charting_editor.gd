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
	
	if strumBar.isMouseDragging:
		strumBar.dragChart(delta)
	
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

#Drag Strum Bar
func _on_strum_bar_started_grab() -> void:
	if strumBar.isMouseDragging:
		conductorSong.stop()

func _on_strum_bar_move_grab(direction: Variant) -> void:
	var curStep = floor(conductor.songPos / conductor.stepCrochet)
	curStep += direction
		
	conductor.songPos = curStep * conductor.stepCrochet
