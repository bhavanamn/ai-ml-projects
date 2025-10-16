extends Node3D

var Camera = load("res://blocks/camera.gd")
var Light  = load("res://blocks/directional_light.gd")
var CrossRoads = load("res://components/cross_roads.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var xroads = CrossRoads.new()
	xroads.options = {'hor_location': Vector3(0, 0, 0),
						'ver_location': Vector3(0, 0, 0),
						'hor_size': Vector3(100, 0.1, 6),
						'ver_size': Vector3(6, 0.1, 100),
						}
	add_child(xroads, true)
	
	var cam = Camera.new()
	cam.options = {'location': Vector3(0, 10, 50), 
						'target': Vector3.ZERO,
						'direction': Vector3.UP
						}
	add_child(cam, true)
	
	var light = Light.new()
	light.energy = 10
	add_child(light, true)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
