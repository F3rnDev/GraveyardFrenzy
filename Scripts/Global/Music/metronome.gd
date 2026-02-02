extends AudioStreamPlayer

@export var hasMetronome:bool
@export_enum("Every Beat", "Every Step") var metronomeTime:int

func playMetronome(step):
	if step == 0:
		pitch_scale = 1.5
	else:
		pitch_scale = 1
		
	play()
