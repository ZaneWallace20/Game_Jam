extends Node3D

@onready var water_drop_audio: AudioStreamPlayer3D = $water_drop_audio
@onready var subway_audio: AudioStreamPlayer3D = $subway_audio

# used for getting random nums
var rng = RandomNumberGenerator.new()

var water_timer = rng.randf_range(2,5)
var subway_timer = rng.randf_range(25,45)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		
		if water_timer <= 0:
	
			water_drop_audio.pitch_scale = rng.randf_range(0.8,1.2)
			water_drop_audio.play()
			water_timer = rng.randf_range(2,5)
		else:
			water_timer -= delta
		
		if subway_timer <= 0:
			subway_audio.play()
			subway_timer = rng.randf_range(25,45)
		elif !subway_audio.playing:
			subway_timer -= delta
			
