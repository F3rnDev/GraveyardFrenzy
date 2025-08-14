extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("Confirm"):
		$Intro.speed_scale = 10.0

func _on_intro_animation_finished(_anim_name):
	if SceneManager.instance != null:
		var overworld = "res://Nodes/Scenes/mainMenu.tscn"
		SceneManager.instance.switchScene(overworld)
	else:
		print("Error changing scene: Scene Manager is not present")
