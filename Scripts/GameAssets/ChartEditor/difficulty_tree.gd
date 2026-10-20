extends Tree

var commonItems:TreeItem
var editedThroughCode = false

func _ready() -> void:
	updateTree()

func updateTree():
	var diffs = create_item()
	diffs.set_text(0, "Difficulty")
	diffs.set_selectable(0, false)
	
	addCommonDiffs()

func addCommonDiffs():
	commonItems = create_item()
	commonItems.set_cell_mode(0, TreeItem.CELL_MODE_CHECK)
	commonItems.set_text(0, "Common")
	commonItems.set_editable(0, true)
	commonItems.set_selectable(0, false)
	
	commonItems.set_checked(0, true)
	
	for diff in Difficulty.commonDiffs:
		var item:TreeItem = create_item(commonItems)
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
		editedThroughCode = true
	
	parentItem.set_checked(0, check)

func getChartDiffs() -> Array[String]:
	var selectedDiffs:Array[String] = []
	
	#common items
	for commonItem in commonItems.get_children():
		if commonItem.is_checked(0):
			selectedDiffs.append(commonItem.get_text(0))
	
	return selectedDiffs

func setTreeValues(diffs:Array):
	for commonItem in commonItems.get_children():
		commonItem.set_checked(0, commonItem.get_text(0) in diffs)
	
	setParentCheck(commonItems)

func _on_item_edited() -> void:
	var selectedItem:TreeItem = get_edited()
	var parentItem = selectedItem.get_parent()
	
	if parentItem == commonItems:
		setParentCheck(parentItem)
	
	if editedThroughCode:
		editedThroughCode = false
		return
	
	if selectedItem == commonItems:
		checkAll(selectedItem)
