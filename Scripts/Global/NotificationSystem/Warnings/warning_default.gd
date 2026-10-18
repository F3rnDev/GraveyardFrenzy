extends NotificationWarning

@export var borderDown = 20.0

@onready var window: ChartEditorWindow = $Panel/window

@onready var warningContainer: VBoxContainer = $Panel/window/VBoxContainer
@onready var warningLabel: Label = $Panel/window/VBoxContainer/warnLabel
@onready var confirmBtn: Button = $Panel/window/VBoxContainer/HBoxContainer/confirmBtn
@onready var cancelBtn: Button = $Panel/window/VBoxContainer/HBoxContainer/cancelBtn

func setData(warningMessage:String, customConfirmText:String = "", customCancelText:String = ""):
	warningLabel.text = warningMessage
	
	confirmBtn.text = customConfirmText if customConfirmText != "" else "Confirm"
	cancelBtn.text = customCancelText if customCancelText != "" else "Cancel"
	
	window.size.y = warningContainer.get_minimum_size().y + borderDown

func _on_confirm_btn_button_down() -> void:
	confirmed.emit()

func _on_cancel_btn_button_down() -> void:
	cancelled.emit()
