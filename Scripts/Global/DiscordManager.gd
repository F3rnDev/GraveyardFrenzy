extends Node

class_name DiscordManager

static var running = false
static var default = {
	"details":"",
	"state":"",
	"large_image":"char_skelly",
	"small_image":"",
	"large_image_text":"",
	"small_image_text":""
}

static func setUp():
	DiscordRPC.app_id = 1349454926522093650
	running = true
	DiscordRPC.refresh()
	
	setData(default)

static func setData(data):
	if !running:
		setUp()
	
	var allowedKeys = ["details", "state", "large_image", "small_image", 
	"start_timestamp", "end_timestamp", "large_image_text", "small_image_text"]
	
	for key in allowedKeys:
		if key in data:
			DiscordRPC.set(key, data[key])
	
	DiscordRPC.refresh()
