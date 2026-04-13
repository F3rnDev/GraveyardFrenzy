extends Node

class_name ChartUIImages

static var notes:Dictionary[ChartNote.NoteTypes, Texture] = {
	ChartNote.NoteTypes.Normal: load("res://Assets/Images/UI Images/ChartEditor/NoteSign.png")
}

static var obstacles:Dictionary[ChartObstacle.ObsTypes, Texture] = {
	ChartObstacle.ObsTypes.Cactus: load("res://Assets/Images/UI Images/ChartEditor/ObstacleSign.png")
}

static var events:Dictionary[ChartEvent.Types, Texture] = {
	ChartEvent.Types.Runner: load("res://Assets/Images/UI Images/ChartEditor/EventSign.png")
}
