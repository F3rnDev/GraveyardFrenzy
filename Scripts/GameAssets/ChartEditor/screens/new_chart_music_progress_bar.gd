extends HBoxContainer

@export var playBtnTexture:Texture
@export var pauseBtnTexture:Texture

@onready var playBtn = $PlayButton
@onready var songProgress = $ProgressBar
@onready var songProgressBtn = $ProgressBar/Button

@onready var songPreviewAudio = $SongPreviewAudio

var songToPlay:AudioStream = null
var lastSongPos:float = 0.0

var dragging = false
var inBar = false
var clicking = false

func _ready() -> void:
	playBtn.icon = playBtnTexture

func _process(_delta: float) -> void:
	if songToPlay == null:
		return
	
	dragMusic()
	updateSongProgress()

func _input(event: InputEvent) -> void:
	if songToPlay == null:
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
	
	lastSongPos = songPos

func updateSongProgress():
	var songPos = songPreviewAudio.get_playback_position()
	
	if !songPreviewAudio.playing:
		songPos = lastSongPos
	
	songProgress.value = songPos
	
	var btn_width = songProgressBtn.size.x
	var bar_width = songProgress.size.x
	
	var progress = songPos/songProgress.max_value
	songProgressBtn.position.x = progress * (bar_width - btn_width)

func setSongPreview(song:AudioStream):
	songToPlay = song
	
	songProgress.max_value = songToPlay.get_length()
	songPreviewAudio.stream = songToPlay
	
	lastSongPos = 0.0

func playSong():
	if songToPlay == null:
		return
	
	playBtn.icon = pauseBtnTexture
	songPreviewAudio.play(lastSongPos)

func stopSong():
	if songToPlay == null:
		return
	
	playBtn.icon = playBtnTexture
	
	if songPreviewAudio.playing:
		lastSongPos = songPreviewAudio.get_playback_position()
	
	songPreviewAudio.stop()

func _on_play_button_button_down() -> void:
	if !songPreviewAudio.playing:
		playSong()
	else:
		stopSong()

func _on_button_button_down() -> void:
	dragging = true
	
	if songPreviewAudio.playing:
		stopSong()

func _on_button_button_up() -> void:
	dragging = false

func _on_progress_bar_mouse_entered() -> void:
	inBar = true

func _on_progress_bar_mouse_exited() -> void:
	inBar = false
