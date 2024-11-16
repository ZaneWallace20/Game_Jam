extends Node2D

var next_scene = ""
var update = 0

@export var MIN_TIME = 0.5
var timer = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	ResourceLoader.load_threaded_request(Global.next_scene)
	next_scene = Global.next_scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if update == 1:
		
		if timer >= MIN_TIME:
			var packed_scene = ResourceLoader.load_threaded_get(next_scene)
			get_tree().change_scene_to_packed(packed_scene)
	else:
		var progress = []
		ResourceLoader.load_threaded_get_status(next_scene,progress)
		
		if progress[0] > update:
			update = progress[0]
	timer += delta
	
