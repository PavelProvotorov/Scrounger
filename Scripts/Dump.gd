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

#func fog_check(entity,x,y):
#	entity.NODE_RAYCAST.cast_to = Vector2(x,y)
#	entity.NODE_RAYCAST.force_raycast_update()
#	var collider = entity.NODE_RAYCAST.get_collider()
#
#	if entity.NODE_RAYCAST.is_colliding() == false:
#		print("FALSE")
#		print(collider)
#	elif entity.NODE_RAYCAST.is_colliding() == true:
#		print("TRUE")
#		print(collider.name)
#		pass
#	else:
#		pass
#	pass

#func fog_check(start:Vector2,cells:Array):
#	var cell_neighbors = [Vector2(0,-1),Vector2(0,1),Vector2(-1,0),Vector2(1,0),Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)]
#	var cells_to_check:Array = [start]
#	var cells_to_fill:Array = [start]
#	var cells_in_range:Array = cells
#	var cells_checked:Array = []
#
#	while cells_to_check.empty() == false:
#		var cell_current = cells_to_check.pop_back()
#		cells_checked.append(cell_current)
#		for n in cell_neighbors:
#			var cell_next = cell_current + n
#			if cells_checked.has(cell_next) == true: continue
#			if cells_checked.has(cell_next) == false:
#				if cells_in_range.has(cell_next) == false: continue
#				if cells_in_range.has(cell_next) == true:
#					if self.get_cell(cell_current.x,cell_current.y) == TILESET_LOGIC.TILE_FLOOR:
#						cells_to_check.append(cell_next)
#						if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_FLOOR: cells_to_fill.append(cell_next)
#						if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_WALL: cells_to_fill.append(cell_next)
#						if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_DOOR: cells_to_fill.append(cell_next)
						
#					if self.get_cell(cell_current.x,cell_current.y) == TILESET_LOGIC.TILE_WALL:
#						cells_to_check.append(cell_next)
#						if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_FLOOR: continue
#						if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_WALL: continue
#						if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_DOOR: continue
						
#					if self.get_cell(cell_current.x,cell_current.y) == TILESET_LOGIC.TILE_DOOR:
#						if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_FLOOR: continue
#						if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_WALL: continue
#						if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_DOOR: continue
					
					#TEST ZONE
#					if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_WALL:
#						var test1 = Vector2(cell_next.x+n.x, cell_next.y+n.y)
#						cells_checked.append(test1)
#						print(cell_current)
#						print(cell_next)
#						if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_FLOOR: continue
#						if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_WALL: continue
#						if self.get_cell(cell_next.x,cell_next.y) == TILESET_LOGIC.TILE_DOOR: continue
	
#	print("--------------------------- CELLS CHECKED")
#	print(cells_checked)
#	print("--------------------------- CELLS TO FILL")
#	print(cells_to_fill)
#	print("---------------------------")
	
#	return cells_to_fill

#func fog_check(point:Vector2,array:Array):
#	var cell = point
#	var cells_to_check = array
#	var cells_to_fill = []
#
#	var check = true
#
#	while check == true:
#		var tile = cells_to_check.pop_back()
#		if !room.has(tile):
#			room.append(tile)
#			self.set_cellv(tile, TILESET_LOGIC.TILE_EMPTY)
#
#			#CHECK ADJACENT CELLS
#			var a1 = Vector2(x, y-1)
#			var a2 = Vector2(x, y+1)
#			var a3 = Vector2(x-1, y)
#			var a4 = Vector2(x+1, y)
#			var a5 = Vector2(x+1, y+1)
#			var a6 = Vector2(x+1, y-1)
#			var a7 = Vector2(x-1, y+1)
#			var a8 = Vector2(x-1, y-1)
#
#			for dir in [north,south,east,west]:
#				if self.get_cellv(dir) == TILESET_LOGIC.TILE_FLOOR:
#					if !to_fill.has(dir) and !room.has(dir):
#						to_fill.append(dir)
#	rooms_array.append(room)
#	pass
	
#		#CHECK ADJACENT CELLS
#		if self.get_cell(x, y-1)   == TILESET_LOGIC.TILE_WALL:  count += 1
#		if self.get_cell(x, y+1)   == TILESET_LOGIC.TILE_WALL:  count += 1
#		if self.get_cell(x-1, y)   == TILESET_LOGIC.TILE_WALL:  count += 1
#		if self.get_cell(x+1, y)   == TILESET_LOGIC.TILE_WALL:  count += 1
#		if self.get_cell(x+1, y+1) == TILESET_LOGIC.TILE_WALL:  count += 1
#		if self.get_cell(x+1, y-1) == TILESET_LOGIC.TILE_WALL:  count += 1
#		if self.get_cell(x-1, y+1) == TILESET_LOGIC.TILE_WALL:  count += 1
#		if self.get_cell(x-1, y-1) == TILESET_LOGIC.TILE_WALL:  count += 1

#	cell_array = fog_check_cells(player_position,cell_array)
#	for cell in cell_array:
#		Global.LAYER_FOG.set_cell(cell.x, cell.y, TILESET_FOG.TILE_NONE)
#		pass

#func fog_check_cells(player_position:Vector2,cell_array:Array):
#	if player.NODE_RAYCAST.is_colliding():
#		var hit_collider = player.NODE_RAYCAST.get_collider()
#		tilemap = hit_collider
#		hit_pos = player.NODE_RAYCAST.get_collision_point()
#		tile_pos = tilemap.world_to_map(hit_pos)
#		print("------------------------")
#		print(tile_to_pixel_center(tile_pos.x,tile_pos.y))
#	pass

#func update_visuals():
#	fog_fill()
#	var player = Global.LEVEL_LAYER_LOGIC.get_node("Player")
#	var player_position = Global.LEVEL_LAYER_LOGIC.world_to_map(player.get_global_position())
#	var player_center = tile_to_pixel_center(player_position.x, player_position.y)
#	var space_state = get_world_2d().direct_space_state
#	for x in range(map_width):
#		for y in range(map_height):
#			player.NODE_RAYCAST.force_raycast_update()
#			if Global.LEVEL_LAYER_LOGIC.get_cell(x, y) == TILESET_LOGIC.TILE_FLOOR:
#				var x_dir = 1 if x < player_position.x else -1
#				var y_dir = 1 if y < player_position.y else -1
#				var test_point = tile_to_pixel_center(x, y) + Vector2(x_dir, y_dir) * tile_size / 2
#
#				var occlusion = space_state.intersect_ray(player_center, test_point)
#				if !occlusion || (occlusion.position - test_point).length() < 1:
#					Global.LAYER_FOG.set_cell(x, y, TILESET_FOG.TILE_NONE)

#func action_move_old(direction):
#	var cellA = NODE_MAIN.position
#	var cellB = NODE_MAIN.position + (direction * grid_size)
#	NODE_RAYCAST_COLLIDE.cast_to = (direction * grid_size)
#	NODE_RAYCAST_COLLIDE.force_raycast_update()
#
#	if NODE_RAYCAST_COLLIDE.is_colliding() == false:
#		if cellA - cellB == Vector2(-grid_size,0): animation_flip(false,false)
#		if cellA - cellB == Vector2(grid_size,0): animation_flip(true,false)
#		NODE_MAIN.action_move_tween(cellA,cellB)
#		$Sound.play()
#		yield(NODE_TWEEN,"tween_all_completed")
#		Global.LEVEL_LAYER_LOGIC.fog_update()
#		check_turn()
#
#	if NODE_RAYCAST_COLLIDE.is_colliding() == true:
#		var collider = NODE_RAYCAST_COLLIDE.get_collider()
#		print(collider)
#		if NODE_RAYCAST_COLLIDE.get_collider() == Global.LEVEL_LAYER_LOGIC:
#			var collider_cell = Vector2(cellB.x/8,cellB.y/8)
#			var collider_cell_id = Global.LEVEL_LAYER_LOGIC.get_cell(collider_cell.x,collider_cell.y)
#			if collider_cell_id == Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_WALL: pass
#			if collider_cell_id == Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_VOID: pass
#			if collider_cell_id == Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_DOOR:
#				Global.LEVEL_LAYER_LOGIC.set_cell(collider_cell.x,collider_cell.y,Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_FLOOR)
#				Global.LEVEL_LAYER_LOGIC.tilemap_texture_set_fixed(Global.LEVEL_LAYER_LOGIC.TILESET_BASE.TILE_DOOR_OPEN,collider_cell,0)
#				NODE_MAIN.action_move_tween(cellA,cellB)
#				$Sound.play()
#				yield(NODE_TWEEN,"tween_all_completed")
#				Global.LEVEL_LAYER_LOGIC.fog_update()
#				check_turn()
#		elif NODE_RAYCAST_COLLIDE.get_collider().is_in_group(Global.GROUPS.HOSTILE) == true:
#			if cellA - cellB == Vector2(-grid_size,0): animation_flip(false,false)
#			if cellA - cellB == Vector2(grid_size,0): animation_flip(true,false)
#			NODE_MAIN.z_index += 1
##			NODE_MAIN.animation_change(ANIMATIONS.MELEE_ATTACK,true,false)
#			NODE_MAIN.calculate_melee_damage(self,collider)
#			NODE_MAIN.action_attack_tween(cellA,cellB)
#			yield(NODE_TWEEN,"tween_all_completed")
##			NODE_MAIN.animation_change(ANIMATIONS.MELEE_IDLE,true,false)
#			NODE_MAIN.z_index -= 1
#			check_turn()
#		elif NODE_RAYCAST_COLLIDE.get_collider().is_in_group(Global.GROUPS.HOSTILE) == false: pass
#		else: 
#			pass
#	else:
#		return

#func util_create_tunnel(point1, point2, cave, tile_empty, tile_filled):
#	randomize()
#	var max_steps = 500
#	var steps = 0
#	var drunk_x = point2[0]
#	var drunk_y = point2[1]
#
#	while steps < max_steps and !cave.has(Vector2(drunk_x, drunk_y)):
#		steps += 1
#
#		# set initial dir weights
#		var n       = 1.0
#		var s       = 1.0
#		var e       = 1.0
#		var w       = 1.0
#		var weight  = 1
#
#		# weight the random walk against edges
#		if drunk_x < point1.x: # drunkard is left of point1
#			e += weight
#		elif drunk_x > point1.x: # drunkard is right of point1
#			w += weight
#		if drunk_y < point1.y: # drunkard is above point1
#			s += weight
#		elif drunk_y > point1.y: # drunkard is below point1
#			n += weight
#
#		# normalize probabilities so they form a range from 0 to 1
#		var total = n + s + e + w
#		n /= total
#		s /= total
#		e /= total
#		w /= total
#
#		var dx
#		var dy
#
#		# choose the direction
#		var choice = randf()
#
#		if 0 <= choice and choice < n:
#			dx = 0
#			dy = -1
#		elif n <= choice and choice < (n+s):
#			dx = 0
#			dy = 1
#		elif (n+s) <= choice and choice < (n+s+e):
#			dx = 1
#			dy = 0
#		else:
#			dx = -1
#			dy = 0
#
#		# ensure not to walk past edge of map
#		if (2 < drunk_x + dx and drunk_x + dx < map_width-2) and \
#			(2 < drunk_y + dy and drunk_y + dy < map_height-2):
#			drunk_x += dx
#			drunk_y += dy
#			if self.get_cell(drunk_x, drunk_y) == tile_filled:
#				self.set_cell(drunk_x, drunk_y, tile_empty)
#
#				# optional: make tunnel wider
#				self.set_cell(drunk_x+1, drunk_y, tile_empty)
#				self.set_cell(drunk_x+1, drunk_y+1, tile_empty)

#func tilemap_check_bottom_cell(x,y):
#	var cell_data = []
#	if get_cell(x, y)   == TILESET_LOGIC.TILE_WALL :  cell_data.append(true)
#	if get_cell(x, y)   == TILESET_LOGIC.TILE_VOID :  cell_data.append(true)
#	if get_cell(x-1, y) == TILESET_LOGIC.TILE_WALL :  cell_data.append(true)
#	if get_cell(x-1, y) == TILESET_LOGIC.TILE_VOID :  cell_data.append(true)
#	if get_cell(x+1, y) == TILESET_LOGIC.TILE_WALL :  cell_data.append(true)
#	if get_cell(x+1, y) == TILESET_LOGIC.TILE_VOID :  cell_data.append(true)
#	return cell_data

#	level_entrance = Global.LEVEL_LAYER_LOGIC.get_used_cells_by_id(Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_ENTRANCE)
#	level_mob_spawn("Grunt",level_entrance[0]+Vector2.UP)
#	level_item_spawn("Ammo",level_entrance[0]+Vector2.UP)
#	level_item_spawn("Ammo",level_entrance[0])
#	level_mob_spawn("Player",level_entrance[0])
#	level_mob_spawn("Player",Vector2(14,5))
#	level_mob_spawn("Grunt",Vector2(13,9))
#	level_mob_spawn("Grunt",Vector2(6,3))
#	level_mob_spawn("Grunt",Vector2(7,5))
#	level_mob_spawn("Grunt",Vector2(10,9))

#var hit_pos
#var vis_color = Color(.867, .91, .247, 0.1)

#func bsp_generator_add_middle_rooms(amount:int):
#	randomize()
#
#	var room:Array = rooms_array[rand_range(0,rooms_array.size())]
#	var cells_to_fill:Array = []
#	var count:int
#
#	for cell in room:
#		count = 0
#		count += util_check_nearby_tile_8(cell.x, cell.y, TILESET_LOGIC.TILE_WALL)
#		count += util_check_nearby_tile_8(cell.x, cell.y, TILESET_LOGIC.TILE_DOOR)
#		if count == 0: 
#			cells_to_fill.append(cell)
#	for i in cells_to_fill: 
#		set_cellv(i, TILESET_LOGIC.TILE_WALL)
#	pass

#func astar_remove_mob_cells():
#	tilemap_scan_node = Global.LEVEL_LAYER_LOGIC
#	for i in tilemap_scan_node.get_child_count():
#		var mobCell = tilemap_scan_node.get_child(i)
#		mobCell = (world_to_map(mobCell.get_global_position()))
#		tilemap_astar_cells.remove(tilemap_astar_cells.find(Vector2(mobCell.x,mobCell.y)))

#						moving_entity.connect("on_action_move_finished",self,"manager_mob_actions")
#						yield(moving_entity.on_action_move(),"on_action_move_finished")
#						moving_entity.connect("on_action_move_finished",Global.NODE_MAIN,"manager_mob_actions")

#	Global.NODE_MAIN.connect("on_action_move_finished",self,"on_action_move")

#func bsp_generator_add_coridors(amount:int):
#	randomize()
#
#	var cells_to_check = self.get_used_cells_by_id(TILESET_LOGIC.TILE_WALL)
#	var start_walls_array = []
#	var free_walls_array = []
#	var coridors_array = []
#	var count
#
#	for cell in cells_to_check:
#		count = 0
#		count += util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_WALL)
##		count += util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_VOID)
#		if count == 4: 
#			free_walls_array.append(cell)
#
#	for cell in cells_to_check:
#		count = 0
#		count += util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_FLOOR)
#		if count == 1:
#			start_walls_array.append(cell)
#			pass
#
#	for cell in free_walls_array:
#		self.set_cell(cell.x,cell.y,TILESET_LOGIC.TILE_EMPTY)
#		pass
#	for cell in start_walls_array:
#		self.set_cell(cell.x,cell.y,TILESET_LOGIC.TILE_EMPTY)
#		pass
#
#	for a in amount:
#		start_walls_array.shuffle()
#		var wall_a = start_walls_array[randi() % start_walls_array.size()]
#		start_walls_array.erase(wall_a)
#		var wall_b = start_walls_array[randi() % start_walls_array.size()]
#		start_walls_array.erase(wall_b)
#
#		astar_clear()
#		astar_get_cells(TILESET_LOGIC.TILE_EMPTY)
#		astar_add_points()
#		astar_connect_points()
#
#		var coridor_path = astar_get_path(wall_a,wall_b)
#		if coridor_path.size() > 2:
#			coridors_array.append(coridor_path)
#		if coridor_path.size() <= 2:
#			pass
#
#	print(coridors_array)
#	for c in coridors_array.size():
#		var coridor = coridors_array[c]
#		print(coridor)
#		for cell in coridor:
#			self.set_cell(cell.x,cell.y,TILESET_LOGIC.TILE_VOID)
#		pass
#
#	cells_to_check = self.get_used_cells_by_id(TILESET_LOGIC.TILE_EMPTY)
#	for cell in cells_to_check:
#		self.set_cell(cell.x,cell.y,TILESET_LOGIC.TILE_WALL)
#		pass

#	Global.NODE_MAIN.connect("on_action_move_finished",self,"on_action_move")

#func play_sound_death(entity,sound_name):
#	entity.NODE_SOUND_DEATH.stream = sound_name
#	entity.NODE_SOUND_DEATH.play()
#	pass

#	var object_cells = []
#	for room in rooms_array:
#		for cell in room:
#			var count = 0
#			count += util_check_nearby_tile_8(cell.x, cell.y, TILESET_LOGIC.TILE_BLOCK)
#			count += util_check_nearby_tile_8(cell.x, cell.y, TILESET_LOGIC.TILE_VOID)
#			count += util_check_nearby_tile_8(cell.x, cell.y, TILESET_LOGIC.TILE_DOOR)
#			if count < 5 && count > 1: 
#				rooms_array.erase(cell)
#				object_cells.append(cell)
#			if count != 0:
#				pass
#		pass

	#CHECK WALL FOR OBJECTS
#	cell_array = []
#	cells_to_fill = []
#	cell_array.append_array(self.get_used_cells_by_id(TILESET_LOGIC.TILE_OBJECT))
#	for cell in cell_array:
#		var cell_to_check = self.get_cellv(cell+Vector2.DOWN)
#		if cell_to_check == TILESET_LOGIC.TILE_FLOOR:
#			cells_to_fill.append(cell+Vector2.DOWN)
#			pass
#		pass
#	for cell in cells_to_fill:
#		var tile = tile_array[round(rand_range(7,9))]
#		print(tile)
#		Global.LEVEL_LAYER_WALL.set_cell(cell.x,cell.y,tile_base_id,false,false,false,tile)
#		pass
#	pass

#	var player_position_center = tile_to_pixel_center(player_position.x, player_position.y)
#func tile_to_pixel_center(x,y):
#	return Vector2((x+0.5)*grid_size,(y+0.5)*grid_size)

#func _load_json(resourceFolder:String,resourceType:String):
#	var jsonText
#	var jsonParse
#	var jsonFile = File.new()
#	var jsonFileFolder = resourceFolder
#	var jsonFileType = resourceType
#	var jsonPathTemp = "res://Resources/%s/%s.json"
#	var jsonPath = jsonPathTemp %[jsonFileFolder,jsonFileType]
#	print(jsonPath)
#
#	jsonFile.open(jsonPath, jsonFile.READ)
#	jsonText = jsonFile.get_as_text()
#	jsonParse = JSON.parse(jsonText)
#	if jsonParse.error == OK:
#		jsonText = jsonParse.result
#	elif jsonParse.error != OK:
#		push_error("Error: _load_json")
#		push_error("The error is: %s" %jsonParse.error)
#		push_error("The line is: %s" %jsonParse.error_line)
#		push_error("The string is: %s" %jsonParse.error_string)
#	else:
#		pass
#	return jsonText
#	pass

# -------------------- PLAYER

#func animation_flip(is_flip_h:bool, is_flip_v:bool):
#	NODE_ANIMATED_SPRITE.flip_h = is_flip_h
#	NODE_ANIMATED_SPRITE.flip_v = is_flip_v
#
#func animation_change(animation_type:String,is_playing:bool,is_random:bool):
#	NODE_ANIMATED_SPRITE.set_animation(animation_type)
#	NODE_ANIMATED_SPRITE.playing = is_playing
#	if is_random == true:
#		NODE_ANIMATED_SPRITE.set_frame(rand_range(0,NODE_ANIMATED_SPRITE.get_sprite_frames().get_frame_count(animation_type)))
#	if is_random == false:
#		pass
#
#func action_move_tween(start,finish):
#	NODE_TWEEN.interpolate_property(self,'position',start,finish,1.0/tween_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
#	NODE_TWEEN.start()
#	yield(NODE_TWEEN,"tween_completed")
#	NODE_TWEEN.emit_signal("tween_all_completed")
#
#func action_attack_tween(start,finish):
#	NODE_TWEEN.interpolate_property(self,"position",start,finish,0.5/tween_speed)
#	NODE_TWEEN.start()
#	yield(NODE_TWEEN,"tween_completed")
#	NODE_TWEEN.interpolate_property(self,"position",finish,start,1.0/tween_speed)
#	NODE_TWEEN.start()
#	yield(NODE_TWEEN,"tween_completed")
#	NODE_TWEEN.emit_signal("tween_all_completed")
#
#func action_shoot_tween(start,finish):
#	if start - finish == Vector2(0,-grid_size): finish = Vector2(finish.x,finish.y-(grid_size/2))
#	if start - finish == Vector2(grid_size,0):  finish = Vector2((grid_size/2)+finish.x,finish.y)
#	if start - finish == Vector2(-grid_size,0): finish = Vector2(finish.x-(grid_size/2),finish.y)
#	if start - finish == Vector2(0,grid_size):  finish = Vector2(finish.x,finish.y+(grid_size/2))
#
#	NODE_TWEEN.interpolate_property(self,"position",start,finish,0.5/tween_speed)
#	NODE_TWEEN.start()
#	yield(NODE_TWEEN,"tween_completed")
#	NODE_TWEEN.interpolate_property(self,"position",finish,start,1.0/tween_speed)
#	NODE_TWEEN.start()
#	yield(NODE_TWEEN,"tween_completed")
#	NODE_TWEEN.emit_signal("tween_all_completed")

#func on_action_pickup():
#	item_pickup_consumable()
#	yield(self.get_idle_frame(),"completed")
#
#func on_action_use():
#	if Data.EQUIPMENT[0].empty() == false:
#		Global.NODE_PLAYER.stat_ammo_bullet += count
#		Sound.play_sound(self,Sound.sfx_pickup)
#
#		# REMOVE FROM INVENTORY
#		item_inventory_remove()
#
#func on_action_tick():
#	pass
