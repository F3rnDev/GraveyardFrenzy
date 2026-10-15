extends VBoxContainer

class_name NotificationMessage

#Onready
@onready var animation: AnimationPlayer = $Animation
@onready var container:PanelContainer = $PanelContainer
@onready var messageIcon: TextureRect = $PanelContainer/HBoxContainer/TextureRect
@onready var messageLbl: Label = $PanelContainer/HBoxContainer/Label
@onready var messageTimer: Timer = $Timer

@export var checkIcon:Texture
@export var errorIcon:Texture

enum Types {
	Success,
	Error
}

var typeMap:Dictionary = {
	Types.Success: preload("res://Assets/Images/UI Images/notificationIcon1.png"),
	Types.Error: preload("res://Assets/Images/UI Images/notificationIcon2.png")
}

func popupMessage(type:Types, message:String):
	messageIcon.texture = typeMap[type]
	messageLbl.text = message
	animation.play("popup")
	
	messageTimer.start()
	
	if type == Types.Error:
		container.modulate = Color.RED
	
	tweenPopupMessage()

func removeMessage():
	animation.play("remove")
	tweenRemoveMessage()

func tweenPopupMessage():
	container.position.x = 100.0
	
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(container, "position:x", -10.0, 0.5)

func tweenRemoveMessage():
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_property(container, "position:y", -300.0, 0.5)

#SIGNALS
func _on_animation_animation_finished(anim_name: StringName) -> void:
	if anim_name == "remove":
		queue_free()

func _on_timer_timeout() -> void:
	removeMessage()

func _on_button_button_down() -> void:
	removeMessage()
