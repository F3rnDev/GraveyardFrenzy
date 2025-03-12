extends Node

static var songDiff
static var songName

func _ready():
	var firstScene = load("res://Nodes/Scenes/intro.tscn")
	DataLoader.loadData()
	DiscordManager.setUp()
	switchScene(firstScene)

func _process(delta):
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_DELETE):
		SongRating.eraseData()
	
	DiscordRPC.run_callbacks()

func switchScene(sceneToAdd, sceneToDelete = null):
	if sceneToDelete != null:
		$transition.startFadeIn(sceneToAdd, sceneToDelete)
	else:
		var sceneNode = sceneToAdd.instantiate()
		add_child(sceneNode)

func _on_transition_faded(newScene, oldScene):
	var sceneNode = newScene.instantiate()
	setNewScene(sceneNode, oldScene)
	
	$transition.startFadeOut(sceneNode)

func setNewScene(newScene, oldScene):
	remove_child(oldScene)
	add_child(newScene)

func setSongProperties(curSong, curDiff):
	songName = curSong
	songDiff = curDiff

func getSongProperties():
	return [songName, songDiff]
