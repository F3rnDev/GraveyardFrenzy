extends ChartObjectContext

class_name ChartObjectWindow

enum OPTIONS{
	EDIT,
	CUT,
	COPY,
	PASTE,
	DELETE,
	SELECTALL
}

func getInactiveOptions(selectedObjects:Array, copiedObjects:Array):
	var inactiveOptions:Array[ChartObjectWindow.OPTIONS]
	
	#Check if one object
	var objectTypes = []
	for object in selectedObjects:
		var curObjectType = object.get_script().get_global_name()
		
		if curObjectType not in objectTypes:
			objectTypes.append(curObjectType)
		
		if objectTypes.size() > 1:
			break
	
	#EDIT
	if objectTypes.size() > 1 or selectedObjects.is_empty():
		inactiveOptions.append(ChartObjectWindow.OPTIONS.EDIT)
	
	#CUT and COPY and DELETE
	if selectedObjects.is_empty():
		inactiveOptions.append(ChartObjectWindow.OPTIONS.CUT)
		inactiveOptions.append(ChartObjectWindow.OPTIONS.COPY)
		inactiveOptions.append(ChartObjectWindow.OPTIONS.DELETE)
	
	#PASTE
	if copiedObjects.is_empty():
		inactiveOptions.append(ChartObjectWindow.OPTIONS.PASTE)
	
	return inactiveOptions
