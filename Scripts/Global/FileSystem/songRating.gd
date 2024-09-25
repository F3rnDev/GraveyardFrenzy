extends Node

class_name SongRating

static var ratings = {
	"S+": 100,
	"S": 95,
	"A": 90,
	"B": 80,
	"C": 70,
	"D": 0
}

static var playerRatings = {}
static var savingPath = "user://rating.save"

static func getRating(accuracy):
	var songRating
	
	for curRating in ratings.keys():
		if accuracy >= ratings[curRating]:
			songRating = curRating
			break
	
	return songRating

static func setSongRating(curSong, diff, rating):
	if playerRatings.has(curSong):
		var lastRating = "D"
		if playerRatings[curSong].has(diff):
			lastRating = playerRatings[curSong][diff]
			
		var curRating = rating
		playerRatings[curSong][diff] = checkRating(lastRating, curRating)
	else:
		playerRatings[curSong] = {diff: rating}
	
	
	saveRating()

static func checkRating(last, cur):
	var ratingToSave
	
	if ratings[last.replace("FC", "")] < ratings[cur.replace("FC", "")]:
		ratingToSave = cur
	elif ratings[last.replace("FC", "")] == ratings[cur.replace("FC", "")] and cur.find("FC") > 0:
		ratingToSave = cur
	else:
		ratingToSave = last
	
	return ratingToSave

static func loadAllRatings():
	if FileAccess.file_exists(savingPath):
		var file = FileAccess.open(savingPath, FileAccess.READ)
		playerRatings = file.get_var()

static func getSongRating(song, diff):
	if playerRatings.has(song) and playerRatings[song].has(diff):
		return playerRatings[song][diff]
	else:
		return ""

static func saveRating():
	var file = FileAccess.open(savingPath, FileAccess.WRITE)
	file.store_var(playerRatings)

static func eraseData():
	playerRatings = {}
	saveRating()
