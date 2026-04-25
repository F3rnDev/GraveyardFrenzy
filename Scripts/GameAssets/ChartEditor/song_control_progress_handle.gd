extends ColorRect

@onready var expandSong = $ExpandSong

@export var conductor:Conductor
@export var rendElements:ChartUIRenderedObjects
@export var gridInfo:GridInfo

var dragging = false

#RETHINKING THE RESIZING FEATURE
#WILL NEED TO CHANGE HOW THE GRID IS RENDERED btw (use _draw instead of adding step nodes)
#var resizing = false
#var minVisibleTime = 0.5
#
#signal resize(newVisibleTime:float)

#func _ready() -> void:
	#expandSong.gui_input.connect(_on_expand_gui_input)

func _process(_delta):
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				updateSongTime(event.position.x)
	
	if event is InputEventMouseMotion and dragging:
		updateSongTime(event.position.x)

func updateSongTime(mouseX: float):
	var percentage = clamp(mouseX / size.x, 0.0, 1.0)
	var target_time = percentage * conductor.songLength
	
	conductor.songPos = target_time

#func _on_expand_gui_input(event:InputEvent) -> void:
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#resizing = event.pressed
			#expandSong.color = Color.YELLOW if resizing else Color.WHITE
	#
	#if event is InputEventMouseMotion and resizing:
		#updateVisibleTime()
#
#func updateVisibleTime():
	#var mouseX = get_local_mouse_position().x
	#var handleX = (conductor.songPos / conductor.songLength) * size.x
	#var newHandleWidth = mouseX - handleX
	#
	#var newVisibleTime = (newHandleWidth * conductor.songLength) / size.x
	#
	#var visibleTime = max(minVisibleTime, newVisibleTime)
	#
	#var viewW = get_viewport_rect().size.x
	#var newStepSize = (viewW * conductor.stepCrochet) / visibleTime
	#resize.emit(newStepSize)

func _draw() -> void:
	#Check if invalid songLength
	#no songLength = no song
	if conductor.songLength <= 0.0:
		return
	
	#Set visible Time
	var pixelsPerSec = gridInfo.stepSize * (1.0 / conductor.stepCrochet)
	var viewSize = get_viewport_rect().size.x + rendElements.initPos
	var visibleTime = viewSize / pixelsPerSec
	
	#Set Handle info
	var handleX = (conductor.songPos / conductor.songLength) * size.x
	var handleWidth = (visibleTime / conductor.songLength) * size.x
	
	#Set and Draw Rect
	var handleRect = Rect2(handleX, 0.0, handleWidth, size.y)
	draw_rect(handleRect, Color(1, 1, 1, 0.3))
	
	#Set ExpandRect
	expandSong.position.x = handleX + handleWidth
	
