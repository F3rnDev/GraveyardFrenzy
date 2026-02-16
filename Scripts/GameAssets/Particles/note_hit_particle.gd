extends AnimatedSprite2D

func _ready() -> void:
	z_index = -1

func playHit(isPerfectHit:bool):
	z_index = 0
	
	var allAnimations = sprite_frames.get_animation_names()
	var rng = randi_range(0, allAnimations.size()-1)
	
	modulate = Color.RED if isPerfectHit else Color.WHITE
	
	play(allAnimations[rng])

func _on_animation_finished() -> void:
	z_index = -1
