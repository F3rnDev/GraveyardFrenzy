extends CharacterBody2D

class_name Player

#Components
@onready var stateMachine: PlayerStateMachine = $PlayerStateMachine
@onready var playerPhysics: Node = $PlayerPhysics
@onready var playerAnimation: Node = $PlayerAnimation
@onready var audio: Node = $Audio
@onready var healthComponent: PlayerHealth = $Health

#Objects
@onready var IFrames: Timer = $IFrames
@onready var flashTimer: Timer = $FlashTimer
@onready var sprite: AnimatedSprite2D = $PlayerSprite
@onready var debugDisplay:Label = $DebugStateDisplay

#Trying to figure out how to sync animations to the rhythm
#@export var conductor:Conductor
const PlayerStates = PlayerStateMachine.States
const SectionTypes = SongSection.Types

var curSection:SectionTypes = SectionTypes.RHYTHM

#Health and Hurt mechanic
@export var health:int = 3
signal hurt

#Get press
var lastHitPress = null
var curHitPress = null

#Debug
func setDebugDisplay(canDisplay:bool):
	debugDisplay.visible = canDisplay

#Initial setup
func _ready():
	healthComponent.modulate.a = 0
	healthComponent.createHearts(health)

func setSection(section:SectionTypes):
	if stateMachine.curState == PlayerStates.DEAD: return
	
	curSection = section
	stateMachine.setState(PlayerStates.TRANSITION)

func _physics_process(delta):
	move_and_slide()

#Player hurt/health logic
func canBeHurt():
	if curSection == SectionTypes.RUNNER and IFrames.is_stopped() and stateMachine.curState != PlayerStates.DEAD:
		playerHurt()

func playerHurt():
	stateMachine.setState(PlayerStates.HURT)
	
	addOrSubHealth(-1)
	hurt.emit()
	IFrames.start()	
	flashTimer.start()
	
	audio.playHurtSound()

func flashPlayer():
	if IFrames.is_stopped():
		sprite.visible = true;	
		flashTimer.stop()
	else:
		sprite.visible = !sprite.visible
		flashTimer.start()

func setHealth(setTo):
	health = setTo

func addOrSubHealth(setTo):
	health += setTo
	healthComponent.setHealthGraph(health)
	
	if health == 1:
		healthComponent.startFlash()

#GameOver
func killPlayer():
	stateMachine.setState(PlayerStates.DEAD)
	playerPhysics.playerKilled()
	healthComponent.visible = false

#PLAYER HIT ANIMATION
func setNoHitAnim(note, strumLine):
	if shouldBlockNoHit(note):
		return
	
	curHitPress = note
	
	stateMachine.setState(PlayerStates.NOHIT)
	playerAnimation.movePlayerToStrumPos(note, strumLine)
	audio.playNoHitSound(note)

func shouldBlockNoHit(note):
	var sameNote = lastHitPress == note
	var isFall = stateMachine.curState == PlayerStates.FALL
	var strumDownHit = is_on_floor() and note == 1
	
	return (sameNote or isFall or strumDownHit)

func setHitAnim(note, strumLine, hold=false):
	curHitPress = note
	
	stateMachine.setState(PlayerStates.HITHOLD if hold else PlayerStates.HITNORMAL)
	playerAnimation.movePlayerToStrumPos(note, strumLine)

func setMissAnimation():
	stateMachine.setState(PlayerStates.MISS)

#signals
func _on_player_state_machine_state_changed(newState: PlayerStates) -> void:
	if curSection == SectionTypes.RUNNER: return
	
	if newState == PlayerStates.LAND or newState == PlayerStates.IDLEWALK:
		curHitPress = null
		lastHitPress = null

func _on_flash_timer_timeout() -> void:
	flashPlayer()
