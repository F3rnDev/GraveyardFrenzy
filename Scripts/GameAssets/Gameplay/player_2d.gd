extends CharacterBody2D

const SPEED = 500.0
const jumpForce = 700.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var isRunnin = false
var initX:float

@export var health:int = 3
var flashTimer = Timer.new()
signal hit

func _ready():
	$player_2d.play("default")
	initX = global_position.x
	
	flashTimer.one_shot = false;
	flashTimer.connect("timeout", flashPlayer)
	add_child(flashTimer)

func _process(delta):
	var overlap = $Area2D.get_overlapping_areas()
	for area in overlap:
		colliding(area)

func setRunnin(run):
	isRunnin = run
	
	if global_position.x != initX and !isRunnin:
		var tweenPos = create_tween()
		tweenPos.set_ease(Tween.EASE_IN_OUT)
		tweenPos.tween_property(self, "global_position:x", initX, 0.5)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if isRunnin:
		InputMovement()
	else:
		velocity = Vector2(0,velocity.y)

	move_and_slide()

func InputMovement():
	var input_dir = Input.get_vector("Left", "Right", "Up", "Down")
	var direction = (Vector2(input_dir.x, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y -= jumpForce
	
	if Input.is_action_just_released("Jump") and velocity.y < -300:
		velocity.y = -300

func colliding(area):	
	if area.get_parent().is_in_group("obstacle") and isRunnin and $IFrames.is_stopped():
		playerHit()

func playerHit():
	health -= 1
	hit.emit()
	$IFrames.start()
	flashTimer.start(0.1)

func flashPlayer():
	if $IFrames.is_stopped():
		visible = true;
		flashTimer.stop()
	else:
		visible = !visible
		flashTimer.start(0.1)
