extends StaticBody3D
var utils = load("res://components/utils.gd")
var options = {}


func _ready() -> void:
	var location = utils.get_value(options, "location", Vector3.ZERO)
	var size = utils.get_value(options, "size", Vector3(10, 0.2, 5)) 
	var color = utils.get_value(options, "color", Color(1, 1, 1, 1))

	
	var mesh_instance = MeshInstance3D.new()
	var elliptical_mesh = create_elliptical_mesh(size.x, size.z, 32)
   
	
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	
	elliptical_mesh.surface_set_material(0, material) 
	mesh_instance.mesh = elliptical_mesh  
	mesh_instance.global_position = location
	add_child(mesh_instance)

	
	#var material = StandardMaterial3D.new()
	#material.albedo_color = color
	#mesh_instance.mesh.surface_set_material(0, material)

	
	var collision_shape = CollisionShape3D.new()
	var shape = create_elliptical_collision(size.x, size.z, 32)
	collision_shape.shape = shape
	collision_shape.global_position = location
	add_child(collision_shape)


func create_elliptical_mesh(a: float, b: float, segments: int) -> ArrayMesh:
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	var inner_factor = 0.5  # Inner radius factor to make a ring

	for i in range(segments):
		var angle1 = i * 2 * PI / segments
		var angle2 = (i + 1) * 2 * PI / segments

		var p1_outer = Vector3(a * cos(angle1), 0, b * sin(angle1))
		var p2_outer = Vector3(a * cos(angle2), 0, b * sin(angle2))
		var p1_inner = Vector3(a * inner_factor * cos(angle1), 0, b * inner_factor * sin(angle1))
		var p2_inner = Vector3(a * inner_factor * cos(angle2), 0, b * inner_factor * sin(angle2))

		st.add_vertex(p1_outer)
		st.add_vertex(p2_outer)
		st.add_vertex(p1_inner)

		st.add_vertex(p2_outer)
		st.add_vertex(p2_inner)
		st.add_vertex(p1_inner)

	var mesh = ArrayMesh.new()
	st.commit(mesh)
	mesh.surface_set_material(0, StandardMaterial3D.new())
	return mesh


func create_elliptical_collision(a: float, b: float, segments: int) -> ConcavePolygonShape3D:
	var points = PackedVector3Array()

	for i in range(segments):
		var angle = i * 2 * PI / segments
		var x = a * cos(angle)
		var z = b * sin(angle)
		points.append(Vector3(x, 0, z))

	var shape = ConcavePolygonShape3D.new()
	shape.set_faces(points)
	return shape
