extends Node3D

var Cuboid = load("res://blocks/cuboid.gd")
var Camera = load("res://blocks/camera.gd")
var Light  = load("res://blocks/directional_light.gd")
var Cylinder = load("res://blocks/cylinder.gd")
var Sphere = load("res://blocks/sphere.gd")
var Labels = load("res://blocks/labels.gd")
var CrossRoads = load("res://components/cross_roads.gd")


func _ready() -> void:
	var cuboid01 = Cuboid.new()
	cuboid01.options = {'location': Vector3(-6, 0, 0), 
						'size': Vector3(6, 1, 1),
						'color': Color(1, 0, 0, 1),
						}
	add_child(cuboid01, true)

	cuboid01 = Cuboid.new()
	cuboid01.options = {'location': Vector3(-6, 1, 0), 
						'size': Vector3(6, 0.5, 1),
						'color': Color(1, 1, 0, 1),
						}
	add_child(cuboid01, true)
	
	cuboid01 = Cuboid.new()
	cuboid01.options = {'location': Vector3(-6, 2, 0), 
						'size': Vector3(6, 0.5, 1),
						'color': Color(1, 1, 0, 1),
						}
	add_child(cuboid01, true)
	
	var cylinder01 = Cylinder.new()
	cylinder01.options = {'location': Vector3(0, 0, 0), 
						'height': 6,
						'radius': 2,
						'color': Color(1, 0, 0, 1),
						}
	add_child(cylinder01, true)

	var sphere01 = Sphere.new()
	sphere01.options = {'location': Vector3(6, 0, 0), 
						'radius': 2,
						'color': Color(1, 0, 0, 1),
						}
	add_child(sphere01, true)
#
	sphere01 = Sphere.new()
	sphere01.options = {'location': Vector3(5, 0, 0), 
						'radius': 2,
						}
	add_child(sphere01, true)
	
	var label01 = Labels.new()
	label01.options = {'location': Vector3(4, 2, 0), 
						'scale': Vector3(2, 2, 2),
						'text': "Raj"
						}
	add_child(label01, true)

	var cam = Camera.new()
	cam.options = {'location': Vector3(0, 0, 20), 
						'target': Vector3.ZERO,
						'direction': Vector3.UP
						}
	add_child(cam, true)
	
	var light = Light.new()
	light.energy = 10
	add_child(light, true)
	
	
	var xroads = CrossRoads.new()
	xroads.options = {	'hor_size': Vector3(5, 1, 1),
						'ver_size': Vector3(1, 5, 1),
						'hor_color': Color(1, 0, 0)
						}
	add_child(xroads)
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
