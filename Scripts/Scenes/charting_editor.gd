extends Control

#Screens
@onready var startScreen = $StartScreen

@onready var conductor = $Conductor
@onready var conductorSong = $Conductor/Song
@onready var noteGrid = $NoteGrp/NoteGrid
@onready var strumBar = $NoteGrp/StrumBar
@onready var rendElements = $NoteGrp/RenderedElements

var songProject:SongProject = SongProject.new()
var songPath:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startScreen.visible = true

#Get Path after selecting the song
func loadChart():
	startScreen.visible = false
	
	conductor.NewSetSong(songProject.commonAudio)
	conductor.setBpm(songProject.data.baseBpm)
	
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
	if newPos < 0 or newPos >= conductor.songLength:
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

#Load/Add Project
func _on_start_screen_add_project(project: SongProject, path: String) -> void:
	SongLoader.saveSong(path, project)
	songProject = project
	songPath = path
	
	loadChart()

func _on_start_screen_load_project(path: String) -> void:
	songProject = SongLoader.loadSongProject(path)
	songPath = path
	
	loadChart()

# NoteControl
func _on_note_grid_add_note(pos: Vector2) -> void:
	rendElements.addNote(pos)
