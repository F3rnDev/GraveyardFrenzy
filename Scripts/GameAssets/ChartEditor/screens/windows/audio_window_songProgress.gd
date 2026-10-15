extends HBoxContainer

@export var audioSelector:ChartEditorAudioSelector

@export var playBtnTexture:Texture
@export var pauseBtnTexture:Texture

@onready var playBtn = $PlayButton
@onready var songProgress = $ProgressBar
@onready var songProgressBtn = $ProgressBar/Button

var dragging = false
var inBar = false
var clicking = false

#Signals
signal play
signal stop
signal setPos(pos:float)

func _ready() -> void:
	playBtn.icon = playBtnTexture

func _process(_delta: float) -> void:
	if audioSelector.loadedAudio == null:
		return
	
	dragMusic()

func _input(_event: InputEvent) -> void:
	if audioSelector.loadedAudio == null:
		return
	
	if Input.is_action_just_pressed("LeftMouseClick") and inBar:
		clicking = true
	elif Input.is_action_just_released("LeftMouseClick") or !inBar:
		clicking = false

func dragMusic():
	if !dragging and !clicking:
		return
	
	var mouseX = get_local_mouse_position().x
	var startPosX = songProgress.position.x
	var endPosX = songProgress.position.x + songProgress.size.x
	
	var progress = clamp((mouseX - startPosX) / (endPosX - startPosX), 0.0, 1.0)
	
	var songPos = progress * songProgress.max_value
	
	setPos.emit(songPos)

func updateSongProgress(playbackPos):
	songProgress.value = playbackPos
	
	var btn_width = songProgressBtn.size.x
	var bar_width = songProgress.size.x
	
	var progress = playbackPos/songProgress.max_value
	songProgressBtn.position.x = progress * (bar_width - btn_width)

func setSongMaxLen(songLength:float):
	songProgress.max_value = songLength

func setPlayIcon():
	playBtn.icon = playBtnTexture

func setPauseIcon():
	playBtn.icon = pauseBtnTexture

func _on_play_button_button_down() -> void:
	play.emit()

func _on_button_button_down() -> void:
	dragging = true
	
	if audioSelector.audioPlayer.playing:
		stop.emit()

func _on_button_button_up() -> void:
	dragging = false

func _on_progress_bar_mouse_entered() -> void:
	inBar = true

func _on_progress_bar_mouse_exited() -> void:
	inBar = false
