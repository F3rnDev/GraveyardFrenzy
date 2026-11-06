extends Node

#Dependencies
@onready var player: Player = $".."
@onready var sprite: AnimatedSprite2D = $"../player_2d"

#Sounds
@onready var noHitAndJumpSound: AudioStreamPlayer = $NoHitAndJumpSound
@onready var stopSound: AudioStreamPlayer = $Stop
@onready var runSound: AudioStreamPlayer = $Run
@onready var hurtSound: AudioStreamPlayer = $Hurt

var jumpedSndPlayed = false

func _on_player_2d_animation_changed() -> void:
	playSfx()

func playSfx():
	if sprite == null:
		return
	
	var stopAnim = sprite.animation != "Hold" and sprite.animation != "deathSlide"
	if stopAnim and stopSound.playing:
		stopSound.stop()
	
	if sprite.animation != "Run" and runSound.playing:
		runSound.stop()
	
	if sprite.animation != "jump":
		jumpedSndPlayed = false
	
	if !player.isRunnin:
		return
	
	match sprite.animation:
		"jump":
			playJumpSound()
		"Hold":
			playHoldSound()
		"Run":
			playRunSound()
		"deathSlide":
			playHoldSound()

func playRunSound():
	if runSound.playing:
		return
	
	runSound.play()

func playJumpSound():
	if jumpedSndPlayed:
		return
	
	noHitAndJumpSound.pitch_scale = 1.2
	noHitAndJumpSound.play()
	
	jumpedSndPlayed = true

func playHoldSound():
	if stopSound.playing:
		return
	
	stopSound.play()

func playHurtSound():
	hurtSound.pitch_scale = randf_range(0.8, 1.2)
	hurtSound.play()

func playNoHitSound(lane):
	noHitAndJumpSound.pitch_scale = 1.2 if lane == 0 else 1.0
	noHitAndJumpSound.play()
