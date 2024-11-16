
extends Node


func get_questions():

	var data = JSON.parse_string(read("res://Files/questions.json"))
	
	# return json of all questions 
	# see file for more info
	return data

func read(filePath):
	
	var file = FileAccess.open(filePath, FileAccess.READ)
	
	# checks to see if it's there
	if !FileAccess.file_exists(filePath):
		return "0"
	var content = file.get_as_text()
	file.close()

	return content

func get_voice_audio(text: String):
	text = text.substr(0,text.length()-1).to_lower() + ".mp3"
	
	var dir = "res://audio/Voice/"
	
	var stream: AudioStream = ResourceLoader.load(dir + text) 
	return stream
	
	
