extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var voice_over: AudioStreamPlayer = $voice_over

@onready var header: Label = $ColorRect/ColorRect/Panel/header
@onready var label: Label = $ColorRect/ColorRect/Panel/Label

var next_scene = ""
var update = 0
var timer = 0
var tutorial = false
var death = false
var SHOW_TIME = 0.5
var should_go_on = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# remove mouse 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# start loading next scene
	ResourceLoader.load_threaded_request(Global.next_scene)
	next_scene = Global.next_scene
	
	tutorial = Global.next_scene == "res://Scenes/main_room.tscn"
	death = Global.how_died != ""
	should_go_on = !tutorial && Global.how_died == ""
	
	if !should_go_on:
		await get_tree().create_timer(SHOW_TIME).timeout
		animation_player.play("show_text")
	
		if death:
			header.text = "YOU DIED\n(Press any key to continue)"
			if Global.how_died == "LIES":
				
				# the most condescending thing ive written
				label.text = """You got caught by changing your story too many times or being too slow. 
						Try and remember which lie you told for each question."""
			else:
				# the most condescending thing ive written
				label.text = """You got caught by telling the truth too much.
					If you tell them too much information they will know you are guilty."""
					
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			should_go_on = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			should_go_on = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# check if scene is loaded
	if update == 1:
		
		# check to see if min time has been met along with should_go_on
		if timer >= Global.min_time && should_go_on:
			
			# fade out
			if tutorial:
				
				# prevent spaming animation
				tutorial = false
				
				# lock out til animation is done
				should_go_on = false
				animation_player.play_backwards("show_text")

				await get_tree().create_timer(animation_player.current_animation_length + 0.25).timeout
				
				# go on
				should_go_on = true
			elif death:
				
				death = false
				
				# lock out til animation is done
				should_go_on = false
				animation_player.play_backwards("show_text")

				await get_tree().create_timer(animation_player.current_animation_length + 0.25).timeout
				
				# go on
				should_go_on = true
			
				
			else:

				# if so swap
				var packed_scene = ResourceLoader.load_threaded_get(next_scene)
				get_tree().change_scene_to_packed(packed_scene)
	else:
		
		# grab progress
		var progress = []
		ResourceLoader.load_threaded_get_status(next_scene,progress)
		
		# check to see what the progress is at if changed
		if progress[0] > update:
			update = progress[0]
			
	# add timer time for min time check
	timer += delta
	
func _on_voice_over_finished() -> void:
	should_go_on = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if !should_go_on && tutorial:
		voice_over.play()
		
