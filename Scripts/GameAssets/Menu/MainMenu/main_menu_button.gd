extends Button

@onready var buttonSprite = $AnimatedSprite2D
@onready var bopAnim = $AnimationPlayer

@export var curOption:MainMenu.Options
@export var animationsRef:MainMenuPicture

var optionString:String = "Adventure"

signal optionSelected(option:MainMenu.Options)

func _ready() -> void:
	setCurButton()

func setCurButton():
	match curOption:
		MainMenu.Options.ADVENTURE:
			optionString = "Adventure"
		MainMenu.Options.FREEPLAY:
			optionString = "Freeplay"
		MainMenu.Options.OPTIONS:
			optionString = "Options"
		MainMenu.Options.EXIT:
			optionString = "Exit"
	
	buttonSprite.play(optionString+"Idle")

func playBop():
	if buttonSprite.animation != optionString+"Selected":
		return
	
	bopAnim.play("bop")

func _on_focus_entered() -> void:
	buttonSprite.play(optionString+"Selected")
	animationsRef.setAnimation(curOption)

func _on_focus_exited() -> void:
	buttonSprite.play(optionString+"Idle")
	bopAnim.play("RESET")

func _on_mouse_entered() -> void:
	grab_focus()

func _on_button_down() -> void:
	optionSelected.emit(curOption)
