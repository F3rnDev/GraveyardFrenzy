extends CharacterBody2D

class_name Player

#Components
@onready var playerPhysics: Node = $PlayerPhysics
@onready var playerAnimation: Node = $PlayerAnimation
@onready var audio: Node = $Audio

#Objects
@onready var IFrames: Timer = $IFrames
@onready var sprite: AnimatedSprite2D = $player_2d
@onready var healthContainer: Node2D = $Health

#Trying to figure out how to sync animations to the rhythm
#@export var conductor:Conductor

#Transition between runner and rhythm sections
var isRunnin = false

#Health and Hurt mechanic
@export var health:int = 3
signal hurt
var flashTimer = Timer.new()
var healthFlash = Timer.new()

#gameOver
var dead = false

var deadRotateTween
@export var deadFriction = 1000

#SoundSfx
var jumpedPlayed = false

#Initial setup
func _ready():
	healthContainer.modulate.a = 0
	setupTimers()

func setupTimers():
	flashTimer.one_shot = false
	flashTimer.connect("timeout", flashPlayer)
	add_child(flashTimer)
	
	healthFlash.one_shot = false
	healthFlash.connect("timeout", flashHealth)
	add_child(healthFlash)

func setRunnin(run):
	if isRunnin == run:
		return
	
	isRunnin = run
	
	playerAnimation.runnerRhythmTransition()

func _physics_process(delta):
	move_and_slide()

#Colliding and player hurt/health logic
func canBeHurt():
	#check if the player is in the runner section (WILL CHANGE)
	#check if hes not dead
	#check if he has IFrames :O
	if isRunnin and IFrames.is_stopped() and !dead:
		playerHurt()

func playerHurt():
	addOrSubHealth(-1)
	hurt.emit()
	IFrames.start()	
	flashTimer.start(0.1)
	
	playerAnimation.playHurtAnimation()
	audio.playHurtSound()

func flashPlayer():
	if IFrames.is_stopped():
		sprite.visible = true;	
		flashTimer.stop()
	else:
		sprite.visible = !sprite.visible
		flashTimer.start(0.1)

func flashHealth():
	if health > 1:
		healthContainer.modulate = Color.WHITE
		healthFlash.stop()
	else:
		healthContainer.modulate = Color.RED if healthContainer.modulate == Color.WHITE else Color.WHITE
		healthFlash.start(0.5)

func setHealth(setTo):
	health = setTo

func addOrSubHealth(setTo):
	health += setTo
	setHealthGraph()

func setHealthGraph():
	healthContainer.modulate.a = 1
	
	for i in range(healthContainer.get_child_count()):
		var heartSprite = healthContainer.get_child(i)
		
		if health <= i:
			heartSprite.play("NoLife")
		else:
			heartSprite.play("Life")
	
	var tween = create_tween()
	
	if health == 1:
		healthFlash.start(0.5)
		tween.tween_property(healthContainer, "modulate:a", 1, 1.5)
	else:
		tween.tween_property(healthContainer, "modulate:a", 0, 2.5)

#GameOver
func killPlayer():
	dead = true
	playerPhysics.playerKilled()
	playerAnimation.playerKilled()
	
	healthContainer.visible = false

#PLAYER HIT ANIMATION
func setNoHitAnim(note, strumLine):
	playerAnimation.playNoHitAnim(note, strumLine)
	audio.playNoHitSound(note)

func setHitAnim(note, strumLine, hold=false):
	playerAnimation.playHitAnim(note, strumLine, hold)

func setMissAnimation():
	playerAnimation.playMissAnimation()
