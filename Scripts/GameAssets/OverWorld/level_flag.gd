extends Node3D

@export var songName:String
@export var songAuthor:String
@export var songPlayMin:float
@export var songPlayMax:float

var enteredArea = false

var songStream

# Called when the node enters the scene tree for the first time.
func _ready():
	$flagViewport/flag.play("default")
	$stageViewport/stage.play("default")
	checkSongClear()

#PLACEHOLDER FUNCTIONALITY
func checkSongClear():
	var clearedSong = false
	for diff in Difficulty.getAllDiffs():
		var diffId = Difficulty.getAllDiffs().find(diff)
		var rating = SongRating.getSongRating(songName, Difficulty.getAllDiffs()[diffId])
		
		if rating != "":
			clearedSong = true
	
	if !clearedSong:
		$flagViewport/flag.visible = false

func _process(delta):
	if Input.is_action_just_pressed("Confirm") and enteredArea and !OverworldRef.instance.inMenu:
		OverworldRef.instance.openSongUI(songName, songAuthor, [songPlayMin, songPlayMax])

func _on_area_area_entered(area):
	if area.get_parent().is_in_group("player"):
		enteredArea = true

func _on_area_area_exited(area):
	enteredArea = false
