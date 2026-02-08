extends TextureRect

#ground
var groundOffset := 0.0
@export var groundSpeed := 5.0

func _ready() -> void:
	groundOffset = material.get_shader_parameter("offset")

func _process(delta):
	groundOffset += groundSpeed * delta
	material.set_shader_parameter("offset", groundOffset)
