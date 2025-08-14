extends Control

@export var discInfo:DiscordInfo

func _ready() -> void:
	if SceneManager.instance != null:
		SceneManager.instance.updateDiscordRPCInfo(discInfo)

func _process(_delta):
	if Input.is_action_just_pressed("Confirm"):
		goToOverworld()

func goToOverworld():
	if SceneManager.instance != null:
		var overworld = "res://Nodes/Scenes/overworld_state.tscn"
		SceneManager.instance.switchScene(overworld)
	else:
		print("Error changing scene: Scene Manager is not present")

func _input(_event):
	var typeStr = "Enter"
	
	match CInput.curType:
		CInput.Type.XboxController:
			typeStr = "A"
		CInput.Type.Ps4Controller:
			typeStr = "X"
		CInput.Type.SwitchController:
			typeStr = "B"
	
	$"Press Enter".text = "- Press " + typeStr + " to Begin -"
