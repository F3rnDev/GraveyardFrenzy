extends GameElement

class_name GameObstacle

var obsType = "cactus"

func setObstacleType(type):
	obsType = type

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	play(obsType)

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is not Player:
		return
	
	var player:Player = area.get_parent()
	player.canBeHurt()
