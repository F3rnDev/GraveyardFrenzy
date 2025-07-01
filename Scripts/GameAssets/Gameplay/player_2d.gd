extends CharacterBody2D

#simple movement var
const SPEED = 500.0
const jumpForce = 700.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

#morePhysics
@export var fastFallMultiplier = 2.0
@export var jumpBufferTime = 0.15
var jumpBufferTimer = 0

var isRunnin = false
var initX:float

@export var health:int = 3
var flashTimer = Timer.new()
signal hit

var healthFlash = Timer.new()

#gameOver
var dead
var animatedDeath
var deadRotateTween
@export var deadFriction = 1000
var deathAnimPlayed = false

func _ready():
	$player_2d.play("Walk(Placeholder)")
	initX = global_position.x
	
	flashTimer.one_shot = false;
	flashTimer.connect("timeout", flashPlayer)
	add_child(flashTimer)
	
	healthFlash.one_shot = false;
	healthFlash.connect("timeout", flashHealth)
	add_child(healthFlash)
	
	$Health.modulate.a = 0

func _process(delta):
	var overlap = $Area2D.get_overlapping_areas()
	for area in overlap:
		colliding(area)

func setRunnin(run):
	isRunnin = run
	
	if global_position.x != initX and !isRunnin and !dead:
		var tweenPos = create_tween()
		tweenPos.set_ease(Tween.EASE_IN_OUT)
		tweenPos.tween_property(self, "global_position:x", initX, 0.5)

func _physics_process(delta):
	#set fast fall multiplyer
	var fastFall = 1
	if velocity.y > 0:
		fastFall = fastFallMultiplier
	
	if not is_on_floor():
		velocity.y += (gravity * fastFall * delta)
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
