extends Control

var paused = false
var selected = 0

var maxOptions = 0

var isMouse = false

var normalBtn
var hoverBtn

func _ready():
	maxOptions = $bg/Options.get_child_count()-1
	$bg/Options.get_child(selected).grab_focus()
	
	normalBtn = $bg/Options.get_child(0).get_theme_stylebox("normal", "Button")
	hoverBtn  = $bg/Options.get_child(0).get_theme_stylebox("hover", "Button")
	
	selectOption(0)

func _input(event):
	if event.is_action_pressed("Pause"):
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
	
	match selected:
		1:
			#CHANGE TO THE MAIN MENU
			var mainMenu = load("res://Nodes/Scenes/overworld_state.tscn")
			sceneManager.switchScene(mainMenu, curNode)
		2:
			get_tree().quit()

func _on_mouse_entered(option):
	selected = option
	
	for button in $bg/Options.get_children():
		button.add_theme_stylebox_override("normal", normalBtn)
		button.set("theme_override_colors/font_color","#ffffff")
	
	isMouse = true

func _on_button_down():
	menuAction()
