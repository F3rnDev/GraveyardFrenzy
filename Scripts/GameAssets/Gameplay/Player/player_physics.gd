extends Node

@onready var player: Player = $".."
@onready var animComponent: Node = $"../PlayerAnimation"

#Movement
const SPEED = 500.0
const jumpForce = 700.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var fastFallMultiplier = 2.0
@export var jumpBufferTime = 0.15
var jumpBufferTimer = 0

#GameOver
@export var deadFriction = 1000
var deathJumped = false
var deathSlid = false

#Actions being continually pressed
func _physics_process(delta):
	applyGravity(delta)
	
	if player.dead:
		deathPhysics(delta)
		return
	
	if !player.isRunnin:
		player.velocity = Vector2(0, player.velocity.y)
		return
	
	runnerMovement()
	runnerJump(delta)

#INPUT
func _input(event: InputEvent) -> void:
	getJumpInputs(event)

func getJumpInputs(event: InputEvent):
	#Set the jumpTimerBuffer (player jumps even if you've pressed it before touching the ground)
	if event.is_action_pressed("Jump"):
		jumpBufferTimer = jumpBufferTime
	
	#Hold jump functionality
	if event.is_action_released("Jump") and player.velocity.y < 0:
		player.velocity.y = 0

#GRAVITY
func applyGravity(delta):
	var fastFall = 1
	if player.velocity.y > 0:
		fastFall = fastFallMultiplier
	
	var canApplyGravity = ((animComponent.animated or player.dead or player.isRunnin) and !player.is_on_floor())
	if !canApplyGravity:
		player.velocity.y = 0
		return
	
	player.velocity.y += gravity * fastFall * delta

#PLAYER MOVEMENT
func runnerMovement():
	var input_dir = Input.get_vector(
		CInput.getInput("Left"), CInput.getInput("Right"), 
		CInput.getInput("Up"), CInput.getInput("Down")
	)
	
	var direction = (Vector2(input_dir.x, input_dir.y)).normalized()
	if direction:
		player.velocity.x = direction.x * SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, SPEED)

func runnerJump(delta):
	if jumpBufferTimer <= 0:
		return
	
	jumpBufferTimer -= delta
	
	#JumpAction
	if player.is_on_floor():
		player.velocity.y -= jumpForce
		jumpBufferTimer = 0

#DEATH
func playerKilled():
	deathJumped = false
	deathSlid = false

func deathPhysics(delta):
	if player.is_on_floor() and deathJumped:
		deathSlide(delta)
	elif !deathJumped:
		deathJump()

func deathJump():
	player.velocity = Vector2.ZERO
	player.velocity += Vector2(jumpForce/2, -jumpForce)
	
	if !player.is_on_floor():
		deathJumped = true

func deathSlide(delta):
	if deathSlid:
		return
	
	animComponent.resetDeadRotateTween()
	
	#Set slide animation
	if abs(player.velocity.x) > 10:
		player.velocity.x = move_toward(player.velocity.x, 0, deadFriction*delta)
		animComponent.playDeathSlideAnimation()
	elif abs(player.velocity.x) <= 10 and !deathSlid:
		player.velocity.x = 0
		deathSlid = true
		animComponent.playDeathFallAnimation()
