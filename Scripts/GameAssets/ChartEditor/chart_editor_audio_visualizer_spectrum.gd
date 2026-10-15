extends Button

@export var audioSelector:ChartEditorAudioSelector

@export_category("AudioConfig")
@export var audioPlayer:AudioStreamPlayer
@export var audioBusStr: String = "Music"
@export var captureEffectId: int = 0

@export_category("Info&Warnings")
@export_multiline var dropFileText:String

@onready var audioSelectDialog: FileDialog = $AudioSelectFile

const sampleTotal = 4096
var frameArray: PackedFloat32Array = PackedFloat32Array()

var enteredMouse = false

func _ready() -> void:
	frameArray.resize(sampleTotal)
	frameArray.fill(0.0)
	
	if audioSelector.loadedAudio == null:
		text = dropFileText
	
	get_window().files_dropped.connect(_on_file_dragged)

func _process(_delta: float) -> void:
	if !audioPlayer or !audioPlayer.playing or audioSelector.loadedAudio == null:
		return
	
	loadBuffers()
	queue_redraw()

func _input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_0):
		if audioPlayer.playing:
			audioPlayer.stop()
		else:
			audioPlayer.play()

func loadBuffers():
	var musicBus = AudioServer.get_bus_index(audioBusStr)
	var audioCapture: AudioEffectCapture = AudioServer.get_bus_effect(musicBus, captureEffectId)
	
	var available = audioCapture.get_frames_available()
	if available <= 0:
		return
		
	var newFrames: PackedVector2Array = audioCapture.get_buffer(available)
	
	# Append incoming frames directly into our main linear array
	for frame in newFrames:
		var avgFrame = (frame.x + frame.y) * 0.5
		frameArray.append(avgFrame)
		
	# Slice away old data from the front so history remains exactly a fixed size
	while frameArray.size() > sampleTotal:
		frameArray.remove_at(0)

func _draw() -> void:
	if frameArray.size() <= 1 or enteredMouse or audioSelector.loadedAudio == null:
		return
	
	var waveformPoints = PackedVector2Array()
	waveformPoints.resize(frameArray.size())
	
	for point in range(frameArray.size()):
		var x = (float(point) / frameArray.size()) * size.x
		var y = remap(frameArray[point], -1.0, 1.0, size.y, 0.0)
		
		waveformPoints[point] = Vector2(x, y)
		
	if waveformPoints.size() > 1:
		draw_polyline(waveformPoints, Color.WHITE, 1.5, true)

#SetOscillator text
func _on_mouse_entered() -> void:
	enteredMouse = true
	
	if audioSelector.loadedAudio == null:
		return
	
	text = dropFileText

func _on_mouse_exited() -> void:
	enteredMouse = false
	
	if audioSelector.loadedAudio == null:
		return
	
	text = ""

func _on_pressed() -> void:
	audioSelectDialog.visible = true
	button_pressed = false
	release_focus()

#File drag
func _on_file_dragged(files:Array):
	#Check if only ONE file was dropped
	if files.size() > 1:
		return #Play a warning or something
	
	#Check if mouse is inside the block
	var mousePos = get_global_mouse_position()
	if !get_global_rect().has_point(mousePos):
		return #Play a warning or something
	
	#Check if an mp3 was dropped
	var file = files[0]
	if !file.ends_with(".mp3"):
		return #Play a warning or something
	
	audioSelector.loadFile(file)
