extends Node2D

class_name MainMenuPicture

@onready var frontGround = $FrontGround
@onready var middleGround = $MiddleGround
@onready var backGround = $BackGround

var curAnimation:MainMenu.Options = MainMenu.Options.ADVENTURE
var isActive = false

func spawn():
	frontGround.play("Appear")
	middleGround.play("Appear")
	isActive = true

func setAnimation(animation:MainMenu.Options):
	curAnimation = animation
	
	if !isActive:
		return
	
	frontGround.play("Disappear")

func animateIdle():
	#Put the idle animations here :D
	pass

func _on_front_ground_animation_finished() -> void:
	var backGroundAnimations = backGround.sprite_frames.get_animation_names()
	
	match frontGround.animation:
		"Disappear":
			backGround.play(backGroundAnimations[curAnimation])
			frontGround.play("Appear")
		"Appear":
			frontGround.play("Idle")


func _on_middle_ground_animation_finished() -> void:
	middleGround.play("Idle")
