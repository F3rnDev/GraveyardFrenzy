extends Control

@onready var songNameInput = $Division/Inputs/SongName
@onready var songComposerInput = $Division/Inputs/Composer
@onready var songCharterInput = $Division/Inputs/Charter
@onready var songBpmInput = $Division/Inputs/Base_Bpm

signal continued(songName, composer, charter, baseBpm)

func validateSongData() -> bool:
	if songNameInput.text == "":
		return false
	
	if songComposerInput.text == "":
		return false
	
	if songCharterInput.text == "":
		return false
	
	return true

func _on_song_data_continue_btn_button_down() -> void:
	if validateSongData():
		var songName = songNameInput.text
		var composer = songComposerInput.text
		var charter = songCharterInput.text
		var baseBpm = songBpmInput.value
		
		continued.emit(songName, composer, charter, baseBpm)
