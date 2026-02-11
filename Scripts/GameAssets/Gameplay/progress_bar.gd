extends TextureProgressBar

@onready var skeletonSpr = $skeleton
@onready var bopAnim = $AnimationPlayer

@onready var startPos = $skeleton.position
@onready var endPos = $flag.position

@onready var accuracyLbl = $Stats/Accuracy/accValue
@onready var missLbl = $Stats/Misses/missValue

func _ready() -> void:
	setSongUIData(100.0, 0)

func setSongTime(maxTime):
	max_value = maxTime
	
func updateSongTime(time):
	value = time
	
	var progress = value/max_value
	skeletonSpr.position = startPos.lerp(endPos, progress)

func playBob():
	bopAnim.stop()
	bopAnim.play("normalBop")

func setSongUIData(acc:float, misses:int):
	updateAcc(acc)
	updateMiss(misses)

func updateAcc(acc):
	if acc != 100.0:
		var snappedAcc = snapped(acc, 0.1)
		accuracyLbl.text = str(snappedAcc) + "%"
	else:
		accuracyLbl.text = "100%"

func updateMiss(miss):
	if miss < 10:
		missLbl.text = "0"
	else:
		missLbl.text = ""
	
	missLbl.text += str(miss)
