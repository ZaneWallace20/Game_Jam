extends Control
@onready var hud: Control = $"."
@onready var button_grid: GridContainer = $buttons_background/button_grid
@onready var button: Button = $buttons_background/button_grid/temp_button

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var buttons_background: Panel = $buttons_background

@onready var main_room := $".."
var total_seconds = 0

func reset_grid():
	button.get_child(0).text = "Lie"
	
	var temp_button = button.duplicate()
	
	temp_button.get_child(0).text = "Truth"
	
	button_grid.add_child(temp_button)
	button_grid.set_anchors_preset(Control.PRESET_CENTER)

func set_up_questions(data: Array):
	animation_player.play("show_buttons")
	for i in button_grid.get_children():
		if i.name != "temp_button":
			i.free()
	button.disabled = false
	button.disconnect("pressed",self.pressed)
	button.connect("pressed",self.pressed.bind(data[0]))
	button.get_child(0).text = data[0]
	data.pop_at(0)
	
	
	for i in data:
		var temp_button = button.duplicate()
		temp_button.disconnect("pressed",self.pressed)
		temp_button.connect("pressed",self.pressed.bind(i))
		temp_button.get_child(0).text = i
		button_grid.add_child(temp_button)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.connect("pressed",self.pressed.bind(""))
	
	reset_grid()


func pressed(data: String) -> void:
	animation_player.play_backwards("show_buttons")
	main_room.answered_question(data)
	print("CLICK")
	for i in button_grid.get_children():
		i.disabled = true
