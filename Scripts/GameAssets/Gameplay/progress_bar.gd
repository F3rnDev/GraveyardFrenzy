extends TextureProgressBar

@onready var skeletonSpr = $skeleton
@onready var bopAnim = $AnimationPlayer

@onready var startPos = $skeleton.position
@onready var endPos = $flag.position

@onready var accuracyLbl = $Stats/Accuracy/accValue
@onready var missLbl = $Stats/Misses/missValue

var curAcc:float = 0.0
var curMiss:int = 0

func _ready() -> void:
	setSongUIData(100.0, 0, true)

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

func setSongUIData(acc:float, misses:int, firstSetup:bool = false):
	if curAcc != acc or firstSetup:
		curAcc = acc
		updateAcc()
	
	if curMiss != misses or firstSetup:
		curMiss = misses
		updateMiss()

func updateAcc():
	if curAcc != 100.0:
		var snappedAcc = snapped(curAcc, 0.1)
		accuracyLbl.text = str(snappedAcc) + "%"
	else:
		accuracyLbl.text = "100%"

func updateMiss():
	if curMiss < 10:
		missLbl.text = "0"
	else:
		missLbl.text = ""
	
	missLbl.text += str(curMiss)
