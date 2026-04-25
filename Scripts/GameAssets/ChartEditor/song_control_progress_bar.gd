extends ColorRect

@export var conductor:Conductor
@export var rendElements:ChartUIRenderedObjects

@export var objMinWidth:float = 2.0
@export var objHeight:float = 8.0
@export var lanes:float = 3.0

func _process(_delta):
	queue_redraw()

func _draw() -> void:
	if not conductor and not rendElements:
		return
	
	for object in rendElements.get_children():
		var pos:float = 0.0
		var lane:int = 0
		var duration:float = 0.0
		
		var objColor = Color.RED
		
		#Set variables
		if object is ChartUINote:
			pos = object.noteData.position
			lane = object.noteData.lane
			duration = object.noteData.holdAmount
		
		elif object is ChartUIObstacle:
			pos = object.obsData.position
			lane = object.obsData.lane
			
			objColor = Color.WHITE
		
		elif object is ChartUIEvent:
			pos = object.eventData.position
			lane = 2
		
		#Set Pos
		var xPos = (pos / conductor.songLength) * size.x
		var yPos = (lane / lanes) * size.y
		
		#Set Size
		var durationPx = (duration / conductor.songLength) * size.x
		var xWidth = max(objMinWidth, durationPx)
		
		#SetRect
		var rect = Rect2(xPos, yPos, xWidth, objHeight)
		draw_rect(rect, objColor, false, objMinWidth/2)
