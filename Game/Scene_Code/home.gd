extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2

@onready var start: Button = $Start


func _on_start_pressed() -> void:
	
	# when starting play the zoom animation
	animation_player.play("zoom")
	
	# when starting play the clear animation
	# this removes the start button
	animation_player_2.play("clear")
	
	# tell the loading file what to load
	Global.next_scene = "res://Scenes/main_room.tscn"
	
	# disable start button to prevent bugs
	start.disabled = true
	
	#disable mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "zoom":
		
		# after zoom is done, switch to loading screen
		get_tree().change_scene_to_file("res://Scenes/loading.tscn")
