extends AIController3D

var ai_move_x = 0.0
var ai_move_z = 0.0
var _reward = 0
var nochange_count = 0
var ai_jump_action = false
var ai_turn_left = false
var ai_turn_right = false
var ai_prev_position = null
var prev_distance_for_waypoint
var highway_check_timer = 0
#var teleport_counter = 0
var current_way_point_index = 0

@export var teleport_same_counter = 15
@export var reset_nochange = 100
@export var reset_highway = 30
var rigid_body_script = load("res://components/rigid_body_functions.gd")

var teleport_list = [
			#Vector3(380,0.03,-294),       			#a
			#Vector3(407.5,0.03,-324),    			#b
			Vector3(375.6,0.03,-380),				#c    #point on highway
			Vector3(401,0.03,-385.41),				#d
			Vector3(389.25, 0.0, -385 ),			#e
			Vector3(400.3,0.0,-478),				#f
			Vector3(361.07, 0.03, -465), 			#g near football
			Vector3(384.4, 0.03, -515),  			#h near football
			Vector3(322.06, 0.03, -766.3),			#i
			Vector3(343.22, 0.03, -916),			#j
			Vector3(371.22, 0.03, -1487.629), 		#fountain
			Vector3(401.73, 0.03, -1959.13),  		#-2 tiles area ending 
			Vector3(404.9098, 0.03, -2007.312),  	#near main gate 
]
@export  var waypoint_list = [
			Vector3(380,0.03,-294),       			#a   point on highway
			#Vector3(407.5,0.03,-324),    			#b
			Vector3(375.6,0.03,-380),				#c    #point on highway
			#Vector3(401,0.03,-385.41),				#d
			#Vector3(389.25, 0.0, -385 ),			#e
			#Vector3(400.3,0.0,-478),				#f
			Vector3(361.07, 0.03, -465), 			#g near football   #but on highway
			Vector3(361.07, 0.03, -505),					#point on highway
			#Vector3(384.4, 0.03, -515),  			#h near football
			#Vector3(322.06, 0.03, -766.3),			#i
			#Vector3(343.22, 0.03, -916),			#j
			Vector3(361.07, 0.03, -575),					#highway point 
			Vector3(371.22, 0.03, -1487.629), 		#fountain
			Vector3(401.73, 0.03, -1959.13),  		#-2 tiles area ending 
			Vector3(404.9098, 0.03, -2007.312),  	#near main gate 
]





func reset():
	#super.reset()
	#print("reward after every reset action: ",_reward)
	n_steps = 0
	done = true
	
	if get_done():
		#print("reward after every action", ai_total_reward)
		pass
	#set_done_false()
	#ai_total_reward = 0.0
	_reward = 0
	reward = 0.0
	ai_move_x = 0.0
	ai_move_z = 0.0
	ai_jump_action = false
	ai_turn_left = false
	ai_turn_right = false
	nochange_count = 0
	#teleport_counter += 1
	current_way_point_index = 0
	#_player.global_transform.origin = _player.reset_teleport
	#if(teleport_counter < teleport_same_counter ):
		#print("_player.global_transform.origin",_player.global_transform.origin, " ", " teleport_counter",teleport_counter)
	_player.global_transform.origin = Vector3(395.52, 0, -275.6)
	#else :
		#var size = teleport_list.size()
		#_player.global_transform.origin = teleport_list[randi_range(0,size-1)]
		#print("_player.global_transform.origin from else loop",_player.global_transform.origin, " ", " teleport_counter",teleport_counter)
	needs_reset = false
	
func is_at_waypoint(pos, waypoint):
	if pos.distance_to(waypoint) <= 15:
		return true
	else:	
		return false


#func get_obs() -> Dictionary:
	##print("-player",_player)
	##print("dis list",_player.dist_list)
	#_player.dist_list[-1] = _player.is_on_floor()
	#
	#return {
		#"obs": _player.dist_list
	#}  

func get_obs() -> Dictionary:
	var obs = []

	obs.append(_player.is_on_floor())
	
	if current_way_point_index < waypoint_list.size():
		var player_pos = _player.global_transform.origin
		var waypoint_pos = waypoint_list[current_way_point_index]
		var direction_to_waypoint = (waypoint_pos - player_pos).normalized()
		direction_to_waypoint = direction_to_waypoint.rotated(Vector3.UP, -rotation.y)
		var distance_to_waypoint = player_pos.distance_to(waypoint_pos)

		obs.append_array([direction_to_waypoint.x, direction_to_waypoint.y, direction_to_waypoint.z])
		obs.append(distance_to_waypoint)
	else:
		obs.append_array([0.0, 0.0, 0.0])
		obs.append(0.0)
	obs.append_array(_player.dist_list)
	
	#print("obs size: ", obs.size(), obs)
	return {"obs": obs}

func get_action_space() -> Dictionary:
	return {
		
		"jump_action": {
			"size": 1,
			"action_type": "discrete",
			"values": [0, 1]
		},
		"turn":{
			"size": 1, 
			"action_type": "discrete",
			"values": [0, 1]
		},
		"turn_left": {
			"size": 1, 
			"action_type": "continuous",
			#"values": [0, 1]
		},
		
	}
	
func set_action(action: Dictionary) -> void:
	#print('Action:', action,"player_is_on_floor",_player.is_on_floor())
	
	ai_move_x = 0 						#clamp(action["move_x"][0], -1, 0)
	ai_move_z = -1 						#clamp(action["move_z"][0], -1, 0)
	_player.options['ai_move_x'] = ai_move_x
	_player.options['ai_move_z'] = ai_move_z
	
	
	#if action["jump_action"] == 1:
		#ai_jump_action = true
		#print("jump action set true")
	#else:
		#ai_jump_action = false
		#print("jump action set false")
		
	#print("_player.left_count",_pyyyyyylayer.left_count,"_player.right_count",_player.right_count,"highway_check_timer",highway_check_timer)
	ai_jump_action = false
	
	if _player.layer_to_export == 2:  				 #build floor
		#print("went into build floor")
		#if highway_check_timer <= reset_highway:
		if (_player.left_count + _player.right_count) >= 6 :
			#print("went into 6 counter")
			ai_jump_action = true
			#print("player details for jump_action",_player.is_on_floor())
		
	_player.options['ai_jump'] = ai_jump_action	
	
	
	if action["turn"] == 1: 				#turn action logic
		var _t = clamp(action["turn_left"][0], 0, 1)
		if _t == 1:
		#if action["turn_left"] == 1:
			ai_turn_left = true
			ai_turn_right = false
		else:
			ai_turn_left = false
			ai_turn_right = true
	else:
		ai_turn_left = false
		ai_turn_right = false
		
	_player.options['ai_turn_left'] = ai_turn_left
	_player.options['ai_turn_right'] = ai_turn_right
	#ai_turn_action = clamp(action["turn_action"][0], -1.0, 1.0) 
	#print("ai turn action values:",ai_turn_action)

	#ai_turn_action = action["turn_action"][0]
	#print("ai turn action values:",ai_turn_action)


func get_reward() -> float:
	var ai_total_reward = 0
	var _done = false
	var current_position = _player.global_transform.origin
	
	
	#waypoint logic:
	#print("waypoint_list",waypoint_list,"current_way_point_index",current_way_point_index)
	print("current_way_point_index",current_way_point_index)
	if current_way_point_index == waypoint_list.size()-1:
		ai_total_reward += 100
		print("finished game")
		_done = true						#reached goal: ->do reset or some other action
	elif current_way_point_index < waypoint_list.size()-1:
		var target_waypoint = waypoint_list[current_way_point_index]
		if is_at_waypoint(current_position, target_waypoint):
			print("Reached waypoint:", current_way_point_index)
			ai_total_reward += 50  								# reward for reaching a waypoint
			current_way_point_index += 1
					
	if _player.layer_to_export == 2:   #build floor
		highway_check_timer += 1
		ai_total_reward -= 3
		
		if highway_check_timer > reset_highway:
			#print("getting in this loop")
			ai_total_reward -= 100
			_done = true
			#print("highway_check_timer",highway_check_timer)
			highway_check_timer = 0
			
	elif _player.layer_to_export == 256:			#sphere
		rigid_body_script.kick_sphere_rigid(_player.collider, -(_player.transform.basis.z) )			
		ai_total_reward += 20    					
		
	elif _player.layer_to_export == 128:  				#water
		ai_total_reward -= 100.0
		_done = true
		
	elif _player.layer_to_export == 8: 					 #highway
		highway_check_timer = 0
		#ai_total_reward = 5
															#highway conditions
		if _player.left_major and _player.right_major:
			if ai_turn_left or ai_turn_right:
				ai_total_reward -= 5
			else:
				ai_total_reward += 10
				
		#if left and forward
		elif _player.left_major  and not _player.right_major:
			if ai_turn_left:
				ai_total_reward += 10
			elif ai_turn_right:
				ai_total_reward -= 5
			else:
				ai_total_reward += 5
				
		##if right and forward
		elif not _player.left_major  and _player.right_major:
			if ai_turn_right:
				ai_total_reward += 10  
			elif ai_turn_left:
				ai_total_reward -= 5
			else:
				ai_total_reward += 5
				
	elif _player.layer_to_export == 16:   							#building
		
		highway_check_timer = 0
		
		if _player.left_major and not _player.right_major:
			if ai_turn_left:
				ai_total_reward += 10
			elif ai_turn_right:
				ai_total_reward -= 5
			else :
				ai_total_reward -= 5
		
		elif not _player.left_major and _player.right_major:
			if ai_turn_left:
				ai_total_reward -= 5
			elif ai_turn_right:
				ai_total_reward += 10
			else : 
				ai_total_reward -= 5
				
		elif _player.left_major or _player.right_major:
			if ai_turn_left:
				ai_total_reward += 10
			elif ai_turn_right:
				ai_total_reward += 10
			else:
				ai_total_reward -= 5 					#if no turn

		else:
			_player.rotate_y(deg_to_rad(180))			#nothing is there:, take a u-turn

	if ai_prev_position:								
		if current_position == ai_prev_position:			#present at same position
			nochange_count += 1
		else:
			nochange_count = 0

		if nochange_count >= reset_nochange:
			ai_total_reward -= 100
			_done = true
	ai_prev_position = current_position
	_reward += ai_total_reward

	
	
	var distance_to_waypoint = _player.global_transform.origin.distance_to(waypoint_list[current_way_point_index])
	
	if ai_prev_position:
		prev_distance_for_waypoint = ai_prev_position.distance_to(waypoint_list[current_way_point_index]) 
	else:
		prev_distance_for_waypoint = distance_to_waypoint
		
	if distance_to_waypoint < prev_distance_for_waypoint:
		ai_total_reward = 50 
	else:
		ai_total_reward = -15 
		
		
	if _done:
		reset()
	if needs_reset:
		reset()
		
	return ai_total_reward      #end of reward function
