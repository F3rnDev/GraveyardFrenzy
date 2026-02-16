extends AnimatedSprite2D

class_name StrumSprite

@onready var normalHitParticle = $NoteHitParticle
@onready var holdNoteParticle = $NoteHoldParticle

func noteHit(isPerfect:bool, releasedHit:bool):
	var animToPlay = "note_hit_normal" if !isPerfect else "note_hit_perfect"
	
	play(animToPlay)
	normalHitParticle.playHit(isPerfect)
	
	if releasedHit:
		await animation_finished
		play("idle")

func setHoldActive(isPerfect:bool):
	holdNoteParticle.setTexture(isPerfect)
	holdNoteParticle.setActive()

func setHoldInactive():
	holdNoteParticle.setInactive()
