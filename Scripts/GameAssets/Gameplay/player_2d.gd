extends CharacterBody2D

#Dependencies
@export var conductor:Conductor

#simple movement var
const SPEED = 500.0
const jumpForce = 700.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#morePhysics
@export var fastFallMultiplier = 2.0
@export var jumpBufferTime = 0.15
var jumpBufferTimer = 0

var isRunnin = false
var initPos:Vector2

#Health
@export var health:int = 3
var flashTimer = Timer.new()
signal hit

var healthFlash = Timer.new()

#gameOver
var dead = false
var animatedDeath = false
var deadRotateTween
@export var deadFriction = 1000
var deathAnimPlayed = false

#AnimateRhythmHit
var animated = true
var canNoHitAnimate = true
var lastPressNote = null
var isHoldingNote = false

#Get last attack anim
var lastAttackAnimation = ""

func _ready():
	$player_2d.play("Walk(Placeholder)")
	initPos = global_position
	
	flashTimer.one_shot = false
	flashTimer.connect("timeout", flashPlayer)
	add_child(flashTimer)
	
	healthFlash.one_shot = false
	healthFlash.connect("timeout", flashHealth)
	add_child(healthFlash)
	
	$Health.modulate.a = 0

func _process(delta):
	var overlap = $Area2D.get_overlapping_areas()
	for area in overlap:
		colliding(area)
	
	animate()

func setRunnin(run):
	isRunnin = run
	
	if global_position.x != initPos.x and !isRunnin and !dead:
		var tweenPos = create_tween()
		tweenPos.set_ease(Tween.EASE_OUT)
		tweenPos.tween_property(self, "global_position:x", initPos.x, 0.5)

func _physics_process(delta):
	#set fast fall multiplyer
	var fastFall = 1
	if velocity.y > 0:
		fastFall = fastFallMultiplier
	
	#Gravity
	if animated:
		if not is_on_floor():
			velocity.y += gravity * fastFall * delta
		else:
			velocity.y = 0
	else:
		velocity.y = 0
	
	if isRunnin and !dead:
		InputMovement(delta)
	elif !isRunnin and !dead:
		velocity = Vector2(0,velocity.y)
	
	if dead and is_on_floor() and animatedDeath:
		deadRotateTween.kill()
		rotation = 0.0
		
		if abs(velocity.x) > 10:
			velocity.x = move_toward(velocity.x, 0, deadFriction*delta)
			$player_2d.play("deathSlide")
		elif abs(velocity.x) <= 10 and !deathAnimPlayed:
			velocity.x = 0
			$player_2d.play("deathFall")
			deathAnimPlayed = true
	
	if dead and !animatedDeath:
		velocity = Vector2.ZERO
		velocity += Vector2(jumpForce/2, -jumpForce)
		
		if !is_on_floor():
			animatedDeath = true

	move_and_slide()

func InputMovement(delta):
	#Horizontal movement
	var input_dir = Input.get_vector(
		CInput.getInput("Left"), CInput.getInput("Right"), 
		CInput.getInput("Up"), CInput.getInput("Down")
	)
	
	var direction = (Vector2(input_dir.x, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	#Set the jumpTimerBuffer (player jumps even if you've pressed it before touching the ground)
	if Input.is_action_just_pressed("Jump"):
		jumpBufferTimer = jumpBufferTime
	
	if jumpBufferTimer > 0:
		jumpBufferTimer -= delta
	
	#JumpAction
	if jumpBufferTimer > 0 and is_on_floor():
		velocity.y -= jumpForce
		jumpBufferTimer = 0
	
	#Hold jump functionality
	if Input.is_action_just_released("Jump") and velocity.y < 0:
		velocity.y = 0

func colliding(area):	
	if area.get_parent().is_in_group("obstacle") and isRunnin and $IFrames.is_stopped() and !dead:
		playerHit()

func playerHit():
	addOrSubHealth(-1)
	hit.emit()
	$IFrames.start()	
	flashTimer.start(0.1)

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
	animatedDeath = false
	deathAnimPlayed = false
	
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

func playHitAnimation():
	var allAnim = $player_2d.sprite_frames.get_animation_names()
	var attackAnimations = []
	
	for animation:String in allAnim:
		if animation.begins_with("Attack0") and animation != $player_2d.animation:
			attackAnimations.append(animation)
	
	var rng = randi_range(0, attackAnimations.size()-1)
	$player_2d.play(attackAnimations[rng])

var tweenPos:Tween
func setPlayerStrumPos(pos):
	tweenPos = create_tween()
	tweenPos.set_ease(Tween.EASE_OUT)
	tweenPos.set_trans(Tween.TRANS_BACK)

	tweenPos.tween_property(self, "global_position:y", pos.y, 0.1)

#ANIMATION
func animate():
	if !animated or dead:
		return
	
	lastPressNote = null
	canNoHitAnimate = true
	
	if is_on_floor():
		playWalkAnimation()
	else:
		playAerialAnimation()

func playWalkAnimation():
	#check speed to run
	$player_2d.play("Walk(Placeholder)")

func playAerialAnimation():
	var curAnimation = "jump" if isRunnin else "fall"
	
	if velocity.y > 0:
		curAnimation = "fall"
	
	if curAnimation != $player_2d.animation:
		$player_2d.play(curAnimation)

#SIGNALS
func _on_player_2d_animation_finished() -> void:
	if !isRunnin or (isRunnin and ($player_2d.animation.contains("Attack") or $player_2d.animation == "jump")):
		animated = true


func _on_animation_timer_timeout() -> void:
	pass # Replace with function body.
