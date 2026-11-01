extends Node

class_name NoteRating

enum Ratings{
	Perfect,
	Good,
	Bad
}

#timing is the difference from the songPosition to elementPosition
#Calculated in ms
static var timings:Dictionary[Ratings, float] = {
	Ratings.Perfect: 25.0,
	Ratings.Good: 80.0,
	Ratings.Bad: 100.0
}

static func getRating(timing:float) -> Ratings:
	for rating in timings:
		if timing <= timings[rating]:
			return rating
	
	return Ratings.Bad
