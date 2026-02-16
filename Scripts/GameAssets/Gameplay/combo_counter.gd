extends MarginContainer

@onready var background = $Background
@onready var comboValueLbl = $Background/ComboValue
@onready var comboTxtLbl = $Background/ComboLabel

@onready var textAnim = $Background/TextAnim
@onready var bopAnim = $bopAnim

@onready var sickParticles = $sickParticles

@export var minCombo = 10
@export var sickCombo = 50

var appeared = false
var runnerSection = false
var curCombo = 0

func _ready() -> void:
	background.visible = false
	background.play("Rythm")
	
	sickParticles.emitting = true
	sickParticles.z_index = -1

# Called when the node enters the scene tree for the first time.
func updateCounter(combo:int):
	curCombo = combo
	
	if curCombo < minCombo:
		if !runnerSection:
			appeared = false
			bopAnim.play("disappear")
			sickParticles.z_index = -1
		else:
			background.visible = true
			setTextVisible(false)
		
		return
	
	if curCombo >= sickCombo:
		modulate = Color.RED
		sickParticles.z_index = 0
	else:
		modulate = Color.WHITE
		sickParticles.z_index = -1
	
	if !appeared:
		bopAnim.play("appear")
		background.visible = true
		setTextVisible(true)
	
	comboValueLbl.text = str(curCombo)
	
	textAnim.stop()
	if !runnerSection:
		textAnim.play("changeValue")
	else:
		textAnim.play("changeValueRunner")

func setTextVisible(isVisible:bool):
	comboValueLbl.visible = isVisible
	comboTxtLbl.visible = isVisible

func setRunnerSection(runner:bool):
	if runnerSection == runner:
		return
	
	runnerSection = runner
	
	if runnerSection:
		transitionToRunner()
	else:
		transitionToRythm()

func transitionToRunner():
	if curCombo < minCombo and !appeared:
		background.visible = true
		setTextVisible(false)
		bopAnim.play("appear")
	
	textAnim.play("rythmToRunner")
	background.play("RunnerTrans")

func transitionToRythm():
	if curCombo < minCombo:
		appeared = false
		bopAnim.play("disappear")
	
	textAnim.play("runnerToRythm")
	background.play("RythmTrans")

func playBop():
	if appeared:
		bopAnim.stop()
		bopAnim.play("bop")

func _on_bop_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "appear":
		appeared = true
	elif anim_name == "disappear":
		background.visible = false
