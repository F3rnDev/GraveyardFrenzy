extends Control

@onready var conductor = $Conductor
@onready var noteGrid = $NoteGrid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadSong()
	noteGrid.setGrid(conductor)

func _process(delta: float) -> void:
	noteGrid.setGridPos(conductor)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Confirm"):
		conductor.playSong(false)

func loadSong():
	#Get Path after selecting the song
	var path = "res://Assets/Audio/Songs/Tutorial/Tutorial"
	
	conductor.setSong(path)
	conductor.setBpm(120)
