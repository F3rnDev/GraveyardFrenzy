extends CharacterBody3D

const SPEED = 5.0
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@export var timeToIdle = 10
@export var idleTimer : Timer = Timer.new()

var animatingXtra = false
var waitForFrame = false

var stopMovement = false

func _ready():
	add_child(idleTimer)
	idleTimer.one_shot = true
	idleTimer.timeout.connect(setIdleAnim)
	
	$SubViewport/player_2d.animation_finished.connect(on_animation_finished)
	
	setIdleAnim(true)

func setIdleAnim(startIdle = false):
	if startIdle:
		$SubViewport/player_2d.play("idle")
		animatingXtra = false
		return

	animatingXtra = true
	
	if $SubViewport/player_2d.frame == 0:
		var random = RandomNumberGenerator.new().randi_range(1, 2)
		$SubViewport/player_2d.play("idleXtra" + str(random))
		waitForFrame = false
	else:
		waitForFrame = true

func on_animation_finished():
	setIdleAnim(true)

func setTimer(time):
	if not idleTimer.is_stopped():
		return
	
	idleTimer.wait_time = time
	idleTimer.start()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	setAnimation()

	move_and_slide()

func _input(event):
	if !OverworldRef.instance.inMenu and !stopMovement:
		InputMovement(event)

func InputMovement(event):
	var input_dir = Input.get_vector(
		CInput.getInput("Left"), CInput.getInput("Right"), 
		CInput.getInput("Up"), CInput.getInput("Down")
	)
	
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func setAnimation():
	if velocity.x != 0 or velocity.z != 0:
		$SubViewport/player_2d.play("Walk(Placeholder)")
		idleTimer.stop()
		animatingXtra = false
		waitForFrame = false
	else:
		if not animatingXtra:
			setIdleAnim(true)
			setTimer(timeToIdle)
		
		if waitForFrame:
			setIdleAnim()
	
	# Ajuste de direção
	if velocity.x > 0:
		var tween = get_tree().create_tween()
		tween.tween_property($SubViewport/player_2d, "scale:x", 5, 0.05)
	elif velocity.x < 0:
		var tween = get_tree().create_tween()
		tween.tween_property($SubViewport/player_2d, "scale:x", -5, 0.05)
