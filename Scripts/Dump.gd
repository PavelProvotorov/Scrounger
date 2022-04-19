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
