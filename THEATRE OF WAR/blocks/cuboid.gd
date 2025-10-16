extends StaticBody3D
var utils = load("res://components/utils.gd")
var options = {}


func _ready() -> void:
	var location = utils.get_value(options, 'location', Vector3.ZERO)
	var size = utils.get_value(options, 'size', Vector3.ONE)
	var color = utils.get_value(options, 'color', Color(1,1,1,1))
	
	var collision_shape = CollisionShape3D.new()
	get_parent().add_child(collision_shape, true)
	
	var shape = BoxShape3D.new()
	shape.size = size
	collision_shape.shape = shape
	collision_shape.global_position = location
	
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = size
	mesh_instance.mesh = box_mesh
	mesh_instance.position = location
	add_child(mesh_instance)

	var material = StandardMaterial3D.new()
	material.albedo_color = color
	box_mesh.material = material
