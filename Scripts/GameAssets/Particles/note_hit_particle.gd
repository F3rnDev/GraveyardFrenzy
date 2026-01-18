extends AnimatedSprite2D

var isPerfectHit:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playHit()

func playHit():
	var allAnimations = sprite_frames.get_animation_names()
	var rng = randi_range(0, allAnimations.size()-1)
	
	modulate = Color.RED if isPerfectHit else Color.WHITE
	
	play(allAnimations[rng])

func _on_animation_finished() -> void:
	queue_free()
