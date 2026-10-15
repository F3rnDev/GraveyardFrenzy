extends HBoxContainer

class_name SongDataWindow

var editorRef:ChartEditor = null
var songDataRef:SongData = null

#Fields
@onready var songName: LineEdit = $SongStats/SongName
@onready var composer: LineEdit = $SongStats/Composer
@onready var charter: LineEdit = $SongStats/Charter
@onready var baseBpm: SpinBox = $SongStats/Base_Bpm

func setFields(data:SongData, editor:ChartEditor):
	songDataRef = data
	editorRef = editor
	
	songName.text = data.songName
	composer.text = data.composer
	charter.text = data.charter
	baseBpm.value = data.baseBpm

func canUpdate() -> bool:
	return songDataRef != null and editorRef != null

#Set values
func _on_song_name_text_changed(new_text: String) -> void:
	if !canUpdate: return
	
	songDataRef.songName = new_text

func _on_composer_text_changed(new_text: String) -> void:
	if !canUpdate: return
	
	songDataRef.composer = new_text

func _on_charter_text_changed(new_text: String) -> void:
	if !canUpdate: return
	
	songDataRef.charter = new_text

func _on_base_bpm_value_changed(value: float) -> void:
	if !canUpdate: return
	
	editorRef.setNewBpm(value)
