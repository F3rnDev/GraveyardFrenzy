extends Node

class_name AfterImageSpawner

@export_category("Dependencies")
@export var sprite:AnimatedSprite2D

@export_category("Parameters")
@export var spawnTime:float = 0.5
@export var startColor:Color = Color.WHITE
@export var fadeTime:float = 0.2
@export var fadeColor:Color = Color.WHITE

#Onready
@onready var afterImage = preload("res://Nodes/GameAssets/Particles/AfterImage/AfterImage.tscn")
@onready var spawnTimer: Timer = $SpawnTimer

var active:bool = false

func _ready() -> void:
	startTimer()

func setActive(isActive:bool):
	active = isActive
	startTimer()

func startTimer():
	if !active: return
	
	spawnTimer.wait_time = spawnTime
	spawnTimer.start()

func _on_spawn_timer_timeout() -> void:
	if !active: return
	
	spawnImage()
	spawnTimer.start()

func spawnImage():
	var imageInstance:AfterImage = afterImage.instantiate()
	add_child(imageInstance)
	imageInstance.setProperties(sprite.global_position, sprite.scale, fadeTime, startColor, fadeColor, sprite.flip_h, sprite.flip_v)
	imageInstance.setImage(getCurrentFrame())

func getCurrentFrame() -> Texture2D:
	var animName: StringName = sprite.animation
	var frameID: int = sprite.frame
	return sprite.sprite_frames.get_frame_texture(animName, frameID)
