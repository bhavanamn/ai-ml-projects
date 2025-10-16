static func get_value(_options, _key, _exceptionValue):
	if _options.has(_key):
		return _options[_key]
	else:
		return _exceptionValue

static func GetAllTreeNodes(node, listOfAllNodesInTree):	
	listOfAllNodesInTree.append(node)
	for childNode in node.get_children():
		GetAllTreeNodes(childNode, listOfAllNodesInTree)
	#return listOfAllNodesInTree

static func add_inputs(player_controls):
	for action in player_controls:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		for key in player_controls[action]:
			var ev = InputEventKey.new()
			ev.keycode = key
			InputMap.action_add_event(action, ev)
			
static func Getlayers() -> Dictionary:   #main.gd
	return{
		'floor':2,
		'character':4,
		'highway':8,
		'building':16,
		'common':32,
		'natural':64,
		'water':128,
		'sphere_rigid':256
	}
static var user_controls = {	'player_controls': 
						{
						"move_right": [KEY_RIGHT, KEY_D],
						"move_left": [KEY_LEFT, KEY_A ],
						"move_forward": [KEY_UP, KEY_W],
						"move_backward": [KEY_DOWN, KEY_S],
						"turn_right":[KEY_9],
						"jump": [KEY_SPACE],
						"turn_left":[KEY_8],
						"camera_left":[KEY_L],
						"camera_right":[KEY_R],
						#"zoom_in"y:[MOUSE_BUTTON_WHEEL_DOWN,KEY_I],
						#"zoom_out":[MOUSE_BUTTON_WHEEL_UP,KEY_O],
						"kick":[KEY_K],
						"ball_bending":[KEY_B],
						"reset":[KEY_Y]
						},
					#'camera_controls': {'global_camera': [KEY_0]},
					'camera_controls':
					{
						'global_camera': [KEY_0]
					},
					'game_controls':
					{
						'start': [KEY_S], 
						'stop':[KEY_Q], 
						'toggle_camera': [KEY_C]
					}
					}
