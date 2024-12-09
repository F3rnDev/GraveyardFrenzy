extends Control

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Confirm"):
		var overworld = load("res://Nodes/Scenes/overworld_state.tscn")
		var sceneManager = self.get_parent()
		sceneManager.switchScene(overworld, self)

func _input(event):
	var typeStr = "Enter"
	
	match CInput.curType:
		CInput.Type.XboxController:
			typeStr = "A"
		CInput.Type.Ps4Controller:
			typeStr = "X"
		CInput.Type.SwitchController:
			typeStr = "B"
	
	$"Press Enter".text = "- Press " + typeStr + " to Begin -"
