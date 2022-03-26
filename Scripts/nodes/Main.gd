extends Node2D

const grid_size = 16

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
	level_mob_spawn("Player",Vector2(7,6))
#	level_mob_spawn("Grunt",Vector2(8,9))
#	level_mob_spawn("Grunt",Vector2(6,3))
#	level_mob_spawn("Grunt",Vector2(7,5))
#	level_mob_spawn("Grunt",Vector2(10,9))
	Global.LEVEL_LAYER_LOGIC.astar_build()
	
	target_entity = Global.LEVEL_LAYER_LOGIC.get_node("Player")
#	print_tree_pretty()
	pass

# MOB BEHAVIOUR
#---------------------------------------------------------------------------------------
func manager_mob():
	print("---------------------------------------------------------")
	print("THE QUEUE SIZE IS: %s" %level_queue.size())
	for i in (level_queue.size()):
		print(i)
		yield(get_tree().create_timer(0.1),"timeout")
		moving_entity = Global.LEVEL_LAYER_LOGIC.get_node(level_queue[i][1])
#		print("Currently Moving: %s" %moving_entity.name)
		print("Currently Moving: %s" %moving_entity)
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
			if moving_entity_path[1] == target_entity_position:
				print("ATTACK")
				mob_action_attack(moving_entity_path[0],moving_entity_path[1])
				yield(self,"on_mob_action_finished")
			if moving_entity_path[1] != target_entity_position:
				print("MOVE")
				mob_action_move(moving_entity_path[0],moving_entity_path[1])
				yield(self,"on_mob_action_finished")
	print("< MANAGER MOB ACTIONS FINISHED >")
	emit_signal("on_manager_mob_actions_finished")

func mob_action_move(cellA:Vector2,cellB:Vector2):
	#MOB MOVEMENT | START
	cellA = Vector2((cellA.x)*grid_size,(cellA.y)*grid_size)
	cellB = Vector2((cellB.x)*grid_size,(cellB.y)*grid_size)
	if cellA - cellB == Vector2(-16,0): moving_entity.animation_flip(false,false)
	if cellA - cellB == Vector2(16,0): moving_entity.animation_flip(true,false)
	moving_entity.action_move_tween(cellA,cellB)
	
	#MOB MOVEMENT | FINISH
	yield(moving_entity.get_node("Tween"),"tween_all_completed")
	
	#MOB MOVEMENT | END
	emit_signal("on_mob_action_finished")

func mob_action_attack(cellA:Vector2,cellB:Vector2):
	#MOB ATTACK | START
	cellA = Vector2((cellA.x)*grid_size,(cellA.y)*grid_size)
	cellB = Vector2((cellB.x)*grid_size,(cellB.y)*grid_size)
	if cellA - cellB == Vector2(-16,0): moving_entity.animation_flip(false,false)
	if cellA - cellB == Vector2(16,0): moving_entity.animation_flip(true,false)

	moving_entity.z_index += 1
	moving_entity.animation_change(Global.ANIMATIONS.MELEE_ATTACK,true,false)
	calculate_melee_damage(moving_entity,target_entity)
	moving_entity.action_attack_tween(cellA,cellB)
	
	#MOB ATTACK | FINISH
	yield(moving_entity.get_node("Tween"),"tween_all_completed")
	
	moving_entity.z_index -= 1
	moving_entity.animation_change(Global.ANIMATIONS.MELEE_IDLE,true,true)
	
	#MOB ATTACK | END
	emit_signal("on_mob_action_finished")

# UTILITY
#---------------------------------------------------------------------------------------
func calculate_melee_damage(is_attacker,is_target):
	is_target.stat_health -= is_attacker.stat_melee_dmg
	if is_target.stat_health <= 0: 
			is_target.queue_free()
			Global.LEVEL_LAYER_LOGIC.remove_child(is_target)

func level_load(level_name:String):
	var level_data = load("res://Scenes/levels/%s.tscn" %level_name)
	var level_instance = level_data.instance()
	add_child(level_instance)
	pass

func level_mob_spawn(mob_name,mob_position:Vector2):
	var mob_data = load("res://Scenes/mobs/%s.tscn" %mob_name)
	var mob_instance = mob_data.instance()
	Global.LEVEL_LAYER_LOGIC.add_child(mob_instance)
	mob_instance.set_global_position(Vector2((mob_position.x)*grid_size,(mob_position.y)*grid_size))
	pass

func level_queue_prepare():
	level_queue = []
	var idx = 0
	var node_to_scan = Global.LEVEL_LAYER_LOGIC
	var node_to_scan_size:int = node_to_scan.get_child_count()
	for i in node_to_scan_size:
		var node_child_group = node_to_scan.get_child(idx)
		if node_child_group.is_in_group(Global.GROUPS.HOSTILE):
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

#func manager_mob_AI():
#	print("---------------------------------------------------------")
#	print("THE QUEUE SIZE IS: %s" %level_queue.size())
#	for i in (level_queue.size()):
#		print(i)
#		yield(get_tree().create_timer(0.6),"timeout")
#		moving_entity = Global.LEVEL_LAYER_LOGIC.get_node(level_queue[i][1])
#		print("Currently Moving: %s" %moving_entity.name)
#		if moving_entity.AI_class == Global.AI_CLASS_LIST.CLASS_NONE:
#			pass
#		elif moving_entity.AI_class == Global.AI_CLASS_LIST.CLASS_MELEE:
#			manager_mob_actions()
#			yield(self,"on_manager_mob_actions_finished")
#			pass
#		elif moving_entity.AI_class == Global.AI_CLASS_LIST.CLASS_RANGED:
#			pass
#		else:
#			pass
#	print("< MANAGER MOB AI FINISHED, CHANGE TO PLAYER >")
#	Global.game_state_manager(Global.GAME_STATE_LIST.STATE_PLAYER_TURN)
#	pass
#
#func manager_mob_actions():
#	if moving_entity.AIState == AI_STATE_LIST[0]:
#		pass
#	elif moving_entity.AIState == AI_STATE_LIST[1]:
#		pass
#	elif moving_entity.AIState == AI_STATE_LIST[2]:
#		for i in moving_entity.stat_speed:
#			moving_entity_position = Global.LEVEL_LAYER_LOGIC.world_to_map(moving_entity.get_global_position())
#			moving_entity_position = Vector2(moving_entity_position.x+1,moving_entity_position.y)
#			mob_action_move(moving_entity_position,target_entity_position)
#			yield(self,"on_mob_action_finished")
#			pass
#		pass
#	elif moving_entity.AIState == AI_STATE_LIST[3]:
#		pass
#	else:
#		pass
#	print("< MANAGER MOB ACTIONS FINISHED >")
#	emit_signal("on_manager_mob_actions_finished")
#
#func mob_action_move(cellA:Vector2,cellB:Vector2):
#	cellA = Vector2((cellA.x)*tile_size,(cellA.y)*tile_size)
#	cellB = Vector2((cellB.x)*tile_size,(cellB.y)*tile_size)
#	moving_entity.action_move_tween(cellA,cellB)
#	yield(moving_entity.get_node("Tween"),"tween_all_completed")
#	emit_signal("on_mob_action_finished")
#
#func mob_action_attack(cellA:Vector2,cellB:Vector2):
#	cellA = Vector2((cellA.x)*tile_size,(cellA.y)*tile_size)
#	cellB = Vector2((cellB.x)*tile_size,(cellB.y)*tile_size)
#	moving_entity.action_attack_tween(cellA,cellB)
#	yield(moving_entity.get_node("Tween"),"tween_all_completed")
#	emit_signal("on_mob_action_finished")

#func _mob_claim():
#	var nearbyCells = moveDirection
#	var nearbyCellsID = 0
#	for i in movingMob.statSpeed:
#		print("TURN NO: %s" %i)
#		nearbyCells.shuffle()
#		movingMobPosition = activeLogicLayer.world_to_map(movingMob.get_global_position())
#		targetMobPosition = Vector2((nearbyCells[nearbyCellsID].x),(nearbyCells[nearbyCellsID].y))
#		targetMobPosition = Vector2((movingMobPosition.x)+(targetMobPosition.x),(movingMobPosition.y)+(targetMobPosition.y))
#		_astar_clear()
#		_astar_get_cells(0)
#		_astar_remove_mob_cells()
#		if tilemapFreeCells.has(targetNodePos) == true:
#			yield(_mob_move(movingNodePos,targetNodePos),"completed")
#			print("MOVE COMPLETE IN CLAIM FUNCTION")
#		elif tilemapFreeCells.has(targetNodePos) == false:
#			for cell in (nearbyCells.size()):
#				targetNodePos = Vector2((nearbyCells[cell].x),(nearbyCells[cell].y))
#				targetNodePos = Vector2((movingNodePos.x)+(targetNodePos.x),(movingNodePos.y)+(targetNodePos.y))
#				print("GOT CELL: %s" %targetNodePos)
#				if tilemapFreeCells.has(targetNodePos) == true:
#					print("CELL IS VALID")
#					yield(_mob_move(movingNodePos,targetNodePos),"completed")
#					print("MOVE COMPLETE IN CLAIM FUNCTION")
#					break
#				elif tilemapFreeCells.has(targetNodePos) == false:
#					print("CELL NOT VALID")
#					pass
#				else:
#					pass
#		else:
#			pass
#	print("< MOB CLAIM FINISHED >")
#	emit_signal("on_mob_action_finished")
#-----------------------------#

#-----------------------------# Loading JSON language files 

#-----------------------------#

#	Global.playerNode = get_node("/root/Main/Logic/%s" %Global.playerNodeWho)
#	Global.playerNodeRayCast = get_node("/root/Main/Logic/%s/RayCast2D" %Global.playerNodeWho)
#	Global.playerNodeTween = get_node("/root/Main/Logic/%s/Tween" %Global.playerNodeWho)
#	Global.playerNode.remove_from_group("Bot")


#	OS.set_window_size(Global.settingWindowSize)
#	OS.set_window_fullscreen(Global.settingWindowFull)
#	print(activeLevelScene.z_index)
#	_load_json(Global.settingLanguage,"rus_strings")
#	gotTextFromJSON = _load_json("rooms","normal_rooms")
#	print("gotTextFromJSON is:")
#	print(gotTextFromJSON)
#	print("got key:")
#	print(gotTextFromJSON.get("room_bottom_center"))


#	Global.NODE_LEVEL = level_current
#	level_layer_logic = level_instance.get_node("Logic")
#	Global.NODE_LEVEL_LAYER_LOGIC = level_layer_logic
#	level_layer_base = level_instance.get_node("Base")
#	Global.NODE_LEVEL_LAYER_BASE = level_layer_base
#	level_layer_wall = level_instance.get_node("Wall")
#	Global.NODE_LEVEL_LAYER_WALL = level_layer_wall
#	level_layer_deco = level_instance.get_node("Deco")
#	Global.NODE_LEVEL_LAYER_DECO = level_layer_deco
	
#	Global.NODE_LEVEL = level_current
#	level_layer_logic = level_instance.get_node("Logic")
#	Global.NODE_LEVEL_LAYER_LOGIC = level_layer_logic
#	level_layer_base = level_instance.get_node("Base")
#	Global.NODE_LEVEL_LAYER_BASE = level_layer_base
#	level_layer_wall = level_instance.get_node("Wall")
#	Global.NODE_LEVEL_LAYER_WALL = level_layer_wall
#	level_layer_deco = level_instance.get_node("Deco")
#	Global.NODE_LEVEL_LAYER_DECO = level_layer_deco
	
#	level_cell_array = level_layer_logic.get_used_cells()
#	level_cell_start = Vector2(level_cell_array.front().x,level_cell_array.front().y)
#	level_cell_finish = Vector2(level_cell_array.back().x-1,level_cell_array.back().y-1)
#	level_border = Rect2(level_cell_start,level_cell_finish)
#	level_cell_array.clear()

#func tilemap_set_wall(atlas_id:int,cell_id:int):
#	randomize()
#	var cell_array = self.get_used_cells_by_id(cell_id)
#	var tile_array = util_atlas_get_tiles(atlas_id,Global.LEVEL_LAYER_WALL)
#	for cell in cell_array:
#		if tilemap_check_bottom_cell(cell.x,cell.y) == true:
#			var tile = tile_array[randi() % tile_array.size()]
#			Global.LEVEL_LAYER_WALL.set_cell(cell.x,cell.y+1,atlas_id,false,false,false,tile)
#		else:
#			pass
#	pass
#
#func tilemap_check_bottom_cell(x,y):
#	if Global.LEVEL_LAYER_LOGIC.get_cell(x, y+1) == TILES.LOGIC_WALL:
#		return false
#	elif Global.LEVEL_LAYER_LOGIC.get_cell(x, y+1) == TILES.LOGIC_VOID:
#		return false
#	else:
#		return true

#func tilemap_set_wall(atlas_id:int,cell_id:int):
#	randomize()
#	var cell_array = self.get_used_cells_by_id(cell_id)
#	var tile_array = util_atlas_get_tiles(atlas_id,Global.LEVEL_LAYER_WALL)
#	for cell in cell_array:
#		var cell_data = tilemap_check_bottom_cell(cell.x,cell.y)
#		var cell_solid
#		var cell_solid_left
#		var cell_solid_right
#		if count == 0 && solid == false:
#			var tile = tile_array[randi() % tile_array.size()]
#			Global.LEVEL_LAYER_WALL.set_cell(cell.x,cell.y+1,atlas_id,false,false,false,tile)
#		elif count == 1 && solid == false:
#			pass
#		elif count == 2 && solid == false:
#			pass
#		else:
#			pass
#	pass

#func bsp_generator_clear_doors():
#	var doors_array = []
#	var cells_array = []
#
#	doors_array = get_used_cells_by_id(TILES.LOGIC_DOOR)
#	for door in doors_array:
#		cells_array = []
#		if get_cell(door.x, door.y-1)   == TILES.LOGIC_FLOOR:  cells_array.append(Vector2(door.x, door.y-1))
#		if get_cell(door.x, door.y+1)   == TILES.LOGIC_FLOOR:  cells_array.append(Vector2(door.x, door.y+1))
#		if get_cell(door.x-1, door.y)   == TILES.LOGIC_FLOOR:  cells_array.append(Vector2(door.x-1, door.y))
#		if get_cell(door.x+1, door.y)   == TILES.LOGIC_FLOOR:  cells_array.append(Vector2(door.x+1, door.y))
#		print(cells_array)
#		for i in cells_array.size():
#			var cell = cells_array[i]
#			var room = rooms_array[i]
#			if room.has(Vector2(cell.x, cell.y)): pass
#			pass
#		pass
#	pass
