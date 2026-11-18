extends CharacterBody2D

class_name Player

#Components
@onready var stateMachine: PlayerStateMachine = $PlayerStateMachine
@onready var playerPhysics: Node = $PlayerPhysics
@onready var playerAnimation: Node = $PlayerAnimation
@onready var audio: Node = $Audio

#Objects
@onready var IFrames: Timer = $IFrames
@onready var sprite: AnimatedSprite2D = $PlayerSprite
@onready var healthContainer: Node2D = $Health
@onready var debugDisplay:Label = $DebugStateDisplay

#Trying to figure out how to sync animations to the rhythm
#@export var conductor:Conductor
const PlayerStates = PlayerStateMachine.States
const SectionTypes = SongSection.Types

var curSection:SectionTypes = SectionTypes.RHYTHM

#Health and Hurt mechanic
@export var health:int = 3
signal hurt
var flashTimer = Timer.new()
var healthFlash = Timer.new()

#Get press
var lastHitPress = null
var curHitPress = null

#Debug
func setDebugDisplay(canDisplay:bool):
	debugDisplay.visible = canDisplay

#Initial setup
func _ready():
	healthContainer.modulate.a = 0
	setupTimers()

func setupTimers():
	flashTimer.one_shot = false
	flashTimer.connect("timeout", flashPlayer)
	add_child(flashTimer)
	
	healthFlash.one_shot = false
	healthFlash.connect("timeout", flashHealth)
	add_child(healthFlash)

func setSection(section:SectionTypes):
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
	flashTimer.start(0.1)
	
	audio.playHurtSound()

func flashPlayer():
	if IFrames.is_stopped():
		sprite.visible = true;	
		flashTimer.stop()
	else:
		sprite.visible = !sprite.visible
		flashTimer.start(0.1)

func flashHealth():
	if health > 1:
		healthContainer.modulate = Color.WHITE
		healthFlash.stop()
	else:
		healthContainer.modulate = Color.RED if healthContainer.modulate == Color.WHITE else Color.WHITE
		healthFlash.start(0.5)

func setHealth(setTo):
	health = setTo

func addOrSubHealth(setTo):
	health += setTo
	setHealthGraph()

func setHealthGraph():
	healthContainer.modulate.a = 1
	
	for i in range(healthContainer.get_child_count()):
		var heartSprite = healthContainer.get_child(i)
		
		if health <= i:
			heartSprite.play("NoLife")
		else:
			heartSprite.play("Life")
	
	var tween = create_tween()
	
	if health == 1:
		healthFlash.start(0.5)
		tween.tween_property(healthContainer, "modulate:a", 1, 1.5)
	else:
		tween.tween_property(healthContainer, "modulate:a", 0, 2.5)

#GameOver
func killPlayer():
	stateMachine.setState(PlayerStates.DEAD)
	playerPhysics.playerKilled()
	healthContainer.visible = false

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
