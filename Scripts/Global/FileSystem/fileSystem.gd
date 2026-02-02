extends Node

class_name FileSystem

static func checkDirectory(path, fileName):
	var dir = DirAccess.open(path + fileName)
	
	if dir == null:
		dir = DirAccess.open(path)
		dir.make_dir(fileName)

static func renameDirectory(path, oldName, newName):
	var dir = DirAccess.open(path)
	
	if dir != null:
		dir.rename(path + "/" + oldName, path + "/" + newName)

static func renameSongFiles(path, oldName, newName):
	var oldPath = path + oldName + "/" + oldName
	var newPath = path + oldName + "/" + newName
	
	var dir = DirAccess.open(path + oldName)
	
	if dir != null:
		for diff in Difficulty.getAllDiffs():
			var diffString = Difficulty.getFileDiff(diff)
			dir.rename(oldPath + diffString + ".json", newPath + diffString + ".json")
		
		dir.rename(oldPath + ".mp3", newPath + ".mp3")
		dir.rename(oldPath + ".wav", newPath + ".wav")
		dir.rename(oldPath + ".ogg", newPath + ".ogg")
		renameDirectory(path, oldName, newName)

static func getFolderNames(path):
	var dir = DirAccess.open(path)
	var songArray = []
	
	if dir != null:
		dir.list_dir_begin()
		var dirName = dir.get_next()
		while dirName != "":
			songArray.append(dirName.get_basename())
			dirName = dir.get_next()
		
	
	return songArray

static func getAudioFile(path) -> String:
	print(path)
	var exts = [".mp3", ".wav", ".ogg"]
	var file
	
	for ext in exts:
		if ResourceLoader.exists(path + ext):
			file = path + ext
			break
	
	return file
