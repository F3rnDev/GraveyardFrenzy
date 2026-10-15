extends Control

class_name NotificationWarning

signal cancelled
signal confirmed

func closeWindow() -> void:
	queue_free()
