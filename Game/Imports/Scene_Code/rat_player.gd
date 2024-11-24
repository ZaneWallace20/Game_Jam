extends AnimationPlayer


var timer = 0


var rng = RandomNumberGenerator.new()
@onready var squeaks: AudioStreamPlayer3D = $"../Squeaks"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = rng.randi_range(3,15)
	squeaks.pitch_scale = rng.randf_range(0.8,1.2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if timer <= 0:
		timer = rng.randi_range(10,25)
		play("move")
	elif !is_playing():
		timer -= delta

# change pitch
func _on_squeaks_finished() -> void:
	squeaks.pitch_scale = rng.randf_range(0.8,1.2)
