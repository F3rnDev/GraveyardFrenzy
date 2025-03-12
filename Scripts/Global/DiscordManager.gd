extends Node

class_name DiscordManager

static func setUp():
	DiscordRPC.app_id = 1349454926522093650 # Application ID
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.refresh()
