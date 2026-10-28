extends GameElement

class_name GameObstacle

var obsType = "cactus"

func setObstacleType(type):
	obsType = type

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	play(obsType)
