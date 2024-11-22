extends Node3D

@onready var water_drop_audio: AudioStreamPlayer3D = $Water_Drop_Audio
@onready var subway_audio: AudioStreamPlayer3D = $Subway_Audio
@onready var dirt_particles: GPUParticles3D = $Dirt_Particles
@onready var main_room: Node3D = $".."

@export var emission_delay = 3
@export var screen_shake_length = 13


var set_screen_shake_length = screen_shake_length
var set_emission_delay = emission_delay
# used for getting random nums
var rng = RandomNumberGenerator.new()

var water_timer = rng.randf_range(2,5)
var subway_timer = rng.randf_range(25,45)

var did_emit = false
var is_shaking = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
		
		# water
		if water_timer <= 0:
	
			water_drop_audio.pitch_scale = rng.randf_range(0.8,1.2)
			water_drop_audio.play()
			water_timer = rng.randf_range(2,5)
		else:
			water_timer -= delta
		
		# subway
		if subway_timer <= 0:
			subway_audio.play()
			subway_timer = rng.randf_range(25,45)
		elif !subway_audio.playing:
			subway_timer -= delta
			
			# reset emit for later
			did_emit = false
		elif !did_emit:
			
			# add a small delay for particles/screen shake
			if emission_delay <= 0:
				emission_delay = set_emission_delay
				
				# dont spam
				did_emit = true
				
				# show shake/particles
				dirt_particles.emitting = true
				main_room.screen_shake()
				
				# start counting down when to stop shaking
				is_shaking = true
				
			else:
				emission_delay -= delta
				
		# start count down when to stop shaking
		if is_shaking:
			
			# stop shaking
			if screen_shake_length <= 0:
				is_shaking = false
				main_room.screen_shake(false)
				screen_shake_length = set_screen_shake_length
			# decrese timer
			else:
				screen_shake_length -= delta
