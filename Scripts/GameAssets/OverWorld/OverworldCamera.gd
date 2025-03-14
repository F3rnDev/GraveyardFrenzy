extends Camera3D

@export var playerRef:CharacterBody3D
@export var minBounds:Vector2
@export var maxBounds:Vector2

var camOffset
@export var camSpeed:float

#DEBUG CAMERA
var debugCamera = false
var camRotation
var yaw = 0
var pitch = 0
var freeCamSpeed = 10

func _ready():
	camOffset = position - playerRef.position
	camRotation = rotation
	
	var dir = DirAccess.open("user://")
	dir.make_dir("Screenshots")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if !debugCamera:
		position = position.slerp(setLimit(camOffset + playerRef.position), camSpeed*delta)
	else:
		freeMovement(delta)

func setLimit(pos) -> Vector3:
	pos.x = clamp(pos.x, minBounds.x, maxBounds.x)
	pos.z = clamp(pos.z, minBounds.y, maxBounds.y)
	return pos

func freeMovement(delta):
	if not debugCamera:
		return
	
	var input_dir = Input.get_vector(
		CInput.getInput("Left"), CInput.getInput("Right"), 
		CInput.getInput("Up"), CInput.getInput("Down")
	)
	
	var direction = (global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction.length() > 0:
		position += direction * freeCamSpeed * delta
	
	# Movimento vertical
	if Input.is_key_pressed(KEY_SPACE):
		position.y += freeCamSpeed * delta
	elif Input.is_key_pressed(KEY_CTRL):
		position.y -= freeCamSpeed * delta

func _input(event: InputEvent):
	var just_pressed = event.is_pressed() and not event.is_echo()
	if Input.is_key_pressed(KEY_F1) and Input.is_key_pressed(KEY_SHIFT) and just_pressed:
		debugCamera = !debugCamera
		rotation = camRotation
	
	if Input.is_key_pressed(KEY_F2) and Input.is_key_pressed(KEY_SHIFT) and just_pressed:
		screenshot()
	
	if event is InputEventMouseMotion and debugCamera:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		yaw -= event.relative.x * 0.005
		pitch -= event.relative.y * 0.005

		pitch = clamp(pitch, -PI/2, PI/2)

		basis = Basis()
		rotate_object_local(Vector3.UP, yaw)
		rotate_object_local(Vector3.RIGHT, pitch)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func screenshot():
	await RenderingServer.frame_post_draw
	
	var number = checkImgNumber()
	var date = Time.get_date_string_from_system()
	var image = get_viewport().get_texture().get_image()
	image.save_png("user://Screenshots/" + date + " " + str(number) + ".png")

func checkImgNumber() -> int:
	var dir = DirAccess.open("user://Screenshots")
	var imgCount = 0
	
	for file in dir.get_files():
		var fileNumber = int(file.substr(11).replace(".png", ""))
		
		if imgCount <= fileNumber:
			imgCount = fileNumber + 1
	
	return imgCount
