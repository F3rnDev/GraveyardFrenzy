class_name Difficulty

static var commonDiffs:Array[String] = ["easy", "normal", "hard"]
static var remixDiffs:Array[String] = ["frenzy"]

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
