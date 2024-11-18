extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hud: Control = $Hud
@onready var static_player: AudioStreamPlayer3D = $static
@onready var voice: AudioStreamPlayer3D = $voice
@onready var tv_text: Label = $Cam/tv/tv_text
@onready var rifle: Node3D = $Rifle
@onready var white_rect: ColorRect = $white

@export var MAX_TRUTHS_ALLOWED = 4
@export var MAX_FAILED_LIES_ALLOWED = 3
@export var QUESTIONS_RIGHT_TO_WIN = 35

var talk_delay = 0.0
var set_talk_delay = 0.0


var static_playing = false
var questions: Array

var File_Pros = preload("res://Imports/file_pross.gd").new()

# used for getting random nums
var rng = RandomNumberGenerator.new()

var tv_words = []
var current_voice_line = []
var MAX_LENGTH = 68

var total_failed_lies = 0
var total_truthes = 0
var total_correct = 0

# list of correct voice lines
var correct = [
	"Very well.",
	"Ok, moving on.", 
	"Noted.",
	"I see.",
	"This cooperation will help you."
	
	]

# used to help prevent repeting voice lines
var correct_num = 0

# list of incorrect voice lines
var incorrect = [
	"Lying gets you nowhere.",
	"I fail to understand.", 
	"Lying will only make me want to kill you more.", 
	"Do you want to die here?",
	"Do you think you are helping your country with this lie?",
	"What do you have to gain with lying?",
	"Don't test our patience."
	]

# used to help prevent repeting voice lines
var incorrect_num = 0

# current queston
var question_num = 0

func update_words(clear = false):
	if clear:
		tv_text.text = ""
		tv_words = []
		return
	if len(tv_text.text) > MAX_LENGTH:
		tv_words.pop_front()
	if len(current_voice_line) > 0:
		
		
		var last = current_voice_line[0].substr(len(current_voice_line[0])-1,-1)
		
		var slows = [".",",",";"]
		if slows.has(last):
			set_talk_delay = 0.6
			if last == ".":
				set_talk_delay += 0.7
			if last == ";":
				set_talk_delay -= 0.1
		else:
			if len(current_voice_line[0]) > 5:
				set_talk_delay = 0.3
			else:
				set_talk_delay = 0.23

		if len(current_voice_line) > 15:
			set_talk_delay -= 0.1
		set_talk_delay *= 1/voice.pitch_scale
		tv_words.append(current_voice_line[0])
		current_voice_line.remove_at(0)
		var temp_string = "\n"
		for i in tv_words:
			temp_string += i + " "
		temp_string.trim_suffix(" ")
		tv_text.text = temp_string
	
	


# function to use TTS
func speak(text: String):
	update_words(true)
	current_voice_line = text.split(" ")
	await get_tree().create_timer(0.1).timeout 
	
	# random pitch up and down, less robotic
	voice.pitch_scale = rng.randf_range(0.98,1.02)

	# start playing static
	static_player.play()
	
	voice.stream = File_Pros.get_voice_audio(text)
	
	talk_delay = 0.2
	set_talk_delay = talk_delay
	
	await get_tree().physics_frame
	voice.play()
	static_playing = true
	
	# prevent moving on while talking
	while voice.playing:
		await get_tree().create_timer(0.33).timeout


# speak correct voice line
func speak_correct():
	
	await speak(correct[correct_num])
	
	# itterate through correct, then suffle when done
	correct_num += 1
	if correct_num == len(correct):
		correct_num = 0
		correct.shuffle()


	total_correct += 1
	hud.correct_label.text = "Total Correct:\n" + str(total_correct)
func speak_incorrect():

	await speak(incorrect[incorrect_num])
	
	incorrect_num += 1
	# itterate through incorrect, then suffle when done
	if incorrect_num == len(incorrect):
		incorrect_num = 0
		incorrect.shuffle()
	total_failed_lies += 1
	
	hud.lie_label.text = "Total Caught Lies:\n" + str(total_failed_lies)
	

func start_question():
	
	print(total_correct)
	if total_truthes >= MAX_TRUTHS_ALLOWED:
		
		await speak("We have enough information, you and I are done here.")
		rifle.fire()
		return
	if total_failed_lies >= MAX_FAILED_LIES_ALLOWED:
		await speak("The truth is what we need, not you or your lies.")
		rifle.fire()
		return
	if total_correct >= QUESTIONS_RIGHT_TO_WIN:
		await speak("It seems to me that you are not telling us the whole story, but alas we have laws in our civilized nation; you may go.")
		await get_tree().create_timer(0.2).timeout
		update_words(true)
		animation_player.play_backwards("zoom_out")
		return
		
	# inc to get a new question
	question_num += 1
	# if halfway done start asking same questions
	if question_num >= len(questions)/ 2:
		
		# prevents pattern
		questions.shuffle()
		question_num = 0

	
	# ask the question
	await speak(questions[question_num]["question"])
	
	hud.reset_grid()

func ask_question():

	# default amount of data to add
	var loop_amount = 4
	
	# all the options avalible in this question (min 4)
	var temp_ask = questions[question_num]["options"].duplicate(true)
	
	var send_data = []
	
	# if question has not been asked
	if questions[question_num]["user_data"] != "" && questions[question_num]["user_data"] != "TRUTH":
		
		# set send data to be the correct answer
		send_data = [questions[question_num]["user_data"]]
		print(temp_ask)
		temp_ask.pop_at(temp_ask.find(send_data[0]))
		print(temp_ask)
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
	
func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("quit"):
		update_words(true)
		animation_player.play_backwards("zoom_out")
		total_correct = QUESTIONS_RIGHT_TO_WIN + 1
		
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	# on start when finished zooming out
	if anim_name == "zoom_out" && total_correct < QUESTIONS_RIGHT_TO_WIN:
		hud.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		await speak("Testing testing, it is time to start. We will be using this voice modifier for obvious reasons.")
		
		# start question
		start_question()
	elif anim_name == "zoom_out":
		Global.min_time = 0.5
		quit()
	
func answerd_truth():

	if questions[question_num]["user_data"] == "" || questions[question_num]["user_data"] == "TRUTH":
		
		await speak_correct()
		if questions[question_num]["user_data"] != "TRUTH":
			total_truthes += 1
			questions[question_num]["user_data"] = "TRUTH"
			hud.truth_label.text = "Total Truthes:\n" + str(total_truthes)

		
	else:
		await speak_incorrect()
	
	
	start_question()

# called from hud when question answered
func answered_question(data: String):
	
	await get_tree().process_frame
	
	# if empty assume correct
	if questions[question_num]["user_data"] == "":
		questions[question_num]["user_data"] = data
		print("CORRECT")
		
		await speak_correct()

	# if correct
	elif questions[question_num]["user_data"] == data:
		await speak_correct()
		
	# if not corrrect
	else:
		await speak_incorrect()
	

	start_question()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	# used to stop static when not speaking
	if !voice.playing && static_playing:
		static_player.stop()
		static_playing = false
	elif voice.playing:
		if talk_delay >= 0:
			talk_delay -= delta
		else:
			update_words()
			talk_delay = set_talk_delay
		

func white_out():
	Global.min_time = 0
	white_rect.visible = true
	

func quit():
	Global.next_scene = "res://Scenes/home.tscn"
	get_tree().change_scene_to_file("res://Scenes/loading.tscn")
