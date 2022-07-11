extends Generator2D

# READY
#---------------------------------------------------------------------------------------
func _ready():
	randomize()
	pass

# ASTAR PATHFINDING
#---------------------------------------------------------------------------------------
func astar_prepare():
	astar_clear()
	astar_get_cells(TILESET_LOGIC.TILE_FLOOR)
	astar_get_cells(TILESET_LOGIC.TILE_DOOR)
	astar_get_cells(TILESET_LOGIC.TILE_ENTRANCE)
	astar_get_cells(TILESET_LOGIC.TILE_EXIT)
	pass

func astar_build():
	astar_add_points()
	astar_connect_points()
	pass

func astar_clear():
	tilemap_astar.clear()
	tilemap_astar_cells = []

func astar_get_cells(id):
	tilemap_astar_cells.append_array(Global.LEVEL_LAYER_LOGIC.get_used_cells_by_id(id))

# Remove hostile entities from astar
func astar_remove_hostile_cells(start_point,end_point):
	var size = Global.LEVEL_LAYER_LOGIC.get_child_count()
	var idx = 0
	while idx < size:
		var point = Global.LEVEL_LAYER_LOGIC.get_child(idx)
		if point.is_in_group(Global.GROUPS.HOSTILE) && point != start_point:
			if point != end_point:
				point = (world_to_map(point.get_global_position()))
				tilemap_astar_cells.remove(tilemap_astar_cells.find(Vector2(point.x,point.y)))
			elif point == end_point:
				pass
			else:
				pass
		elif point.is_in_group(Global.GROUPS.HOSTILE) && point == start_point:
			pass
		else:
			pass
		idx += 1

func astar_remove_mobs(mob_current):
	var mob_list = get_tree().get_nodes_in_group(Global.GROUPS.HOSTILE)
	for size in mob_list.size():
		var mob = mob_list[size]
		if mob != mob_current:
			var mob_position = (world_to_map(mob.get_global_position()))
			tilemap_astar_cells.remove(tilemap_astar_cells.find(Vector2(mob_position.x,mob_position.y)))
		elif mob == mob_current:
			pass
		else:
			pass

func astar_remove_extra_cells(extraPoint):
	tilemap_astar_cells.remove(tilemap_astar_cells.find(Vector2(extraPoint.x,extraPoint.y)))

# Applying unique IDs to empty cells
func astar_add_points():
	for cell in tilemap_astar_cells:
		tilemap_astar.add_point(uuid(cell),cell,1.0)

#Checking neighbour cells in order RIGHT, LEFT, DOWN, UP
func astar_connect_points():
	for cell in tilemap_astar_cells:
		var tilemapAdjacentCells = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)]
		for check in tilemapAdjacentCells:
			var nextCell = cell + check
			if tilemap_astar_cells.has(nextCell):
				tilemap_astar.connect_points(uuid(cell),uuid(nextCell),false)

#Building a path between two points
func astar_get_path(start,end):
#	var tilemap_astar_path:PoolVector2Array
#	var tilemap_astar_path:Array
	var tilemap_astar_path
	tilemap_astar_path = tilemap_astar.get_point_path(uuid(start),uuid(end))
	return tilemap_astar_path
	
# Pairing function for creating unique IDs based on the Vector2 x and y coordinates
func uuid(point:Vector2):
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b

# FOG OF WAR
#---------------------------------------------------------------------------------------
func fog_fill():
	for x in range(0, map_width):
		for y in range(0, map_height):
			Global.LEVEL_LAYER_FOG.set_cell(x, y, TILESET_FOG.TILE_FULL)
	pass

func fog_update():
	var cell_array:Array
	
	var player = Global.LEVEL_LAYER_LOGIC.get_node("Player")
	var player_position = Global.LEVEL_LAYER_LOGIC.world_to_map(player.get_global_position())
	
	var fog_range = player.stat_visibility
	var rect_start = Vector2(player_position.x - fog_range, player_position.y - fog_range)
	var rect_close = Vector2(player_position.x + fog_range, player_position.y + fog_range)
	var rect_width = ((rect_close.x - rect_start.x)+1)
	var rect_height = ((rect_close.y - rect_start.y)+1)
	var rect = Rect2(rect_start,rect_close)
	
	fog_fill()
	
	#FOG SPECIFIC CHECK
	cell_array = []
	for x in range(0, rect_width):
		for y in range(0, rect_height):
			var cell = Vector2((rect_start.x + x),(rect_start.y + y))
			cell_array.append(cell)
			
	for cell in cell_array:
		player.raycast_cast_to(player.NODE_RAYCAST_FOG,player_position,cell)
		if player.NODE_RAYCAST_FOG.is_colliding() == true:
			var raycast_collider = player.NODE_RAYCAST_FOG.get_collider()
			var raycast_collider_point = player.NODE_RAYCAST_FOG.get_collision_point()
			var raycast_collider_position = self.world_to_map(raycast_collider_point)
			if raycast_collider == Global.LEVEL_LAYER_LOGIC:
				Global.LEVEL_LAYER_FOG.set_cell(raycast_collider_position.x, raycast_collider_position.y, TILESET_FOG.TILE_NONE)
			elif raycast_collider.is_in_group(Global.GROUPS.HOSTILE):
#				raycast_collider.AI_state = Global.AI_STATE_LIST.STATE_ENGAGE
				player.NODE_RAYCAST_FOG.add_exception(raycast_collider)
				Global.LEVEL_LAYER_FOG.set_cell(cell.x, cell.y, TILESET_FOG.TILE_NONE)
			elif raycast_collider.is_in_group(Global.GROUPS.ITEM):
				player.NODE_RAYCAST_FOG.add_exception(raycast_collider)
				Global.LEVEL_LAYER_FOG.set_cell(cell.x, cell.y, TILESET_FOG.TILE_NONE)
#			elif raycast_collider.is_in_group(Global.GROUPS.OBJECT):
#				print("BUMP INTO OBJECT")
#				print(raycast_collider)
#				Global.LEVEL_LAYER_FOG.set_cell(cell.x, cell.y, TILESET_FOG.TILE_NONE)
		if player.NODE_RAYCAST_FOG.is_colliding() == false:
			Global.LEVEL_LAYER_FOG.set_cell(cell.x, cell.y, TILESET_FOG.TILE_NONE)
			
	#MOB SPECIFIC CHECK
	cell_array = []
	rect_start = Vector2(player_position.x - (fog_range+1), player_position.y - (fog_range+1))
	rect_close = Vector2(player_position.x + (fog_range+1), player_position.y + (fog_range+1))
	rect_width = ((rect_close.x - rect_start.x)+1)
	rect_height = ((rect_close.y - rect_start.y)+1)
	for x in range(0, rect_width):
		for y in range(0, rect_height):
			var cell = Vector2((rect_start.x + x),(rect_start.y + y))
			cell_array.append(cell)
			
	for cell in cell_array:
		player.raycast_cast_to(player.NODE_RAYCAST_MOB,player_position,cell)
		player.NODE_RAYCAST_MOB.force_raycast_update()
		if player.NODE_RAYCAST_MOB.is_colliding() == true:
			var raycast_collider = player.NODE_RAYCAST_MOB.get_collider()
			var raycast_collider_point = player.NODE_RAYCAST_MOB.get_collision_point()
			var raycast_collider_position = self.world_to_map(raycast_collider_point)
			if raycast_collider == Global.LEVEL_LAYER_LOGIC:
				pass
			elif raycast_collider.is_in_group(Global.GROUPS.ITEM):
				player.NODE_RAYCAST_MOB.add_exception(raycast_collider)
			elif raycast_collider.is_in_group(Global.GROUPS.HOSTILE):
				raycast_collider.AI_state = Global.AI_STATE_LIST.STATE_ENGAGE
				player.NODE_RAYCAST_MOB.add_exception(raycast_collider)
		if player.NODE_RAYCAST_MOB.is_colliding() == false:
			pass
	
	player.NODE_RAYCAST_MOB.clear_exceptions()
