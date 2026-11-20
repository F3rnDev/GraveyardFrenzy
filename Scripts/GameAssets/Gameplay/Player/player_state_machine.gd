extends Node

class_name PlayerStateMachine

const SectionTypes = SongSection.Types

@onready var player: Player = $".."
@onready var sprite: AnimatedSprite2D = $"../PlayerSprite"
@onready var debugDisplay: Label = $"../DebugStateDisplay"

enum States
{
	#Basic movement
	IDLEWALK, RUN, STOP, 
	JUMP, FALL, LAND, TRANSITION,
	#Note Hit
	HITNORMAL, HITHOLD, NOHIT,
	#Damage and Miss
	HURT, MISS, DEAD
}

#States that can trigger, even if the curState was already defined
var forcedStates:Array[States] = [States.NOHIT, States.HITNORMAL, States.MISS]
var curState:States = States.IDLEWALK:
	set(value):
		if curState == value and !forcedStates.has(curState):
			return
		curState = value
		stateChanged.emit(value)

signal stateChanged(newState:States)

#DEBUG
func displayDebugState():
	debugDisplay.text = States.find_key(curState)

#SETUP
func setState(state:States):
	curState = state

func _physics_process(_delta: float) -> void:
	if curState == States.HURT or curState == States.DEAD:
		displayDebugState()
		return
	
	match player.curSection:
		SectionTypes.RHYTHM: processRhythmStates()
		SectionTypes.RUNNER: processRunnerStates()
	
	displayDebugState()

#RhythmSection
func processRhythmStates():
	if !player.is_on_floor():
		return
	
	match curState:
		States.FALL: curState = States.LAND

#RunnerSection
func processRunnerStates():
	if player.is_on_floor(): processGroundStates()
	else: processAerialStates()

func processGroundStates():
	match curState:
		States.FALL: 
			curState = States.LAND
			return
		States.LAND: return
	
	#Check velocity
	if player.velocity.x == 0.0: curState = States.IDLEWALK
	elif player.velocity.x < 0.0: curState = States.STOP
	else: curState = States.RUN

func processAerialStates():
	if player.velocity.y > 0: curState = States.FALL
	else: curState = States.JUMP

#SIGNALS
func _on_player_sprite_animation_finished() -> void:
	match curState:
		States.LAND, States.HURT: 
			curState = States.IDLEWALK
		States.HITNORMAL, States.HITHOLD, States.NOHIT, States.MISS:
			curState = States.FALL
