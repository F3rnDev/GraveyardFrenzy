extends TextureRect

#ground
var groundOffset := 0.0
@export var groundSpeed := 5.0

func _process(delta):
	groundOffset += groundSpeed * delta
	material.set_shader_parameter("offset", groundOffset)
