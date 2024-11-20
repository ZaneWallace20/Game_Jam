extends Node3D

@onready var water_drop_audio: AudioStreamPlayer3D = $water_drop_audio

# used for getting random nums
var rng = RandomNumberGenerator.new()
var water_timer = rng.randf_range(2,5)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		
		if water_timer <= 0:
			print("PLAY")
			water_drop_audio.pitch_scale = rng.randf_range(0.8,1.2)
			water_drop_audio.play()
			water_timer = rng.randf_range(2,5)
			
		water_timer -= delta
