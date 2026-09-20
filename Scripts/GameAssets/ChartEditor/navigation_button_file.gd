extends NavigationUIButton

@onready var group = get_parent()
@onready var createNewPath = $CreateNewPath
@onready var openPath = $OpenPath
@onready var saveAs = $SaveAs

@onready var newChartWindow = preload("res://Nodes/GameAssets/ChartEditor/Screens/new_chart.tscn")

#New project
func startNewProject():
	group.setBlackScreen(true)
	createNewPath.visible = true

func showNewProjectWindow():
	group.setBlackScreen(true)
	
	var newChartInstance = newChartWindow.instantiate()
	newChartInstance.cancelled.connect(group.setBlackScreen.bind(false))
	newChartInstance.created.connect(createNewProject.bind(newChartInstance))
	group.editor.add_child(newChartInstance)

func createNewProject(project:SongProject, windowToDelete):
	group.addProject.emit(project, group.loadPath)
	windowToDelete.queue_free()

func _on_create_new_path_dir_selected(dir: String) -> void:
	group.loadPath = dir
	showNewProjectWindow()

func _on_create_new_path_canceled() -> void:
	group.setBlackScreen(false)

#Open Project
func startOpenProject():
	group.setBlackScreen(true)
	openPath.visible = true

func _on_open_path_file_selected(path: String) -> void:
	group.loadProject.emit(path)

func _on_open_path_canceled() -> void:
	group.setBlackScreen(false)

#Save Project
func saveProject():
	group.editor.saveChart()
	group.editor.saveProject()

#Save Project As
func startSaveProjectAs():
	group.setBlackScreen(true)
	saveAs.current_path = group.editor.songPath
	saveAs.visible = true

func _on_save_as_file_selected(path: String) -> void:
	group.setBlackScreen(false)
	
	if !path.contains(".frzp"):
		path += ".frzp"
	
	group.saveProjectAs.emit(path)

func _on_save_as_canceled() -> void:
	group.setBlackScreen(false)
