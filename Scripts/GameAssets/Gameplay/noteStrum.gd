extends Node2D

enum notePress {StrumUp, StrumDown}

signal notePressed(note)
signal noteReleased(note)

func setDebug(active):
	$judment.editor_only = !active

func _ready():
	for curNote in notePress:
		get_node(curNote).play("idle")
		get_node(curNote).frame = 1

func _input(event):
	for curNote in notePress:
		if event.is_action_pressed(curNote):
			get_node(curNote).play("note_press")
			emit_signal("notePressed", curNote)
		elif event.is_action_released(curNote):
			get_node(curNote).play("idle")
			emit_signal("noteReleased", curNote)

func getJudgment() -> Rect2:
	return $judment.get_global_rect()
