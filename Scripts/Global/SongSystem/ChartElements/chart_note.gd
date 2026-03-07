extends ChartElement

class_name ChartNote

enum NoteTypes
{
	Normal
}

var noteType:NoteTypes = NoteTypes.Normal
var holdAmount:float = 0.0

func getDict() -> Dictionary:
	var dict = super.getDict()
	
	dict["noteType"] = noteType
	dict["holdAmount"] = holdAmount
	
	return dict

func setNode(dict:Dictionary):
	super.setNode(dict)
	
	noteType = dict["noteType"]
	holdAmount = dict["holdAmount"]
