extends Node3D

var Cylinder = load("res://blocks/cylinder.gd")
var Cone = load("res://blocks/cone.gd")
var Sphere = load("res://blocks/sphere.gd")
var Labels = load("res://blocks/labels.gd")
var Cuboid = load("res://blocks/cuboid.gd")
var utils = load("res://components/utils.gd")
var CrossRoads = load("res://components/cross_roads.gd")

var options = {}
var body
var head
var right_leg
var left_leg
var right_arm
var left_arm

func _ready() -> void:
	var disp_name = utils.get_value(options, 'name', '')
	var location = utils.get_value(options, 'location', Vector3.ZERO)
	var want_collision_on_hands = utils.get_value(options, 'want_collision_on_hands', false)
	var height = utils.get_value(options, 'height', 1.8)
	var width = utils.get_value(options, 'width', 0.5)
	
	var legs_height = height/2.0
	var head_height = legs_height/4.0
	var torso_height = 3.0 * legs_height/4.0
	var hands_height = legs_height + 0.5 * head_height
	
	var world = get_parent()
	
	body = Cone.new()
	body.options = {
	'location': location + Vector3(0, legs_height + 0.5 * torso_height, 0),
	'height': torso_height,
	'top_radius': width/1.5,
	'bottom_radius': width/2.0,
	'color': Color(1, 0, 0, 1),
	}
	world.add_child(body, true)
		
	#var head1 = Sphere.new()
	#head1.options = {'location': location + Vector3(0, legs_height, 0), 'radius': width, 'color': Color(1, 0, 1, 1)}
	#world.add_child(head1)
	
	head = Cone.new()
	head.options = {
	'location': location + Vector3(0, height - 0.5 * head_height, 0),
	'height': head_height,
	'top_radius': width/4,
	'bottom_radius': width/2.0,
	'color': Color(1, 0, 0, 1),
	}
	world.add_child(head, true)
	
	right_leg = Cylinder.new()
	right_leg.options = {'location': location + Vector3(width * 0.2, 0.5 * legs_height, 0),
						'height': legs_height,
						'radius': width/4.0,
						'angle_z': deg_to_rad(0),
						'color': Color(0, 0, 1, 1),
						}
	world.add_child(right_leg, true)
	
	left_leg = Cylinder.new()
	left_leg.options = {'location': location + Vector3(-width * 0.2, 0.5 * legs_height, 0),
						'height': legs_height,
						'radius': width/4.0,
						'angle_z': deg_to_rad(0),
						'color': Color(1, 0, 1, 1),
						}
	world.add_child(left_leg, true)
	
	left_arm = Cylinder.new()
	left_arm.options = {'location': location + Vector3(-width * 0.7, 1.8 * head_height + torso_height, 0),
					'height': hands_height,
					'radius': width/5.0,
					'angle_z': deg_to_rad(-15),
					'color':Color(1, 0, 1, 1)
					}
	
	right_arm = Cylinder.new()
	right_arm.options = {'location': location + Vector3(width * 0.7, 1.8 * head_height + torso_height, 0),
					'height': hands_height,
					'radius': width/5.0,
					'angle_z': deg_to_rad(15),
					}

	if want_collision_on_hands:
		world.add_child(right_arm, true)
		world.add_child(left_arm, true)
	else:
		add_child(right_arm)
		add_child(left_arm)
	
	var disp = Labels.new()
	var font_scale = body.options['top_radius'] * 4
	disp.options = {'location': body.options['location']+ Vector3(0, 0, body.options['top_radius']),
							'scale': Vector3.ONE * font_scale,
							'text': disp_name,
							'modulate': Color(0, 1, 1, 1)
							}
	add_child(disp)

	#var xroads = CrossRoads.new()
	#xroads.options = {	'hor_size': Vector3(5, 1, 1),
						#'ver_size': Vector3(1, 5, 1),
						#'hor_color': Color(1, 0, 0)
						#}
	#add_child(xroads)

	#var listOfAllNodesInTree = []
	#utils.GetAllTreeNodes(get_tree().root, listOfAllNodesInTree)
	#for node in listOfAllNodesInTree:		
		#if node.name != 'root':
			#print(node, node.global_position)
	#
	
