class_name Difficulty

enum allDiff {Easy, Normal, Hard}

static func getAllDiffs() -> Array:
	var array = []
	
	for diff in allDiff:
		array.append(str(diff))
	
	return array

static func getFileDiff(curDiff) -> String:
	var fileDiff = ""
	
	if curDiff != "Normal":
		fileDiff = "-" + curDiff.to_lower()
	
	return fileDiff
