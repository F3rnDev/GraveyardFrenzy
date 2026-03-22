extends VBoxContainer

class_name NoteGridStep

var thisStep = 0

@export var inScene = false

@onready var stepTexture = $StepDivision/StepTex
@onready var beatNumber = $StepDivision/StepTex/BeatNum
@onready var separator = $SeparatorGrp

@onready var laneUp = $LaneUp
@onready var laneDown = $LaneDown

@onready var stepDivision = preload("res://Assets/Images/UI Images/ChartEditor/noteGridDivision1.png")
@onready var beatDivision = preload("res://Assets/Images/UI Images/ChartEditor/noteGridDivision2.png")
@onready var sectionDivision = preload("res://Assets/Images/UI Images/ChartEditor/noteGridDivision3.png")

#0 = upLane, 1 = downLane
signal btnEntered(pos:Vector2)
signal btnExited()

signal btnPressed(pos:Vector2)

func setStep(step:int):
	thisStep = step
	
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

#Button entered
func _on_lane_up_mouse_entered() -> void:
	btnEntered.emit(laneUp.global_position)

func _on_lane_up_mouse_exited() -> void:
	btnExited.emit()

func _on_lane_down_mouse_entered() -> void:
	btnEntered.emit(laneDown.global_position)

func _on_lane_down_mouse_exited() -> void:
	btnExited.emit()

#Button pressed
func _on_lane_up_button_down() -> void:
	btnPressed.emit(laneUp.global_position)

func _on_lane_down_button_down() -> void:
	btnPressed.emit(laneDown.global_position)
