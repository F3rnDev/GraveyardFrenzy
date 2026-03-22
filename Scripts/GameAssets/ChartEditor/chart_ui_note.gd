extends TextureRect

class_name ChartUINote

var noteData:ChartNote = ChartNote.new()

#Hovered
var isHovered = true

#Select
@onready var selectRect = $ColorRect
var isSelected = false

#Drag
var mouseDragStart:Vector2
var isDragging = false
var dragThreshold = 6.0

#HoldNote
@onready var holdNoteLine = $HoldLine
@onready var holdNoteEnd = $HoldEnd

#Signals
signal noteSelected(note:ChartUINote)
signal startNoteDragging(note:ChartUINote)
signal noteDragging()

func setNote(newNote:ChartNote):
	noteData = newNote
	setUI()

func setUI():
	#Set hold info
	holdNoteLine.visible = noteData.holdAmount > 0.0
	holdNoteEnd.visible = noteData.holdAmount > 0.0
	
	#Set Color Rect Size
	selectRect.size.x = holdNoteEnd.position.x + holdNoteEnd.size.x
	
	$Label.text = str(noteData.holdAmount)

func setSelected(selected:bool):
	isSelected = selected
	selectRect.visible = selected

func _input(event: InputEvent) -> void:
	if !isHovered and !isDragging:
		return
	
	if !isSelected and isDragging:
		isDragging = false
	
	if Input.is_action_just_pressed("RightMouseClick"):
		#OpenPopup, to edit or delete :D
		return
	
	if isSelected and Input.is_action_just_pressed("LeftMouseClick"):
		startNoteDrag()
	elif isSelected and Input.is_action_pressed("LeftMouseClick"):
		checkDrag()
	
	noteSelect()

func startNoteDrag():
	mouseDragStart = get_global_mouse_position()
	isDragging = false
	
	startNoteDragging.emit()

func checkDrag():
	var mousePos = get_global_mouse_position()

	if !isDragging:
		if mousePos.distance_to(mouseDragStart) > dragThreshold:
			isDragging = true
	
	noteDrag()

func noteSelect():
	if Input.is_action_just_released("LeftMouseClick") and !isDragging:
		noteSelected.emit(self)

func noteDrag():
	if isDragging:
		var mousePos = get_global_mouse_position()
		noteDragging.emit(self)

func _on_mouse_entered() -> void:
	isHovered = true
	
	print(isHovered)
	print(isSelected)
	print(isDragging)

func _on_mouse_exited() -> void:
	isHovered = false
