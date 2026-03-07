extends Node

class_name SongLoader

static var songExtension = ".frzp" #Frenzy Project

static func saveSong(path:String, project:SongProject):
	var packer:ZIPPacker = ZIPPacker.new()
	
	var err = packer.open(path + "/" + project.data.songName + songExtension)
	if err != OK:
		return err
	
	#Song Data
	var songDataJson = JSON.stringify(project.data.getDict())
	packer.start_file("data.json")
	packer.write_file(songDataJson.to_utf8_buffer())
	packer.close_file()
	
	#Song Charts
	for diff in project.data.availableDiffs:
		var chartJson = JSON.stringify(project.charts[diff].getDict())
		packer.start_file("chart-" + diff + ".json")
		packer.write_file(chartJson.to_utf8_buffer())
		packer.close_file()
	
	#Common Song Audio
	packer.start_file("songAudio.mp3")
	packer.write_file(project.commonAudio)
	packer.close_file()
	
	packer.close()

static func loadSongProject(path:String) -> SongProject:
	var project:SongProject = SongProject.new()
	
	var reader:ZIPReader = ZIPReader.new()
	reader.open(path)
	
	#Song Data
	var songDataBytes = reader.read_file("data.json").get_string_from_utf8()
	var songDataJson = JSON.parse_string(songDataBytes)
	project.data.setNode(songDataJson)
	
	#Song Chart
	for diff in project.data.availableDiffs:
		var chartFile = "chart-" + diff + ".json"
		var chartBytes = reader.read_file(chartFile).get_string_from_utf8()
		var chartJson = JSON.parse_string(chartBytes)
		
		var chartObj = Chart.new()
		chartObj.setNode(chartJson)
		
		project.charts[diff] = chartObj
	
	#Audio
	var commonAudioBytes = reader.read_file("songAudio.mp3")
	project.commonAudio = commonAudioBytes
	
	return project

#LoadChart
#LoadSongData
#LoadMusic
