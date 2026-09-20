extends Node

class_name SongData

var songName:String = ""
var composer:String = ""
var charter:String = ""
var baseBpm:int = 120
var availableDiffs:Array = []

func getDict() -> Dictionary:
	return {
		"songName": songName,
		"composer": composer,
		"charter": charter,
		"baseBpm": baseBpm,
		"availableDiffs": availableDiffs
	}

func setNode(dict:Dictionary):
	songName = dict["songName"]
	composer = dict["composer"]
	charter = dict["charter"]
	baseBpm = dict["baseBpm"]
	availableDiffs = dict["availableDiffs"]
