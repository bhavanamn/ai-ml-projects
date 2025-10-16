extends RigidBody3D

var utils = load("res://components/utils.gd")
var options = {}

func _ready() -> void:
	var location = utils.get_value(options, 'location', Vector3.ZERO)
	var radius = utils.get_value(options, 'radius', 1.0)
	var color = utils.get_value(options, 'color', Color(1, 1, 1, 1))

	global_position = location

	var collision_shape = CollisionShape3D.new()
	add_child(collision_shape, true)

	var shape = SphereShape3D.new()
	shape.radius = radius
	collision_shape.shape = shape

	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = radius
	sphere_mesh.height = radius * 2  
	mesh_instance.mesh = sphere_mesh
	mesh_instance.position = Vector3.ZERO  
	add_child(mesh_instance)

	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	sphere_mesh.material = material

	
	mass = 1.0 
	gravity_scale = 1.0  
