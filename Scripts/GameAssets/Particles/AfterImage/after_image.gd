extends Sprite2D

class_name AfterImage

var fadeTime:float = 0.2
var fadeColor:Color = Color.WHITE

func setProperties(pos:Vector2, curScale:Vector2, time:float=fadeTime, initialColor:Color=Color.WHITE, fadeToColor:Color=fadeColor, flipH:bool=false, flipV:bool=false):
	global_position = pos
	scale = curScale
	flip_h = flipH
	flip_v = flipV
	
	modulate = initialColor
	
	fadeTime = time
	fadeColor = fadeToColor

func setImage(tex:Texture):
	texture = tex
	fadeImage()

func fadeImage():
	var fadeTween:Tween = create_tween().set_parallel()
	fadeTween.tween_property(self, "self_modulate:a", 0.0, fadeTime)
	fadeTween.tween_property(self, "modulate", fadeColor, fadeTime/2)
	fadeTween.finished.connect(queue_free)
