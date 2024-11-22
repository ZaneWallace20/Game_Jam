extends Node2D

@onready var text_player: AnimationPlayer = $Text_Player

@onready var header: Label = $ColorRect/ColorRect/Panel/Header
@onready var label: Label = $ColorRect/ColorRect/Panel/Label

var next_scene = ""
var update = 0
var timer = 0
var tutorial = false
var death = false
var SHOW_TIME = 0.5
var should_go_on = false
var wait = false
# Called when the node enters the scene tree for the first time.
func _ready():
	
	# remove mouse 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# start loading next scene
	ResourceLoader.load_threaded_request(Global.next_scene)
	next_scene = Global.next_scene
	

	wait = Global.how_died != "" || Global.next_scene == "res://Scenes/main_room.tscn"
	should_go_on = !wait
	
	

	if !should_go_on:
		await get_tree().create_timer(SHOW_TIME).timeout
		text_player.play("show_text")
		death = Global.how_died != ""
		if death:
			header.text = "YOU DIED\n(Press any key to continue)"
			if Global.how_died == "LIES":
				
				# the most condescending thing ive written
				label.text = """You got caught by changing your story too many times or being too slow. 
						Try and remember your answer for each question."""
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
			if wait:
				
				# prevent spaming animation
				wait = false
				
				# lock out til animation is done
				should_go_on = false
				text_player.play_backwards("show_text")

				await get_tree().create_timer(text_player.current_animation_length + 0.25).timeout
				
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
