extends Control

@onready var diffTree = $Tree
var commonItem:TreeItem

var editedTroughCode = false

signal continued(songDiffs)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	updateTree()

func updateTree():
	var diffs = diffTree.create_item()
	diffs.set_text(0, "Difficulty")
	diffs.set_selectable(0, false)
	
	addCommonDiffs()

func addCommonDiffs():
	commonItem = diffTree.create_item()
	commonItem.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	commonItem.set_text(0, "Common")
	commonItem.set_editable(0, true)
	commonItem.set_selectable(0, false)
	
	commonItem.set_checked(0, true)
	
	for diff in Difficulty.commonDiffs:
		var item:TreeItem = diffTree.create_item(commonItem)
		item.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
		item.set_text(0, diff)
		item.set_editable(0, true)
		item.set_selectable(0, false)
		
		item.set_checked(0, true)

func checkAll(parentItem:TreeItem):
	for item in parentItem.get_children():
		item.set_checked(0, parentItem.is_checked(0))

func setParentCheck(parentItem:TreeItem):
	var check = true
	
	for item in parentItem.get_children():
		if !item.is_checked(0):
			check = false
	
	if parentItem.is_checked(0) != check:
		editedTroughCode = true
	
	parentItem.set_checked(0, check)

func getChartDiffs() -> Array[String]:
	var selectedDiffs:Array[String] = []
	
	#common items
	for commonItem in commonItem.get_children():
		if commonItem.is_checked(0):
			selectedDiffs.append(commonItem.get_text(0))
	
	return selectedDiffs

func _on_tree_item_edited() -> void:
	var selectedItem:TreeItem = diffTree.get_edited()
	var parentItem = selectedItem.get_parent()
	
	if parentItem == commonItem:
		setParentCheck(parentItem)
	
	if editedTroughCode:
		editedTroughCode = false
		return
	
	if selectedItem == commonItem:
		checkAll(selectedItem)

func _on_difficulty_continue_btn_button_down() -> void:
	var chartDiff = getChartDiffs()
	
	if chartDiff.size() == 0:
		return
	
	continued.emit(chartDiff)
