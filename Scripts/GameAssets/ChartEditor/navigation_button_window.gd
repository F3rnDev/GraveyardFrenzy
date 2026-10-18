extends NavigationUIButton

enum Options{
	Edit,
	Data,
	Music,
	Diff
}

@export var group:ChartHeaderGroup

func _ready() -> void:
	super._ready()
	setShortcuts()

func setShortcuts():
	setShortcut(0, "ChartWindowEdit")
	setShortcut(1, "ChartWindowSongData")
	setShortcut(2, "ChartWindowAudio")
	setShortcut(3, "ChartWindowDiff")

func setCheckedItems(activeWindows):
	var editor = group.editor
	
	get_popup().set_item_checked(0, editor.editWindow in activeWindows)
	get_popup().set_item_checked(1, editor.songDataWindow in activeWindows)
	get_popup().set_item_checked(2, editor.audioWindow in activeWindows)
	get_popup().set_item_checked(3, editor.diffWindow in activeWindows)

func _on_selected(id: Variant) -> void:
	var editor = group.editor
	var windowToOpen = null
	
	match id:
		Options.Edit:
			windowToOpen = editor.editWindow
		Options.Data:
			windowToOpen = editor.songDataWindow
		Options.Music:
			windowToOpen = editor.audioWindow
		Options.Diff:
			windowToOpen = editor.diffWindow
	
	if windowToOpen == null:
		return
	
	if !get_popup().is_item_checked(id):
		editor.openWindow(windowToOpen)
	else:
		editor.closeWindow(windowToOpen)
