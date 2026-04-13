extends TextureRect

@export var renderedNotes:ChartUIRenderedObjects
@export var elementTypeSelect:ElementTypeSelectUI

func _ready() -> void:
	setVisible(false)

func setPosition(pos:Vector2):
	global_position = pos

func setVisible(isVisible:bool):
	visible = isVisible

func addPreview(pos:Vector2, image:Texture):
	if Input.is_action_pressed("LeftMouseClick"):
		return
	
	texture = image
	
	setPosition(pos)
	setVisible(true)

#Note/Obstacles
func _on_note_grid_preview_note_add(pos: Vector2) -> void:
	var element
	var image
	match elementTypeSelect.currentType:
		ChartElement.Types.Note:
			element = renderedNotes.lastNoteType
			image = ChartUIImages.notes[element]
		ChartElement.Types.Obs:
			element = renderedNotes.lastObsType
			image = ChartUIImages.obstacles[element]
	
	addPreview(pos, image)

func _on_note_grid_preview_note_remove() -> void:
	setVisible(false)

#Events
func _on_event_grid_preview_event_add(pos: Vector2) -> void:
	var event = renderedNotes.lastEventType
	var image = ChartUIImages.events[event]
	
	addPreview(pos, image)

func _on_event_grid_preview_event_remove() -> void:
	setVisible(false)
