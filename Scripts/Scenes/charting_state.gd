extends Node2D

class_name ChartEditor

var curSong

var totalSections = 0
@export var curSection:int
var lastSection:int

var noteGrid
@export var gridX:int
@export var gridY:int
@export var gridSize:int

var mouseInStrumLine = false
var mouseDragging = false
var saveMousePos = 0
@export var dragForce:float

@export var minZoom:float
@export var maxZoom:float

var curSongName = ""
var curDiff

@export var updateNotes:bool #change the notes if i add a new property to it
@export var propertyIndex:int
var propertyDefaultValue = 0

func _ready():
	setupSongList()

func setupSongList():
	$CanvasLayer/loadSongUI.visible = true
	$CanvasLayer/loadSongUI/ListSongs.clear() 
	
	var selectedSongId = 0 #if the item is disabled, select next item
	
	var songArray = FileSystem.getFolderNames("res://Assets/Songs")
	for songId in range(songArray.size()):
		$CanvasLayer/loadSongUI/ListSongs.add_item(songArray[songId])
		
		var isSongLoaded = []
		var audioExtensions = [".mp3", ".wav", ".ogg"]
		for ext in audioExtensions:
			var filePath = "res://Assets/Songs/" + songArray[songId] + "/" + songArray[songId] + ext
			isSongLoaded.append(ResourceLoader.exists(filePath))
		
		if !isSongLoaded.has(true):
			var unloadedMessage = " (Reopen the application)"
			$CanvasLayer/loadSongUI/ListSongs.set_item_disabled(songId, true)
			$CanvasLayer/loadSongUI/ListSongs.set_item_text(songId, songArray[songId] + unloadedMessage)
			
			if songId + 1 > $CanvasLayer/loadSongUI/ListSongs.get_item_count() - 1:
				selectedSongId = songId + 1
	
	if $CanvasLayer/loadSongUI/ListSongs.get_item_count() > selectedSongId:
		$CanvasLayer/loadSongUI/ListSongs.select(selectedSongId)

func _on_load_song_load_ui_button_down():
	var closeWindow = true
	var itemList = $CanvasLayer/loadSongUI/ListSongs
	if itemList.is_anything_selected():
		var itemId = itemList.get_selected_items()[0]
		var itemText = itemList.get_item_text(itemId)
		loadSong(itemText)
	else:
		if curSong == null:
			print("no song loaded, load a song or create a new one")
			closeWindow = false
		else:
			print("nothing selected, closing load window")
	
	if closeWindow:
		$CanvasLayer/loadSongUI.visible = false

func _on_add_song_button_down():
	$CanvasLayer/SelectSong.visible = true

func _on_select_song_file_selected(path):
	FileSystem.checkDirectory("res://Assets/Songs/", path.get_file().get_basename())
	
	var selectedFile = FileAccess.open(path, FileAccess.READ)	
	var fileBuffer = selectedFile.get_buffer(selectedFile.get_length())
	selectedFile.close()
	
	var savePath = "res://Assets/Songs/" + path.get_file().get_basename() + "/" + path.get_file()
	
	var saveTo = FileAccess.open(savePath, FileAccess.WRITE)
	saveTo.store_buffer(fileBuffer)
	saveTo.close()
	
	for diff in Difficulty.getAllDiffs():
		var songToLoad = $Song.Song.new()
		songToLoad.bpm = 80
		songToLoad.songName = path.get_file().get_basename()
		songToLoad.saveSong(path.get_file().get_basename(), songToLoad, Difficulty.getFileDiff(diff))
	
	$CanvasLayer/loadSongUI.visible = false

	loadSong(path.get_file().get_basename(), false, savePath, path)

func setupChartingState():
	totalSections = floor(($Conductor/Song.stream.get_length() / $Conductor.stepCrochet) / 16)
	setupGrid()
	changeSection()
	setDifficultyUI()

func setDifficultyUI():	
	var inputUI = $CanvasLayer/MusicInfoUI/TabContainer/SongInfo/SongDifficulty/Input
	var selectedDiff
	var allDiffs = Difficulty.getAllDiffs()
	
	inputUI.clear()
	
	for diff in range(allDiffs.size()):
		inputUI.add_item(allDiffs[diff])
		
		if allDiffs[diff] == curDiff:
			selectedDiff = diff
	
	inputUI.select(selectedDiff)

func loadSong(songToLoad, reloading = false, filePath = "", rawPath = ""):	
	$Conductor.songPos = 0
	
	if !reloading:
		curDiff = "Normal"
	
	curSong = $Song.Song.new().loadSong(songToLoad, Difficulty.getFileDiff(curDiff))
	
	var loadedResource
	
	if filePath != "":
		loadedResource = ResourceLoader.exists(filePath)
	else:
		loadedResource = true
	
	if curSong != null:
		$Conductor.setBpm(curSong.bpm)
		
		if !reloading:
			if loadedResource:
				var path = "res://Assets/Songs/" + curSong.songName + "/" + curSong.songName
				$Conductor.setSong(path)
			else:
				$Conductor.setSong(rawPath, false)
		
		print("Loaded Song: " + curSong.songName + ", With bpm: " + str(curSong.bpm))
		setupChartingState()
		loadUI()
	else:
		print("error loading song")

func setupGrid():
	if noteGrid != null:
		remove_child(noteGrid)
	
	noteGrid = NoteGrid.new(totalSections, self, gridX, gridY, gridSize)
	add_child(noteGrid)
	
	$StrumLine.position = Vector2(noteGrid.position.x, 
	noteGrid.position.y - ($StrumLine.get_size().y/5))
	
	if updateNotes:
		updateNoteInfo()
	
	noteGrid.updateGrid(curSong.notes)

func updateNoteInfo():
	for section in curSong.notes:
		for notes in section.sectionNotes:
			if notes.size()-1 < propertyIndex:
				notes.append(propertyDefaultValue)
				print("Updated Note Information")

func loadUI():
	$CanvasLayer/MusicInfoUI/TabContainer/SongInfo/SongName/input.text = curSong.songName
	$CanvasLayer/MusicInfoUI/TabContainer/SongInfo/SongBpm/input.value = curSong.bpm

func _process(delta):	
	if curSong != null:
		noteGrid.moveGrid(GetXFromSongBeat())

		controls()

		if $Conductor.songPos < 0:
			$Conductor.songPos = 0

		if $Conductor.songPos >= $Conductor/Song.stream.get_length():
			$Conductor.songPos = $Conductor/Song.stream.get_length()

		curSection = floor(($Conductor.songPos/$Conductor.stepCrochet)/16)
		if lastSection != curSection:
			changeSection()
		
		if $Conductor/Song.playing:
			$"CanvasLayer/Play Song".icon = preload("res://Assets/Images/UI Images/pauseIcon.png")
		else:
			$"CanvasLayer/Play Song".icon = preload("res://Assets/Images/UI Images/playIcon.png")

func GetXFromSongBeat():
	return - (($Conductor.songPos / $Conductor.stepCrochet) * gridSize) + gridX

func controls():
	var wheelInput = [Input.is_action_just_pressed("WheelUp"), 
					Input.is_action_just_pressed("WheelDown")]
	
	var isCtrl = Input.is_physical_key_pressed(KEY_CTRL)
	
	if wheelInput.has(true) and isCtrl:
		moveChart(wheelInput.find(true))
	elif wheelInput.has(true) and !isCtrl:
		zoomChart(wheelInput.find(true))
	
	if Input.is_action_pressed("LeftMouseClick") and (mouseInStrumLine or mouseDragging):
		dragChart(true)
	elif Input.is_action_pressed("MiddleMouseClick"):
		dragChart(false)
	else:
		mouseDragging = false

func moveChart(direction):
	$Conductor/Song.stop()
	
	match direction:
		0:#"Up"
			$Conductor.songPos = floor($Conductor.songPos / 
				$Conductor.stepCrochet) * $Conductor.stepCrochet
			
			$Conductor.songPos += $Conductor.stepCrochet
		1:#"Down"
			$Conductor.songPos = ceil($Conductor.songPos / 
				$Conductor.stepCrochet) * $Conductor.stepCrochet
			
			$Conductor.songPos -= $Conductor.stepCrochet

func zoomChart(direction):
	var zoomAmount = 0
	var canZoom = ((direction == 1 and $Camera2D.zoom >= Vector2(maxZoom, maxZoom)) 
				or (direction == 0 and $Camera2D.zoom < Vector2(minZoom, minZoom)))
	
	if canZoom:
		zoomAmount = 0.1
	
	match direction:
		0:#"Up"
			$Camera2D.zoom += Vector2(zoomAmount, zoomAmount)
		1:#"Down"
			$Camera2D.zoom -= Vector2(zoomAmount, zoomAmount)

func dragChart(dragByStrumLine):
	if !mouseDragging:
		saveMousePos = get_global_mouse_position().x
	
	$Conductor/Song.stop()
	mouseDragging = true
	
	var referencePos = saveMousePos
	if dragByStrumLine:
		referencePos = gridX
	
	var mousePos = floor((get_global_mouse_position().x - referencePos) / $StrumLine.position.x)
	$Conductor.songPos += mousePos * dragForce

func changeSection():
	lastSection = curSection
	noteGrid.changeSection(curSection)
	
	if curSection <= curSong.notes.size()-1:
		setSectionInfo()
	
	if curSong.notes.size() < curSection+1:
		curSong.notes.append($Song.SongSection.new())
		print("addedNewSection")

func noteAction(rect:Rect2):	
	var thereIsNote = false
	var strumTime = rect.position.x
	var noteData = floor(rect.position.y / gridSize)
	
	var notes = curSong.notes[curSection].sectionNotes
	
	for index in range(notes.size()):
		var fullNote = notes[index][0] + notes[index][2]
		if notes[index][0] <= strumTime and fullNote >= strumTime and notes[index][1] == noteData:
			thereIsNote = true
			if strumTime != fullNote or notes[index][2] == 0:
				deleteNote(index)
			else:
				selectNote(notes[index][0], rect.position.y, notes[index][2])
			break
	
	if !thereIsNote:
		addNote(strumTime, noteData)

func holdAction(posArray:Array):	
	var finalPos = posArray[posArray.size() - 1].x - posArray[0].x
	var strumTime = posArray[0].x
	var noteData = floor(posArray[0].y / gridSize) 
	
	var notes = curSong.notes[curSection].sectionNotes
	var noteId = -1
	
	for index in range(notes.size()):
		if notes[index][0] == strumTime and notes[index][1] == noteData:
			noteId = index
			break
	
	if noteId != -1:
		setHold(noteId, finalPos)

func setHold(id, hold):
	curSong.notes[curSection].sectionNotes[id][2] = hold
	noteGrid.updateGrid(curSong.notes)

func addNote(strum, data):	
	curSong.notes[curSection].sectionNotes.append([strum, data, 0.0])
	curSong.notes[curSection].sectionNotes.sort()
	noteGrid.updateGrid(curSong.notes)

func deleteNote(indexToDelete):
	curSong.notes[curSection].sectionNotes.remove_at(indexToDelete)
	noteGrid.updateGrid(curSong.notes)

func selectNote(strum, data, hold):
	var strumVec = Vector2(strum, data)
	var holdVec = Vector2(strum+hold, data)
	noteGrid.selectNote([strumVec, holdVec])

func _on_strum_area_mouse_entered():
	mouseInStrumLine = true

func _on_strum_area_mouse_exited():
	mouseInStrumLine = false


func _on_play_song_button_down():
	$Conductor.playSong(false)	
	$"CanvasLayer/Play Song".release_focus()

func _on_input_text_changed(new_text):
	curSongName = new_text


func _on_input_value_changed(value):
	curSong.bpm = value


func _on_save_song_button_down():
	if curSongName != "":			
		FileSystem.renameSongFiles("res://Assets/Songs/", curSong.songName, curSongName)
		
		for diff in Difficulty.getAllDiffs():
			var songLoaded = $Song.Song.new().loadSong(curSongName, Difficulty.getFileDiff(diff))
			songLoaded.songName = curSongName
			$Song.Song.new().saveSong(songLoaded.songName, songLoaded, Difficulty.getFileDiff(diff))
		
		curSong.songName = curSongName
		
		curSongName = ""
	
	$Song.Song.new().saveSong(curSong.songName, curSong, Difficulty.getFileDiff(curDiff))
	loadSong(curSong.songName, true)

func _on_load_song_info_ui_button_down():
	setupSongList()

func _on_input_item_selected(index):
	var inputDiff = $CanvasLayer/MusicInfoUI/TabContainer/SongInfo/SongDifficulty/Input
	if inputDiff.get_item_text(index) != curDiff:
		set_reload_song(true)
	else:
		set_reload_song(false)

func set_reload_song(set):
	$CanvasLayer/MusicInfoUI/SaveSong.visible = !set
	$CanvasLayer/MusicInfoUI/ReloadSong.visible = set

func _on_reload_song_button_down():
	var inputDiff = $CanvasLayer/MusicInfoUI/TabContainer/SongInfo/SongDifficulty/Input
	var diffId = inputDiff.get_selected_id()
	curDiff = inputDiff.get_item_text(diffId)
	
	set_reload_song(false)
	loadSong(curSong.songName, true)


func _on_section_input_item_selected(index):
	var inputSection = $CanvasLayer/MusicInfoUI/TabContainer/SectionInfo/sectionType/Input
	var sectionTypeId = inputSection.get_selected_id()
	var sectionType = inputSection.get_item_text(sectionTypeId)
	
	curSong.notes[curSection].runnerSection = (sectionType == "Runner")
	noteGrid.updateGrid(curSong.notes)

func setSectionInfo():
	var inputSection = $CanvasLayer/MusicInfoUI/TabContainer/SectionInfo/sectionType/Input
	var isRunner = curSong.notes[curSection].runnerSection
	
	if isRunner:
		inputSection.select(1)
	else:
		inputSection.select(0)
