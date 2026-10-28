extends AnimatedSprite2D

class_name GameElement

#References
var gameplayRef:GameplayScene
var conductorRef:Conductor = null
var elementRef:ChartElement = null

#Variables
var targetTime:float = 0.0
var scrollSpeed:float = 1.0
var elementOffset:float = 0.0 #strum bar position

func setup(gameplayScene:GameplayScene, element:ChartElement, time:float, yPos:float, scroll:float, Offset:float):
	gameplayRef = gameplayScene
	conductorRef = gameplayScene.conductor
	elementRef = element
	targetTime = time
	scrollSpeed = scroll
	elementOffset = Offset
	
	z_index = 1
	position.y = yPos
	
	moveElement() #SetNewPos

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if elementRef == null:
		return
	
	moveElement()

func moveElement():
	var curTime = targetTime - gameplayRef.getObjectPos(conductorRef.songPos)
	position.x = (curTime * scrollSpeed) + elementOffset
