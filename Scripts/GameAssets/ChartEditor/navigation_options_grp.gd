extends HBoxContainer

@export var editor:Control

#FileOption
@onready var fileBtn = $File
signal addProject(project:SongProject, path:String)
signal loadProject(path:String)
signal saveProjectAs(path:String)

var loadPath = ""

func setBlackScreen(isVisible):
	editor.blackScreen.visible = isVisible

#File
func _on_file_selected(id: Variant) -> void:
	match id:
		0: #Create new
			fileBtn.startNewProject()
		1: #Open project
			fileBtn.startOpenProject()
		2: #Save project
			fileBtn.saveProject()
		3: #Save project as
			fileBtn.startSaveProjectAs()
