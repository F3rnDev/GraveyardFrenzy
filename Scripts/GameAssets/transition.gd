extends CanvasLayer

signal faded(newScene, oldScene)

func startFadeIn(newScene, oldScene):
	self.visible = true
	$AnimationPlayer.play("ui_fadeIn")
	await $AnimationPlayer.animation_finished
	faded.emit(newScene, oldScene)

func startFadeOut(node):
	var nodeName = str(node.name)
	
	get_parent().get_node(nodeName).process_mode = Node.PROCESS_MODE_DISABLED
	$AnimationPlayer.play("ui_fadeOut")
	await $AnimationPlayer.animation_finished
	self.visible = false
	get_parent().get_node(nodeName).process_mode = Node.PROCESS_MODE_INHERIT
