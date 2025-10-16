extends Label3D

var utils = load("res://components/utils.gd")
var options = {}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = utils.get_value(options, 'text', '')
	position = utils.get_value(options, 'location', Vector3.ZERO)
	scale = utils.get_value(options, 'scale', Vector3.ONE)
	
