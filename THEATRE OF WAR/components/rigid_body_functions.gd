extends RigidBody3D
static var kick_force_magnitude = 30

#var human_script= load("res://components/movable_human.gd")
#var human = human_script.new()
##var collider_get = human.collider
#static var c_linear_velocity = Vector3.ZERO
#static var speed
#static func reset():
	#var position = Vector3.ZERO
	#c_linear_velocity = Vector3(randf_range(-1.0,1.0),0.0,randf_range(-1.0,1.0))
	#_normalize_velocity()
#
#static func _normalize_velocity():
	#if c_linear_velocity.length()>0:
		#c_linear_velocity = c_linear_velocity.normalized()
		#c_linear_velocity *= speed
	#else:
		#c_linear_velocity = Vector3.ZERO
	
static func add_light_to_sphere(collider_get):
	var light = OmniLight3D.new()
	collider_get.add_child(light)
	light.light_energy = 3
	
static func kick_sphere_rigid(collider_get, kick_direction):	
	print("function kick sphere has been called")
	#add_light_to_sphere(collider_get)
	#var kick_direction = (sphere.global_position ).normalized()
	if collider_get == null:
		return
	collider_get.apply_impulse(kick_direction * kick_force_magnitude)
	print("applied impulse successfully")
	var spin_axis = Vector3(0,1,0)
	collider_get.apply_torque_impulse(spin_axis*30)
	if kick_force_magnitude > 100:  
		explode_sphere(collider_get)
	
static func explode_sphere(sphere):
	print("Sphere Exploded!")
	sphere.queue_free() 

static func create_movement(collider_get, direction_to_push):
	#var direction_to_push = main_player.transform.basis.z.normalized()
	var force = direction_to_push * kick_force_magnitude * 10
	collider_get.apply_impulse(force)
