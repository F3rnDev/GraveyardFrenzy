extends SongControlButton

@onready var pauseIcon = load("res://Assets/Images/UI Images/ChartEditor/PlayIcons3.png")

var playing = false

func setIcon():
	super.setIcon()
	
	if playing:
		icon = pauseIcon

func setPlaying(isToggled:bool):
	playing = isToggled
	setIcon()

func _on_toggled(toggled_on: bool) -> void:
	setPlaying(toggled_on)
