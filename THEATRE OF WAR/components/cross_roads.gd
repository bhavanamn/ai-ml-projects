extends Node3D

var Cuboid = load("res://blocks/cuboid.gd")
var utils = load('res://components/utils.gd')

var options = {}

func _ready() -> void:
	var world = Cuboid.new()
	world.options = {'size': Vector3.ZERO,}
	add_child(world)
	
	var ground = Cuboid.new()
	var floor_dim = utils.get_value(options, 'floor_dim', 200)
	ground.options = {'location': Vector3(0, -0.01 ,0),
					'size': Vector3(floor_dim, 0.01, floor_dim),
					'color': utils.get_value(options, 'floor_color', Color(0.2, 1, 0.2)) 
					}
	#world.collision_layer = options['collision_layer']
	#world.collision_mask = options['collision_mask'] 
	world.collision_layer = options['collision_layer_world']
	world.collision_mask = options['collision_mask_world'] 
	world.add_child(ground, true)
	
	
	
	
	var horizontal_road = Cuboid.new()
	horizontal_road.options = {'location': utils.get_value(options, 'hor_location',Vector3.ZERO), 
								'size': utils.get_value(options, 'hor_size', Vector3.ONE),
								'color': utils.get_value(options, 'hor_color', Color(0.2, 0.2, 0.2))
								}
	
	#horizontal_road.collision_layer = options['collision_layer']
	#horizontal_road.collision_mask = options['collision_mask'] 
	horizontal_road.collision_layer = options['collision_layer_roads']
	horizontal_road.collision_mask = options['collision_mask_roads'] 
	#world.add_child(horizontal_road, true)
	
	var vertical_road = Cuboid.new()
	vertical_road.options = {'location': utils.get_value(options, 'ver_location',Vector3.ZERO), 
								'size': utils.get_value(options, 'ver_size', Vector3.ONE),
								'color': utils.get_value(options, 'ver_color', Color(0.2, 0.2, 0.2))
								}
	
	#vertical_road.collision_layer = options['collision_layer']
	#vertical_road.collision_mask = options['collision_mask'] 

	vertical_road.collision_layer = options['collision_layer_roads']
	vertical_road.collision_mask = options['collision_mask_roads'] 
	#world.add_child(vertical_road, true)
	
