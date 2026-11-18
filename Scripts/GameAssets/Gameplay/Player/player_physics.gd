extends Node

@onready var player: Player = $".."
@onready var animComponent: Node = $"../PlayerAnimation"
@onready var stateMachine: PlayerStateMachine = $"../PlayerStateMachine"

const PlayerStates = PlayerStateMachine.States
const SectionTypes = SongSection.Types

#PlayerStates where the gravity does not apply
var noGravityStates:Array[PlayerStates] = [
	PlayerStates.TRANSITION,
	PlayerStates.HITNORMAL,
	PlayerStates.HITHOLD,
	PlayerStates.NOHIT,
	PlayerStates.MISS
]

#Movement
const SPEED = 500.0
const jumpForce = 700.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var fastFallMultiplier = 2.0
@export var jumpBufferTime = 0.15
var jumpBufferTimer = 0

var moveDirection:Vector2

#GameOver
@export var deadFriction = 1000
var deathJumped = false
var deathSlid = false

#Actions being continually pressed
func _physics_process(delta):
	applyGravity(delta)
	
	if stateMachine.curState == PlayerStates.DEAD: #Change this if to account the state
		deathPhysics(delta)
		return
	
	processPlayerMovement(delta)

func processPlayerMovement(delta):
	if player.curSection != SectionTypes.RUNNER:
		player.velocity = Vector2(0, player.velocity.y)
		return
	
	runnerMovement()
	runnerJump(delta)

#INPUT
func _input(event: InputEvent) -> void:
	#Block input if not on runner section
	if player.curSection != SectionTypes.RUNNER: return
	
	getMovementInputs()
	getJumpInputs(event)

func getMovementInputs():
	var inputDir = Input.get_vector(
		CInput.getInput("Left"), CInput.getInput("Right"), 
		CInput.getInput("Up"), CInput.getInput("Down")
	)
	
	moveDirection = inputDir.normalized()

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
	
	var canApplyGravity = (!noGravityStates.has(stateMachine.curState) and !player.is_on_floor())
	if !canApplyGravity:
		player.velocity.y = 0
		return
	
	player.velocity.y += gravity * fastFall * delta

#PLAYER MOVEMENT
func runnerMovement():
	if moveDirection:
		player.velocity.x = moveDirection.x * SPEED
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
