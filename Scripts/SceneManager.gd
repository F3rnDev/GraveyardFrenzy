extends Node

class_name SceneManager

static var songDiff
static var songName

@onready var loadingScene = preload("res://Nodes/Scenes/LoadingScreen.tscn")

@export_file("*.tscn") var firstScene = "res://Nodes/Scenes/intro.tscn"

static var instance = null

func _ready():
	instance = self
	DataLoader.loadData()
	switchScene(firstScene)

func _process(_delta):
	if Input.is_key_pressed(KEY_CTRL) and Input.is_key_pressed(KEY_DELETE):
		SongRating.eraseData()

func switchScene(sceneToAdd):
	if sceneToAdd == firstScene:
		loadScene(sceneToAdd)
		return
	
	$transition.startFadeIn(sceneToAdd)

func loadScene(scene):
	var loading = loadingScene.instantiate() as LoadingScreen
	loading.loaded.connect(setNewScene)
	add_child(loading)
	loading.load(scene)

func _on_transition_faded(newScene):
	for scene in $Scene.get_children():
		scene.queue_free()
	
	loadScene(newScene)

func setNewScene(scenePath):
	var loadedScene = ResourceLoader.load_threaded_get(scenePath)
	var sceneNode = loadedScene.instantiate()
	$Scene.add_child(sceneNode)
	
	for scene in $Scene.get_children():
		if scene != sceneNode:
			scene.queue_free()
	
	if scenePath != firstScene:
		$transition.startFadeOut(sceneNode)

#SONG
func setSongProperties(curSong, curDiff):
	songName = curSong
	songDiff = curDiff

func getSongProperties():
	return [songName, songDiff]

#DiscordRPC
func updateDiscordRPCInfo(data:DiscordInfo):
	var manager = get_node_or_null("DiscordManager")
	if manager != null:
		manager.setData(data)
