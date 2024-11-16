extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hud: Control = $Hud

@onready var static_player: AudioStreamPlayer = $static


var voices: Array[Dictionary] = DisplayServer.tts_get_voices()

var static_playing = false

var questions: Array

var File_Pros = preload("res://Imports/file_pross.gd").new()

var rng = RandomNumberGenerator.new()

var correct = [
	"Very well",
	"Ok, moving on.", 
	"Noted",
	"I see",
	"Unexpected result",
	"This cooperation will help you."
	
	]

var correct_num = 0

var incorrect = [
	"Lying gets you nowhere.","I fail to understand.", 
	"Lying will only make me want to kill you more.", 
	"Do you want to die here?",
	"Do you think you are helping your country with this lie?",
	"What do you have to gain with lying.",
	"Don't test our patience."
	]
	
var incorrect_num = 0

var question_num = 0
func speek(text: String):

	static_player.play()
	var selected_voice = voices[0]["id"]

	static_playing = true
	DisplayServer.tts_speak(text, selected_voice,50,0,0.9)
	while DisplayServer.tts_is_speaking():
		await get_tree().create_timer(0.25).timeout


func speek_correct():
	await get_tree().create_timer(0.5).timeout
	speek(correct[correct_num])
	correct_num += 1
	
	if correct_num == len(correct):
		correct_num = 0
		correct.shuffle()

func speek_incorrect():

	speek(incorrect[incorrect_num])
	incorrect_num += 1
	
	if incorrect_num == len(incorrect):
		incorrect_num = 0
		incorrect.shuffle()

func ask_question():
	
	await speek(questions[question_num]["question"])

		
	var loop_amount = 4
	
	var temp_ask = questions[question_num]["options"].duplicate(true)
	var send_data = []
	
	if questions[question_num]["user_data"] != "":
		send_data = [questions[question_num]["user_data"]]
		temp_ask.pop_at(temp_ask.find(send_data))
		loop_amount = 3
		print(send_data)
		print(temp_ask)
		print("\n\n\n\n")
		
		
	for i in range(loop_amount):
		var option_num = rng.randi_range(0,len(temp_ask)-1)
		send_data.append(temp_ask[option_num])
		temp_ask.pop_at(option_num)
	
	send_data.shuffle()
	
	hud.set_up_questions(send_data)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("zoom_out")
	questions = File_Pros.get_questions()["lies"]
	questions.shuffle()
	correct.shuffle()
	incorrect.shuffle()
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "zoom_out":
		hud.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		await speek("Testing testing, it is time to start. We will be using this voice modifier for, obvious reasons.")
		
		ask_question()

func answered_question(data: String):
	if questions[question_num]["user_data"] == "":
		await speek_correct()
		questions[question_num]["user_data"] = data
	elif questions[question_num]["user_data"] == data:
		await speek_correct()
	else:
		await speek_incorrect()
	
	question_num += 1
	if question_num >= len(questions)/ 2:
		questions.shuffle()
		question_num = 0
	
	
	ask_question()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !DisplayServer.tts_is_speaking() && static_playing:
		static_player.stop()
		static_playing = false
