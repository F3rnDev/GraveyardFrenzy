extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Confirm"):
		var overworld = load("res://Nodes/Scenes/overworld_state.tscn")
		var sceneManager = self.get_parent()
		sceneManager.switchScene(overworld, self)
