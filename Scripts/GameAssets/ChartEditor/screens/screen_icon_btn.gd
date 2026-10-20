extends Button

@onready var btnImage = $Icon
@onready var btnText = $Text

@export var newImage:Texture
@export var newText:String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	btnImage.texture = newImage
	btnText.text = newText


func _on_mouse_entered() -> void:
	btnText.modulate = Color.BLACK

func _on_mouse_exited() -> void:
	btnText.modulate = Color.WHITE
