#const CONSTANTS = preload("res://src/common/constants.gd")
#
#
#static func get_polygon_height(feature, layer):
	#var heights = 0
#
	#var tag = feature.tags(layer)
#
	#if tag.has(CONSTANTS.HEIGHT_IN_LEVELS):
		#heights = tag[CONSTANTS.HEIGHT_IN_LEVELS] * 2.75
		#print([CONSTANTS.HEIGHT_IN_LEVELS])
	#elif tag.has(CONSTANTS.HEIGHT_IN_METERS):
		#heights = tag[CONSTANTS.HEIGHT_IN_METERS]
		#print([CONSTANTS.HEIGHT_IN_METERS])
	#else:
		#print(tag)
		#heights = 2.75
	#return heights
const POLYGON_VECTOR_CALCULATOR = preload("res://src/polygons/calculate_polygon_vectors.gd")
const CONSTANTS = preload("res://src/common/constants.gd")

static func get_polygon_height(feature, layer):
	var heights = 2.75
# Initialize an empty array to store names of buildings
	
	var tag = feature.tags(layer)

	if tag.has(CONSTANTS.HEIGHT_IN_LEVELS):
		heights = tag[CONSTANTS.HEIGHT_IN_LEVELS] * 2.75
		#print([CONSTANTS.HEIGHT_IN_LEVELS])
	elif tag.has(CONSTANTS.HEIGHT_IN_METERS):
		heights = tag[CONSTANTS.HEIGHT_IN_METERS]
	#var tag = feature.tags(layer)
	#if tag.has("name"):
		#var building_name = tag["name"]
		##names.append(building_name)  # Append the name of the building to the list
		#print("Building name:", building_name)

	# Now, check if 'name' exists and append it to the 'names' array
	  # Optionally print the name for debugging
	
	# Return both heights and the names array
	return heights
	#
#static func get_polygon_name(feature, layer, tile_node_current):
	#if feature.tags(layer).has("name"):
		#var building_name = feature.tags(layer)["name"]
		#print("Building name:", building_name)
		#
		## Create a 3D label
		#var label = Label3D.new()
		#label.text = building_name
		#label.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED  # Make the label face the camera
		#
		## Position the label at the center of the polygon
		#if feature.has("geometry"):
			#var geometry_center = POLYGON_VECTOR_CALCULATOR.get_geometry_center(feature.geometry())
			#label.global_transform.origin = geometry_center
		#else:
			#print("Feature does not have geometry.")
		#
		## Add the label to the tile node
		#tile_node_current.add_child(label)
		#print("Label added to the parent node successfully.")
	#else:
		#print("No 'name' tag found for this feature.")
