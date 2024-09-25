extends AnimatedSprite2D

var hit:bool = false

func setDebug(active):
	$noteJudment.editor_only = !active

func setHit(value:bool):
	hit = value

func getHit() -> bool:
	return hit

func setHold():
	$noteHold.clear_points()
	$noteHold.width = 10
	$noteHold.add_point(Vector2(0, 0))
	$noteHold.add_point($holdEnd.position)

func getHoldEnd():
	return $holdEnd

func getHold():
	return $noteHold

func getJudgment() -> Rect2:
	return $noteJudment.get_global_rect()

func getHoldJudgment() -> Rect2:
	return $holdEnd/noteJudment.get_global_rect()
