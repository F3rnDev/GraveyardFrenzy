extends Node2D

@onready var noteHitParticle = preload("res://Nodes/GameAssets/Particles/noteHitParticle.tscn")
@onready var noteHoldParticle = preload("res://Nodes/GameAssets/Particles/noteHoldParticle.tscn")

enum notePress {StrumUp, StrumDown}

signal notePressed(note)
signal noteReleased(note)

func setDebug(active):
	$judment.editor_only = !active

func _ready():
	for curNote in notePress:
		get_node(curNote).play("idle")
		get_node(curNote).frame = 1
	
	addHoldParticles()

func addHoldParticles():
	for curNote in notePress:
		var strumHit = get_node(curNote)
		var particleInstance:GPUParticles2D = noteHoldParticle.instantiate()
		particleInstance.emitting = false
		particleInstance.visible = false
		
		strumHit.add_child(particleInstance)

func _input(event):
	for curNote in notePress:
		if event.is_action_pressed(curNote):
			get_node(curNote).play("note_press")
			emit_signal("notePressed", curNote)
			
		elif event.is_action_released(curNote):
			get_node(curNote).play("idle")
			emit_signal("noteReleased", curNote)

func spawnParticle(noteData:int, rating:String):
	var strumHit:AnimatedSprite2D = get_child(noteData)
	var particleInstance = noteHitParticle.instantiate()
	particleInstance.global_position = strumHit.global_position
	
	match rating:
		"perfect":
			particleInstance.isPerfectHit = true
		"good":
			particleInstance.isPerfectHit = false
		_:
			return
	
	get_tree().current_scene.add_child(particleInstance)

func spawnHoldParticle(noteData:int, rating:String):
	var strumHit:AnimatedSprite2D = get_child(noteData)
	var particleObj:GPUParticles2D = strumHit.get_child(0)
	
	particleObj.emitting = true
	particleObj.visible = true
	particleObj.setTexture(rating == "perfect")

func removeHoldParticle(noteData:int):
	var strumHit:AnimatedSprite2D = get_child(noteData)
	var particleObj:GPUParticles2D = strumHit.get_child(0)
	
	particleObj.emitting = false
	particleObj.visible = false

func playHitAnimation(noteData:int, isPerfect, releasedHit = false):
	var strumHit:AnimatedSprite2D = get_child(noteData)
	var animToPlay = "note_hit_normal" if !isPerfect else "note_hit_perfect"
	
	strumHit.play(animToPlay)
	
	if releasedHit:
		await strumHit.animation_finished
		strumHit.play("idle")

func getJudgment() -> Rect2:
	return $judment.get_global_rect()
