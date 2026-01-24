extends CharacterBody2D

#Trying to figure out how to sync animations to the rhythm
#@export var conductor:Conductor

#Player Movement
const SPEED = 500.0
const jumpForce = 700.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var fastFallMultiplier = 2.0
@export var jumpBufferTime = 0.15
var jumpBufferTimer = 0

#Transition between runner and rhythm sections
var isRunnin = false
var initPos:Vector2 #Player start position, go to this position when runner section is over
var runninTransitionTween: Tween

#Health and Hurt mechanic
@export var health:int = 3
signal hurt
var flashTimer = Timer.new()
var healthFlash = Timer.new()

#gameOver
var dead = false
var deathJumped = false
var deathSlid = false

var deadRotateTween
@export var deadFriction = 1000

#Player animations
var animated = true #When playing a animation that ends, set this to false
var canNoHitAnimate = true
var lastPressNote = null
var isHoldingNote = false
var rythmMovementTween:Tween

var missAnimations = []
var hitAnimations = []
var lastHitOrMissIndex := -1

#SoundSfx
var jumpedPlayed = false

#Initial setup
func _ready():
	$player_2d.play("Walk(Placeholder)")
	initPos = global_position
	$Health.modulate.a = 0
	
	setupTimers()
	setupAnimations()

func setupAnimations():
	var allAnim = $player_2d.sprite_frames.get_animation_names()
	
	for animation:String in allAnim:
		if animation.begins_with("Attack0"):
			hitAnimations.append(animation)
		elif animation.begins_with("Miss0"):
			missAnimations.append(animation)

func setupTimers():
	flashTimer.one_shot = false
	flashTimer.connect("timeout", flashPlayer)
	add_child(flashTimer)
	
	healthFlash.one_shot = false
	healthFlash.connect("timeout", flashHealth)
	add_child(healthFlash)


func _process(_delta):
	checkCollision()
	animate()
	playRunnerSfx()

func checkCollision():
	var overlap = $Area2D.get_overlapping_areas()
	for area in overlap:
		colliding(area)

func setRunnin(run):
	if isRunnin == run:
		return
	
	isRunnin = run
	
	if global_position.x != initPos.x and !isRunnin and !dead:
		runninTransitionTween = create_tween()
		runninTransitionTween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		runninTransitionTween.tween_property(self, "global_position:x", initPos.x, 0.5)
		
		#Animate While tweening
		if is_on_floor():
			$player_2d.play("Hold")
			animated = false
			await runninTransitionTween.finished
			animated = true

func _physics_process(delta):
	applyGravity(delta)
	
	if !dead:
		if isRunnin:
			InputRunnerMovement(delta)
		else:
			velocity = Vector2(0,velocity.y)
	
	checkDeath(delta)

	move_and_slide()

func applyGravity(delta):
	#fast fall
	var fastFall = 1
	if velocity.y > 0:
		fastFall = fastFallMultiplier
	
	#gravity
	if animated or dead or isRunnin:
		if not is_on_floor():
			velocity.y += gravity * fastFall * delta
		else:
			velocity.y = 0
	else:
		velocity.y = 0

#Player death
func checkDeath(delta):
	if !dead:
		return
	
	if is_on_floor() and deathJumped:
		deathSlide(delta)
	elif !deathJumped:
		deathJump()

func deathJump():
	velocity = Vector2.ZERO
	velocity += Vector2(jumpForce/2, -jumpForce)
	
	if !is_on_floor():
		deathJumped = true

func deathSlide(delta):
	if deathSlid:
		return
	
	#Reset Rotation
	if rotation != 0.0:
		deadRotateTween.kill()
		rotation = 0.0
	
	#Set slide animation
	if abs(velocity.x) > 10:
		velocity.x = move_toward(velocity.x, 0, deadFriction*delta)
		$player_2d.play("deathSlide")
	elif abs(velocity.x) <= 10 and !deathSlid:
		velocity.x = 0
		$player_2d.play("deathFall")
		deathSlid = true

#RunnerMovement
func InputRunnerMovement(delta):
	runnerMovement()
	runnerJump(delta)

func runnerMovement():
	var input_dir = Input.get_vector(
		CInput.getInput("Left"), CInput.getInput("Right"), 
		CInput.getInput("Up"), CInput.getInput("Down")
	)
	
	var direction = (Vector2(input_dir.x, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

func runnerJump(delta):
	#Set the jumpTimerBuffer (player jumps even if you've pressed it before touching the ground)
	if Input.is_action_just_pressed("Jump"):
		jumpBufferTimer = jumpBufferTime
	
	if jumpBufferTimer > 0:
		jumpBufferTimer -= delta
		
		#JumpAction
		if is_on_floor():
			velocity.y -= jumpForce
			jumpBufferTimer = 0
	
	#Hold jump functionality
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = 0

#Colliding and player hurt/health logic
func colliding(area):	
	if area.get_parent().is_in_group("obstacle") and isRunnin and $IFrames.is_stopped() and !dead:
		playerHurt()

func playerHurt():
	addOrSubHealth(-1)
	hurt.emit()
	$IFrames.start()	
	flashTimer.start(0.1)
	
	#Animate player
	animated = false
	$player_2d.play("Hurt")
	
	#PlaySound
	$Audio/Hurt.pitch_scale = randf_range(0.8, 1.2)
	$Audio/Hurt.play()

func flashPlayer():
	if $IFrames.is_stopped():
		$player_2d.visible = true;	
		flashTimer.stop()
	else:
		$player_2d.visible = !$player_2d.visible
		flashTimer.start(0.1)

func flashHealth():
	if health > 1:
		$Health.modulate = Color.WHITE
		healthFlash.stop()
	else:
		$Health.modulate = Color.RED if $Health.modulate == Color.WHITE else Color.WHITE
		healthFlash.start(0.5)

func setHealth(setTo):
	health = setTo

func addOrSubHealth(setTo):
	health += setTo
	setHealthGraph()

func setHealthGraph():
	$Health.modulate.a = 1
	
	for i in range($Health.get_child_count()):
		if health <= i:
			$Health.get_child(i).play("NoLife")
		else:
			$Health.get_child(i).play("Life")
	
	var tween = create_tween()
	
	if health == 1:
		healthFlash.start(0.5)
		tween.tween_property($Health, "modulate:a", 1, 1.5)
	else:
		tween.tween_property($Health, "modulate:a", 0, 2.5)

#GameOver
func killPlayer():
	dead = true
	deathJumped = false
	deathSlid = false
	
	deadRotateTween = create_tween()
	deadRotateTween.tween_property(self, "rotation", deg_to_rad(90.0), 1.0)
	
	$Health.visible = false

#PLAYER HIT ANIMATION
func validateNoHitAnim(note):
	#Main Validations
	var sameNote = (note == lastPressNote)
	var downHit = (note == 1 and lastPressNote == 0)
	var jumpUp = (note == 0 and lastPressNote == 1)
	
	#Ifs
	# if on ground and not attacking down
	var onGround = note == 1 and not downHit and not jumpUp
	# if on air and not attacking down
	var onAir = not is_on_floor() and not downHit and not jumpUp
	
	#Validate
	return (sameNote or onGround or onAir)

func setNoHitAnim(note, strumLine):
	if !canNoHitAnimate:
		return
	
	if validateNoHitAnim(note):
		return
	
	var strumPos = strumLine.get_child(note).global_position
	var downHit = (note == 1 and global_position.y < strumPos.y)
	
	setPlayerStrumPos(strumPos)
	
	animated = false
	lastPressNote = note
	$player_2d.stop()
	
	#PLAY ANIMATION
	if downHit:
		$player_2d.play("AttackDown")
	else:
		$player_2d.play("jump")
	
	#PLAY SOUND
	$Audio/NoHitAndJumpSound.pitch_scale = 1.2 if note == 0 else 1.0
	$Audio/NoHitAndJumpSound.play()

func setHitAnim(note, strumLine, hold=false):
	canNoHitAnimate = false
	
	var strumPos = strumLine.get_child(note).global_position
	var downHit = (note == 1 and global_position.y < strumPos.y)
	
	setPlayerStrumPos(strumPos)
	
	animated = false
	lastPressNote = note
	
	if hold:
		if !isHoldingNote:
			isHoldingNote = true
			#PlayHoldAnimation
			$player_2d.play("AttackHold")
		
		return
	
	$player_2d.stop()
	
	if isHoldingNote:
		isHoldingNote = false
		#PlayHoldEndAnimation
		$player_2d.play("Attack01")
		return
	
	#PLAY ANIMATION
	if downHit:
		$player_2d.play("AttackDown")
	else:
		playHitAnimation()

func setPlayerStrumPos(pos):
	rythmMovementTween = create_tween()
	rythmMovementTween.set_ease(Tween.EASE_OUT)
	rythmMovementTween.set_trans(Tween.TRANS_BACK)

	rythmMovementTween.tween_property(self, "global_position:y", pos.y, 0.1)

#ANIMATION
func animate():
	if !animated or dead:
		$player_2d.speed_scale = 1.0
		return
	
	lastPressNote = null
	canNoHitAnimate = true
	
	if is_on_floor():
		playWalkAnimation()
	else:
		playAerialAnimation()

func playWalkAnimation():
	var curAnim = "Walk(Placeholder)"
	
	if velocity.x > 0:
		curAnim = "Run"
	elif velocity.x < 0:
		curAnim = "Hold"
	
	if $player_2d.animation != curAnim:
		$player_2d.play(curAnim)

func playAerialAnimation():
	var curAnimation = "jump" if isRunnin else "fall"
	
	if velocity.y > 0:
		curAnimation = "fall"
	
	if curAnimation != $player_2d.animation:
		$player_2d.play(curAnimation)

func playMissAnimation():
	animated = false
	isHoldingNote = false
	$player_2d.stop()
	
	var animationToPlay = "Miss01"
	if $player_2d.animation != "AttackHold":
		animationToPlay = getRandomHitOrMissAnimation("Miss")
	
	$player_2d.play(animationToPlay)

func playHitAnimation():
	$player_2d.play(getRandomHitOrMissAnimation())

func getRandomHitOrMissAnimation(animType: String = "Hit") -> String:
	var curAnimations = hitAnimations if animType == "Hit" else missAnimations
	var count = curAnimations.size()

	var index = randi_range(0, count - 2)

	if index >= lastHitOrMissIndex:
		index += 1

	lastHitOrMissIndex = index
	return curAnimations[index]

#SOUND EFFECTS
func playRunnerSfx():
	var stopAnim = $player_2d.animation != "Hold" and $player_2d.animation != "deathSlide"
	if stopAnim and $Audio/Stop.playing:
		$Audio/Stop.stop()
	
	if $player_2d.animation != "Run" and $Audio/Run.playing:
		$Audio/Run.stop()
	
	if $player_2d.animation != "jump":
		jumpedPlayed = false
	
	if !isRunnin:
		return
	
	match $player_2d.animation:
		"jump":
			playJumpSound()
		"Hold":
			playHoldSound()
		"Run":
			playRunSound()
		"deathSlide":
			playHoldSound()

func playRunSound():
	if $Audio/Run.playing:
		return
	
	$Audio/Run.play()

func playJumpSound():
	if jumpedPlayed:
		return
	
	$Audio/NoHitAndJumpSound.pitch_scale = 1.2
	$Audio/NoHitAndJumpSound.play()
	
	jumpedPlayed = true

func playHoldSound():
	if $Audio/Stop.playing:
		return
	
	$Audio/Stop.play()

#SIGNALS
func _on_player_2d_animation_finished() -> void:
	animated = true
