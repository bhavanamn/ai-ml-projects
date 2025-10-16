#class_name MyCamera
extends Camera3D
var utils = load("res://components/utils.gd")
var options = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	global_position = utils.get_value(options, 'location', Vector3.ZERO)
	var target = utils.get_value(options, 'target', Vector3.ZERO)
	var direction = utils.get_value(options, 'direction', Vector3.UP)
	look_at(target, direction)
	
#func _process(delta):
	#pass
