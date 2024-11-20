extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2

@onready var animation_player_3: AnimationPlayer = $AnimationPlayer3

@onready var start: Button = $Start
@onready var title: Label = $title
@onready var title_2: Label = $title2
@onready var cam: Camera3D = $Cam
@onready var strike: Label = $title/strike

var should_go = false
var instructions_open = false

# used for getting random nums
var rng = RandomNumberGenerator.new()

func _unhandled_input(event: InputEvent) -> void:
	
	# end game
	if event.is_action_pressed("quit"):
		get_tree().quit()

func _ready() -> void:
	
	# check to see if not first run
	if Global.next_scene != "":
		
		# zoom out from center
		cam.fov = 5
		start.disabled = true
		animation_player_2.play_backwards("clear")
		animation_player.play_backwards("zoom")
		
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	# 5% chance to show`
	var should_show_strike = rng.randi_range(0,20) == 10
	
	
	if should_show_strike:
		strike.visible = true
	
func _on_start_pressed() -> void:
	should_go = true
	# when starting play the zoom animation
	animation_player.play("zoom")
	
	# when starting play the clear animation
	# this removes the start button
	animation_player_2.play("clear")
	
	# tell the loading file what to load
	Global.next_scene = "res://Scenes/main_room.tscn"
	Global.min_time = 0.5
	
	# disable start button to prevent bugs
	start.disabled = true
	
	#disable mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "zoom" && should_go:
		
		# after zoom is done, switch to loading screen
		get_tree().change_scene_to_file("res://Scenes/loading.tscn")
	else:
		start.disabled = false

# toggle instructions
func _on_question_pressed() -> void:
	if instructions_open:
		animation_player_3.play_backwards("show_instructions")
	else:
		animation_player_3.play("show_instructions")
	
	instructions_open = !instructions_open
