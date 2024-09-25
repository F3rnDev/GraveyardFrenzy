extends CharacterBody3D


const SPEED = 5.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	$SubViewport/player_2d.play("default")


func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if !OverworldRef.instance.inMenu:
		InputMovement()

	move_and_slide()

func InputMovement():
	var input_dir = Input.get_vector("Left", "Right", "Up", "Down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
