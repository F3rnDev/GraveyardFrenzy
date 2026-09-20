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
	
	#CUT and COPY and DELETE
	if selectedObjects.is_empty():
		inactiveOptions.append(ChartObjectWindow.OPTIONS.EDIT)
		inactiveOptions.append(ChartObjectWindow.OPTIONS.CUT)
		inactiveOptions.append(ChartObjectWindow.OPTIONS.COPY)
		inactiveOptions.append(ChartObjectWindow.OPTIONS.DELETE)
	
	#PASTE
	if copiedObjects.is_empty():
		inactiveOptions.append(ChartObjectWindow.OPTIONS.PASTE)
	
	return inactiveOptions
