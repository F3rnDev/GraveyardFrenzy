extends ChartUIObject

class_name ChartUIEvent

enum MergeStatus{NORMAL, MERGING}
var curMergeStatus = MergeStatus.NORMAL

func getDataType():
	return ChartEvent

func changeMergeStatus(allowed:bool):
	if allowed:
		setCancelMerge()
	else:
		setMerging()

func setMerging():
	if curMergeStatus == MergeStatus.MERGING:
		return
	
	z_index = 1
	selectRect.visible = false
	
	setMergeAnimation(0.7)
	
	curMergeStatus = MergeStatus.MERGING

func setCancelMerge():
	if curMergeStatus == MergeStatus.NORMAL:
		return
	
	z_index = 0
	selectRect.visible = true
	
	setMergeAnimation(1.0)
	
	curMergeStatus = MergeStatus.NORMAL

func setMergeAnimation(value):
	var mat = material as ShaderMaterial
	if not mat:
		return
	
	#Animate
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	tween.tween_property(mat, "shader_parameter/texture_scale", value, 0.2)
