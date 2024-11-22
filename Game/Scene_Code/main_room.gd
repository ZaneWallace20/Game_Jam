extends Node3D

@onready var zoom_player: AnimationPlayer = $Zoom_Player
@onready var shake_player: AnimationPlayer = $Shake_Player

@onready var hud: Control = $Hud
@onready var static_player: AudioStreamPlayer3D = $Static
@onready var voice: AudioStreamPlayer = $Voice
@onready var tv_text: Label = $"Tv/2d_In_3d/Window/Tv_Text"
@onready var rifle: Node3D = $Rifle
@onready var white_rect: ColorRect = $White
@onready var spotlight: Node3D = $Spotlight

@onready var cam: Camera3D = $Shake_Node/Head/Cam
@onready var head: Node3D = $Shake_Node/Head
@onready var shake_node: Node3D = $Shake_Node

@export var MAX_TRUTHS_ALLOWED = 3
@export var MAX_FAILED_LIES_ALLOWED = 3
@export var QUESTIONS_RIGHT_TO_WIN = 25

@export var MOUSE_SENS = 0.001


var talk_delay = 0.0
var set_talk_delay = 0.0

var should_quit = false

var static_playing = false
var questions: Dictionary

var File_Pros = preload("res://Imports/file_pross.gd").new()

# used for getting random nums
var rng = RandomNumberGenerator.new()

var tv_words = []
var current_voice_line = []
var MAX_LENGTH = 65

var total_failed_lies = 0
var total_truths = 0
var total_correct = 0

var quit_game = false

var should_shake = false


var shake_speed = .25

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

# list of quick time voice lines
var quick_time_text = [
	"DID YOU KILL HIM?",
	#"IS YOUR BOSS IN DC?",
	"DID YOU PLANT THE BOMB?",
	#"DID YOU HAVE A TEAM?",
]

# question topics
var topics = ["people","places","dates","items"]

var topic_amount = {
	"people":0,
	"places":0,
	"dates":0,
	"items":0
	}
# current queston
var question_num = 0

var max_amount_per_topic = 0

var current_topic = ""


func get_user_data():
	
	return questions[current_topic]["questions"][question_num]["userData"]
	
func set_user_data(value):
	questions[current_topic]["questions"][question_num]["userData"] = value


# used to clear update tv_text
func update_words(clear = false):
	
	# clear the text
	if clear:
		tv_text.text = ""
		tv_words = []
		return
		
	# check to see if the tv_text is too long to fit
	if len(tv_text.text) > MAX_LENGTH:
		tv_words.pop_front()
		
	# check to see if done
	if len(current_voice_line) > 0:

		# check for pause
		var last = current_voice_line[0].substr(len(current_voice_line[0])-1,-1)
		
		# a bunch of fine tune for speed of tv text
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
		
		# longer lines need a bit of a boost
		if len(current_voice_line) > 15:
			set_talk_delay -= 0.1
			
		# multiply by 1/pitch to scale for pitch speed
		set_talk_delay *= 1/voice.pitch_scale
		
		# add on the new word
		tv_words.append(current_voice_line[0])
		
		# remove the old word
		current_voice_line.remove_at(0)
		
		# add words to temp string
		var temp_string = ""
		for i in tv_words:
			temp_string += i + " "
			
		# remove last space
		temp_string.trim_suffix(" ")
		
		# set tv_text to the temp string
		tv_text.text = temp_string

# function to use TTS
func speak(text: String, quick_time_event = false):
	
	# can look when talking
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
	update_words(true)
	current_voice_line = text.split(" ")
	await get_tree().create_timer(0.1).timeout 
	
	# random pitch up and down, less robotic
	voice.pitch_scale = rng.randf_range(0.98,1.02)
	
	# start playing static
	static_player.play()
	
	voice.stream = File_Pros.get_voice_audio(text)
	
	# if quick time event be louder
	if quick_time_event:
		voice.volume_db = 18
	else:
		voice.volume_db = 7

	# reset talk_delay
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
	
	# itterate through correct, then suffle when done
	
	if correct_num == len(correct) - 1:
		correct_num = -1
		correct.shuffle()
	correct_num += 1
	
	await speak(correct[correct_num])
	
	# add and update total_correct/text
	total_correct += 1
	hud.correct_label.text = "Total Correct:\n" + str(total_correct)

# speak incorrect voice line
func speak_incorrect():
	
	# itterate through incorrect, then suffle when done
	if incorrect_num == len(incorrect) - 1:
		incorrect_num = -1
		incorrect.shuffle()
	incorrect_num += 1
	
	await speak(incorrect[incorrect_num])
	
	# add and update total_failed_lies/text
	total_failed_lies += 1
	hud.lie_label.text = "Total Caught Lies:\n" + str(total_failed_lies)
	
# start asking a question
func start_question():

	# check to see if win/lose
	if total_truths > MAX_TRUTHS_ALLOWED:
		await speak("We have enough information, you and I are done here.")
		Global.how_died = "TRUTH"
		rifle.fire()
		return
	if total_failed_lies >= MAX_FAILED_LIES_ALLOWED:
		await speak("The truth is what we need, not you or your lies.")
		Global.how_died = "LIES"
		rifle.fire()
		return
	if total_correct >= QUESTIONS_RIGHT_TO_WIN:
		await speak("It seems to me that you are not telling us the whole story, but alas we have laws in our civilized nation; you may go.")
		await get_tree().create_timer(0.2).timeout
		update_words(true)
		should_quit = true 
		zoom_player.play_backwards("zoom_out")
		return
	
	# if game is not over 10% chance for quick time event
	var should_quick = randi_range(0,10) == 5
	
	if should_quick:
		
		# shuffle the quick time voice lines
		
		# Note I do not care if you get two in a row
		quick_time_text.shuffle()
		await speak(quick_time_text[0],true)
		
		# start hud quick time
		hud.quick_time_event()
		
		return

	current_topic = topics.pick_random()

	question_num = topic_amount[current_topic]


	# if done start asking same questions
	if topic_amount[current_topic] >= max_amount_per_topic:
		
		# prevents pattern
		questions[current_topic]["questions"].shuffle()
		topic_amount[current_topic] = 0
		question_num = 0

	# ask the question
	await speak(questions[current_topic]["questions"][question_num]["question"])

	
	hud.reset_questions()


# arr1 - arr2
func difference(arr1, arr2):
	var only_in_arr1 = []
	for i in arr1:
		if not (i in arr2):
			only_in_arr1.append(i)
	return only_in_arr1

func get_question_options():

	# default amount of data to add
	var loop_amount = 4
	
	# all the options avalible in this question (min 4)
	var temp_ask = questions[current_topic]["answers"].duplicate(true)
	
	var send_data = []

	# if question has been asked
	if get_user_data() != "" && get_user_data() != "TRUTH":
		
		# set send data to be the correct answer
		send_data = [get_user_data()]
		temp_ask.pop_at(temp_ask.find(send_data[0]))
		
		# only need 3 more random choices
		loop_amount = 3

	else:
		
		# all used answers for current topic
		var used = questions[current_topic]["usedAnswers"].duplicate(true)
	
		# remove them from the answer pool
		temp_ask = difference(temp_ask,used)
		
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
	zoom_player.play("zoom_out")
	
	# grab all questinos
	questions = File_Pros.get_questions()
	
	# shufle to prevent a pattern
	for i in topics:
		questions[i]["questions"].shuffle()
	
	correct.shuffle()
	incorrect.shuffle()
	
	MAX_TRUTHS_ALLOWED += rng.randi_range(0,2)
	
	# get amount of questions per topic
	max_amount_per_topic = len(questions["people"]["questions"])
	
	

func _input(event: InputEvent) -> void:
	
	# check if esc pressed
	if Input.is_action_just_pressed("quit"):
		
		# clear tv_text
		update_words(true)
		zoom_player.play_backwards("zoom_out")
		should_quit = true
		
		
	# if mouse
	if event is InputEventMouseMotion:
		
		# if mouse is captured
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			
			
			# move head
			head.rotate_y(-event.relative.x * MOUSE_SENS)
			
			# move cam
			cam.rotate_x(-event.relative.y * MOUSE_SENS)
			
			# keep the total range of motion small
			cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-20),deg_to_rad(20))
			head.rotation.y = clamp(head.rotation.y,deg_to_rad(-20),deg_to_rad(20))

func _on_zoom_player_animation_finished(anim_name: StringName) -> void:
	
	# on start when finished zooming out
	if anim_name == "zoom_out" && !should_quit:
		hud.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		await speak("Testing testing, it is time to start. We will be using this voice modifier for obvious reasons.")
		
		# start question
		start_question()
	
	# if not at start
	elif anim_name == "zoom_out":
		Global.min_time = 0.5
		quit()

# on first question start and pressed truth
func answerd_truth():

	# first check to see if saying the truth is right
	if get_user_data() == "" || get_user_data() == "TRUTH":
		
		await speak_correct()
		
		# if the user data is not "TRUTH" set to truth
		if get_user_data() != "TRUTH":
			
			# also update total truths/lable
			total_truths += 1
			set_user_data("TRUTH")
			hud.truth_label.text = "Total Truths:\n" + str(total_truths)

		
	else:
		
		# if wrong increse truths anyways as you told him something
		total_truths += 1
		hud.truth_label.text = "Total Truths:\n" + str(total_truths)
		await speak_incorrect()
	
	topic_amount[current_topic] += 1
	
	# new queston
	start_question()

# if you click the correct quick time button
func answerd_no():
	
	# no game progress on quick time event
	total_correct -= 1

	await speak_correct()
	
	# new question
	start_question()

# called from hud when question answered on lie
func answered_question(data: String):
	
	await get_tree().process_frame
	
	# if empty assume correct
	if get_user_data()  == "":
		set_user_data(data)
		questions[current_topic]["usedAnswers"].append(data)
		await speak_correct()

	# if correct
	elif get_user_data() == data:
		await speak_correct()
		
	# if not corrrect
	else:
		await speak_incorrect()
	
	topic_amount[current_topic] += 1
	
	# new question
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
	if should_shake:
		shake_player.play("screen_shake",-1,shake_speed)
		shake_speed += 0.5 * delta
	else:
		if shake_speed == .25:
			if abs(shake_node.rotation.z) < deg_to_rad(0.2):
				shake_player.stop()
				shake_node.rotation.z = 0
				spotlight.rotation = Vector3.ZERO

		else:
			shake_speed -= 0.5 * delta
			shake_player.play("screen_shake",-1,shake_speed)
	shake_speed = clamp(shake_speed,.25,1)
			
			
		
func screen_shake(start = true):
	
	should_shake = start

# used after being shot
func white_out():
	Global.min_time = 0
	white_rect.visible = true

# normal time event time out
func time_out():
	await speak_incorrect()
	start_question()

# quick time event time out
func quick_time_out():
	
	# you die D:
	total_truths = MAX_TRUTHS_ALLOWED + 1
	start_question()

# end the game
func quit():
	Global.next_scene = "res://Scenes/home.tscn"
	get_tree().change_scene_to_file("res://Scenes/loading.tscn")
