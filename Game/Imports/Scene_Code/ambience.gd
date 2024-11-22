extends Node3D

@onready var water_drop_audio: AudioStreamPlayer3D = $water_drop_audio
@onready var subway_audio: AudioStreamPlayer3D = $subway_audio
@onready var dirt_particles: GPUParticles3D = $dirt_particles

@export var emission_delay = 3



var set_emission_delay = emission_delay
# used for getting random nums
var rng = RandomNumberGenerator.new()

var water_timer = rng.randf_range(2,5)
var subway_timer = rng.randf_range(2,4)

var did_emit = false

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
			did_emit = false
		elif !did_emit:
			
			if emission_delay <= 0:
				emission_delay = set_emission_delay
				did_emit = true
				dirt_particles.emitting = true
				print("emit")
			else:
				emission_delay -= delta
		
		
		
			
