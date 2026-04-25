extends Control

#Screens
@onready var startScreen = $StartScreen

#Conductor
@onready var conductor = $Conductor
@onready var conductorSong = $Conductor/Song

#NoteSystem
@onready var gridInfo = $ChartControl/GridInfo
@onready var noteGrid = $ChartControl/NoteGrid
@onready var eventGrid = $ChartControl/EventGrid
@onready var rendElements = $ChartControl/RenderedElements
@onready var chartSelector = $ChartControl/ChartSelectorArea
@onready var strumBar = $ChartControl/StrumBar

#SongControl
@onready var songTimeLabel = $SongControl/SongTime
@onready var diffSelector = $SongControl/Info/DifficultySelector
@onready var chartBpm = $SongControl/Info/ChartBpm
@onready var songPlayBtn = $SongControl/ControlButtons/PlaySong

var songProject:SongProject = SongProject.new()
var curDiff = "normal"
var songPath:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startScreen.visible = true

func _process(delta: float) -> void:
	if songTimeLabel.curTime != conductor.songPos:
		songTimeLabel.updateCurTime(conductor.songPos)
	
	if conductorSong.playing != songPlayBtn.playing:
		songPlayBtn.setPlaying(conductorSong.playing)
		songPlayBtn.set_pressed_no_signal(conductorSong.playing)

#Save/Load Project and Chart
func loadProject():
	startScreen.visible = false
	
	conductor.NewSetSong(songProject.commonAudio)
	conductor.setBpm(songProject.data.baseBpm)
	
	noteGrid.setGrid()
	eventGrid.setGrid()
	chartSelector.active = true
	
	loadChart(0)
	
	songTimeLabel.updateSongLen(conductor.songLength)
	diffSelector.setOptions(songProject.data.availableDiffs)
	chartBpm.setUIBpm(conductor.bpm)

func saveProject():
	SongLoader.saveSong(songPath, songProject)

func loadChart(diffID:int):
	curDiff = songProject.data.availableDiffs[diffID]
	rendElements.loadChart(songProject.charts[curDiff])

func saveChart():
	songProject.charts[curDiff] = rendElements.getChart()

#Input
func _input(event: InputEvent) -> void:
	#ChangeChartPos based on scroll
	if Input.is_action_just_pressed("WheelUp"):
		moveChart(1.0)
	elif Input.is_action_just_pressed("WheelDown"):
		moveChart(-1.0)
	
	keyShortcuts()

#Shortcut
func keyShortcuts():
	if Input.is_action_just_pressed("SaveChart"):
		saveChart()
		saveProject()

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
	
	loadProject()

func _on_start_screen_load_project(path: String) -> void:
	songProject = SongLoader.loadSongProject(path)
	songPath = path
	
	loadProject()

# SongButtons
func _on_play_song_toggled(toggled_on: bool) -> void:
	if toggled_on:
		conductor.playSong(false)
	else:
		conductor.pauseSong()

func _on_skip_to_start_button_down() -> void:
	conductor.pauseSong()
	conductor.songPos = 0.0

func _on_skip_to_end_button_down() -> void:
	conductor.pauseSong()
	conductor.songPos = conductor.songLength

func _on_previous_section_button_down() -> void:
	conductor.pauseSong()
	var curStep = conductor.songPos / conductor.stepCrochet
	
	var previousSection = floor((curStep - 0.1) / 16)
	var targetStep = max(0, previousSection * 16)
	
	conductor.songPos = targetStep * conductor.stepCrochet

func _on_next_section_button_down() -> void:
	conductor.pauseSong()
	var curStep = conductor.songPos / conductor.stepCrochet
	var finalStep = conductor.songLength / conductor.stepCrochet
	
	var nextSection = floor(curStep / 16) + 1
	var targetStep = min(finalStep, nextSection * 16)
	
	conductor.songPos = targetStep * conductor.stepCrochet

#Select new difficulty
func _on_difficulty_selector_item_selected(index: int) -> void:
	saveChart()
	loadChart(index)

#Set new BPM
func _on_chart_bpm_value_changed(value: float) -> void:
	conductor.setBpm(value)
	songProject.data.baseBpm = value

#ResizeChart
#func _on_song_progress_handle_resize(newVisibleTime: float) -> void:
	#gridInfo.stepSize = newVisibleTime
