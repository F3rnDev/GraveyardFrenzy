extends Camera2D

@export var rngStr:float = 20.0
@export var shakeFade:float = 5.0

var rng = RandomNumberGenerator.new()

var shakeStr = 0.0

func shake():
	shakeStr = rngStr

func _process(delta):
	if shakeStr > 0:
		shakeStr = lerpf(shakeStr, 0, shakeFade * delta)
		offset = randomOffset()

func randomOffset() -> Vector2:
	return Vector2(rng.randf_range(-shakeStr, shakeStr), rng.randf_range(-shakeStr, shakeStr))
	
