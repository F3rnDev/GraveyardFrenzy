extends Button

class_name SongControlButton

@export_file("*.png") var iconNormalPath = "res://Assets/Images/UI Images/ChartEditor/"
@export_file("*.png") var iconHoverPath = "res://Assets/Images/UI Images/ChartEditor/"
var iconNormal:Texture2D
var iconHover:Texture2D

var hovered = false

func _ready() -> void:
	iconNormal = load(iconNormalPath)
	iconHover = load(iconHoverPath)
	
	setIcon()

func setIcon():
	icon = iconNormal if !hovered else iconHover

func _on_mouse_entered() -> void:
	hovered = true
	setIcon()

func _on_mouse_exited() -> void:
	hovered = false
	setIcon()
