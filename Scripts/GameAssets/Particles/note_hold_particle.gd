extends GPUParticles2D

@export var normalTex:Texture
@export var perfectTex:Texture

func setTexture(isPerfect:bool = false):
	texture = perfectTex if isPerfect else normalTex
	
	$AnimatedSprite2D.modulate = Color.RED if isPerfect else Color.WHITE
