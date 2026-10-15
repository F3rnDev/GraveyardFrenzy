extends HBoxContainer

class_name ChartHeaderGroup

@export var editor:ChartEditor

#FileOption
@onready var fileBtn = $File
signal addProject(project:SongProject, path:String)
signal loadProject(path:String)
signal saveProjectAs(path:String)

var loadPath = ""

func setBlackScreen(isVisible):
	editor.blackScreen.visible = isVisible
