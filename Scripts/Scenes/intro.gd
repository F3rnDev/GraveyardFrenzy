extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Confirm"):
		$Intro.seek(4, true)
		$Intro.speed_scale = 5.0


func _on_intro_animation_finished(anim_name):
	var overworld = load("res://Nodes/Scenes/mainMenu.tscn")
	var sceneManager = self.get_parent()
	sceneManager.switchScene(overworld, self)
