extends Node

const PlayerStates = PlayerStateMachine.States
const SectionTypes = SongSection.Types

#Dependencies
@onready var player: Player = $".."
@onready var sprite: AnimatedSprite2D = $"../PlayerSprite"
@onready var afterImageSpawner: AfterImageSpawner = $"../AfterImageSpawner"
@onready var stateMachine: PlayerStateMachine = $"../PlayerStateMachine"

#Transition between runner and rhythm sections
var initPos:Vector2 #Player start position, go to this position when runner section is over
var runninTransitionTween: Tween

#Player animations
var rythmMovementTween:Tween

var missAnimations = []
var hitAnimations = []
var lastHitOrMissIndex := -1

#gameOver
var deadRotateTween:Tween

##SETUP
func _ready():
	sprite.play("Walk")
	initPos = player.global_position
	
	setupAnimations()

func setupAnimations():
	var allAnim = sprite.sprite_frames.get_animation_names()
	
	for animation:String in allAnim:
		if animation.begins_with("Attack0"): hitAnimations.append(animation)
		elif animation.begins_with("Miss0"): missAnimations.append(animation)

##RUNNER/RHYTHM TRANSITION
func runnerRhythmTransition():
	var rhythmAndUndead = (player.curSection == SectionTypes.RHYTHM and
	stateMachine.curState != stateMachine.States.DEAD)
	
	if player.global_position != initPos and rhythmAndUndead:
		runninTransitionTween = create_tween()
		runninTransitionTween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		runninTransitionTween.tween_property(player, "global_position", initPos, 0.5)
		
		#Animate While tweening
		if player.is_on_floor():
			if player.global_position.x >= initPos.x:
				sprite.play("Hold")
			elif player.global_position.x < initPos.x:
				sprite.play("Run")
			
		else: sprite.play("transitionToRhythm")
		
		afterImageSpawner.setActive(true)
		
		await runninTransitionTween.finished
		
		afterImageSpawner.setActive(false)
		stateMachine.setState(PlayerStates.LAND)

##PLAYER ANIMATIONS
func _on_player_state_machine_state_changed(newState: PlayerStates) -> void:
	startAnimation(newState)
func startAnimation(newState: PlayerStates):
	match newState:
		PlayerStates.IDLEWALK: sprite.play("Walk")
		PlayerStates.RUN: sprite.play("Run")
		PlayerStates.STOP: sprite.play("Hold")
		
		PlayerStates.JUMP: sprite.play("jump")
		PlayerStates.FALL: sprite.play("fall")
		PlayerStates.LAND: sprite.play("land")
		
		PlayerStates.NOHIT:
			playNoHitAnim(player.curHitPress)
			player.lastHitPress = player.curHitPress
		PlayerStates.HITNORMAL:
			playNormalHitAnim(player.curHitPress)
			player.lastHitPress = player.curHitPress
		PlayerStates.HITHOLD:
			playHoldHitAnim()
			player.lastHitPress = player.curHitPress
		
		PlayerStates.TRANSITION: runnerRhythmTransition()
		
		PlayerStates.HURT: sprite.play("Hurt")
		PlayerStates.MISS: playMissAnimation()
		PlayerStates.DEAD: playerKilled()

##PLAYER HIT/NOHIT ANIMATIONS
func playNoHitAnim(note):
	sprite.stop()
	sprite.frame = 0
	
	var downHit = (note == 1 and player.lastHitPress == 0)
	
	if downHit:
		sprite.play("AttackDown")
	else:
		sprite.play("jump")

func playNormalHitAnim(note):
	sprite.stop()
	sprite.frame = 0
	
	var downHit = (note == 1 and player.lastHitPress == 0)
	
	if downHit:
		sprite.play("AttackDown")
		return
	
	if sprite.animation == "AttackHold":
		sprite.play("Attack01")
	else:
		sprite.play(getRandomHitOrMissAnimation())

func playHoldHitAnim():
	sprite.play("AttackHold")

func movePlayerToStrumPos(note, strumLine):
	var strumPos = strumLine.get_child(note).global_position
	
	rythmMovementTween = create_tween()
	rythmMovementTween.set_ease(Tween.EASE_OUT)
	rythmMovementTween.set_trans(Tween.TRANS_BACK)

	rythmMovementTween.tween_property(player, "global_position:y", strumPos.y, 0.1)

##PLAYER MISS ANIMATIONS
func playMissAnimation():
	sprite.stop()
	sprite.frame = 0
	
	var animationToPlay = "Miss01"
	if sprite.animation != "AttackHold":
		animationToPlay = getRandomHitOrMissAnimation("Miss")
	
	sprite.play(animationToPlay)

##PLAYER KILL ANIMATION
func playerKilled():
	deadRotateTween = create_tween()
	deadRotateTween.tween_property(player, "rotation", deg_to_rad(90.0), 1.0)

func resetDeadRotateTween():
	if player.rotation != 0.0:
		deadRotateTween.kill()
		player.rotation = 0.0

func playDeathSlideAnimation():
	sprite.play("deathSlide")

func playDeathFallAnimation():
	sprite.play("deathFall")

func getRandomHitOrMissAnimation(animType: String = "Hit") -> String:
	var curAnimations = hitAnimations if animType == "Hit" else missAnimations
	var count = curAnimations.size()

	var index = randi_range(0, count - 2)

	if index >= lastHitOrMissIndex:
		index += 1

	lastHitOrMissIndex = index
	return curAnimations[index]
