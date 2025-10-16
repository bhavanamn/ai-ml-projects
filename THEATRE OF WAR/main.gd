class_name HumanTest
extends Node3D

var Camera = load("res://blocks/camera.gd")
var Light  = load("res://blocks/directional_light.gd")
var MovablePerson = load("res://components/movable_human.gd")

var utils = load("res://components/utils.gd")
var Sphere_Rigid = load("res://blocks/sphere_with_rigid_body.gd")
var rigid_body_script = load("res://components/rigid_body_functions.gd")
var label = load("res://blocks/labels.gd")

#var SyncConnection = load("res://addons/godot_rl_agents/sync.gd")
var main_map = load("res://main.gd")

@export var speed = 10
@export var jump_velocity = 5 					#2
@export var reset_teleport = Vector3(395.52, 0, -275.6)         # -255.6

enum ControlModes {HUMAN, TRAINING}
@export var control_mode: ControlModes = ControlModes.HUMAN


var default_camera_player_location = Vector3.ZERO
var default_camera_player_offset = Vector3(0, 15, 50)
var layers = utils.Getlayers()

var players = {}
var persons_list = [
	{'name': 'A', 'want_collision_on_hands': true, 
	#'location':  Vector3(-5, road_width/2, 0),
	'location':  reset_teleport,
	'height': 8, 'width': 1.5, 'player_controls': utils.user_controls['player_controls'],
	'speed': speed, 'jump_velocity' : jump_velocity, 'selected': false 
	},
	#{
	#'name': 'B', 'want_collision_on_hands': true, 'location': reset_teleport,
	#'height': 8, 'width': 1.5, 'player_controls': utils.user_controls['player_controls'],
	#'speed': speed, 'jump_velocity' :jump_velocity, 'selected': false
	 #},
	#{
	#'name': 'C', 'want_collision_on_hands': true, 'location': reset_teleport,
	#'height': 8, 'width': 1.5, 'player_controls': utils.user_controls['player_controls'],
	#'speed': speed, 'jump_velocity' :jump_velocity, 'selected': false 
	#},
	]


var main_player = null
var assign_camera_to_main_player = false
var has_collided = false 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var idx = 0
	for person in persons_list:
		var p1 = MovablePerson.new()
		p1.options = person
		p1.options['collision_layer']=  layers["character"] #4
		p1.options['collision_mask'] =  layers['sphere_rigid'] |  layers["floor"] | layers["highway"]  | layers["building"]  | layers["common"] | 	layers["water"]   #2 | 8 | 16 | 32 | 64 | 128
		p1.options['player_mode'] = control_mode
		p1.rotate_y(deg_to_rad(90))
		add_child(p1, true)
		
		if main_player == null:
			main_player = p1
			main_player.options['selected'] = true
			assign_camera_to_main_player = true
			$map.player_inst = main_player
			
				
		idx+=1
		utils.user_controls['camera_controls'][person.name] = [KEY_0 + idx]
		
	
	var col_obj1 = Sphere_Rigid.new()
	col_obj1.options['location'] = Vector3(361.07,0.030,-471)
	col_obj1.options['radius'] = 2
	col_obj1.options['color'] = Color(1,1,0,1)
	col_obj1.collision_layer = layers['sphere_rigid'] 
	col_obj1.collision_mask = layers['character'] | layers["floor"] | layers["highway"]  | layers["building"]  | layers["common"] | 	layers["water"]
	add_child(col_obj1)
	
	
	var col_obj2 = Sphere_Rigid.new()
	col_obj2.options['location'] = Vector3(384.4,0.030,-500)
	col_obj2.options['radius'] = 2
	col_obj2.options['color'] = Color(1,1,0,1)
	col_obj2.collision_layer = layers['sphere_rigid'] 
	col_obj2.collision_mask = layers['character'] | layers["floor"] | layers["highway"]  | layers["building"]  | layers["common"] | 	layers["water"]
	add_child(col_obj2)
	
	var col_obj3 = Sphere_Rigid.new()
	col_obj3.options['location'] = Vector3(380,0.030,-294)
	col_obj3.options['radius'] = 2
	col_obj3.options['color'] = Color(1,1,0,1)
	col_obj3.collision_layer = layers['sphere_rigid'] 
	col_obj3.collision_mask = layers['character'] | layers["floor"] | layers["highway"]  | layers["building"]  | layers["common"] | 	layers["water"]
	add_child(col_obj3)
	
	var col_obj4 = Sphere_Rigid.new()
	col_obj4.options['location'] = Vector3(407.53,0.030,-324)
	col_obj4.options['radius'] = 2
	col_obj4.options['color'] = Color(1,1,0,1)
	col_obj4.collision_layer = layers['sphere_rigid'] 
	col_obj4.collision_mask = layers['character'] | layers["floor"] | layers["highway"]  | layers["building"]  | layers["common"] | 	layers["water"]
	add_child(col_obj4)
	
	var col_obj5 = Sphere_Rigid.new()
	col_obj5.options['location'] = Vector3(361.07,0.030,-471)
	col_obj5.options['radius'] = 2
	col_obj5.options['color'] = Color(1,1,0,1)
	col_obj5.collision_layer = layers['sphere_rigid'] 
	col_obj5.collision_mask = layers['character'] | layers["floor"] | layers["highway"]  | layers["building"]  | layers["common"] | 	layers["water"]
	add_child(col_obj5)
	
	var col_obj6 = Sphere_Rigid.new()
	col_obj6.options['location'] = Vector3(384.4,0.030,-520)
	col_obj6.options['radius'] = 2
	col_obj6.options['color'] = Color(1,1,0,1)
	col_obj6.collision_layer = layers['sphere_rigid'] 
	col_obj6.collision_mask = layers['character'] | layers["floor"] | layers["highway"]  | layers["building"]  | layers["common"] | 	layers["water"]
	add_child(col_obj6)
		
	var col_obj7 = Sphere_Rigid.new()
	col_obj7.options['location'] = Vector3(375.6,0.03,-375)
	col_obj7.options['radius'] = 2
	col_obj7.options['color'] = Color(1,1,0,1)
	col_obj7.collision_layer = layers['sphere_rigid'] 
	col_obj7.collision_mask = layers['character'] | layers["floor"] | layers["highway"]  | layers["building"]  | layers["common"] | 	layers["water"]
	add_child(col_obj7)
	#
	var col_obj8 = Sphere_Rigid.new()
	col_obj8.options['location'] = 	Vector3(401,0.03,-380.41)
	col_obj8.options['radius'] = 2
	col_obj8.options['color'] = Color(1,1,0,1)
	col_obj8.collision_layer = layers['sphere_rigid'] 
	col_obj8.collision_mask = layers['character'] | layers["floor"] | layers["highway"]  | layers["building"]  | layers["common"] | 	layers["water"]
	add_child(col_obj8)	

	
	var cam = Camera.new()
	cam.options = {'location': default_camera_player_location + default_camera_player_offset,}		
	add_child(cam, true)
	
	utils.add_inputs(utils.user_controls['camera_controls'])
	utils.add_inputs(utils.user_controls['game_controls'])
	
	#var light = Light.new()
	#light.energy = 10
	#add_child(light, true)
	
	for node in get_children():
		#print("node: ",node,node.name)
		if 'players' in node.name:
			for n in node.get_children():	
				if 'CharacterBody3D' in n.name:
					#print("names: ",n.name,n.options['name'],n )
					players[n.options['name']] = n
					
		if 'CharacterBody3D' in node.name:
			#print("names: ",node.name,node.options['name'] ,node)
			players[node.options['name']] = node
		
	#var map = main_map.new()
	#map.player_inst = main_player
	#add_child(map)1
	
	
	#var syncconnection = SyncConnection.new()
	#add_child(syncconnection)
	#var child_data = $main
	#for i in child_data.get_children():
		#print("child_data", i.name)
		
	#var player_data = $players
	#for p in player_data.get_children():
		#print("p's name",p.options['name'])
		#idx += 1
		#print("[KEY_0 + idx]",[KEY_0 + idx])
		#utils.user_controls['camera_controls'][p.options['name']] = [KEY_0 + idx]
		#
	#print("player_data",player_data.get_children())
	#
	#var p_data = get_node('players')
	#print("p_data",p_data.get_children())
	#
	
	
func _process(_delta):
	for cam in utils.user_controls['camera_controls']:
		if Input.is_action_just_pressed(cam):
			if players.has(cam):
				main_player = players[cam]
				for player in players:
					players[player].options['selected'] = false
				main_player.options['selected'] = true
				assign_camera_to_main_player = true
			else:
				main_player = null
	
	if Input.is_action_just_pressed('toggle_camera'):
		assign_camera_to_main_player = not assign_camera_to_main_player
	
	var camera = get_node('Camera3D')
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		camera.rotate_y(deg_to_rad(10))
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		camera.rotate_y(deg_to_rad(-10))
			
	if assign_camera_to_main_player == false:
		camera.global_position = default_camera_player_location + default_camera_player_offset
	else:
		if main_player:
			var forward_dir = main_player.transform.basis.z 
			var camera_offset = Vector3(0, main_player.options["height"] + 8, 20)  
			#var total_rotation_matrix = main_player.transform.basis			
#			-transform.basis.z always gives front direction  (important concept)
#			+trasform.basis.z always gives backward direction that's why we used for keeping the camera backward:
			if Input.is_action_just_pressed("kick") :
				rigid_body_script.kick_sphere_rigid(main_player.collider, -forward_dir)
			
			camera.global_position  = main_player.global_position + (forward_dir * camera_offset.z) + Vector3(0, camera_offset.y, 0)
			camera.look_at(main_player.global_position)
