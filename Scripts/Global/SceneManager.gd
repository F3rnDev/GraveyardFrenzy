extends Node

static var songDiff
static var songName

func _ready():
	var firstScene = load("res://Nodes/Scenes/overworld_state.tscn")
	DataLoader.loadData()
	switchScene(firstScene)

func _process(delta):
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_DELETE):
		SongRating.eraseData()

func switchScene(sceneToAdd, sceneToDelete = null):
	if sceneToDelete != null:
		$transition.startFadeIn(sceneToAdd, sceneToDelete)
	else:
		var sceneNode = sceneToAdd.instantiate()
		add_child(sceneNode)

func _on_transition_faded(newScene, oldScene):
	remove_child(oldScene)
	var sceneNode = newScene.instantiate()
	add_child(sceneNode)
	
	$transition.startFadeOut(sceneNode)

func setSongProperties(curSong, curDiff):
	songName = curSong
	songDiff = curDiff

func getSongProperties():
	return [songName, songDiff]
