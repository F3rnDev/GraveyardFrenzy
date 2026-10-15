extends CanvasLayer

#Warning
enum WarningTypes
{
	ChartNoteDeletion
}
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
		WarningTypes.ChartNoteDeletion:
			warningInstance = warnNoteDeletion.instantiate()
			add_child(warningInstance)
			warningInstance.setData(params)
	
	return warningInstance
