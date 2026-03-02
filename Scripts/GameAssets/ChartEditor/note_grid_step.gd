extends VBoxContainer

@export var inScene = false

@onready var stepTexture = $StepDivision/StepTex
@onready var beatNumber = $StepDivision/StepTex/BeatNum
@onready var separator = $SeparatorGrp

@onready var laneUp = $LaneUp
@onready var laneDown = $LaneDown

@onready var stepDivision = preload("res://Assets/Images/UI Images/ChartEditor/noteGridDivision1.png")
@onready var beatDivision = preload("res://Assets/Images/UI Images/ChartEditor/noteGridDivision2.png")
@onready var sectionDivision = preload("res://Assets/Images/UI Images/ChartEditor/noteGridDivision3.png")

func setStep(step:int):
	beatNumber.visible = false
	separator.visible = false
	stepTexture.texture = stepDivision
	
	if step%16 == 0:
		var sectionNum = floor(step/16) + 1
		beatNumber.text = str(sectionNum)
		beatNumber.visible = true
		
		stepTexture.texture = sectionDivision
		separator.visible = true
		
		return
	
	if step%4 == 0:
		stepTexture.texture = beatDivision

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if inScene:
		queue_free()
