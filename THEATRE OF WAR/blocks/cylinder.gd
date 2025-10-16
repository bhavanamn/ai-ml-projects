extends StaticBody3D

var utils = load("res://components/utils.gd")
var options = {}

func _ready() -> void:
	var location = utils.get_value(options, 'location', Vector3.ZERO)
	var height = utils.get_value(options, 'height', 1.0)
	var radius = utils.get_value(options, 'radius', 1.0)
	var angle_x = utils.get_value(options, 'angle_x', 0.0)
	var angle_y = utils.get_value(options, 'angle_y', 0.0)
	var angle_z = utils.get_value(options, 'angle_z', 0.0)
	var color = utils.get_value(options, 'color', Color(1,1,1,1))
	
	var collision_shape = CollisionShape3D.new()
	get_parent().add_child(collision_shape, true)
	
	var shape = CylinderShape3D.new()
	shape.height = height
	shape.radius = radius
	
	collision_shape.shape = shape
	collision_shape.global_position = location
	collision_shape.rotate_x(angle_x)
	collision_shape.rotate_y(angle_y)
	collision_shape.rotate_z(angle_z)
	
	var mesh_instance = MeshInstance3D.new()
	var cylinder_mesh = CylinderMesh.new()
	cylinder_mesh.height = height
	cylinder_mesh.top_radius = radius
	cylinder_mesh.bottom_radius = radius
	mesh_instance.mesh = cylinder_mesh
	
	mesh_instance.position = location
	mesh_instance.rotate_x(angle_x)
	mesh_instance.rotate_y(angle_y)
	mesh_instance.rotate_z(angle_z)
	add_child(mesh_instance)

	var material = StandardMaterial3D.new()
	material.albedo_color = color
	cylinder_mesh.material = material

	
