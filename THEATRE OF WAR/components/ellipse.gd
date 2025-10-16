extends Node3D


var road_width = 0.1
#var static_body = StaticBody3D.new()
var inner_points = PackedVector3Array()
var outer_points = PackedVector3Array()

func _ready() -> void:
	var outer_curve = create_outer_ellipse()
	var inner_curve = create_inner_ellipse()
	var start_curve = create_start_line()
	var end_curve = create_end_line()
	
	#create_start_line()
	#var path1 = Path3D.new()
	#path1.curve = inner_curve
	##path1.curve = outer_curve
	#add_child(path1)
	
	#var path2 = Path3D.new()
	#path2.curve = outer_curve
	##path1.curve = outer_curve
	#add_child(path2)

	
	var line1 = MeshInstance3D.new()
	var line2 = MeshInstance3D.new()
	
	
	
	line1.mesh = create_curve_mesh(inner_curve)
	line2.mesh = create_curve_mesh(outer_curve)
	
	#var material1 = StandardMaterial3D.new()
	#material1.albedo_color = Color(1,0,0)
	#line1.set_surface_override_material(0,material1)
	
	#var material2 = StandardMaterial3D.new()
	#material2.albedo_color = Color(0,0,1)
	#line2.set_surface_override_material(0,material2)
	
	get_parent().add_child(line1)
	get_parent().add_child(line2)

	var collision1 = create_curve_collision_inner(inner_curve)
	var collision2 = create_curve_collision_outer(outer_curve)
	get_parent().add_child(collision1)
	get_parent().add_child(collision2)
	
	
	var road = MeshInstance3D.new()
	road.mesh = create_road_mesh(inner_points, outer_points)
	add_child(road)

	# Create road collision
	var collision = create_road_collision(inner_points, outer_points)
	add_child(collision)
	#add_child(static_body)
func create_curve_collision_inner(curve: Curve3D):
#	this will be returning a static body 
	
	
	var collision_shape = CollisionShape3D.new()
	var shape = ConcavePolygonShape3D.new()
	collision_shape.shape = shape
	
	
	#print("baked length of the curve",curve.get_baked_length())
	for i in range(1000):  
		var t = i / 999.0
		#print("t values",t)
		#print("total offset",t * curve.get_baked_length())
		inner_points.append(curve.sample_baked(t * curve.get_baked_length()))
		
	#shape.set_faces(points) 
	#print("all the points of the inner curve", inner_points)
	
	add_child(collision_shape)

	#return static_body
func create_curve_collision_outer(curve: Curve3D):
#	this will be returning a static body 
	
	
	var collision_shape = CollisionShape3D.new()
	var shape = ConcavePolygonShape3D.new()
	collision_shape.shape = shape
	
	
	#print("baked length of the curve",curve.get_baked_length())
	for i in range(1000):  
		var t = i / 999.0
		#print("t values",t)
		#print("total offset",t * curve.get_baked_length())
		outer_points.append(curve.sample_baked(t * curve.get_baked_length()))
		
	#shape.set_faces(points) 
	#print("all the points of outer curve", outer_points)
	
	add_child(collision_shape)

	#return static_body
	



func create_curve_mesh(curve: Curve3D) -> Mesh:
	var line_mesh = ImmediateMesh.new()
	line_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	
	#var outer_points =PackedVector3Array()
	for i in range(1000):  
		var t = i / 999.0
		line_mesh.surface_add_vertex(curve.sample_baked(t * curve.get_baked_length()))
		#outer_points.append(curve.sample_baked(t*curve.get_baked_length()))
		
	#print("outer prints for the ellipse", outer_points)
	line_mesh.surface_end()
	return line_mesh
func create_outer_ellipse():
	var outer_curve = Curve3D.new()

	outer_curve.add_point(Vector3(25, road_width, 20), Vector3(0, road_width, 20), Vector3(80, road_width, 0))  # Right mirrored
	outer_curve.add_point(Vector3(25, road_width, -20), Vector3(80, road_width, 0), Vector3(0, road_width, -20))  # Left mirrored (connecting back)
 	
	outer_curve.add_point(Vector3(25, road_width, -20)) 
	outer_curve.add_point(Vector3(-25, road_width, -20))
	
	outer_curve.add_point(Vector3(-25, road_width, -20), Vector3(0, road_width, -20), Vector3(-80, road_width, 0))  # Right mirrored
	outer_curve.add_point(Vector3(-25, road_width, 20), Vector3(-80, road_width, 0), Vector3(0, road_width, 20))  # Left mirrored (connecting back)
	
	outer_curve.add_point(Vector3(-25, road_width, 20)) 
	outer_curve.add_point(Vector3(25, road_width, 20)) 
	
	return outer_curve
	
	
	 
func create_inner_ellipse():
	#inner ellipse
	var inner_curve = Curve3D.new()
	inner_curve.add_point(Vector3(25, road_width, 10), Vector3(0, road_width, 10), Vector3(50, road_width, 0))  # Right mirrored
	inner_curve.add_point(Vector3(25, road_width, -10), Vector3(50, road_width, 0), Vector3(0, road_width, -10))  # Left mirrored (connecting back)
 	
	inner_curve.add_point(Vector3(25, road_width, -10)) 
	inner_curve.add_point(Vector3(-25, road_width, -10))
	
	inner_curve.add_point(Vector3(-25, road_width, -10), Vector3(0, road_width, -10), Vector3(-50, road_width, 0))  # Right mirrored
	inner_curve.add_point(Vector3(-25, road_width, 10), Vector3(-50, road_width, 0), Vector3(0, road_width, 10))  # Left mirrored (connecting back)
	
	inner_curve.add_point(Vector3(-25, road_width, 10)) 
	inner_curve.add_point(Vector3(25, road_width, 10)) 
	
	return inner_curve
	


	
func create_start_line():
	var start_curve = Curve3D.new()
	
	start_curve.add_point(Vector3(25, 0.2, 20))  # Outer ellipse start point
	start_curve.add_point(Vector3(25, 0.2, 10))  # Inner ellipse start point
	
	start_curve.add_point(Vector3(22, 0.2, 10))
	start_curve.add_point(Vector3(22, 0.2, 20))
	start_curve.add_point(Vector3(25, 0.2, 20))  
	
	
	
	var start_path = Path3D.new()
	start_path.curve = start_curve
	add_child(start_path)

	var start_line = MeshInstance3D.new()
	start_line.mesh = create_curve_mesh(start_curve)
	

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(255, 0, 0)  # White color for start line
	
	
	start_line.set_surface_override_material(0, material)

	add_child(start_line)
	var start_mesh = MeshInstance3D.new()
	start_mesh.mesh = create_red_mesh(start_curve)
	start_mesh.set_surface_override_material(0, material)
	add_child(start_mesh)
	return start_curve
	
func create_red_mesh(curve: Curve3D) -> Mesh:
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	var red_color = Color(1, 0, 0)  # Red color

	var points = [
		Vector3(25, 0.2, 20),  # Top Right
		Vector3(25, 0.2, 10),  # Bottom Right
		Vector3(22, 0.2, 10),  # Bottom Left
		Vector3(22, 0.2, 20)   # Top Left
	]

	# Create two triangles forming a quad
	surface_tool.set_color(red_color)
	surface_tool.add_vertex(points[0])
	surface_tool.add_vertex(points[1])
	surface_tool.add_vertex(points[2])

	surface_tool.add_vertex(points[0])
	#surface_tool.add_vertex(points[2])
	surface_tool.add_vertex(points[3])

	surface_tool.index()
	surface_tool.commit(mesh)
	
	var collision_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var shape = ConvexPolygonShape3D.new()
	shape.points = PackedVector3Array(points)

	collision_shape.shape = shape
	collision_body.add_child(collision_shape)
	add_child(collision_body)

	

	return mesh

func create_end_line():
	var end_curve = Curve3D.new()
	
	end_curve.add_point(Vector3(-25, 0.2, -20)) 
	end_curve.add_point(Vector3(-25, 0.2, -10)) 
	
	end_curve.add_point(Vector3(-28, 0.2, -10))
	end_curve.add_point(Vector3(-28, 0.2, -20))
	end_curve.add_point(Vector3(-25, 0.2, -20))  
	
	var end_path = Path3D.new()
	end_path.curve = end_curve
	add_child(end_path)

	var end_line = MeshInstance3D.new()
	end_line.mesh = create_curve_mesh(end_curve)

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0, 0, 255) #blue color
	
	end_line.set_surface_override_material(0, material)
	add_child(end_line)

	var end_mesh = MeshInstance3D.new()
	end_mesh.mesh = create_blue_mesh(end_curve)
	end_mesh.set_surface_override_material(0, material)
	add_child(end_mesh)

	return end_curve
	
func create_blue_mesh(curve: Curve3D) -> Mesh:
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	var blue_color = Color(0, 0, 1)  # Blue color

	var points = [
		Vector3(-25, 0.2, -20),  # Top Right
		Vector3(-25, 0.2, -10),  # Bottom Right
		Vector3(-28, 0.2, -10),  # Bottom Left
		Vector3(-28, 0.2, -20)   # Top Left
	]

	# Create two triangles forming a quad
	surface_tool.set_color(blue_color)
	surface_tool.add_vertex(points[0])
	surface_tool.add_vertex(points[1])
	surface_tool.add_vertex(points[2])

	surface_tool.add_vertex(points[0])
	#surface_tool.add_vertex(points[2])
	surface_tool.add_vertex(points[3])

	surface_tool.index()
	surface_tool.commit(mesh)
	
	# Add collision
	var collision_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var shape = ConvexPolygonShape3D.new()
	shape.points = PackedVector3Array(points)

	collision_shape.shape = shape
	collision_body.add_child(collision_shape)
	add_child(collision_body)

	return mesh


#func create_road_mesh(inner: PackedVector3Array, outer: PackedVector3Array) -> Mesh:
	#var mesh = ArrayMesh.new()
	#var surface_tool = SurfaceTool.new()
	#surface_tool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
#
	#for i in range(inner.size()):
		#surface_tool.add_vertex(outer[i])
		#surface_tool.add_vertex(inner[i])
#
	#surface_tool.index()
	#surface_tool.commit(mesh)
	#
	#var road_material = StandardMaterial3D.new()
	#road_material.albedo_color = Color(0.2,0.2,0.2)
	#mesh.set_surface_override_material(0,road_material)
	#return mesh
func create_road_mesh(inner, outer):
	var mesh = ArrayMesh.new()
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLE_STRIP)
	
	var red_color = Color(0, 0, 0)
	var start_line_color = Color(1, 0, 0)  # Red color for start line
	
	var start_index = Vector3(25,road_width,20)
	var end_index = Vector3(25,road_width,10) # Number of points used for the start line
	
	
	
	for i in range(inner.size()):
		surface_tool.set_color(red_color) 
		surface_tool.add_vertex(outer[i])

		 
		surface_tool.add_vertex(inner[i])

	surface_tool.index()
	surface_tool.generate_normals()  # Ensures lighting works properly
	surface_tool.commit(mesh)

	var road_material = StandardMaterial3D.new()
	road_material.vertex_color_use_as_albedo = true  # Use per-vertex color instead of albedo
	road_material.unshaded = true 
	mesh.surface_set_material(0, road_material)  

	return mesh


func create_road_collision(inner: PackedVector3Array, outer: PackedVector3Array):
	var collision_body = StaticBody3D.new()
	var collision_shape = CollisionShape3D.new()
	var shape = ConcavePolygonShape3D.new()

	var faces = PackedVector3Array()
	for i in range(inner.size() - 1):
		faces.append(outer[i])
		faces.append(inner[i])
		faces.append(inner[i + 1])

		
		faces.append(outer[i + 1])

	shape.set_faces(faces)
	collision_shape.shape = shape
	collision_body.add_child(collision_shape)
	return collision_body
