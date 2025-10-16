extends Node3D

var Camera = load("res://blocks/camera.gd")
var Light  = load("res://blocks/directional_light.gd")

var Person = load("res://components/static_human.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var p1 = Person.new()
	p1.options = {'height': 18, 'width': 5, 'name': "A"}
	add_child(p1, true)

	p1 = Person.new()
	p1.options = {'height': 18, 'width': 5, 'name': "B", 'location': Vector3(15, 5, 0)}
	add_child(p1, true)

	p1 = Person.new()
	p1.options = {'height': 18, 'width': 5, 'name': "C", 'location': Vector3(-15, -5, 0)}
	add_child(p1, true)

	var cam = Camera.new()
	cam.options = {'location': Vector3(0, 0, 50), 'target': Vector3(0, 0, 0), 
					'direction': Vector3.UP,
					}
	add_child(cam, true)
	
	#var light = Light.new()
	#light.energy = 10
	#add_child(light, true)
