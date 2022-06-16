extends TileMap

var tilemap_astar = AStar2D.new()
var tilemap_cells_radius:PoolVector2Array
var tilemap_astar_cells:Array
var tilemap_scan_node

var grid_size = 8
var map_width = 32
var map_height = 18
var min_width = 3
var stop_width = min_width * 2 + 1

var free_cells = []
var rooms_vents_array = []
var rooms_array = []
var level = []
var level_floor = 0

const DIRECTIONS = {
	UP = Vector2.UP,
	DOWN = Vector2.DOWN,
	LEFT = Vector2.LEFT,
	RIGHT = Vector2.RIGHT
}

enum TILESET_FOG {
	TILE_FULL = 0,
	TILE_HALF = 1,
	TILE_NONE = 2
}

enum TILESET_BASE {
	TILE_FLOOR       = 0,
	TILE_BLOCK        = 1,
	TILE_DOOR_CLOSED = 2,
	TILE_DOOR_OPEN   = 3,
	TILE_EXIT        = 4,
	TILE_ENTRANCE    = 5,
	TILE_VENT_CLOSED = 6,
	TILE_VENT_OPEN   = 7,
	TILE_WALL        = 8
}

enum TILESET_LOGIC {
	TILE_FLOOR       = 0,
	TILE_BLOCK       = 1,
	TILE_DOOR        = 2,
	TILE_VENT        = 3,
	TILE_EXIT        = 4,
	TILE_ENTRANCE    = 5,
	TILE_EMPTY       = 14,
	TILE_VOID        = 15
	}

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
	var player_position_center = tile_to_pixel_center(player_position.x, player_position.y)
	
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
	
func tile_to_pixel_center(x,y):
	return Vector2((x+0.5)*grid_size,(y+0.5)*grid_size)

# BSP GENERATOR
#---------------------------------------------------------------------------------------
func bsp_generator():
	randomize()
	
	# PREPARE TILEMAP
	bsp_generator_prepare()
	bsp_generator_fill()
	bsp_generator_add_border()
	bsp_generator_subdivide(1, 1, map_width - 2, map_height - 2)
	
	# REMOVE REDUNDANT TILES
	bsp_generator_clear_dead_doors()
	bsp_generator_clear_dead_walls()
	bsp_generator_clear_dead_doors()
	bsp_generator_clear_dead_walls()
	bsp_generator_get_rooms()
	
	# FILL ONEWAY ROOMS
	bsp_generator_fill_oneway_rooms()
	bsp_generator_clear_final()
	bsp_generator_get_rooms()
	
	# ADD MISC TO ROOMS
	bsp_generator_add_middle_rooms(round(rand_range(0,3)))
	bsp_generator_add_arks(round(rand_range(0,3)))
	bsp_generator_add_vents(round(rand_range(0,3)))
	bsp_generator_get_rooms()
	bsp_generator_add_passage()
	
	# ADD CONTENT TO ROOMS
	bsp_generator_add_mobs()
	bsp_generator_add_items()

	# SET TEXTURES FOR TILES
	tilemap_texture_set_random(TILESET_BASE.TILE_DOOR_CLOSED,TILESET_LOGIC.TILE_DOOR)
	tilemap_texture_set_random(TILESET_BASE.TILE_BLOCK ,TILESET_LOGIC.TILE_VOID)
	tilemap_texture_set_random(TILESET_BASE.TILE_FLOOR,TILESET_LOGIC.TILE_FLOOR)
	tilemap_texture_set_random(TILESET_BASE.TILE_BLOCK ,TILESET_LOGIC.TILE_BLOCK )
	tilemap_texture_set_random(TILESET_BASE.TILE_VENT_CLOSED,TILESET_LOGIC.TILE_VENT)
	tilemap_texture_set_random(TILESET_BASE.TILE_EXIT,TILESET_LOGIC.TILE_EXIT)
	tilemap_texture_set_random(TILESET_BASE.TILE_ENTRANCE,TILESET_LOGIC.TILE_ENTRANCE)
	tilemap_texture_set_walls(TILESET_BASE.TILE_WALL)
	
	# OTHER
	yield(self.get_idle_frame(),"completed")
	fog_update()

# BSP GENERATOR 
#---------------------------------------------------------------------------------------

func bsp_generator_prepare():
	level_floor += 1
	
	Global.LEVEL_LAYER_LOGIC.clear()
	Global.LEVEL_LAYER_BASE.clear()
	Global.LEVEL_LAYER_WALL.clear()
	Global.LEVEL_LAYER_FOG.clear()
	
	for child in Global.LEVEL_LAYER_LOGIC.get_children():
		if child.is_in_group(Global.GROUPS.HOSTILE):
			child.queue_free()
			Global.LEVEL_LAYER_LOGIC.remove_child(child)
		elif child.is_in_group(Global.GROUPS.ITEM):
			child.queue_free()
			Global.LEVEL_LAYER_LOGIC.remove_child(child)

func bsp_generator_fill():
	for x in range(0, map_width):
		for y in range(0, map_height):
			set_cell(x, y, TILESET_LOGIC.TILE_FLOOR)
	level = get_used_cells_by_id(TILESET_LOGIC.TILE_FLOOR)
	pass
	
func bsp_generator_add_border():
# Add WALL on inner border
	for y in range(map_height):
		set_cell(1, y, TILESET_LOGIC.TILE_BLOCK)
		set_cell(map_width-2, y, TILESET_LOGIC.TILE_BLOCK)
		for x in range(map_width):
			set_cell(x,1, TILESET_LOGIC.TILE_BLOCK)
			set_cell(x,map_height-2, TILESET_LOGIC.TILE_BLOCK)
# Add VOID on outer border
	for y in range(map_height):
		set_cell(0, y, TILESET_LOGIC.TILE_VOID)
		set_cell(map_width-1, y, TILESET_LOGIC.TILE_VOID)
		for x in range(map_width):
			set_cell(x,0, TILESET_LOGIC.TILE_VOID)
			set_cell(x,map_height-1, TILESET_LOGIC.TILE_VOID)
	pass

func bsp_generator_subdivide(x1, y1, x2, y2):
	randomize()
	var w = x2 - x1 + 1
	var h = y2 - y1 + 1
	if w >= h and w >= stop_width:
		bsp_generator_subdivide_width(x1, y1, x2, y2)
	elif h >= stop_width:
		bsp_generator_subdivide_height(x1, y1, x2, y2)

func bsp_generator_subdivide_width(x1, y1, x2, y2):
	randomize()
	var x = rand_range(x1 + min_width, x2 - min_width)

	for y in range(y1, y2 + 1):
		set_cell(x, y, TILESET_LOGIC.TILE_BLOCK)

	bsp_generator_subdivide(x1, y1, x - 1, y2)
	bsp_generator_subdivide(x + 1, y1, x2, y2)

#	DOORS BY Y
	var doory = rand_range(y1 + 1, y2 - 1)
	set_cell(x, doory, TILESET_LOGIC.TILE_DOOR)
	
#	# Account for walls placed deeper into recursion.
	set_cell(x-1, doory, TILESET_LOGIC.TILE_DOOR)
	set_cell(x+1, doory, TILESET_LOGIC.TILE_DOOR)

func bsp_generator_subdivide_height(x1, y1, x2, y2):
	randomize()
	var y = rand_range(y1 + min_width, y2 - min_width)

	for x in range(x1, x2 + 1):
		set_cell(x, y, TILESET_LOGIC.TILE_BLOCK)

	bsp_generator_subdivide(x1, y1, x2, y - 1)
	bsp_generator_subdivide(x1, y + 1, x2, y2)

#	DOORS BY X
	var doorx = rand_range(x1 + 1, x2 - 1)
	set_cell(doorx, y, TILESET_LOGIC.TILE_DOOR)
	# Account for walls placed deeper into recursion.
	set_cell(doorx, y-1, TILESET_LOGIC.TILE_DOOR)
	set_cell(doorx, y+1, TILESET_LOGIC.TILE_DOOR)

func bsp_generator_clear_dead_doors():
	var done = false
	while !done:
		done = true
		for cell in get_used_cells_by_id(TILESET_LOGIC.TILE_DOOR):
			if get_cellv(cell) != TILESET_LOGIC.TILE_DOOR: continue
			var count = util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_BLOCK)
			if count < 2:
				set_cellv(cell,TILESET_LOGIC.TILE_FLOOR)
				done = false
	pass

func bsp_generator_clear_dead_walls():
	var done = false
	while !done:
		done = true
		for cell in get_used_cells_by_id(TILESET_LOGIC.TILE_BLOCK):
			if get_cellv(cell) != TILESET_LOGIC.TILE_BLOCK: continue
			var count 
			count = util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_FLOOR)
			if count >= 3:
				set_cellv(cell, TILESET_LOGIC.TILE_FLOOR)
				done = false
	pass

func bsp_generator_clear_final():
	# CLEAR DEADENDS AFTER FILL
	var done = false
	while !done:
		done = true
		for cell in get_used_cells_by_id(TILESET_LOGIC.TILE_DOOR):
			if get_cellv(cell) != TILESET_LOGIC.TILE_DOOR: continue
			var wall_count = util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_BLOCK)
			if wall_count >= 3:
				set_cellv(cell, TILESET_LOGIC.TILE_BLOCK)
				done = false
	pass

func bsp_generator_get_rooms():
	rooms_array = []
	var empty_cells_array = []
	for x in range (0, map_width):
		for y in range (0, map_height):
			if self.get_cell(x, y) == TILESET_LOGIC.TILE_FLOOR:
				bsp_generator_flood_fill(x,y)
	bsp_generator_sort_room_vectors(rooms_array)
	empty_cells_array = self.get_used_cells_by_id(TILESET_LOGIC.TILE_EMPTY)
	for empty in empty_cells_array:
		set_cell(empty.x, empty.y, TILESET_LOGIC.TILE_FLOOR)

	pass

func bsp_generator_flood_fill(cell_x,cell_y):
	var empty_cells_array = []
	var room = []
	var to_fill = [Vector2(cell_x, cell_y)]
	while to_fill:
		var tile = to_fill.pop_back()
		if !room.has(tile):
			room.append(tile)
			self.set_cellv(tile, TILESET_LOGIC.TILE_EMPTY)
			#check adjacent cells
			var north = Vector2(tile.x, tile.y-1)
			var south = Vector2(tile.x, tile.y+1)
			var east  = Vector2(tile.x+1, tile.y)
			var west  = Vector2(tile.x-1, tile.y)
			#check adjacent cells
			for dir in [north,south,east,west]:
				if self.get_cellv(dir) == TILESET_LOGIC.TILE_FLOOR:
					if !to_fill.has(dir) and !room.has(dir):
						to_fill.append(dir)
	rooms_array.append(room)
	pass

func bsp_generator_fill_oneway_rooms():
	var rooms_oneway_array = []
	var room = []
	
	var door_count
	for i in rooms_array.size():
		door_count = 0
		room = rooms_array[i]
		for cell in room:
			var door = util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_DOOR)
			door_count = door_count + door
		if door_count == 1:
			rooms_oneway_array.append(room)

	for r in rooms_oneway_array.size():
		room = rooms_oneway_array[r]
		for cell in room:
			set_cell(cell.x, cell.y, TILESET_LOGIC.TILE_BLOCK)
			pass
	pass

func bsp_generator_add_middle_rooms(amount:int):
	randomize()
	
	var rooms_array_local = rooms_array
	var cells_to_fill:Array = []
	var room:Array = []
	var count:int
	
	if amount != 0:
		for i in amount:
			rooms_array_local.shuffle()
			room = rooms_array_local[rand_range(0,rooms_array_local.size())]
			rooms_array_local.erase(room)
			
			var cells_to_check = room
			for cell in cells_to_check:
				count = 0
				count += util_check_nearby_tile_8(cell.x, cell.y, TILESET_LOGIC.TILE_BLOCK)
				count += util_check_nearby_tile_8(cell.x, cell.y, TILESET_LOGIC.TILE_VOID)
				count += util_check_nearby_tile_8(cell.x, cell.y, TILESET_LOGIC.TILE_DOOR)
				if count == 0: 
					rooms_array.erase(cell)
					cells_to_fill.append(cell)
				if count != 0:
					pass
		for fill in cells_to_fill: 
			set_cellv(fill, TILESET_LOGIC.TILE_BLOCK)
		pass
	rooms_array.append(room)

func bsp_generator_add_arks(amount:int):
	randomize()

	var doors_array = self.get_used_cells_by_id(TILESET_LOGIC.TILE_DOOR)
	var count:int
	
	if amount != 0:
		for i in amount:
			doors_array.shuffle()
			var door = (doors_array[rand_range(0,doors_array.size())])
			doors_array.erase(door)
			var cells_to_fill:Array = []
			var cells_to_check:Array = [
				(door),
				(door + Vector2.UP*2),
				(door + Vector2.DOWN*2),
				(door + Vector2.LEFT*2),
				(door + Vector2.RIGHT*2)
			]

			for cell in cells_to_check:
				count = 0
				count += util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_BLOCK)
				count += util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_VOID)
				count += util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_DOOR)
				if count == 2: 
					cells_to_fill.append(cell)
			
				if cells_to_fill.size() >= 2:
					for fill in cells_to_fill: 
						set_cellv(fill, TILESET_LOGIC.TILE_FLOOR)
				else:
					pass

func bsp_generator_add_passage():
	var tile:Vector2
	var room:Array
	
	#ADD ENTRANCE
	room = (rooms_array[rand_range(0,rooms_array.size())])
	room.shuffle()

	for cell in room:
		var count = util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_DOOR)
		if count == 0:
			rooms_array.erase(room)
			self.set_cell(cell.x,cell.y,TILESET_LOGIC.TILE_ENTRANCE)
			break
			
	#ADD EXIT
	room = (rooms_array[rand_range(0,rooms_array.size())])
	room.shuffle()
	
	for cell in room:
		var count = util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_DOOR)
		if count == 0:
			room.erase(cell)
			self.set_cell(cell.x,cell.y,TILESET_LOGIC.TILE_EXIT)
			break
	
	#ADD PLAYER
	var level_entrance = get_used_cells_by_id(TILESET_LOGIC.TILE_ENTRANCE)
	
	if Global.NODE_PLAYER == null:
		Global.NODE_MAIN.level_mob_spawn("Player",level_entrance[0])
		Global.NODE_PLAYER = self.get_child(0)
	elif Global.NODE_PLAYER != null:
		Global.NODE_PLAYER.position = Vector2(level_entrance[0].x*grid_size,level_entrance[0].y*grid_size)
		pass
		
	Global.NODE_MAIN.target_entity = Global.NODE_PLAYER

func bsp_generator_add_vents(amount:int):
	var cells_to_check = self.get_used_cells_by_id(TILESET_LOGIC.TILE_BLOCK)
	var walls_array = []
	for cell in cells_to_check:
		if get_cellv(cell) != TILESET_LOGIC.TILE_BLOCK: continue
		var count = util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_FLOOR)
		if count == 1: walls_array.append(cell)
	for i in range (0,amount):
		var tile = walls_array[randi() % walls_array.size()]
		self.set_cell(tile.x,tile.y,TILESET_LOGIC.TILE_VENT)
		walls_array.erase(tile)

func bsp_generator_add_mobs():
	var mob_list = Data.MOB_LIST[level_floor].keys()
	
	free_cells = []
	for room in rooms_array:
		for cell in room:
			free_cells.append(cell)
		pass
	
	var mob_count  = (round(free_cells.size()/(rand_range(5,8))))
	
	for mob in mob_count:
		randomize()
		var cell = free_cells[randi() % free_cells.size()]
		var mob_type = mob_list[randi() % mob_list.size()]
		var mob_chance = Data.MOB_LIST[level_floor][mob_type]
		var spawn_chance = util_chance(mob_chance)
		if spawn_chance == true:
			Global.NODE_MAIN.level_mob_spawn(mob_type,cell)
			free_cells.erase(cell)
		if spawn_chance == false:
			Global.NODE_MAIN.level_mob_spawn(mob_list[0],cell)
			free_cells.erase(cell)
	pass

func bsp_generator_add_items():
	var item_list = Data.ITEM_LIST[level_floor].keys()
	var item_count  = (round(free_cells.size()/(rand_range(18,20))))

	for item in item_count:
		randomize()
		var cell = free_cells[randi() % free_cells.size()]
		var item_type = item_list[randi() % item_list.size()]
		var item_chance = Data.ITEM_LIST[level_floor][item_type]
		var spawn_chance = util_chance(item_chance)
		if spawn_chance == true:
			Global.NODE_MAIN.level_item_spawn(item_type,cell)
			free_cells.erase(cell)
		if spawn_chance == false:
			pass
	pass

func bsp_generator_sort_room_vectors(rooms:Array):
	for room in rooms:
		room.sort()
	return rooms_array

# TEXTURES TO TILES
#---------------------------------------------------------------------------------------
func tilemap_texture_set_walls(tile_base_id:int):
	randomize()
	var cell_array:Array
	var cells_to_fill:Array = []
	var tile_array = util_atlas_get_tiles(tile_base_id,Global.LEVEL_LAYER_BASE)
	cell_array.append_array(self.get_used_cells_by_id(TILESET_LOGIC.TILE_BLOCK))
	cell_array.append_array(self.get_used_cells_by_id(TILESET_LOGIC.TILE_VOID))
	cell_array.append_array(self.get_used_cells_by_id(TILESET_LOGIC.TILE_VENT))
	print(cell_array)
	
	#CHECK WALL FOR BLOCKS
	for cell in cell_array:
		var cell_to_check = self.get_cellv(cell+Vector2.DOWN)
		if cell_to_check == TILESET_LOGIC.TILE_FLOOR:
			cells_to_fill.append(cell+Vector2.DOWN)
			pass
		pass
	for cell in cells_to_fill:
		var tile = tile_array[randi() % (tile_array.size()-2)]
		Global.LEVEL_LAYER_WALL.set_cell(cell.x,cell.y,tile_base_id,false,false,false,tile)
		pass
	pass
	
	#CHECK WALL FOR DOORS
	cell_array = []
	cells_to_fill = []
	cell_array.append_array(self.get_used_cells_by_id(TILESET_LOGIC.TILE_DOOR))
	for cell in cell_array:
		var cell_to_check = self.get_cellv(cell+Vector2.DOWN)
		if cell_to_check == TILESET_LOGIC.TILE_FLOOR:
			cells_to_fill.append(cell+Vector2.DOWN)
			pass
		pass
	for cell in cells_to_fill:
		var tile = tile_array[6]
		Global.LEVEL_LAYER_WALL.set_cell(cell.x,cell.y,tile_base_id,false,false,false,tile)
		pass
	pass

func tilemap_texture_set_random(tile_base_id:int,tile_logic_id:int):
	randomize()
	var cell_array = self.get_used_cells_by_id(tile_logic_id)
	var tile_array = util_atlas_get_tiles(tile_base_id,Global.LEVEL_LAYER_BASE)
	for cell in cell_array:
		var tile = tile_array[randi() % tile_array.size()]
		Global.LEVEL_LAYER_BASE.set_cell(cell.x,cell.y,tile_base_id,false,false,false,tile)
		pass
	pass

func tilemap_texture_set_fixed(layer,tile_base_id:int,tile_position:Vector2,id:int):
	randomize()
	var tile_array = util_atlas_get_tiles(tile_base_id,Global.LEVEL_LAYER_BASE)
	var tile = tile_array[id]
	layer.set_cell(tile_position.x,tile_position.y,tile_base_id,false,false,false,tile)

# UTILITY FUNCTIONS
#---------------------------------------------------------------------------------------
func get_idle_frame():
	yield(get_tree(),"idle_frame")

func sort_room_vectors_custom(vector_a,vector_b):
	if vector_a[0] > vector_b[0]:
		return true
	return false

func util_get_rect(rect_range:int,object_pos):
	var rect_start = Vector2(object_pos.x - rect_range, object_pos.y - rect_range)
	var rect_close = Vector2(object_pos.x + rect_range, object_pos.y + rect_range)
	var rect_width = ((rect_close.x - rect_start.x)+1)
	var rect_height = ((rect_close.y - rect_start.y)+1)
	var rect = Vector2(rect_width,rect_height)
#	var rect = Rect2(rect_start,rect_close)
	return rect

func util_clear_deadends():
	var done = false

	while !done:
		done = true

		for cell in get_used_cells():
			if get_cellv(cell) != TILESET_LOGIC.TILE_FLOOR: continue

			var wall_count = util_check_nearby_tile_4(cell.x, cell.y, TILESET_LOGIC.TILE_BLOCK)
			if wall_count == 3:
				set_cellv(cell, TILESET_LOGIC.TILE_BLOCK)
				done = false
	pass

func util_atlas_get_tiles(id,layer):
	var tileset = layer.tile_set
	var atlas = tileset.tile_get_region(id)
	var atlas_size_x = atlas.size.x / tileset.autotile_get_size(id).x
	var atlas_size_y = atlas.size.y / tileset.autotile_get_size(id).y
	var atlas_tile_array = []
	for x in range(atlas_size_x):
		for y in range(atlas_size_y):
			var priority = tileset.autotile_get_subtile_priority(id,Vector2(x,y))
			for p in priority:
				atlas_tile_array.append(Vector2(x,y))
	return atlas_tile_array

func util_chance(percentage):
	randomize()
	if randi() % 100 <= percentage:  
		return true
	else:                     
		return false

func util_choose(choices):
	randomize()
	var rand_index = randi() % choices.size()
	return choices[rand_index]

func util_randi_range(low, high):
	return floor(rand_range(low, high))

func util_check_nearby_tile_4(x, y, tile_id):
	var count = 0
	if get_cell(x, y-1)   == tile_id:  count += 1
	if get_cell(x, y+1)   == tile_id:  count += 1
	if get_cell(x-1, y)   == tile_id:  count += 1
	if get_cell(x+1, y)   == tile_id:  count += 1
	return count

func util_check_nearby_tile_8(x, y, TILE):
	var count = 0
	if self.get_cell(x, y-1)   == TILE:  count += 1
	if self.get_cell(x, y+1)   == TILE:  count += 1
	if self.get_cell(x-1, y)   == TILE:  count += 1
	if self.get_cell(x+1, y)   == TILE:  count += 1
	if self.get_cell(x+1, y+1) == TILE:  count += 1
	if self.get_cell(x+1, y-1) == TILE:  count += 1
	if self.get_cell(x-1, y+1) == TILE:  count += 1
	if self.get_cell(x-1, y-1) == TILE:  count += 1
	return count
