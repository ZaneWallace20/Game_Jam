extends Control

# --- Nodes ---
@onready var hud: Control = $"."  
@onready var button_grid: GridContainer = $Buttons_Background/Button_Grid
@onready var button: Button = $Buttons_Background/Button_Grid/Temp_Button
@onready var show_player: AnimationPlayer = $Show_Player
@onready var buttons_background: Panel = $Buttons_Background
@onready var main_room = $".."  
@onready var lie_label: Label = $Color_Background/Lie_Label
@onready var correct_label: Label = $Color_Background2/Correct_Label
@onready var truth_label: Label = $Color_Background3/Truth_Label
@onready var progress_bar: ProgressBar = $Buttons_Background/Progress_Bar
@onready var number_input: LineEdit = $Buttons_Background/Button_Grid/Number_Input

# --- Timer Settings ---
@export var progress_timer = 10  
@export var quick_progress_timer = 1
var set_timer = progress_timer
var set_quick_timer = quick_progress_timer
var should_time = false  
var should_time_quick = false  


func reset():
	
	
	if Input.mouse_mode != Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	number_input.visible = false
	number_input.text = ""
	button.disconnect("pressed",self.pressed)
	
	# show the buttons
	show_player.play("show_buttons")
	
	# remove old buttons
	for i in button_grid.get_children():
		if i.name != "Temp_Button" and i.name != "Number_Input":
			i.free()
	
	# make the default button clickable
	button.disabled = false


func quick_time_event():
		# reset/start timer
		should_time_quick = true
		progress_bar.value = 100
		quick_progress_timer = set_quick_timer
		
		reset()
		
		# play the animation, faster
		show_player.play("show_buttons",-1,2)
		
		# used to randomize options
		var yes_no =["YES","NO"]
		
		yes_no.shuffle()
		
		# set buttons to either "YES" or "NO"
		button.get_child(0).text = yes_no[0] + "!"
		button.connect("pressed",self.pressed.bind(yes_no[0]))
		var temp_button = button.duplicate()
		
		temp_button.get_child(0).text = yes_no[1]+"!"
		temp_button.connect("pressed",self.pressed.bind(yes_no[1]))
		button_grid.add_child(temp_button)
		
		button_grid.set_anchors_preset(Control.PRESET_CENTER)
		

# will be used to give lie/truth option
func reset_questions():

	# reset/start timer
	should_time = true
	progress_bar.value = 100
	progress_timer = set_timer
	
	# show the buttons
	show_player.play("show_buttons")
	
	reset()
	
	button.get_child(0).text = "Try and Tell a Lie"
	button.connect("pressed",self.pressed.bind("LIE"))
	var temp_button = button.duplicate()
	
	temp_button.get_child(0).text = "Tell the Truth"
	temp_button.connect("pressed",self.pressed.bind("TRUTH"))
	button_grid.add_child(temp_button)
	
	button_grid.set_anchors_preset(Control.PRESET_CENTER)


# grab data from main_room and set it to the buttons
func set_up_questions(data: Array):

	# show the buttons
	show_player.play("show_buttons")
	
	reset()
	
	# connect the button to the pressed func with the data[0] peramater
	button.connect("pressed",self.pressed.bind(data[0]))
	button.get_child(0).text = data[0]
	
	# remove data[0] as it's in use
	data.pop_at(0)
	
	# itterate through remaining data
	for i in data:
		
		# dup default button
		var temp_button = button.duplicate()
		
		# connect the button to the pressed func with the i peramater
		temp_button.connect("pressed",self.pressed.bind(i))
		temp_button.get_child(0).text = i
		button_grid.add_child(temp_button)

# frq on numbers only
func set_up_questions_free():
		show_player.play("show_buttons")
	
		reset()
		button.get_child(0).text = "Submit"
		button.connect("pressed",self.pressed.bind("Input"))
		number_input.visible = true
		
		
	
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# on start set button to pressed to prevent bugs
	button.connect("pressed",self.pressed.bind(""))
	

func pressed(data: String) -> void:
	
	# check const options
	if data == "LIE":
		# ask main_room to send question options
		main_room.get_question_options()
		return
	elif data == "TRUTH":
		main_room.answerd_truth()
		should_time = false
	# frq response
	elif data == "Input":
		
		var return_data = number_input.text
		return_data = return_data.trim_prefix(" ")
		return_data.trim_suffix(" ")
		main_room.answered_question(return_data)
		should_time = false
	elif data == "YES":
		main_room.quick_time_out()
		should_time_quick = false
	elif  data == "NO":
		main_room.answerd_no()
		should_time_quick = false
	else:
		# send data back to the room
		main_room.answered_question(data)
		should_time = false
		
	# when pressed hide buttons
	show_player.play_backwards("show_buttons")
	
	#disable all buttons to prevent bugs
	for i in button_grid.get_children():
		if i is Button:
			i.disabled = true


func _process(delta: float) -> void:
	
	# normal timer
	if should_time:
		
		# if timeout
		if progress_timer <= 0:
			main_room.time_out()
			show_player.play_backwards("show_buttons")
			should_time = false
			
			#disable all buttons to prevent bugs
			for i in button_grid.get_children():
				if i is Button:
					i.disabled = true
				
		# decrese/update timer
		progress_timer -= delta
		progress_bar.value = 100 - ((set_timer-progress_timer)/set_timer) * 100

	# quick timer
	if should_time_quick:
		
		# if timeout
		if quick_progress_timer <= 0:
			main_room.quick_time_out()
			show_player.play_backwards("show_buttons")
			should_time_quick = false
			
			#disable all buttons to prevent bugs
			for i in button_grid.get_children():
				if i is Button:
					i.disabled = true

		# decrese/update timer
		quick_progress_timer -= delta
		progress_bar.value = 100 - ((set_quick_timer-quick_progress_timer)/set_quick_timer) * 100
	
