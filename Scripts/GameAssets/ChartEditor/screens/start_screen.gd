extends Control

@onready var startWindow = $StartWindow
@onready var newChartWindow = preload("res://Nodes/GameAssets/ChartEditor/Screens/new_chart.tscn")

@onready var createNewPath = $StartWindow/WindowContent/WindowDivision/RightSide/Buttons/CreateNew/CreateNewPath
@onready var loadChartPath = $StartWindow/WindowContent/WindowDivision/RightSide/Buttons/LoadChart/LoadChartPath

var loadPath = ""

signal addProject(project:SongProject, path:String)
signal loadProject(path:String)


# Load the chart listing here btw
func _ready() -> void:
	startWindow.visible = true

func showWindow():
	startWindow.animations.play("appear")

#NEW PROJECT
func showNewProjectWindow():
	startWindow.animations.play("disappear")
	
	var newChartInstance = newChartWindow.instantiate()
	newChartInstance.cancelled.connect(showWindow)
	newChartInstance.created.connect(createNewProject)
	add_child(newChartInstance)

func createNewProject(project:SongProject):
	addProject.emit(project, loadPath)

func _on_create_new_button_down() -> void:
	createNewPath.visible = true

func _on_create_new_path_dir_selected(dir: String) -> void:
	loadPath = dir
	showNewProjectWindow()

#LOAD PROJECT
func _on_load_chart_button_down() -> void:
	loadChartPath.visible = true

func _on_load_chart_path_file_selected(path: String) -> void:
	loadProject.emit(path)
