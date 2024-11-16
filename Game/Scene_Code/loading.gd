extends Node2D

var next_scene = ""
var update = 0

# min time this should be visible
@export var MIN_TIME = 0.5
var timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# remove mouse 
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# start loading next scene
	ResourceLoader.load_threaded_request(Global.next_scene)
	next_scene = Global.next_scene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	# check if scene is loaded
	if update == 1:
		
		# check to see if min time has been met
		if timer >= MIN_TIME:
			
			# if so swap
			var packed_scene = ResourceLoader.load_threaded_get(next_scene)
			get_tree().change_scene_to_packed(packed_scene)
	else:
		
		# grab progress
		var progress = []
		ResourceLoader.load_threaded_get_status(next_scene,progress)
		
		# check to see what the progress is at if changed
		if progress[0] > update:
			update = progress[0]
			
	# add timer time for min time check
	timer += delta
	
