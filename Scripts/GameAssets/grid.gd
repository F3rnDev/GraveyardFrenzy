extends Node2D

class_name NoteGrid

var chartEditor #Reference to the charting_state editor

var grid_size
var grid_color:Color

var gridSection = [] #Contains all the grid steps refering to the current song section
var allGrids = []
var selectedGrid #Currently selected grid

var sectionsTotal = 0 #Total sections in song
var sectionCur = 0 #Current section

var renderedNotes = []

var pressing:bool
var firstSelectedGrid
var selectedNotes = []

func _init(totalSection, editor, xPos, yPos, size):
	sectionsTotal = totalSection
	chartEditor = editor
	position.x = xPos
	position.y = yPos
	grid_size = size

func changeSection(curSection):
	sectionCur = curSection
	queue_redraw()

func moveGrid(xPos):
	position.x = xPos

func getGridSize():
	return (allGrids.size() / 2) * grid_size

func _draw():
	gridSection.clear()
	allGrids.clear()
	
	for i in sectionsTotal:
		drawGrid(i)
	
	if selectedGrid != null:
		selectGrid(selectedGrid)

func drawGrid(section):
	for step in range(16 * 2): 
		var col = step % 16
		var row = step / 16
		
		if (col + row) % 2 == 0: grid_color = Color.WHITE
		else: grid_color = Color.GRAY
		
		var sectionStartPos = section * grid_size * 16
		var gridPos = Rect2(sectionStartPos + (col * grid_size), (row * grid_size), grid_size, grid_size)
		
		if section != sectionCur: 
			grid_color *= 0.5
		else:
			gridSection.append([gridPos, grid_color])
		
		allGrids.append(gridPos)
		
		draw_rect(gridPos, grid_color)

func selectGrid(grid):
	if grid != null:
		grid[1] = Color.RED
		grid[1].a = 0.4
		draw_rect(grid[0], grid[1])

func _process(delta):
	var mousePos = get_global_mouse_position()
	mousePos.y -= position.y
	mousePos.x -= position.x
	
	var mouseOnGrid = false
	
	for grid in gridSection:
		if grid[0].has_point(mousePos):
			selectedGrid = grid
			mouseOnGrid = true
			
			if Input.is_action_just_pressed("LeftMouseClick"):
				chartEditor.noteAction(grid[0])
			elif Input.is_action_pressed("LeftMouseClick"):
				pressing = true
				
				var validateNote = (selectedNotes.size() > 0 
					and grid[0].position.y == selectedNotes[0].y
					and grid[0].position.x >= selectedNotes[0].x)
				
				if !selectedNotes.has(grid[0].position):
					if selectedNotes.size() == 0 or validateNote:
						selectedNotes.append(grid[0].position)
						selectedNotes.sort()
						chartEditor.holdAction(selectedNotes)
				else:
					if validateNote and grid[0].position.x < selectedNotes[selectedNotes.size()-1].x:
						selectedNotes.remove_at(selectedNotes.size()-1)
						chartEditor.holdAction(selectedNotes)
			else:
				pressing = false
			
			queue_redraw()
	
	if !mouseOnGrid:
		selectedGrid = null
		queue_redraw()
	
	if !pressing:
		selectedNotes.clear()

func selectNote(array):
	pressing = true
	for i in array:
		selectedNotes.append(i)

func updateGrid(notes):
	for note in renderedNotes:
		note.queue_free()
	
	renderedNotes.clear()
	
	for section in range(notes.size()):
		if notes[section].runnerSection:
			addObstacle(notes, section)
		else:
			addNote(notes, section)

func addObstacle(daNotes, section):
	for noteInfo in daNotes[section].sectionNotes:
		var xPos = noteInfo[0] + grid_size/2
		var yPos = (noteInfo[1]*grid_size) + grid_size/2
		
		#obstacle
		var obstacle = preload("res://Nodes/GameAssets/Gameplay/NoteSystem/obstacle.tscn").instantiate()
		obstacle.position = Vector2(xPos, yPos)
		obstacle.scale = Vector2(1.9, 1.9)
		obstacle.z_index = 1
		obstacle.play("default")
		add_child(obstacle)
		renderedNotes.append(obstacle)
		
		#set sprite to whatever the user wants.
		if noteInfo[1] == 1:
			obstacle.frame = 0
		else:
			obstacle.frame = 1

func addNote(daNotes, section):
	for noteInfo in daNotes[section].sectionNotes:
		var xPos = noteInfo[0] + grid_size/2
		var yPos = (noteInfo[1]*grid_size) + grid_size/2
		
		#note
		var noteSprite = preload("res://Nodes/GameAssets/Gameplay/NoteSystem/note.tscn").instantiate()
		noteSprite.position = Vector2(xPos, yPos)
		noteSprite.scale = Vector2(2, 2)
		noteSprite.z_index = 1
		noteSprite.play("default")
		add_child(noteSprite)
		renderedNotes.append(noteSprite)
		
		#noteFinalHold
		if noteInfo[2] != 0:
			var noteEnd = noteSprite.getHoldEnd()
			noteEnd.visible = true
			noteEnd.global_position.x = noteSprite.global_position.x + noteInfo[2]
			noteEnd.play("holdEnd")
			noteSprite.setHold()
