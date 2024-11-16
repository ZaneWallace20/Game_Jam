extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hud: Control = $Hud
@onready var static_player: AudioStreamPlayer = $static
@onready var voice: AudioStreamPlayer3D = $voice

var static_playing = false
var questions: Array

var File_Pros = preload("res://Imports/file_pross.gd").new()

# used for getting random nums
var rng = RandomNumberGenerator.new()

# list of correct voice lines
var correct = [
	"Very well",
	"Ok, moving on.", 
	"Noted",
	"I see",
	"Unexpected result",
	"This cooperation will help you."
	
	]

# used to prevent repeting voice lines
var correct_num = 0

# list of incorrect voice lines
var incorrect = [
	"Lying gets you nowhere.","I fail to understand.", 
	"Lying will only make me want to kill you more.", 
	"Do you want to die here?",
	"Do you think you are helping your country with this lie?",
	"What do you have to gain with lying.",
	"Don't test our patience."
	]

# used to prevent repeting voice lines
var incorrect_num = 0

# current queston
var question_num = 0

# function to use TTS
func speek(text: String):
	print("44565465")
	# start playing static
	static_player.play()
	static_playing = true
	voice.stream = File_Pros.get_voice_audio("What is your name?")
	await get_tree().physics_frame
	voice.play()

	# prevent moving on while talking
	while voice.playing:
		await get_tree().create_timer(0.25).timeout


# speek correct voice line
func speek_correct():
	
	#minor pause
	await get_tree().create_timer(0.5).timeout

	speek(correct[correct_num])
	
	# itterate through correct, then suffle when done
	correct_num += 1
	if correct_num == len(correct):
		correct_num = 0
		correct.shuffle()

func speek_incorrect():

	#minor pause
	await get_tree().create_timer(0.5).timeout
	speek(incorrect[incorrect_num])
	incorrect_num += 1
	
	# itterate through incorrect, then suffle when done
	if incorrect_num == len(incorrect):
		incorrect_num = 0
		incorrect.shuffle()

func ask_question():
	
	# ask the question
	await speek(questions[question_num]["question"])

	# default amount of data to add
	var loop_amount = 4
	
	# all the options avalible in this question (min 4)
	var temp_ask = questions[question_num]["options"].duplicate(true)
	
	
	var send_data = []
	
	# if question has not been asked
	if questions[question_num]["user_data"] != "":
		
		# set send data to be the correct answer
		send_data = [questions[question_num]["user_data"]]
		temp_ask.pop_at(temp_ask.find(send_data))
		
		# only need 3 more random choices
		loop_amount = 3

		
	# add on random choices
	for i in range(loop_amount):
		var option_num = rng.randi_range(0,len(temp_ask)-1)
		send_data.append(temp_ask[option_num])
		
		# remove duplicates
		temp_ask.pop_at(option_num)
	
	# shuffle to prevent same placement
	send_data.shuffle()
	
	hud.set_up_questions(send_data)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# start by zooming out
	animation_player.play("zoom_out")
	
	# grab all questinos
	questions = File_Pros.get_questions()["lies"]
	
	# shufle to prevent a pattern
	questions.shuffle()
	correct.shuffle()
	incorrect.shuffle()
	

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	# on start when finished zooming out
	if anim_name == "zoom_out":
		hud.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		await speek("Testing testing, it is time to start. We will be using this voice modifier for, obvious reasons.")
		
		# start question
		ask_question()

# called from hud when question answered
func answered_question(data: String):
	
	# if empty assume correct
	if questions[question_num]["user_data"] == "":
		await speek_correct()
		questions[question_num]["user_data"] = data
		
	# if correct
	elif questions[question_num]["user_data"] == data:
		await speek_correct()
		
	# if not corrrect
	else:
		await speek_incorrect()
	
	# inc to get a new question
	question_num += 1
	
	# if halfway done start asking same questions
	if question_num >= len(questions)/ 2:
		
		# prevents pattern
		questions.shuffle()
		question_num = 0
	
	ask_question()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# used to stop static when not speeking
	if !voice.playing && static_playing:
		static_player.stop()
		static_playing = false
