extends Control
@onready var hud: Control = $"."
@onready var button_grid: GridContainer = $buttons_background/button_grid
@onready var button: Button = $buttons_background/button_grid/temp_button

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var buttons_background: Panel = $buttons_background

@onready var main_room := $".."
var total_seconds = 0

# will be used to give lie/truth option
func reset_grid():
	
	button.disconnect("pressed",self.pressed)
	
	# show the buttons
	animation_player.play("show_buttons")
	
	# remove old buttons
	for i in button_grid.get_children():
		if i.name != "temp_button":
			i.free()
	
	# make the default button clickable
	button.disabled = false
	
	button.get_child(0).text = "Lie"
	button.connect("pressed",self.pressed.bind("LIE"))
	var temp_button = button.duplicate()
	
	temp_button.get_child(0).text = "Truth"
	temp_button.connect("pressed",self.pressed.bind("TRUTH"))
	button_grid.add_child(temp_button)
	
	button_grid.set_anchors_preset(Control.PRESET_CENTER)


# grab data from main_room and set it to the buttons
func set_up_questions(data: Array):
	
	# show the buttons
	animation_player.play("show_buttons")
	
	# remove old buttons
	for i in button_grid.get_children():
		if i.name != "temp_button":
			i.free()
			
	# make the default button clickable
	button.disabled = false
	
	# disconnect to prevent bugs
	button.disconnect("pressed",self.pressed)
	
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
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# on start set button to pressed to prevent bugs
	button.connect("pressed",self.pressed.bind(""))
	

func pressed(data: String) -> void:
	
	
	if data == "LIE":
		main_room.ask_question()
		return
	elif data == "TRUTH":
		main_room.answerd_truth()
		
	else:
		# send data back to the room
		main_room.answered_question(data)
		
	# when pressed hide buttons
	animation_player.play_backwards("show_buttons")
	
	#disable all buttons to prevent bugs
	for i in button_grid.get_children():
		i.disabled = true
