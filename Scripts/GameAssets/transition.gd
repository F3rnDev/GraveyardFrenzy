extends CanvasLayer

signal faded(newScene)

func startFadeIn(newScene):
	$AnimationPlayer.play("ui_fadeIn")
	await $AnimationPlayer.animation_finished
	faded.emit(newScene)

func startFadeOut(node):
	if node == null:
		return
	
	$AnimationPlayer.play("ui_fadeOut")
