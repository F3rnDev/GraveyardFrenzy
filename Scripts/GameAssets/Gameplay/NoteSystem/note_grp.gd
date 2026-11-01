extends Node2D

var rotationTween:Tween = null

func rotateStrum(rot:float = 2.0, time:float = 0.2):
	if rotationTween != null and (!rotationTween.finished or rot == rotation_degrees):
		return
	
	rotationTween = create_tween()
	rotationTween.tween_property(self, "rotation_degrees", rot, time)
