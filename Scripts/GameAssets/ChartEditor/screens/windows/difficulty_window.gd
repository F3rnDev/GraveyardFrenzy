extends Panel

class_name DiffWindow

@onready var diffTree:Tree = $Tree

var projectRef:SongProject
var editorRef:ChartEditor

func setProjectRef(proj:SongProject, editor:ChartEditor):
	projectRef = proj
	editorRef = editor
	
	diffTree.setTreeValues(proj.data.availableDiffs)

func saveDiffs(diffs:Array):
	#Remove old charts
	for currentDiff in projectRef.charts.keys():
		if currentDiff not in diffs:
			projectRef.charts.erase(currentDiff)
	
	#Set new charts
	for diff in diffs:
		if diff not in projectRef.charts:
			projectRef.charts[diff] = Chart.new()
	
	editorRef.setNewDiffs(diffs)

func _on_save_available_diffs_button_down() -> void:
	var selectedDiffs = diffTree.getChartDiffs()
	
	#Check if empty
	if selectedDiffs.is_empty():
		NotificationManager.popupMessage(NotificationMessage.Types.Error, "You need to select at least one difficulty")
		return
	
	#Check all currently saved difficulties for any that were unchecked and have content
	var diffsWithContent = []
	for diff in projectRef.data.availableDiffs:
		if diff in selectedDiffs:
			continue
		
		var chart = projectRef.charts[diff]
		if chart and (!chart.elements.is_empty() or !chart.events.is_empty()):
			diffsWithContent.append(diff)
	
	if !diffsWithContent.is_empty():
		var diffList = ", ".join(diffsWithContent).capitalize()
		
		var params = {
			"warningMessage": "Unchecking these difficulties will permanently delete all their notes and events:\n\n [%s] \n\n Do you still want to proceed?" % diffList,
			"customConfirmBtn": "Yes, Delete",
			"customCancelBtn": ""
		}
		var warning = NotificationManager.popupWarning(NotificationManager.WarningTypes.Default, params)
		warning.confirmed.connect(saveDiffs.bind(selectedDiffs))
		warning.cancelled.connect(diffTree.setTreeValues.bind(projectRef.data.availableDiffs))
		
		return
	
	saveDiffs(selectedDiffs)
