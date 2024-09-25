extends Camera3D

@export var playerRef:CharacterBody3D
@export var minBounds:Vector2
@export var maxBounds:Vector2

var camOffset
@export var camSpeed:float

func _ready():
	camOffset = position - playerRef.position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position = position.slerp(setLimit(camOffset + playerRef.position), camSpeed*delta)
	
	if Input.is_key_pressed(KEY_F1) and Input.is_key_pressed(KEY_CTRL):
		print(global_position)

func setLimit(pos) -> Vector3:
	pos.x = clamp(pos.x, minBounds.x, maxBounds.x)
	pos.z = clamp(pos.z, minBounds.y, maxBounds.y)
	return pos
