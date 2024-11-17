extends Node3D
@onready var rack_sound: AudioStreamPlayer3D = $RigidBody3D/Gun/Rack
@onready var gun_shot_sound: AudioStreamPlayer3D = $RigidBody3D/Gun/GunShot
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var main_room: Node3D = $".."


func fire():
	await get_tree().create_timer(0.25).timeout
	animation_player.play("Fire")
	await get_tree().create_timer(0.75).timeout
	main_room.white_out()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Fire":
		main_room.quit()
