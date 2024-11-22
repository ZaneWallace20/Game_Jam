extends Node3D
@onready var rack_sound: AudioStreamPlayer3D = $Rack
@onready var gun_shot_sound: AudioStreamPlayer3D = $Gun_Shot_Audio
@onready var fire_player: AnimationPlayer = $Fire_Player
@onready var main_room: Node3D = $".."

func fire():
	await get_tree().create_timer(0.25).timeout
	fire_player.play("Fire")
	await get_tree().create_timer(0.75).timeout
	main_room.white_out()


# you died quit the game
func _on_fire_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Fire":
		main_room.quit()
