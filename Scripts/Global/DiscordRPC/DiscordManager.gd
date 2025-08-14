extends Node

var running = false

func _process(delta: float) -> void:
	DiscordRPC.run_callbacks()

func setUp(info):
	DiscordRPC.app_id = 1349454926522093650
	running = true
	DiscordRPC.refresh()
	
	setData(info)

func setData(data:DiscordInfo):
	if !running:
		setUp(data)
	
	#Set Data
	DiscordRPC.details = data.details
	DiscordRPC.state = data.state
	DiscordRPC.large_image = data.largeImageID
	DiscordRPC.small_image = data.smallImageID
	DiscordRPC.large_image_text = data.largeImageText
	DiscordRPC.small_image_text = data.smallImageText
	
	DiscordRPC.refresh()
