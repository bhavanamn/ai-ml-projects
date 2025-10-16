@tool
extends ISensor3D
class_name RayCastSensor3D
@export_flags_3d_physics var collision_mask = 1:
	get:
		return collision_mask
	set(value):
		collision_mask = value
		_update()
@export_flags_3d_physics var boolean_class_mask = 1:
	get:
		return boolean_class_mask
	set(value):
		boolean_class_mask = value
		_update()

@export var n_rays_width := 6:
	get:
		return n_rays_width
	set(value):
		n_rays_width = value
		_update()

@export var n_rays_height := 6:
	get:
		return n_rays_height
	set(value):
		n_rays_height = value
		_update()

@export var ray_length := 1:
	get:
		return ray_length
	set(value):
		ray_length = value
		_update()

@export var cone_width := 60:
	get:
		return cone_width
	set(value):
		cone_width = value
		_update()

@export var cone_height := 60:
	get:
		return cone_height
	set(value):
		cone_height = value
		_update()

@export var collide_with_areas := false:
	get:
		return collide_with_areas
	set(value):
		collide_with_areas = value
		_update()

@export var collide_with_bodies := true:
	get:
		return collide_with_bodies
	set(value):
		collide_with_bodies = value
		_update()

@export var class_sensor := false

var rays := []
var geo = null


func _update():
	if Engine.is_editor_hint():
		if is_node_ready():
			_spawn_nodes()


func _ready() -> void:
	if Engine.is_editor_hint():
		if get_child_count() == 0:
			_spawn_nodes()
	else:
		_spawn_nodes()

#
#func _spawn_nodes():
	#print("spawning nodes")
	#for ray in get_children():
		#ray.queue_free()
	#if geo:
		#geo.clear()
	##$Lines.remove_points()
	#rays = []
#
	#var horizontal_step = cone_width / (n_rays_width)
	#var vertical_step = cone_height / (n_rays_height)
#
	#var horizontal_start = horizontal_step / 2 - cone_width / 2
	#var vertical_start = vertical_step / 2 - cone_height / 2
#
	#var points = []
#
	#for i in n_rays_width:
		#for j in n_rays_height:
			#var angle_w = horizontal_start + i * horizontal_step
			#var angle_h = vertical_start + j * vertical_step
			##angle_h = 0.0
			#var ray = RayCast3D.new()
			#var cast_to = to_spherical_coords(ray_length, angle_w, angle_h)
			#ray.set_target_position(cast_to)
#
			#points.append(cast_to)
#
			#ray.set_name("node_" + str(i) + " " + str(j))
			#ray.enabled = true
			#ray.collide_with_bodies = collide_with_bodies
			#ray.collide_with_areas = collide_with_areas
			#ray.collision_mask = collision_mask
			#add_child(ray)
			#ray.set_owner(get_tree().edited_scene_root)
			#rays.append(ray)
			#ray.force_raycast_update()
var mesh_instance: MeshInstance3D = null  # Store the reference

func _spawn_nodes():
	print("spawning nodes")

	# Remove existing rays
	for ray in get_children():
		ray.queue_free()

	# Remove old MeshInstance3D (contains geo)
	if mesh_instance:
		mesh_instance.queue_free()
		mesh_instance = null
		geo = null  # Reset geo as well

	# Create new ImmediateMesh and attach it to MeshInstance3D
	geo = ImmediateMesh.new()
	mesh_instance = MeshInstance3D.new()
	mesh_instance.mesh = geo
	add_child(mesh_instance)

	rays = []

	var horizontal_step = cone_width / n_rays_width
	var vertical_step = cone_height / n_rays_height

	var horizontal_start = horizontal_step / 2 - cone_width / 2
	var vertical_start = vertical_step / 2 - cone_height / 2

	var points = []
	var ray_index = 0
	
	for j in n_rays_height:
		for i in n_rays_width:
			var angle_w = horizontal_start + i * horizontal_step
			var angle_h = vertical_start + j * vertical_step - 54
			var ray = RayCast3D.new()
			var cast_to = to_spherical_coords(ray_length, angle_w, angle_h)
			ray.set_target_position(cast_to)

			points.append(cast_to)

			ray.set_name("node_" + str(i) + " " + str(j))
			ray.enabled = true
			ray.collide_with_bodies = collide_with_bodies
			ray.collide_with_areas = collide_with_areas
			ray.collision_mask = collision_mask
			add_child(ray)
			ray.set_owner(get_tree().edited_scene_root)
			rays.append(ray)
			ray.force_raycast_update()
			
			
			var label = Label3D.new()
			label.text = str(ray_index)
			label.position = cast_to * 0.2 # Place label halfway along the ray
			#label.billboard = Label3D.BILLBOARD_ENABLED # Make it face the camera
			ray.add_child(label)
			label.set_owner(get_tree().edited_scene_root)

			ray_index += 1 # Increment the ray index
	# Now create debug visualization
	_create_debug_lines(points)




	# Now create debug visualization
	_create_debug_lines(points)

#    if Engine.editor_hint:
#        _create_debug_lines(points)


func _create_debug_lines(points):
	#if not geo:
		##geo = ImmediateMesh.new()
		##add_child(geo)
		#var mesh_instance = MeshInstance3D.new()
		#geo = ImmediateMesh.new()
		#mesh_instance.mesh = geo
		#add_child(mesh_instance)
#
#
	#geo.clear()
	#geo.begin(Mesh.PRIMITIVE_LINES)
	#for point in points:
		#geo.set_color(Color.AQUA)
		#geo.add_vertex(Vector3.ZERO)
		#geo.add_vertex(point)
	#geo.end()
	if points.size() == 0:
		return

	var mesh_instance = MeshInstance3D.new()
	geo = ImmediateMesh.new()
	mesh_instance.mesh = geo
	add_child(mesh_instance)

	# Draw the lines
	geo.surface_begin(Mesh.PRIMITIVE_LINES)
	for point in points:
		geo.surface_set_color(Color.AQUA)
		geo.surface_add_vertex(Vector3.ZERO)
		geo.surface_add_vertex(point)
	geo.surface_end()


func display():
	if geo:
		geo.display()


func to_spherical_coords(r, inc, azimuth) -> Vector3:
	var forward = Vector3.FORWARD * r
	var rotated = forward.rotated(Vector3.UP, deg_to_rad(inc))
	rotated = rotated.rotated(Vector3.RIGHT, deg_to_rad(azimuth))
	return rotated
	#return Vector3(
		#r * sin(deg_to_rad(inc)) * cos(deg_to_rad(azimuth)),
		#r * sin(deg_to_rad(azimuth)),
		#r * cos(deg_to_rad(inc)) * cos(deg_to_rad(azimuth))
	#)


func get_observation() -> Array:
	return self.calculate_raycasts()

#
#func calculate_raycasts() -> Array:
	#var result = []
	#for ray in rays:
		#ray.set_enabled(true)
		#ray.force_raycast_update()
		#var distance = _get_raycast_distance(ray)
#
		#result.append(distance)
		#if class_sensor:
			#var hit_class: float = 0
			#if ray.get_collider():
				#var hit_collision_layer = ray.get_collider().collision_layer
				#hit_collision_layer = hit_collision_layer & collision_mask
				#hit_class = (hit_collision_layer & boolean_class_mask) > 0
			#result.append(float(hit_class))
		#ray.set_enabled(false)
	#return result
#func calculate_raycasts() -> Array:
	#var result = []
	#for i in range(rays.size()):
		#var ray = rays[i]
		#ray.force_raycast_update()
#
		#var distance = ray_length  
		#var collider = null
		#var mask_value = 0 
#
		#if ray.is_colliding():
			#collider = ray.get_collider()
			#distance = (ray.get_collision_point() - ray.global_transform.origin).length()
			#mask_value = collider.collision_layer  
#
		#result.append({
			#"ray_index": i, 
			#"distance": distance, 
			#"collider": collider, 
			#"mask_value": mask_value
		#})
#
	#return result
func calculate_raycasts() -> Array:
	var result = []
	var dummy = []
	for i in range(rays.size()):
		var ray = rays[i]
		ray.force_raycast_update()

		var distance = ray_length  # Default to max length if no collision
		var collider = null
		var collision_layer = 0  # Default layer to 0 (no collision)

		if ray.is_colliding():
			collider = ray.get_collider()
			distance = (ray.get_collision_point() - ray.global_transform.origin).length()
			collision_layer = collider.collision_layer  

			# Debug print to check what's being detected
			#print("Ray", i, "hit:", collider, "Layer:", collision_layer, "Distance:", distance)
		#if class_sensor:
			#var hit_class: float = 0
			#if ray.get_collider():
				#var hit_collision_layer = ray.get_collider().collision_layer
				#hit_collision_layer = hit_collision_layer & collision_mask
				#hit_class = (hit_collision_layer & boolean_class_mask) > 0
			#result.append(float(hit_class))
			result.append({
				"ray_index": i, 
				"distance": distance, 
				"collider": collider, 
				"collision_layer": collision_layer
			})
			#dummy.append({"distance":distance})
			#print("dummy",dummy)
	#print("result",result)
	return result



func _get_raycast_distance(ray: RayCast3D) -> float:
	if !ray.is_colliding():
		return 0.0

	var distance = (global_transform.origin - ray.get_collision_point()).length()
	distance = clamp(distance, 0.0, ray_length)
	return (ray_length - distance) / ray_length
#@tool
#extends ISensor3D
#class_name RayCastSensor3D
#@export_flags_3d_physics var collision_mask = 1:
	#get:
		#return collision_mask
	#set(value):
		#collision_mask = value
		#_update()
#@export_flags_3d_physics var boolean_class_mask = 1:
	#get:
		#return boolean_class_mask
	#set(value):
		#boolean_class_mask = value
		#_update()
#
#@export var n_rays_width := 6.0:
	#get:
		#return n_rays_width
	#set(value):
		#n_rays_width = value
		#_update()
#
#@export var n_rays_height := 6.0:
	#get:
		#return n_rays_height
	#set(value):
		#n_rays_height = value
		#_update()
#
#@export var ray_length := 10.0:
	#get:
		#return ray_length
	#set(value):
		#ray_length = value
		#_update()
#
#@export var cone_width := 60.0:
	#get:
		#return cone_width
	#set(value):
		#cone_width = value
		#_update()
#
#@export var cone_height := 60.0:
	#get:
		#return cone_height
	#set(value):
		#cone_height = value
		#_update()
#
#@export var collide_with_areas := false:
	#get:
		#return collide_with_areas
	#set(value):
		#collide_with_areas = value
		#_update()
#
#@export var collide_with_bodies := true:
	#get:
		#return collide_with_bodies
	#set(value):
		#collide_with_bodies = value
		#_update()
#
#@export var class_sensor := false
#
#var rays := []
#var geo = null
#
#
#func _update():
	#if Engine.is_editor_hint():
		#if is_node_ready():
			#_spawn_nodes()
#
#
#func _ready() -> void:
	#if Engine.is_editor_hint():
		#if get_child_count() == 0:
			#_spawn_nodes()
	#else:
		#_spawn_nodes()
#
#
#func _spawn_nodes():
	#print("spawning nodes")
	#for ray in get_children():
		#ray.queue_free()
	#if geo:
		#geo.clear()
	##$Lines.remove_points()
	#rays = []
#
	#var horizontal_step = cone_width / (n_rays_width)
	#var vertical_step = cone_height / (n_rays_height)
#
	#var horizontal_start = horizontal_step / 2 - cone_width / 2
	#var vertical_start = vertical_step / 2 - cone_height / 2
#
	#var points = []
#
	#for i in n_rays_width:
		#for j in n_rays_height:
			#var angle_w = horizontal_start + i * horizontal_step
			#var angle_h = vertical_start + j * vertical_step
			##angle_h = 0.0
			#var ray = RayCast3D.new()
			#var cast_to = to_spherical_coords(ray_length, angle_w, angle_h)
			#ray.set_target_position(cast_to)
#
			#points.append(cast_to)
#
			#ray.set_name("node_" + str(i) + " " + str(j))
			#ray.enabled = true
			#ray.collide_with_bodies = collide_with_bodies
			#ray.collide_with_areas = collide_with_areas
			#ray.collision_mask = collision_mask
			#add_child(ray)
			#ray.set_owner(get_tree().edited_scene_root)
			#rays.append(ray)
			#ray.force_raycast_update()
#
#
##    if Engine.editor_hint:
##        _create_debug_lines(points)
#
#
#func _create_debug_lines(points):
	#if not geo:
		#geo = ImmediateMesh.new()
		#add_child(geo)
#
	#geo.clear()
	#geo.begin(Mesh.PRIMITIVE_LINES)
	#for point in points:
		#geo.set_color(Color.AQUA)
		#geo.add_vertex(Vector3.ZERO)
		#geo.add_vertex(point)
	#geo.end()
#
#
#func display():
	#if geo:
		#geo.display()
#
#
#func to_spherical_coords(r, inc, azimuth) -> Vector3:
	#return Vector3(
		#r * sin(deg_to_rad(inc)) * cos(deg_to_rad(azimuth)),
		#r * sin(deg_to_rad(azimuth)),
		#r * cos(deg_to_rad(inc)) * cos(deg_to_rad(azimuth))
	#)
#
#
#func get_observation() -> Array:
	#return self.calculate_raycasts()
#
#
#func calculate_raycasts() -> Array:
	#var result = []
	#for ray in rays:
		#ray.set_enabled(true)
		#ray.force_raycast_update()
		#var distance = _get_raycast_distance(ray)
#
		#result.append(distance)
		#if class_sensor:
			#var hit_class: float = 0
			#if ray.get_collider():
				#var hit_collision_layer = ray.get_collider().collision_layer
				#hit_collision_layer = hit_collision_layer & collision_mask
				#hit_class = (hit_collision_layer & boolean_class_mask) > 0
			#result.append(float(hit_class))
		#ray.set_enabled(false)
	#return result
#
#
#func _get_raycast_distance(ray: RayCast3D) -> float:
	#if !ray.is_colliding():
		#return 0.0
#
	#var distance = (global_transform.origin - ray.get_collision_point()).length()
	#distance = clamp(distance, 0.0, ray_length)
	#return (ray_length - distance) / ray_length
