extends OmniLight3D

@export var noise: NoiseTexture3D

@onready var electric_sound: AudioStreamPlayer3D = $"../Electric_Sound"

var time_passed := 0.0

var last_noise = 0

var electric_cool_down = 0.1
var set_electric_cool_down = 0.5

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_passed += delta
	
	var sampled_noise = noise.noise.get_noise_1d(time_passed)
	sampled_noise = abs(sampled_noise)
	
	light_energy = sampled_noise * 10
	
	electric_sound.pitch_scale = clamp(sampled_noise * 10, 0.95, 1.0) - .2
	electric_sound.volume_db = lerp(-40, -15, sampled_noise) 
