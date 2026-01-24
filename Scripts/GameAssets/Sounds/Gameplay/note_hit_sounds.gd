extends AudioStreamPlayer

@export var defaultHitSound:AudioStream

#When Creating the chart system, edit this script to be able to load a chart custom hitSounds
#IDEA: Define specific hitsounds to the chart, aaaaand to a specific note
# Example: "I want this specific note to play a synth when the player hits", and so on

func playAudio(_noteData):
	stream = defaultHitSound
	pitch_scale = randf_range(0.9, 1.1)
	
	play()
