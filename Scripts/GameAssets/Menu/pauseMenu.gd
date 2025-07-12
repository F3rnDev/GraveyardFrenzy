extends Control

@export_flags("Resume", "Main Menu", 
"Overworld", "Exit") var menuOptions = 0

var canPause = true
var paused = false
var selected = 0

var maxOptions = 0

var isMouse = false

var normalBtn
var hoverBtn

func _ready():
	$bg/Options.get_child(selected).grab_focus()
	
	normalBtn = $bg/Options.get_child(0).get_theme_stylebox("normal", "Button")
	hoverBtn  = $bg/Options.get_child(0).get_theme_stylebox("hover", "Button")
	
	setMenuOptions()
	selectOption(0)

func setMenuOptions():
	var options = $bg/Options.get_children()
	var menuCount = 0
	
	for i in range(options.size()):
		if !bool(menuOptions & (1 << i)):
			options[i].queue_free()
		else:
			menuCount += 1;
	
	maxOptions = menuCount-1
	print(maxOptions)

func _input(event):
	if event.is_action_pressed("Pause") and canPause:
		pauseGame()
	
	if paused:
		menuInput(event)

func menuInput(event):
	if event.is_action_pressed("CDown") or event.is_action_pressed("Down"):
		selectOption(1)
	elif event.is_action_pressed("CUp") or event.is_action_pressed("Up"):
		selectOption(-1)
	
	if event.is_action_pressed("Confirm"):
		menuAction()

func pauseGame():
	paused = !paused
	visible = paused
	get_tree().paused = paused
	
	if(paused):
		Engine.time_scale = 0
	else:
		Engine.time_scale = 1

func selectOption(select):
	if !isMouse:
		selected += select
	
	if selected < 0:
		selected = maxOptions
	elif selected > maxOptions:
		selected = 0
	
	for button in $bg/Options.get_children():
		button.release_focus()
		button.add_theme_stylebox_override("normal", normalBtn)
		button.set("theme_override_colors/font_color","#ffffff")
		
		if button.get_index() == selected:
			button.add_theme_stylebox_override("normal", hoverBtn)
			button.set("theme_override_colors/font_color","#000000")
		
		button.queue_redraw()

	isMouse = false

func menuAction():
	pauseGame()
	
	var curNode = self.get_parent().get_parent()
	var sceneManager = curNode.get_parent()
	
	var options = $bg/Options.get_children()
	var selected_option = options[selected].name if selected < options.size() else ""
	
	match selected_option:
		"Overworld":
			var overworld = load("res://Nodes/Scenes/overworld_state.tscn")
			sceneManager.switchScene(overworld, curNode)
		"MainMenu":
			var mainMenu = load("res://Nodes/Scenes/mainMenu.tscn")
			sceneManager.switchScene(mainMenu, curNode)
		"Exit":
			get_tree().quit()

func _on_mouse_entered(option):
	selected = option
	
	for button in $bg/Options.get_children():
		button.add_theme_stylebox_override("normal", normalBtn)
		button.set("theme_override_colors/font_color","#ffffff")
	
	isMouse = true

func _on_button_down():
	menuAction()
