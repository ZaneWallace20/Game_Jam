extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var animation_player_2: AnimationPlayer = $AnimationPlayer2

@onready var start: Button = $Start


func _on_start_pressed() -> void:
	animation_player.play("zoom")
	animation_player_2.play("clear")
	Global.next_scene = "res://Scenes/main_room.tscn"
	start.disabled = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "zoom":
		get_tree().change_scene_to_file("res://Scenes/loading.tscn")
