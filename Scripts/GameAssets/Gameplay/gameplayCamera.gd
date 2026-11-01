extends Camera2D

#Different type of shakes
enum ShakeTypes
{
	DAMAGE,
	NOTEHIT
}

var shakeType = ShakeTypes.DAMAGE

#DAMAGE SHAKE
@export var rngStr:float = 20.0
@export var shakeFade:float = 5.0

#NOTEHIT SHAKE
var maxNoteShake := 6.0

var rng = RandomNumberGenerator.new()
var shakeStr = 0.0

var zoomTween:Tween = null

func shake(type = ShakeTypes.DAMAGE, customFade = 5.0, customRngStr = 20.0):
	shakeType = type
	shakeFade = customFade
	
	match shakeType:
		ShakeTypes.DAMAGE:
			rngStr = customRngStr
			shakeStr = rngStr
		ShakeTypes.NOTEHIT:
			shakeStr = min(shakeStr + customRngStr, maxNoteShake)

func zoomCamera(zoomVal:Vector2 = Vector2(1.01, 1.01), animDur:float = 0.2):
	if zoomTween != null and (!zoomTween.finished or zoomVal == zoom):
		return
	
	zoomTween = create_tween()
	zoomTween.tween_property(self, "zoom", zoomVal, animDur)

func _process(delta):
	if shakeStr > 0:
		shakeStr = lerpf(shakeStr, 0, shakeFade * delta)
		offset = randomOffset()

func randomOffset() -> Vector2:
	if shakeType == ShakeTypes.NOTEHIT:
		return Vector2(0, rng.randf_range(-shakeStr, shakeStr))
	
	return Vector2(rng.randf_range(-shakeStr, shakeStr), rng.randf_range(-shakeStr, shakeStr))
	
