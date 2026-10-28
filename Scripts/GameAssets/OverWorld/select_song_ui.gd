extends VBoxContainer

@onready var songNamePanel: PanelContainer = $SongNameContainer
@onready var songName: Label = $SongNameContainer/name

@onready var extrasPanel: PanelContainer = $ExtrasInfo
@onready var songDiff: Label = $ExtrasInfo/HBoxContainer/SongDiff

var songMetadata:SongData = null
var selectedDiff:int = 0

func _ready() -> void:
	hideName()
	hideExtras()

func setData(newMetadata:SongData):
	songMetadata = newMetadata

#Names
func displayName():
	if songMetadata == null: return
	songNamePanel.visible = true
	
	songName.text = songMetadata.songName

func hideName():
	songNamePanel.visible = false

#Extras
func displayExtras():
	if songMetadata == null: return
	extrasPanel.visible = true
	
	setDiffText()

func hideExtras():
	extrasPanel.visible = false

#Diff
func setDiffText():
	songDiff.text = songMetadata.availableDiffs[selectedDiff].capitalize()

func changeDiff(plusValue):
	selectedDiff += plusValue
		
	if selectedDiff < 0:
		selectedDiff = songMetadata.availableDiffs.size()-1
	elif selectedDiff > songMetadata.availableDiffs.size()-1:
		selectedDiff = 0
	
	setDiffText()

func _on_diff_left_button_button_down() -> void:
	changeDiff(-1)

func _on_diff_right_button_button_down() -> void:
	changeDiff(1)
