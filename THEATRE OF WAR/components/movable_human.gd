extends CharacterBody3D
class_name Moveable

#changing movable
var StaticHuman = load("res://components/static_human.gd")
var utils = load("res://components/utils.gd")
var rigid_body_script = load("res://components/rigid_body_functions.gd")
var AIController = load("res://components/ai_controller.gd")

var collider
var layer_to_export

var options = {}

var aicontroller
var player_mode

@onready var static_human = StaticHuman.new()
var reset_teleport
var layers = utils.Getlayers()
var raycastsensor_road = {} 

var ray_sensor
var left_major = false
var right_major = false
var dist_list=[]
var prev_position = null

var curr_pos = null
var total_distance = 0
var left_count = 0
var right_count = 0
@export var person_name = "xyz"

func _ready():
	options['name'] = utils.get_value(options, 'name', person_name)
	
	static_human.options = {
							'name': options['name'],
							'want_collision_on_hands' : utils.get_value(options, 'want_collision_on_hands', true),
							'height' : utils.get_value(options, 'height', 8),
							'width' : utils.get_value(options, 'width', 1.5),
							#'location': utils.get_value(options, 'location', Vector3.ZERO),
							'location': Vector3.ZERO,
							
							}
	
	add_child(static_human, true)
	
	collision_layer = utils.get_value(options, 'collision_layer', layers["character"]) #options['collision_layer']  
	var _mask=  layers['sphere_rigid'] |  layers["floor"] | layers["highway"]  | layers["building"]  | layers["common"] | 	layers["water"]   #2 | 8 | 16 | 32 | 64 | 128
	collision_mask = utils.get_value(options, 'collision_mask', _mask)
	

	player_mode = utils.get_value(options, 'player_mode', 1)
	
	aicontroller = AIController.new()
	
	if player_mode == 0:
		aicontroller.set_heuristic('human')
	else:
		aicontroller.set_heuristic('model')
	add_child(aicontroller)
	aicontroller.init(self)
	aicontroller.reset()
		
	ray_sensor =RayCastSensor3D.new()
	ray_sensor.n_rays_width = 10 #2
	ray_sensor.n_rays_height = 1 #2
	ray_sensor.ray_length = 15
	ray_sensor.cone_width = 70
	ray_sensor.cone_height = 50
	ray_sensor.collision_mask =layers["floor"] | layers["highway"]  | layers["building"]  | layers["common"] | 	layers["water"] | layers['sphere_rigid'] #layers['grass'] | layers['xroads_layer']  
	#print("ray_sensor.collision_mask ",ray_sensor.collision_mask )
	ray_sensor._create_debug_lines(ray_sensor.rays)
	add_child(ray_sensor)
	
	var no_of_rays = (ray_sensor.n_rays_width) * (ray_sensor.n_rays_height)
	for i in range(no_of_rays):
		dist_list.append(0) 
	#dist_list.append(0) 
	for j in range(no_of_rays):
		raycastsensor_road[j] = 0
	
	
	#assert(options.has('player_controls'), 'EXCEPTION: player controls defining is compulsary')
	#utils.add_inputs(options['player_controls'])
	utils.add_inputs(utils.get_value(options, 'player_controls', utils.user_controls['player_controls']))
	
	global_position = utils.get_value(options, 'location', Vector3(0,0,0))
	reset_teleport = global_position + Vector3(0,0,randi_range(10,100))

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("reset") :
			aicontroller.reset()
			
			
	ray_sensor.global_position = global_position + Vector3(0, utils.get_value(options,'height',8) + 0.1, 0)
	var selected = utils.get_value(options, 'selected', false)
	#if selected:
	var jump_velocity = utils.get_value(options, 'jump_velocity', 4.5)
	var speed = utils.get_value(options, 'speed', 5.0)
	
	var observation = ray_sensor.get_observation()
	#print('total observation',observation)
	
	var number_of_rays = observation.size()
	#print("observation size in movebale",number_of_rays)
	var half = number_of_rays/ 2
	#print("half",half)
	
	left_count = 0
	right_count = 0
	
	#
	#
	for obs in observation:
		#print("obs",obs)
		#print("Ray Index:", obs["ray_index"], "collision_layer:", obs["collision_layer"])
		#print("obs size",number_of_rays)
		#print("obs of collision layer",obs["collision_layer"])
		if obs["collision_layer"] == layers['highway']:
			raycastsensor_road[obs["ray_index"]] = 1.0
			dist_list[obs["ray_index"]] = obs['distance']
			
			if (obs["ray_index"] % 10) < half : 
				right_count += 1
			else :
				left_count += 1
		else :
			raycastsensor_road[obs["ray_index"]] = 0.0
			dist_list[obs["ray_index"]] = 0
	
	#print("dist_list before",dist_list)
	
	if left_count > half/2:
		left_major = true
	else :
		left_major = false
	if right_count > half / 2:
		right_major = true	
	else :
		right_major = false
	#print("left count",left_count, " ", "right count",right_count)
	
	
	#print("left_major:",left_major, " ", "right major :",right_major)
	#print("raycastsensor_road results:",raycastsensor_road)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	var input_dir = Vector2.ZERO
	var local_rotation = 0.0
	var jump = false
	var local_rotation_left
	var local_rotation_right

	
	if player_mode == 0 and selected:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		if Input.is_action_just_pressed("turn_left") :
			local_rotation = deg_to_rad(30)
		if Input.is_action_just_pressed("turn_right") :
			local_rotation = -deg_to_rad(30)
		

		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			jump = true
	else:
		
		
		input_dir.x = utils.get_value(options, 'ai_move_x', 0.0) #ai_controller.move_x
		input_dir.y = utils.get_value(options, 'ai_move_z', 0.0) #ai_controller.move_z
		if utils.get_value(options, 'ai_jump', false) and is_on_floor():
			jump = true
		
		local_rotation_left = utils.get_value(options, 'ai_turn_left', false)
		local_rotation_right = utils.get_value(options, 'ai_turn_right', false)
		
		if local_rotation_left:
			local_rotation = -deg_to_rad(2)

		elif local_rotation_right:
			local_rotation = deg_to_rad(2)
		else:
			local_rotation = 0
			
			
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	if jump:
		velocity.y = jump_velocity
	
	move_and_slide()
	rotate_y(local_rotation)
	
	var num_collisions = get_slide_collision_count()
	if num_collisions == 0:
		collider = null
		layer_to_export = -1
	else:
		for i in range(num_collisions):
			var collision = get_slide_collision(i)
			var _collider = collision.get_collider()

			if _collider.collision_layer == 2 or _collider.collision_layer == 4 or _collider.collision_layer == 8 or _collider.collision_layer == 16 or _collider.collision_layer == 32:
				layer_to_export = _collider.collision_layer
				collider = _collider
				#print("collided with", _collider.collision_layer)
			elif _collider.collision_layer == 64 or _collider.collision_layer == 128 or _collider.collision_layer == 256 :
				layer_to_export = _collider.collision_layer
				collider = _collider
				#print("collider",collider)
				#print("collided with", _collider.collision_layer)
				
			
			else:
				collider = null
				layer_to_export = -1
				#print("collided with", layer_to_export)
