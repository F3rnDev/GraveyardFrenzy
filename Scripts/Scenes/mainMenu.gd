extends Control

class_name MainMenu

enum Options
{
	ADVENTURE,
	FREEPLAY,
	OPTIONS,
	EXIT
}

@onready var conductor:Conductor = $Conductor
@onready var mainMenuTransition = $"MainMenu Transition"

@export var discInfo:DiscordInfo
var menuMusicPath:String = "res://Assets/Audio/Music/Main Menu"
@export var menuMusicBpm:int = 120

var curScreen = 0

#Opening screen
@onready var enterTxt = $"OpeningScreen/Press Enter"
@onready var logoAnim = $OpeningScreen/LOGO/LogoAnim
@onready var labelAnim = $"OpeningScreen/Press Enter/LabelAnim"

#MainMenu Buttons
@onready var adventureOpt = $MenuOptions/Options/Adventure
@onready var freeplayOpt = $MenuOptions/Options/Freeplay
@onready var optionsOpt = $MenuOptions/Options/Options
@onready var exitOpt = $MenuOptions/Options/Exit

#MainMenu Animation
@onready var animations = $MenuOptions/AnimationContainer/MainMenuPicture

func _ready() -> void:
	if SceneManager.instance != null:
		SceneManager.instance.updateDiscordRPCInfo(discInfo)
	
	setConductor()
	
	#REMOVE EXIT BTN IN WEB
	if OS.has_feature("web"):
		exitOpt.queue_free()

func setConductor():
	conductor.setSong(menuMusicPath)
	conductor.setBpm(menuMusicBpm)
	conductor.playSong(false)

func transitionEnd():
	adventureOpt.grab_focus()

#SELECT OPTIONS
func selectOption(option:Options):
	match option:
		Options.ADVENTURE:
			goToOverworld()
		Options.EXIT:
			get_tree().quit()
		_:
			print("Option doesn't exist yet you dummy")

func goToOverworld():
	if SceneManager.instance != null:
		var overworld = "res://Nodes/Scenes/overworld_state.tscn"
		SceneManager.instance.switchScene(overworld)
	else:
		print("Error changing scene: Scene Manager is not present")

func _input(_event):
	var typeStr = "Enter"
	
	match CInput.curType:
		CInput.Type.XboxController:
			typeStr = "A"
		CInput.Type.Ps4Controller:
			typeStr = "X"
		CInput.Type.SwitchController:
			typeStr = "B"
	
	enterTxt.text = "- Press " + typeStr + " to Begin -"
	
	if Input.is_action_just_pressed("Confirm") and curScreen == 0:
		labelAnim.stop()
		mainMenuTransition.play("toMainMenu")
		curScreen += 1

func _on_conductor_beat_hit(songPos: Variant) -> void:
	logoAnim.play("idle")
	animations.animateIdle()
	
	adventureOpt.playBop()
	freeplayOpt.playBop()
	optionsOpt.playBop()
	exitOpt.playBop()
