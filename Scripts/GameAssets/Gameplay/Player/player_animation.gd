extends Node
#Dependencies
@onready var player: Player = $".."
@onready var sprite: AnimatedSprite2D = $"../player_2d"
@onready var afterImageSpawner: AfterImageSpawner = $"../AfterImageSpawner"

#Transition between runner and rhythm sections
var initPos:Vector2 #Player start position, go to this position when runner section is over
var runninTransitionTween: Tween

#Player animations
var animated:bool = true #When playing a animation that ends, set this to false
var canNoHitAnimate:bool = true
var lastPressNote = null
var isHoldingNote:bool = false
var rythmMovementTween:Tween

var missAnimations = []
var hitAnimations = []
var lastHitOrMissIndex := -1

#gameOver
var deadRotateTween:Tween

##SETUP
func _ready():
	sprite.play("Walk(Placeholder)")
	initPos = player.global_position
	
	setupAnimations()

func setupAnimations():
	var allAnim = sprite.sprite_frames.get_animation_names()
	
	for animation:String in allAnim:
		if animation.begins_with("Attack0"): hitAnimations.append(animation)
		elif animation.begins_with("Miss0"): missAnimations.append(animation)

##RUNNER/RHYTHM TRANSITION
func runnerRhythmTransition():
	if player.global_position != initPos and !player.isRunnin and !player.dead:
		runninTransitionTween = create_tween()
		runninTransitionTween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		runninTransitionTween.tween_property(player, "global_position", initPos, 0.5)
		
		#Animate While tweening
		if player.is_on_floor(): sprite.play("Hold")
		else: sprite.play("Hurt") #Change animation
		
		afterImageSpawner.setActive(true)
		animated = false
		
		await runninTransitionTween.finished
		
		animated = true
		afterImageSpawner.setActive(false)

##PLAYER NORMAL ANIMATIONS (IDLE/RUN)
func _process(_delta):
	playAnimations()

func playAnimations():
	if !animated or player.dead:
		sprite.speed_scale = 1.0
		return
	
	lastPressNote = null
	canNoHitAnimate = true
	
	if player.is_on_floor():
		playGroundAnimation()
	else:
		playAerialAnimation()

func playGroundAnimation():
	var curAnim = "Walk(Placeholder)"
	
	if player.velocity.x > 0:
		curAnim = "Run"
	elif player.velocity.x < 0:
		curAnim = "Hold"
	
	if sprite.animation != curAnim:
		sprite.play(curAnim)

func playAerialAnimation():
	var curAnimation = "jump" if player.isRunnin else "fall"
	
	if player.velocity.y > 0:
		curAnimation = "fall"
	
	if curAnimation != sprite.animation:
		sprite.play(curAnimation)

##PLAYER HIT/NOHIT ANIMATIONS
func playNoHitAnim(note, strumLine):
	if !canNoHitAnimate or validateNoHitAnim(note):
		return
	
	var strumPos = strumLine.get_child(note).global_position
	var downHit = (note == 1 and player.global_position.y < strumPos.y)
	
	setPlayerStrumPos(strumPos)
	
	animated = false
	lastPressNote = note
	sprite.stop()
	
	#PLAY ANIMATION
	if downHit:
		sprite.play("AttackDown")
	else:
		sprite.play("jump")

func playHitAnim(note, strumLine, hold=false):
	canNoHitAnimate = false
	
	var strumPos = strumLine.get_child(note).global_position
	var downHit = (note == 1 and player.global_position.y < strumPos.y)
	
	setPlayerStrumPos(strumPos)
	
	animated = false
	lastPressNote = note
	
	if hold:
		if !isHoldingNote:
			isHoldingNote = true
			sprite.play("AttackHold")
		
		return
	
	sprite.stop()
	
	if isHoldingNote:
		isHoldingNote = false
		sprite.play("Attack01") #PlayHoldEndAnimation
		return
	
	#PLAY ANIMATION
	if downHit:
		sprite.play("AttackDown")
	else:
		playHitAnimation()

func playHitAnimation():
	sprite.play(getRandomHitOrMissAnimation())

##PLAYER MISS ANIMATIONS
func playMissAnimation():
	animated = false
	isHoldingNote = false
	sprite.stop()
	
	var animationToPlay = "Miss01"
	if sprite.animation != "AttackHold":
		animationToPlay = getRandomHitOrMissAnimation("Miss")
	
	sprite.play(animationToPlay)

##PLAYER HURT ANIMATIONS
func playHurtAnimation():
	animated = false
	sprite.play("Hurt")

##PLAYER KILL ANIMATION
func playerKilled():
	deadRotateTween = create_tween()
	deadRotateTween.tween_property(player, "rotation", deg_to_rad(90.0), 1.0)

func resetDeadRotateTween():
	if player.rotation != 0.0:
		deadRotateTween.kill()
		player.rotation = 0.0

func playDeathSlideAnimation():
	sprite.play("deathSlide")

func playDeathFallAnimation():
	sprite.play("deathFall")

##HELPER FUNCTIONS
func setPlayerStrumPos(pos):
	rythmMovementTween = create_tween()
	rythmMovementTween.set_ease(Tween.EASE_OUT)
	rythmMovementTween.set_trans(Tween.TRANS_BACK)

	rythmMovementTween.tween_property(player, "global_position:y", pos.y, 0.1)

func validateNoHitAnim(note):
	#Main Validations
	var sameNote = (note == lastPressNote)
	var downHit = (note == 1 and lastPressNote == 0)
	var jumpUp = (note == 0 and lastPressNote == 1)
	
	# if on ground and not attacking down
	var onGround = note == 1 and not downHit and not jumpUp
	# if on air and not attacking down
	var onAir = not player.is_on_floor() and not downHit and not jumpUp
	
	#Validate
	return (sameNote or onGround or onAir)

func getRandomHitOrMissAnimation(animType: String = "Hit") -> String:
	var curAnimations = hitAnimations if animType == "Hit" else missAnimations
	var count = curAnimations.size()

	var index = randi_range(0, count - 2)

	if index >= lastHitOrMissIndex:
		index += 1

	lastHitOrMissIndex = index
	return curAnimations[index]

##SIGNALS
func _on_player_2d_animation_finished() -> void:
	animated = true
