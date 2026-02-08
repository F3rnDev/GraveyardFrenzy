extends TextureProgressBar

@onready var skeletonSpr = $skeleton
@onready var bopAnim = $AnimationPlayer

@onready var startPos = $skeleton.position
@onready var endPos = $flag.position

# Called when the node enters the scene tree for the first time.
func setSongTime(maxTime):
	max_value = maxTime
	
func updateSongTime(time):
	value = time
	
	var progress = value/max_value
	skeletonSpr.position = startPos.lerp(endPos, progress)

func playBob():
	bopAnim.stop()
	bopAnim.play("normalBop")
