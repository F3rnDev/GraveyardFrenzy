extends BoxContainer

class_name PlayerHealth
@onready var player: Player = $".."

@onready var healthFlash: Timer = $HealthFlash

@onready var container: HBoxContainer = $HeartContainer
@onready var heartGraph = preload("res://Nodes/GameAssets/Gameplay/Player/heart_graph.tscn")

var heartSprites:Array[AnimatedSprite2D] = []

func createHearts(health:int):
	for heart in range(health):
		var heartInstance = heartGraph.instantiate()
		container.add_child(heartInstance)
		heartSprites.append(heartInstance.get_child(0))
	
	if health == 0: return
	pivot_offset.x = 4.5 * health

func setHealthGraph(health:int):
	modulate.a = 1
	
	for i in range(heartSprites.size()):
		var sprite = heartSprites[i]
		
		if health <= i:
			sprite.play("NoLife")
		else:
			sprite.play("Life")
	
	var tween = create_tween()
	
	if health == 1:
		tween.tween_property(self, "modulate:a", 1, 1.5)
	else:
		tween.tween_property(self, "modulate:a", 0, 2.5)

func setHealthColor(color:Color):
	modulate = color

#Flash Health
func startFlash():
	healthFlash.start()

func flashHealth(health):
	if health > 1:
		setHealthColor(Color.WHITE)
		healthFlash.stop()
	else:
		setHealthColor(Color.RED if modulate == Color.WHITE else Color.WHITE)
		healthFlash.start()

func _on_health_flash_timeout() -> void:
	flashHealth(player.health)
