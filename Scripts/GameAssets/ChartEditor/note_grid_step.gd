extends VBoxContainer

@export var inScene = false

@onready var stepTexture = $StepTex
@onready var beatNumber = $StepTex/BeatNum

@onready var stepDivision = preload("res://Assets/Images/UI Images/ChartEditor/noteGridDivision1.png")
@onready var sectionDivision = preload("res://Assets/Images/UI Images/ChartEditor/noteGridDivision2.png")

func setStep(step:int):
	if step%16 == 0:
		var sectionNum = floor(step/16) + 1
		beatNumber.text = str(sectionNum)
		beatNumber.visible = true
	else:
		beatNumber.visible = false
	
	if step%4 == 0:
		stepTexture.texture = sectionDivision
		return
	
	stepTexture.texture = stepDivision

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if inScene:
		queue_free()
