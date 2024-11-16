extends Node2D
@onready var seconds: Label = $ColorRect/Label/Seconds
@onready var hud: Node2D = $"."

var total_seconds = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	seconds.text = str(round(total_seconds))
	total_seconds += delta
