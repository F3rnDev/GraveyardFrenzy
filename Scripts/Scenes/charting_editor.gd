extends Control

class_name ChartEditor

#Screens
@onready var blackScreen = $BlackScreen
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
@onready var chartBpm = $ChartControl/BpmAndTimeSignature/ChartBpm
@onready var songPlayBtn = $SongControl/ControlButtons/PlaySong

#Header
@onready var headerWindow = $EditorHeader/Options/Window

#Windows
@onready var windowGrp = $WindowGrp
var activeWindows:Dictionary = {}

@onready var editWindow = preload("res://Nodes/GameAssets/ChartEditor/Screens/Windows/edit_window.tscn")
@onready var songDataWindow = preload("res://Nodes/GameAssets/ChartEditor/Screens/Windows/song_data_window.tscn")
@onready var audioWindow = preload("res://Nodes/GameAssets/ChartEditor/Screens/Windows/audio_window.tscn")

var songProject:SongProject = SongProject.new()
var curDiff = "normal"
var songPath:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	startScreen.visible = true
	blackScreen.visible = true

func _process(delta: float) -> void:
	if songTimeLabel.curTime != conductor.songPos:
		songTimeLabel.updateCurTime(conductor.songPos)
	
	if conductorSong.playing != songPlayBtn.playing:
		songPlayBtn.setPlaying(conductorSong.playing)
		songPlayBtn.set_pressed_no_signal(conductorSong.playing)

#Save/Load Project and Chart
func newProject(project: SongProject, path: String) -> void:
	SongLoader.saveSong(path, project)
	songProject = project
	songPath = path
	
	loadProject()

func openProject(path: String) -> void:
	songProject = SongLoader.loadSongProject(path)
	songPath = path
	
	loadProject()

func saveProjectAs(path:String) -> void:
	saveChart()
	
	SongLoader.saveSong(path, songProject)
	songPath = path
	
	rendElements.loadChart()

func loadProject():
	rendElements.unselectObjects()
	startScreen.visible = false
	blackScreen.visible = false
	
	conductor.NewSetSong(songProject.commonAudio)
	conductor.setBpm(songProject.data.baseBpm)
	conductor.songPos = 0.0
	
	noteGrid.renderGrid()
	eventGrid.renderGrid()
	chartSelector.active = true
	
	loadChart(0)
	
	songTimeLabel.updateSongLen(conductor.songLength)
	diffSelector.setOptions(songProject.data.availableDiffs)
	chartBpm.setUIBpm(conductor.bpm)

func saveProject():
	SongLoader.saveSong(songPath, songProject)
	rendElements.loadChart()

func loadChart(diffID:int):
	curDiff = songProject.data.availableDiffs[diffID]
	rendElements.setChart(songProject.charts[curDiff])

func saveChart():
	songProject.charts[curDiff] = rendElements.getChart()

#Input
func _input(event: InputEvent) -> void:
	#ChangeChartPos based on scroll
	if Input.is_action_just_pressed("WheelUp"):
		moveChart(1.0)
	elif Input.is_action_just_pressed("WheelDown"):
		moveChart(-1.0)

#reset position if the song position is out of bounds
func canMoveChart(newPos:float) -> bool:
	if newPos < 0 or newPos >= conductor.songLength:
		return false
	
	return true

#Drag Strum Bar
func moveChart(direction):
	var curStep = int(round(conductor.songPos / conductor.stepCrochet))
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

#Set new Bpm
func setNewBpm(value:int):
	songProject.data.baseBpm = value
	conductor.setBpm(value)
	chartBpm.setUIBpm(value)
	rendElements.reloadChart()
	
	noteGrid.renderGrid()
	eventGrid.renderGrid()

#ResizeChart
#func _on_song_progress_handle_resize(newVisibleTime: float) -> void:
	#gridInfo.stepSize = newVisibleTime

#Windows
func openWindow(window):
	#Check if in active windows
	if window in activeWindows:
		headerWindow.setCheckedItems(activeWindows)
		return
	
	var windowInstance:ChartEditorWindow = window.instantiate()
	windowGrp.add_child(windowInstance)
	
	windowInstance.close.connect(removeWindow.bind(window))
	activeWindows[window] = windowInstance
	
	headerWindow.setCheckedItems(activeWindows)
	
	#Set the data:
	if windowInstance.contentRef is EditWindow:
		setEditWindowInfo(windowInstance.contentRef)
	elif windowInstance.contentRef is SongDataWindow:
		setSongDataWindowInfo(windowInstance.contentRef)
	elif windowInstance.contentRef is AudioWindow:
		setAudioWindowInfo(windowInstance.contentRef)

func closeWindow(window):
	if window not in activeWindows:
		return
	
	var windowInstance:ChartEditorWindow = activeWindows[window]
	windowInstance.closeWindow()

func removeWindow(window):
	if window in activeWindows:
		activeWindows.erase(window)
	
	headerWindow.setCheckedItems(activeWindows)

#EditWindow
func setEditWindowInfo(content:EditWindow):
	content.setReference(rendElements.selectedObjects, conductor)
	rendElements.changedSelection.connect(content.setActiveFields)
	content.updatedValue.connect(rendElements.updateActiveObjects)

#SongDataWindow
func setSongDataWindowInfo(content:SongDataWindow):
	content.setFields(songProject.data, self)

#SongAudioWindow
func setAudioWindowInfo(content:AudioWindow):
	content.setAudios(self)

func getElementsOutside(newBytes:PackedByteArray) -> Dictionary:
	if songProject == null:
		return {}
	
	var newStream:AudioStreamMP3 = AudioStreamMP3.new()
	newStream.data = newBytes
	
	var newLength = newStream.get_length()
	
	if newLength >= conductor.songLength:
		return {}
	
	#Get elements outside the chart
	var outsideElements = {}
	
	if songProject.charts.is_empty():
		return {}
	
	for diff in songProject.charts.keys():
		var chart:Chart = songProject.charts[diff]
		var outside:Array = []
		
		for element in chart.elements:
			if element.position >= newLength:
				outside.append(element)
		
		for event in chart.events:
			if event.position >= newLength:
				outside.append(event)
		
		if !outside.is_empty():
			outsideElements[diff] = outside
	
	return outsideElements

func removeElementsOutside(outsideElements:Dictionary):
	if songProject == null:
		return
	
	for diff in outsideElements.keys():
		if not songProject.charts.has(diff):
			continue
		
		var data = songProject.charts[diff]
		var outside = outsideElements[diff]
		
		var lookup = {}
		for item in outside:
			lookup[item] = true
		
		if "elements" in data:
			data.elements = data.elements.filter(func(item): return not lookup.has(item))
		
		if "events" in data:
			data.events = data.events.filter(func(item): return not lookup.has(item))

func updateAudio(newAudioBytes):
	songProject.commonAudio = newAudioBytes
	rendElements.unselectObjects()
	
	#Update info
	conductor.NewSetSong(songProject.commonAudio)
	conductor.songPos = 0.0
	
	noteGrid.renderGrid()
	eventGrid.renderGrid()
	rendElements.reloadChart()
	
	songTimeLabel.updateSongLen(conductor.songLength)

func _on_rendered_elements_open_edit_window() -> void:
	openWindow(editWindow)
