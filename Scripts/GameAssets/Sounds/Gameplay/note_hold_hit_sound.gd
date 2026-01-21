extends AudioStreamPlayer

@export var pitchMax = 4.0
@export var pitchAdd = 0.1

# Called when the node enters the scene tree for the first time.
func playAudio():
	pitch_scale = 1.0
	play()

func stopAudio():
	stop()

func _process(delta: float) -> void:
	if playing and pitch_scale < pitchMax:
		pitch_scale += pitchAdd * delta 
