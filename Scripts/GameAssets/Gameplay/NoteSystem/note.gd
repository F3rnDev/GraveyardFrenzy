extends GameElement

class_name GameNote

@onready var noteJudgment: ReferenceRect = $noteJudment
@onready var holdJudgment: ReferenceRect = $holdEnd/noteJudment

@onready var noteHold: Line2D = $noteHold
@onready var holdEnd: AnimatedSprite2D = $holdEnd

var holding:bool = false

func _ready() -> void:
	play("default")
	
	setDebug(gameplayRef.noteAreaDebug)
	setHold(gameplayRef.getObjectPos(elementRef.holdAmount))

func setDebug(active):
	noteJudgment.editor_only = !active
	holdJudgment.editor_only = !active

#Set and Get hold
func setHold(holdXPos:float):
	var finalPos = Vector2(holdXPos / global_scale.x, position.y)
	holdEnd.position = Vector2.RIGHT * finalPos
	
	if holdXPos > 0:
		holdEnd.visible = true
	
	setHoldLine()

func setHoldLine():
	noteHold.clear_points()
	noteHold.width = 10
	noteHold.add_point(Vector2(0, 0))
	noteHold.add_point(holdEnd.position)

func getHoldEnd():
	return holdEnd

func getHold():
	return noteHold

func getJudgment() -> Rect2:
	return noteJudgment.get_global_rect()

func getHoldJudgment() -> Rect2:
	return holdJudgment.get_global_rect()

func isOverlappingJudgment(judgmentLine) -> bool:
	var noteJudgment = getJudgment()
	
	if noteJudgment == null or judgmentLine == null:
		return false
	
	return judgmentLine.intersects(noteJudgment)

func isOverlappingHoldJudgment(judgmentLine) -> bool:
	var holdJudgment = getHoldJudgment()
	
	if holdJudgment == null or judgmentLine == null:
		return false
	
	return judgmentLine.intersects(holdJudgment)
#END

#Set miss
func missNote():
	holdEnd.self_modulate.a = 0.3
	noteHold.self_modulate.a = 0.3
	self_modulate.a = 0.3
	
	if holding: targetTime = gameplayRef.getObjectPos(conductorRef.songPos)

#Note hit
func updateHoldHit(newHold:float):
	position.x = 0.0
	setHold(gameplayRef.getObjectPos(newHold))
	
	self_modulate.a = 0.3
	holdEnd.self_modulate.a = 1.0
	noteHold.self_modulate.a = 0.3
	
	holding = true
