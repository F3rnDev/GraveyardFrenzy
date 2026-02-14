extends Control

class_name PopupScore

@onready var animation = $spawnAnim
@onready var sprite = $Graphic
@onready var timingLabel = $Timing

@export var yOffset = 200
@export var xOffset = 250.0

@export var noteTextures:Dictionary[String, Texture]

func setPopup(notePos, rating, timing, canShowTiming):
	global_position = Vector2(xOffset, notePos.y - yOffset)
	animation.play("spawn")
	sprite.texture = noteTextures[rating]
	
	if canShowTiming:
		showTiming(timing, rating)

func showTiming(timing, rating):
	var textColor = Color.WHITE
	var timingDesc = ""
	var timingText = str(snapped(abs(timing), 0.01))
	
	#DEFINE TEXT COLOR
	match rating:
		"bad":
			textColor = Color.RED
		"good":
			textColor = Color.YELLOW
		"perfect":
			textColor = Color.GREEN
	
	#CHECK IF TIMING IS EARLY OR LATE
	if timing > 60:
		timingDesc = "\n(too early)"
	elif timing < -60:
		timingDesc = "\n(too late)"
	else:
		""
	
	#UPDATE TEXT
	timingLabel.text = timingText + " ms" + timingDesc
	timingLabel.set("theme_override_colors/font_color", textColor)


func _on_spawn_anim_animation_finished(_anim_name: StringName) -> void:
	queue_free()
