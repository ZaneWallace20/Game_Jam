extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hud: Node2D = $Hud

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("zoom_out")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "zoom_out":
		hud.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
