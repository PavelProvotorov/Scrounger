extends Node2D

const grid_size = 8

var level_entrance
var level_queue

var moving_entity
var moving_entity_path
var moving_entity_position:Vector2

var target_entity
var target_entitiy_path
var target_entity_position:Vector2

var gotTextFromJSON

const DIRECTION_LIST:Array = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
	]

signal on_manager_mob_actions_finished
signal on_mob_action_finished


# READY
#---------------------------------------------------------------------------------------
func _ready():
	level_load("Level_Empty")
	Global.LEVEL_LAYER_LOGIC.bsp_generator()
	Global.LEVEL_LAYER_LOGIC.astar_build()
	pass

# MOB BEHAVIOUR
#---------------------------------------------------------------------------------------
func manager_mob():
	print("---------------------------------------------------------")
	print("THE QUEUE SIZE IS: %s" %level_queue.size())
	for i in (level_queue.size()):
#		print(i)
#		yield(get_tree().create_timer(0.025),"timeout")
		moving_entity = Global.LEVEL_LAYER_LOGIC.get_node(level_queue[i][1])
#		print("Currently Moving: %s" %moving_entity.name)
#		print("Currently Moving: %s" %moving_entity)
		manager_mob_actions()
		yield(self,"on_manager_mob_actions_finished")

	print("< MANAGER MOB FINISHED, CHANGE TO PLAYER >")
	Global.game_state_manager(Global.GAME_STATE_LIST.STATE_PLAYER_TURN)
	pass

func manager_mob_actions():
	if moving_entity.AI_state == Global.AI_STATE_LIST.STATE_ENGAGE:
		Global.LEVEL_LAYER_LOGIC.astar_prepare()
		Global.LEVEL_LAYER_LOGIC.astar_remove_mobs(moving_entity)
		Global.LEVEL_LAYER_LOGIC.astar_build()
		for speed in moving_entity.stat_speed:
			moving_entity_position = Global.LEVEL_LAYER_LOGIC.world_to_map(moving_entity.get_global_position())
			target_entity_position = Global.LEVEL_LAYER_LOGIC.world_to_map(target_entity.get_global_position())
			moving_entity_path = Global.LEVEL_LAYER_LOGIC.astar_get_path(moving_entity_position,target_entity_position)
#			print(moving_entity_path)
#			print(moving_entity_path.size())
			if moving_entity_path.size() > 0:
				if moving_entity_path[1] == target_entity_position:
					mob_action_attack(moving_entity_path[0],moving_entity_path[1])
					Sound.play_sound(moving_entity,moving_entity.sound_on_melee)
					Sound.play_sound(target_entity,target_entity.sound_on_hit)
					yield(self,"on_mob_action_finished")
				elif moving_entity_path[1] != target_entity_position:
					var cell_is_fog:bool = cell_is_fog(moving_entity_path[1])
					if cell_is_fog == true:
						mob_action_shift(moving_entity_path[0],moving_entity_path[1])
						mob_action_skip()
						yield(self.mob_action_skip(),"completed")
					elif cell_is_fog == false:
						mob_action_move(moving_entity_path[0],moving_entity_path[1])
						Sound.play_sound(moving_entity,moving_entity.sound_on_move)
						yield(self,"on_mob_action_finished")
			elif moving_entity_path.size() == 0:
				mob_action_skip()
				yield(self.mob_action_skip(),"completed")
	elif moving_entity.AI_state == Global.AI_STATE_LIST.STATE_IDLE: 
		yield(self.mob_action_skip(),"completed")
	
	print("< MANAGER MOB ACTIONS FINISHED >")
	emit_signal("on_manager_mob_actions_finished")

func mob_action_skip():
	yield(get_tree(),"idle_frame")

func mob_action_shift(cellA:Vector2,cellB:Vector2):
	#MOB MOVEMENT | START
	cellA = Vector2((cellA.x)*grid_size,(cellA.y)*grid_size)
	cellB = Vector2((cellB.x)*grid_size,(cellB.y)*grid_size)
	if cellA - cellB == Vector2(-grid_size,0): moving_entity.animation_flip(false,false)
	if cellA - cellB == Vector2(grid_size,0): moving_entity.animation_flip(true,false)
	
	#MOB MOVEMENT | FINISH
	moving_entity.set_global_position(cellB)

	pass

func mob_action_move(cellA:Vector2,cellB:Vector2):
	#MOB MOVEMENT | START
	cellA = Vector2((cellA.x)*grid_size,(cellA.y)*grid_size)
	cellB = Vector2((cellB.x)*grid_size,(cellB.y)*grid_size)
	if cellA - cellB == Vector2(-grid_size,0): moving_entity.animation_flip(false,false)
	if cellA - cellB == Vector2(grid_size,0): moving_entity.animation_flip(true,false)
	moving_entity.action_move_tween(cellA,cellB)
	
	#MOB MOVEMENT | FINISH
	yield(moving_entity.get_node("Tween"),"tween_all_completed")
	
	#MOB MOVEMENT | END
	emit_signal("on_mob_action_finished")

func mob_action_attack(cellA:Vector2,cellB:Vector2):
	#MOB ATTACK | START
	cellA = Vector2((cellA.x)*grid_size,(cellA.y)*grid_size)
	cellB = Vector2((cellB.x)*grid_size,(cellB.y)*grid_size)
	if cellA - cellB == Vector2(-grid_size,0): moving_entity.animation_flip(false,false)
	if cellA - cellB == Vector2(grid_size,0): moving_entity.animation_flip(true,false)

	moving_entity.z_index += 1
#	moving_entity.animation_change(Global.ANIMATIONS.MELEE_ATTACK,true,false)
	calculate_melee_damage(moving_entity,target_entity)
	moving_entity.action_attack_tween(cellA,cellB)
	
	#MOB ATTACK | FINISH
	yield(moving_entity.get_node("Tween"),"tween_all_completed")
	
	moving_entity.z_index -= 1
#	moving_entity.animation_change(Global.ANIMATIONS.MELEE_IDLE,true,true)
	
	#MOB ATTACK | END
	emit_signal("on_mob_action_finished")

# UTILITY
#---------------------------------------------------------------------------------------

func cell_is_fog(cell:Vector2):
	var cell_to_check = Vector2((cell.x)*grid_size,(cell.y)*grid_size)
	cell_to_check = Global.LEVEL_LAYER_FOG.get_cellv(cell)
	if cell_to_check == Global.LEVEL_LAYER_LOGIC.TILESET_FOG.TILE_FULL:
		return true
	if cell_to_check == Global.LEVEL_LAYER_LOGIC.TILESET_FOG.TILE_NONE:
		return false

func calculate_melee_damage(is_attacker,is_target):
	is_target.stat_health -= is_attacker.stat_melee_dmg
	if is_target.stat_health <= 0: 
			is_target.queue_free()
			Global.LEVEL_LAYER_LOGIC.remove_child(is_target)

func level_load(level_name:String):
	var level_data = load("res://Scenes/%s.tscn" %level_name)
	var level_instance = level_data.instance()
	add_child(level_instance)
	pass

func level_mob_spawn(mob_name,mob_position:Vector2):
	var mob_data = load("res://Mobs/%s.tscn" %mob_name)
	var mob_instance = mob_data.instance()
	Global.LEVEL_LAYER_LOGIC.add_child(mob_instance)
	mob_instance.set_global_position(Vector2((mob_position.x)*grid_size,(mob_position.y)*grid_size))
	pass

func level_item_spawn(item_name,item_position:Vector2):
	var item_data = load("res://Items/%s.tscn" %item_name)
	var item_instance = item_data.instance()
	Global.LEVEL_LAYER_LOGIC.add_child(item_instance)
	item_instance.set_global_position(Vector2((item_position.x)*grid_size,(item_position.y)*grid_size))
	pass

func level_queue_prepare():
	level_queue = []
	var idx = 0
	var node_to_scan = Global.LEVEL_LAYER_LOGIC
	var node_to_scan_size:int = node_to_scan.get_child_count()
	for i in node_to_scan_size:
		var node_child_group = node_to_scan.get_child(idx)
		if node_child_group.is_in_group(Global.GROUPS.HOSTILE) and node_child_group.AI_state == Global.AI_STATE_LIST.STATE_ENGAGE:
			var node_child_name:String = node_to_scan.get_child(idx).name
			var node_child_data:int = node_to_scan.get_child(idx).stat_ambition
			var node_child_fetch = [node_child_data,node_child_name]
			level_queue.push_back(node_child_fetch)
		else:
			pass
		idx += 1
		i += 1
	level_queue.sort_custom(self,"level_queue_sort")
	Global.LEVEL_QUEUE = level_queue
	print("QUEUE AFTER SCAN:")
	print(level_queue)
	pass

func level_queue_sort(a,b):
	if a[0] > b[0]:
		return true
	return false

func _load_json(resourceFolder:String,resourceType:String):
	var jsonText
	var jsonParse
	var jsonFile = File.new()
	var jsonFileFolder = resourceFolder
	var jsonFileType = resourceType
	var jsonPathTemp = "res://Resources/%s/%s.json"
	var jsonPath = jsonPathTemp %[jsonFileFolder,jsonFileType]
	print(jsonPath)
	
	jsonFile.open(jsonPath, jsonFile.READ)
	jsonText = jsonFile.get_as_text()
	jsonParse = JSON.parse(jsonText)
	if jsonParse.error == OK:
		jsonText = jsonParse.result
	elif jsonParse.error != OK:
		push_error("Error: _load_json")
		push_error("The error is: %s" %jsonParse.error)
		push_error("The line is: %s" %jsonParse.error_line)
		push_error("The string is: %s" %jsonParse.error_string)
	else:
		pass
	return jsonText
	pass
