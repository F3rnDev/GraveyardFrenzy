extends Node

class_name SongInfo

class SongSection:
	var sectionNotes = []
	var runnerSection = false

class Song:
	var songName:String
	var notes = []
	var bpm:float
	
	func saveSong(fileName, songData, fileDiff):
		FileSystem.checkDirectory("res://Assets/Songs/", fileName)
		
		var jsonData = JSON.stringify(parseSong(songData))
		var file = FileAccess.open("res://Assets/Songs/" + fileName + "/" + fileName + fileDiff + ".json", FileAccess.WRITE)
		file.store_string(jsonData)
	
	func loadSong(fileName, fileDiff):
		var file = FileAccess.open("res://Assets/Songs/" + fileName + "/" + fileName + fileDiff + ".json", FileAccess.READ)
		var result
		
		if file == null:
			result = null
		else:
			result = JSON.parse_string(file.get_as_text())
		
		return result
	
	func parseSong(song) -> Dictionary:
		return {
			"songName": song.songName,
			"bpm": song.bpm,
			"notes": parseSection(song.notes)
		}
	
	func parseSection(notes):
		var notesArray = []
		
		for notesInSection in notes:
			var addToString = {
				"sectionNotes": notesInSection.sectionNotes,
				"runnerSection": notesInSection.runnerSection
			}
			
			notesArray.append(addToString)
		
		return notesArray
