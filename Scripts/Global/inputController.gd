extends Node

#This script checks if you uses a controller/keyboard
#In the future, store the keybindings for the user :DDDDD
enum Type {Keyboard, Ps4Controller, XboxController, SwitchController}

var curType:Type = 0

func _input(event):	
	if event.is_pressed:
		handlePressInput(event)
	
	if event is InputEventJoypadMotion and abs(event.axis_value) > 0.5:
		setControllerType()

func handlePressInput(event):
	if event is InputEventKey:
		curType = Type.Keyboard
	elif event is InputEventJoypadButton:
		setControllerType()

func setControllerType():
	var controllerName = Input.get_joy_name(0)
	
	curType = Type.XboxController
	
	#check for contains
	if "PS4" in controllerName:
		curType = Type.Ps4Controller
	elif "Nintendo Switch" in controllerName:
		curType = Type.SwitchController

func checkInput(input:String, action:String) -> bool:
	var boolean = false
	
	match action:
		"justPressed":
			boolean = (Input.is_action_just_pressed(input) or 
			Input.is_action_just_pressed("C" + input))
		"justReleased":
			boolean = (Input.is_action_just_released(input) or 
			Input.is_action_just_released("C" + input))
		"pressed":
			boolean = (Input.is_action_pressed(input) or 
			Input.is_action_pressed("C" + input))
	
	return boolean

func getInput(input:String) -> String:
	var actualInput = input
	
	if curType != Type.Keyboard:
		actualInput = "C" + input
	
	return actualInput
