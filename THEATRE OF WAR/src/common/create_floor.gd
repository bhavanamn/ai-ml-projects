static func build_floor(caller_node, offset_x, offset_y,build_cl,build_cm):
	var floor_polygon = CSGPolygon3D.new()
	var polygon_vectors = [
		Vector2(0, 0), Vector2(0, 655.25), Vector2(655.25, 655.25), Vector2(655.25, 0)
	]
	floor_polygon.polygon = polygon_vectors
	#floor_polygon.depth = 1.498
	floor_polygon.depth = 0
	floor_polygon.use_collision = true
	floor_polygon.collision_layer = build_cl
	floor_polygon.collision_mask = build_cm
	floor_polygon.rotate(Vector3(1, 0, 0), deg_to_rad(90))
	floor_polygon.translate(Vector3(offset_x, offset_y, 1))
	caller_node.add_child(floor_polygon)
	
