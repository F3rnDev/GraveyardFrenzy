extends CanvasLayer

#Warning
enum WarningTypes
{
	Default,
	ChartNoteDeletion
}
@onready var warnDef = preload("res://Nodes/Global/NotificationSystem/Warnings/warning_default.tscn")
@onready var warnNoteDeletion = preload("res://Nodes/Global/NotificationSystem/Warnings/warning_note_deletion.tscn")


#Messages
@onready var message = preload("res://Nodes/Global/NotificationSystem/notificationMessage.tscn")
@onready var message_container: VBoxContainer = $messageContainer

func popupMessage(messageType:NotificationMessage.Types, messageStr:String) -> NotificationMessage:
	var messageInstance:NotificationMessage = message.instantiate()
	message_container.add_child(messageInstance)
	messageInstance.popupMessage(messageType, messageStr)
	
	return messageInstance

func popupWarning(type:WarningTypes, params:Dictionary) -> NotificationWarning:
	var warningInstance:NotificationWarning = null
	match type:
		WarningTypes.Default:
			var message = params["warningMessage"]
			var confirmBtn = params["customConfirmBtn"]
			var cancelBtn = params ["customCancelBtn"]
			
			warningInstance = warnDef.instantiate()
			add_child(warningInstance)
			warningInstance.setData(message, confirmBtn, cancelBtn)
		
		WarningTypes.ChartNoteDeletion:
			warningInstance = warnNoteDeletion.instantiate()
			add_child(warningInstance)
			warningInstance.setData(params)
	
	return warningInstance
