
extends Node3D
# The camera reference will be stored
#var camera : Camera3D
############################
#Set start position here
#const START_X = 58210
#const START_Y = 25805
###########################
const START_X = 46043
const START_Y = 29238

#DO NOT TOUCH!!!
const MVT_READER = preload("res://addons/geo-tile-loader/vector_tile_loader.gd")
const WEBSERVER = preload("res://src/webserver.gd")
const CONSTANTS = preload("res://src/common/constants.gd")
const POLYGON_VECTOR_CALCULATOR = preload("res://src/polygons/calculate_polygon_vectors.gd")
const POLYGON_HEIGHT_CALCULATOR = preload("res://src/polygons/calculate_polygon_heights.gd")
const POLYGON_BUILDER = preload("res://src/polygons/build_polygons.gd")
const PLAIN_BUILDER = preload("res://generate_plain.gd")
const LINESTRING_VECTOR_CALCULATOR = preload(
	"res://src/linestrings/calculate_linestring_vectors.gd"
)
const LINESTRING_BUILDER = preload("res://src/linestrings/build_linestrings.gd")
const POINTS = preload("res://src/points/pois.gd")
const FLOOR_BUILDER = preload("res://src/common/create_floor.gd")

var utils = load("res://components/utils.gd")
var Light = load("res://blocks/directional_light.gd")

var tiles_loaded_x_max = 2
var tiles_loaded_x_min = -2
var tiles_loaded_y_max = 2
var tiles_loaded_y_min = -2

#updated process points
var process_x = null
var process_y = null

var steps_x = 0
var steps_y = 0

var player_inst


var layers = utils.Getlayers()
#var layers = {
	#'floor': 2,
	#'character' : 4,
	#'highway': 8,
	#'building' : 16,    
	#'common' : 32,
	#'natural' : 64,
	#'water' : 128
#}

func _ready():
	
	#camera = get_viewport().get_camera()  # Get the current camera when the scene starts
	for i in range(tiles_loaded_x_min, tiles_loaded_x_max, 1):
		for j in range(tiles_loaded_y_min, tiles_loaded_y_max, 1):
			var tile_node = Node3D.new()
			tile_node.name = str(START_X + i) + str(START_Y + j)
			add_child(tile_node)
			#print(tile_node)
			var webserver = WEBSERVER.new()
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			process_x = START_X + i
			process_y = START_Y + j
			webserver.download_file(
				process_x, process_y, CONSTANTS.OFFSET * i, CONSTANTS.OFFSET * j
			)
	process_x = START_X
	process_y = START_Y
	
	#var light = Light.new()
	#light.energy = 10
	#add_child(light, true)
		

func _on_download_completed(success, current_x, current_y, offset_x, offset_y):
	if success:
		#print("download successfull for: x=", current_x, ", ", current_y)
		render_geometries(current_x, current_y, offset_x, offset_y)
	else:
		print("Download failed or timed out.")


func render_geometries(x, y, offset_x, offset_y):
	
	var tilepath = "res://tiles/" + str(x) + str(y)
	var tile = MVT_READER.load_tile(tilepath)
	var current_tile_node_path = str(x) + str(y)
	var tile_node_current = get_node(current_tile_node_path)
	#print(tile_node_current)
	
	#imp
	var build_cl = layers['floor']
	var build_cm  =layers['highway'] | layers['character'] | layers['building'] | layers['common'] | layers['water'] | layers['natural']
	
	FLOOR_BUILDER.build_floor(tile_node_current, offset_x, offset_y,build_cl,build_cm)
	
	for layer in tile.layers():
		#print(layer, layer.name())
		if layer.name() == CONSTANTS.HIGHWAYS:
			var high_cl = layers['highway']
			var high_cm= layers['floor'] | layers['character'] | layers['building'] | layers['common'] | layers['water'] | layers['natural']
			for feature in layer.features():
				var width = null
				if feature.tags(layer).has("pathType"):
					if CONSTANTS.WIDTHS.has(feature.tags(layer).pathType):
						width = CONSTANTS.WIDTHS[feature.tags(layer).pathType]
					
				var linestring_geometries = (
					LINESTRING_VECTOR_CALCULATOR.build_linestring_geometries(feature.geometry())
				)
				LINESTRING_BUILDER.generate_paths(
					linestring_geometries,
					tile_node_current,
					Color(0, 0, 0, 1),
					offset_x,
					offset_y,
					high_cl,
					high_cm,
					10
				)

		if layer.name() == CONSTANTS.BUILDINGS:
			var building_cl = layers['building']
			var building_cm= layers['floor'] | layers['character'] | layers['highway'] | layers['common'] | layers['water'] | layers['natural']
			for feature in layer.features():
				var polygon_height = POLYGON_HEIGHT_CALCULATOR.get_polygon_height(feature, layer)
				
				var sanitized_geometries = POLYGON_VECTOR_CALCULATOR.build_polygon_geometries(
					feature.geometry()
				)
				#print("what is sanitized_geometries",sanitized_geometries)
				var polygon_geometries = POLYGON_VECTOR_CALCULATOR.calculate_polygon_vectors(
					sanitized_geometries
				)
				#print("what is polygon_geomtries",polygon_geometries)
				
				var polygon_array = POLYGON_BUILDER.generate_polygons(
					polygon_geometries,
					tile_node_current,
					Color(0.85, 0.78, 0.63, 1.0),
					offset_x,
					offset_y,
					building_cl, 
					building_cm,
					polygon_height
				)
				#print("the coordinates of building after doing offset",polygon_array)
				var first = polygon_array[0]
				var first_x = first[0]
				var first_y = first[1]
				
				if feature.tags(layer).has("name"):
					var building_name = feature.tags(layer)["name"]
					var tag
					tag = Label3D.new()
					tag.text = building_name
					tag.transform.origin= Vector3(first_x,polygon_height+5,first_y)
					tag.scale= Vector3(30,30,30)
					add_child(tag)
					#print("print the x,y coordinate", labels_x,labels_y)
				
		if layer.name() == CONSTANTS.COMMON:
			var common_cl = layers['common']
			var common_cm = layers['floor']  | layers['character'] | layers['highway'] | layers['building'] |layers['water'] | layers['natural']
			for feature in layer.features():
				var sanitized_geometries = POLYGON_VECTOR_CALCULATOR.build_polygon_geometries(
					feature.geometry()
				)
				var polygon_geometries = POLYGON_VECTOR_CALCULATOR.calculate_polygon_vectors(
					sanitized_geometries
				)
				#var plain_g = PLAIN_BUILDER.generate_plain(
					#polygon_geometries,
					#tile_node_current,
					##Color(0.396, 0.263, 0.129, 1.0),
					#Color(1.0, 0.0, 1.0, 1.0),
					#offset_x,
					#offset_y,
					#common_cl,
					#common_cm,
					#0.01
				#)
				PLAIN_BUILDER.generate_plain(
					polygon_geometries,
					tile_node_current,
					#Color(0.396, 0.263, 0.129, 1.0),
					Color(1.0, 0.0, 1.0, 1.0),
					offset_x,
					offset_y,
					common_cl,
					common_cm,
					0.01
				)

		if layer.name() == CONSTANTS.WATER:
			var water_cl = layers['water']
			var water_cm = layers['floor']  | layers['character'] | layers['highway'] | layers['building'] | layers['common'] | layers['natural']
			for feature in layer.features():
				var type = feature.geom_type()
				if type["GeomType"] == "LINESTRING":
					var linestring_geometries = (
						LINESTRING_VECTOR_CALCULATOR.build_linestring_geometries(feature.geometry())
					)
					LINESTRING_BUILDER.generate_paths(
						linestring_geometries,
						tile_node_current,
						Color(0.004, 0.34, 0.61, 0.4),
						offset_x,
						offset_y,
						water_cl,
						water_cm
					)

				if type["GeomType"] == "POLYGON":
					var sanitized_geometries = POLYGON_VECTOR_CALCULATOR.build_polygon_geometries(
						feature.geometry()
					)
					var polygon_geometries = POLYGON_VECTOR_CALCULATOR.calculate_polygon_vectors(
						sanitized_geometries
					)

					var water_geomtries = POLYGON_BUILDER.generate_polygons(
						polygon_geometries,
						tile_node_current,
						Color(0.004, 0.34, 0.61, 0.4),
						offset_x,
						offset_y,
						water_cl,
						water_cm
					)
			
					var firstw = water_geomtries[0]
					var first_xw = firstw[0]
					var first_yw = firstw[1]
				
					if feature.tags(layer).has("name"):
						var water_name= feature.tags(layer)["name"]
				
						var tag1
						tag1 = Label3D.new()
						tag1.text = water_name
						tag1.transform.origin= Vector3(first_xw,1,first_yw)
						tag1.scale= Vector3(30,30,30)
						tag1.add_to_group("billboard_labels")
						add_child(tag1)

		if layer.name() == CONSTANTS.POINT:
			POINTS.generate_pois(tile, tile_node_current, offset_x, offset_y)

		if layer.name() == CONSTANTS.NATURAL: #grass
			var natural_cl = layers['natural']
			var natural_cm = layers['floor']  | layers['character'] | layers['highway'] | layers['building'] | layers['common'] | layers['water']
			for feature in layer.features():
				var sanitized_geometries = POLYGON_VECTOR_CALCULATOR.build_polygon_geometries(
					feature.geometry()
				)
				var polygon_geometries = POLYGON_VECTOR_CALCULATOR.calculate_polygon_vectors(
					sanitized_geometries
				)

				var plain_coordi = PLAIN_BUILDER.generate_plain(
					polygon_geometries,
					tile_node_current,
					Color(0.21, 0.42, 0.21, 1),
					offset_x,
					offset_y,
					natural_cl,
					natural_cm,
					0.01
				)
				var firstp = plain_coordi[0]
				#print("priting first plain coordinates",firstp)
				var first_xp = firstp[0]
				var first_yp = firstp[1]
				if feature.tags(layer).has("name"):
					var plain_name= feature.tags(layer)["name"]
					var tag2
					tag2 = Label3D.new()
					tag2.text = plain_name
					tag2.transform.origin= Vector3(first_xp,1,first_yp)
					tag2.scale= Vector3(30,30,30)
					add_child(tag2)

# _process needs an argument, even if its never used
# gdlint:ignore = unused-argument
func _process(delta):
	#if player_inst and ray_sensor:
		#ray_sensor.global_position = player_inst.global_position 
		#print("pos",ray_sensor.global_position)
		
		#var observation = ray_sensor.get_observation()
		#for obs in observation:
			#print("Ray Index:", obs["ray_index"])	
			
	#print("player_inst.position",player_inst.position)
	#print("player_inst.global_position",player_inst.global_position)
	
	#var tile_distance_x = int(ai_inst.arena.main_player.position.x / CONSTANTS.OFFSET)
	#var tile_distance_y = int(ai_inst.arena.main_player.position.z / CONSTANTS.OFFSET)
	
	var tile_distance_x = int(player_inst.position.x / CONSTANTS.OFFSET)
	var tile_distance_y = int(player_inst.position.z / CONSTANTS.OFFSET)
	#load tiles if going to wards positive x loaded border
	if tile_distance_x > (tiles_loaded_x_max - 2):
		tiles_loaded_x_max += 1
		tiles_loaded_x_min += 1
		process_x = process_x + 2
		steps_x += 1

		for i in range(tiles_loaded_x_min, tiles_loaded_x_max, 1):
			var webserver = WEBSERVER.new()
			var tile_node = Node3D.new()
			add_child(tile_node)
			tile_node.name = str(process_x) + str(process_y + i)
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.download_file(
				process_x,
				process_y + i,
				CONSTANTS.OFFSET * (tiles_loaded_x_max - 1),
				CONSTANTS.OFFSET * (i + steps_y)
			)
			var childnode = get_node(str(process_x - 4) + str(process_y + i))
			remove_child(childnode)

		process_x = process_x - 1

	#load tiles of going towards negative x border
	if tile_distance_x < (tiles_loaded_x_min + 2):
		tiles_loaded_x_max -= 1
		tiles_loaded_x_min -= 1
		process_x = process_x - 3
		steps_x -= 1

		for i in range(tiles_loaded_x_min, tiles_loaded_x_max, 1):
			var webserver = WEBSERVER.new()
			var tile_node = Node3D.new()
			add_child(tile_node)
			tile_node.name = str(process_x) + str(process_y + i)
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.download_file(
				process_x,
				process_y + i,
				CONSTANTS.OFFSET * (tiles_loaded_x_min),
				CONSTANTS.OFFSET * (i + steps_y)
			)

			var childnode = get_node(str(process_x + 4) + str(process_y + i))
			remove_child(childnode)

		process_x = process_x + 2

	#load tiles if going towards positive y border
	if tile_distance_y > (tiles_loaded_y_max - 2):
		tiles_loaded_y_max += 1
		tiles_loaded_y_min += 1
		process_y = process_y + 2

		steps_y += 1

		for i in range(tiles_loaded_y_min, tiles_loaded_y_max, 1):
			var webserver = WEBSERVER.new()
			var tile_node = Node3D.new()
			add_child(tile_node)
			tile_node.name = str(process_x + i) + str(process_y)
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.download_file(
				process_x + i,
				process_y,
				CONSTANTS.OFFSET * (i + steps_x),
				CONSTANTS.OFFSET * (tiles_loaded_y_max - 1)
			)

			var childnode = get_node(str(process_x + i) + str(process_y - 4))
			remove_child(childnode)

		process_y = process_y - 1

	#load tiles if going towards negative y border
	if tile_distance_y < (tiles_loaded_y_min + 2):
		tiles_loaded_y_max -= 1
		tiles_loaded_y_min -= 1
		process_y = process_y - 3

		steps_y -= 1

		for i in range(tiles_loaded_y_min, tiles_loaded_y_max, 1):
			var webserver = WEBSERVER.new()
			var tile_node = Node3D.new()
			add_child(tile_node)
			tile_node.name = str(process_x + i) + str(process_y)
			add_child(webserver)
			webserver.connect("download_completed", _on_download_completed)
			webserver.download_file(
				process_x + i,
				process_y,
				CONSTANTS.OFFSET * (i + steps_x),
				CONSTANTS.OFFSET * tiles_loaded_y_min
			)

			var childnode = get_node(str(process_x + i) + str(process_y + 4))
			remove_child(childnode)

		process_y = process_y + 2
