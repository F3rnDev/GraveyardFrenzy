extends Node

@export var defaultInfo:DiscordInfo

func _ready() -> void:
	if OS.has_feature("web"):
		queue_free()
		return
	
	addDiscordManager()

func addDiscordManager():
	var managerFile = load("res://Nodes/Global/DiscordRPC/DiscordManager.tscn")
	
	var manager = managerFile.instantiate()
	manager.setUp(defaultInfo)
	
	get_tree().current_scene.add_child.call_deferred(manager)
	
	queue_free()
