extends TileMap

var tilemap_astar = AStar2D.new()
var tilemap_cells_radius:PoolVector2Array
var tilemap_astar_cells:Array
var tilemap_scan_node

var map_width = 32
var map_height = 18
var min_width = 3
var stop_width = min_width * 2 + 1

var rooms_array = []
var level = []

const DIRECTIONS = {
	UP = Vector2.UP,
	DOWN = Vector2.DOWN,
	LEFT = Vector2.LEFT,
	RIGHT = Vector2.RIGHT
	}

enum TILES {
	LOGIC_FLOOR = 0,
	LOGIC_WALL = 1,
	LOGIC_DOOR = 2,
	LOGIC_EMPTY = 14,
	LOGIC_VOID = 15
	}

enum TEXTURES {
	ATLAS_WALL  = 0,
	ATLAS_FLOOR = 1,
	ATLAS_DOOR = 2
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
	astar_get_cells(TILES.LOGIC_FLOOR)
	astar_get_cells(TILES.LOGIC_DOOR)
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

func astar_remove_mob_cells():
	tilemap_scan_node = Global.LEVEL_LAYER_LOGIC
	for i in tilemap_scan_node.get_child_count():
		var mobCell = tilemap_scan_node.get_child(i)
		mobCell = (world_to_map(mobCell.get_global_position()))
		tilemap_astar_cells.remove(tilemap_astar_cells.find(Vector2(mobCell.x,mobCell.y)))

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
	var tilemap_astar_path:Array
	tilemap_astar_path = tilemap_astar.get_point_path(uuid(start),uuid(end))
	return tilemap_astar_path
	
# Pairing function for creating unique IDs based on the Vector2 x and y coordinates
func uuid(point):
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b

# BSP GENERATOR
#---------------------------------------------------------------------------------------
func bsp_generator():
	randomize()
	
	# PREPARE TILEMAP
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
	bsp_generator_get_rooms()
	
	# FILL MIDDLE ROOMS
	bsp_generator_fill_middle_rooms()
	bsp_generator_get_rooms()

	# SET TEXTURES FOR TILES
#	tilemap_texture_set_fixed(TEXTURES.ATLAS_DOOR,TILES.LOGIC_DOOR,0)
#	tilemap_texture_set_random(TEXTURES.ATLAS_WALL,TILES.LOGIC_VOID)
#	tilemap_texture_set_random(TEXTURES.ATLAS_FLOOR,TILES.LOGIC_FLOOR)
#	tilemap_texture_set_random(TEXTURES.ATLAS_WALL,TILES.LOGIC_WALL)
#	Global.LEVEL_LAYER_BASE.update_bitmask_region()

#LOGIC_TILES.TILE_EMPTY = Global.LEVEL_LAYER_LOGIC.get_tileset().find_tile_by_name("TILE_EMPTY")

func bsp_generator_fill():
	for x in range(0, map_width):
		for y in range(0, map_height):
			set_cell(x, y, TILES.LOGIC_FLOOR)
	level = get_used_cells_by_id(TILES.LOGIC_FLOOR)
	pass
	
func bsp_generator_add_border():
# Add WALL on inner border
	for y in range(map_height):
		set_cell(1, y, TILES.LOGIC_WALL)
		set_cell(map_width-2, y, TILES.LOGIC_WALL)
		for x in range(map_width):
			set_cell(x,1, TILES.LOGIC_WALL)
			set_cell(x,map_height-2, TILES.LOGIC_WALL)
# Add VOID on outer border
	for y in range(map_height):
		set_cell(0, y, TILES.LOGIC_VOID)
		set_cell(map_width-1, y, TILES.LOGIC_VOID)
		for x in range(map_width):
			set_cell(x,0, TILES.LOGIC_VOID)
			set_cell(x,map_height-1, TILES.LOGIC_VOID)
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
		set_cell(x, y, TILES.LOGIC_WALL)

	bsp_generator_subdivide(x1, y1, x - 1, y2)
	bsp_generator_subdivide(x + 1, y1, x2, y2)

#	DOORS BY Y
	var doory = rand_range(y1 + 1, y2 - 1)
	set_cell(x, doory, TILES.LOGIC_DOOR)
	
#	# Account for walls placed deeper into recursion.
	set_cell(x-1, doory, TILES.LOGIC_DOOR)
	set_cell(x+1, doory, TILES.LOGIC_DOOR)

func bsp_generator_subdivide_height(x1, y1, x2, y2):
	randomize()
	var y = rand_range(y1 + min_width, y2 - min_width)

	for x in range(x1, x2 + 1):
		set_cell(x, y, TILES.LOGIC_WALL)

	bsp_generator_subdivide(x1, y1, x2, y - 1)
	bsp_generator_subdivide(x1, y + 1, x2, y2)

#	DOORS BY X
	var doorx = rand_range(x1 + 1, x2 - 1)
	set_cell(doorx, y, TILES.LOGIC_DOOR)
	# Account for walls placed deeper into recursion.
	set_cell(doorx, y-1, TILES.LOGIC_DOOR)
	set_cell(doorx, y+1, TILES.LOGIC_DOOR)

func bsp_generator_clear_dead_doors():
	var done = false
	while !done:
		done = true
		for cell in get_used_cells_by_id(TILES.LOGIC_DOOR):
			if get_cellv(cell) != TILES.LOGIC_DOOR: continue
			var count = util_check_nearby_tile_4(cell.x, cell.y, TILES.LOGIC_WALL)
			if count < 2:
				set_cellv(cell,TILES.LOGIC_FLOOR)
				done = false
	pass

func bsp_generator_clear_dead_walls():
	var done = false
	while !done:
		done = true
		for cell in get_used_cells_by_id(TILES.LOGIC_WALL):
			if get_cellv(cell) != TILES.LOGIC_WALL: continue
			var count 
			count = util_check_nearby_tile_4(cell.x, cell.y, TILES.LOGIC_FLOOR)
			if count >= 3:
				set_cellv(cell, TILES.LOGIC_FLOOR)
				done = false
	pass

func bsp_generator_get_rooms():
	rooms_array = []
	var empty_cells_array = []
	for x in range (0, map_width):
		for y in range (0, map_height):
			if self.get_cell(x, y) == TILES.LOGIC_FLOOR:
				bsp_generator_flood_fill(x,y)
	bsp_generator_sort_room_vectors(rooms_array)
	empty_cells_array = self.get_used_cells_by_id(TILES.LOGIC_EMPTY)
	for empty in empty_cells_array:
		set_cell(empty.x, empty.y, TILES.LOGIC_FLOOR)
	pass

func bsp_generator_flood_fill(cell_x,cell_y):
	var empty_cells_array = []
	var room = []
	var to_fill = [Vector2(cell_x, cell_y)]
	while to_fill:
		var tile = to_fill.pop_back()
		if !room.has(tile):
			room.append(tile)
			self.set_cellv(tile, TILES.LOGIC_EMPTY)
			#check adjacent cells
			var north = Vector2(tile.x, tile.y-1)
			var south = Vector2(tile.x, tile.y+1)
			var east  = Vector2(tile.x+1, tile.y)
			var west  = Vector2(tile.x-1, tile.y)
			#check adjacent cells
			for dir in [north,south,east,west]:
				if self.get_cellv(dir) == TILES.LOGIC_FLOOR:
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
			var door = util_check_nearby_tile_4(cell.x, cell.y, TILES.LOGIC_DOOR)
			door_count = door_count + door
		if door_count == 1:
			rooms_oneway_array.append(room)

	for r in rooms_oneway_array.size():
		room = rooms_oneway_array[r]
		for cell in room:
			set_cell(cell.x, cell.y, TILES.LOGIC_WALL)
			pass
	pass

func bsp_generator_fill_middle_rooms():
	var room:Array = rooms_array[rand_range(0,rooms_array.size())]
	var cells_to_fill:Array = []
	var count:int
	
	print("GOT ROOM")
	print(room)
	
	for cell in room:
		count = 0
		count += util_check_nearby_tile_8(cell.x, cell.y, TILES.LOGIC_WALL)
		count += util_check_nearby_tile_8(cell.x, cell.y, TILES.LOGIC_DOOR)
		if count == 0: 
			cells_to_fill.append(cell)
	for i in cells_to_fill: 
		set_cellv(i, TILES.LOGIC_WALL)
	pass
	
	# CLEAR DEADENDS AFTER FILL
	var done = false
	while !done:
		done = true
		for cell in get_used_cells_by_id(TILES.LOGIC_DOOR):
			if get_cellv(cell) != TILES.LOGIC_DOOR: continue
			var wall_count = util_check_nearby_tile_4(cell.x, cell.y, TILES.LOGIC_WALL)
			if wall_count >= 3:
				set_cellv(cell, TILES.LOGIC_WALL)
				done = false
	pass

func bsp_generator_sort_room_vectors(rooms:Array):
	for room in rooms:
		room.sort()
	return rooms_array



# TEXTURES TO TILES
#---------------------------------------------------------------------------------------
func tilemap_texture_set_random(atlas_id:int,cell_id:int):
	randomize()
	var cell_array = self.get_used_cells_by_id(cell_id)
	var tile_array = util_atlas_get_tiles(atlas_id,Global.LEVEL_LAYER_BASE)
	for cell in cell_array:
		var tile = tile_array[randi() % tile_array.size()]
		Global.LEVEL_LAYER_BASE.set_cell(cell.x,cell.y,atlas_id,false,false,false,tile)
		pass
	pass

func tilemap_texture_set_fixed(atlas_id,cell_id,tile_id):
	randomize()
	var cell_array = self.get_used_cells_by_id(cell_id)
	var tile_array = util_atlas_get_tiles(atlas_id,Global.LEVEL_LAYER_BASE)
	for cell in cell_array:
		var tile = tile_array[tile_id]
		Global.LEVEL_LAYER_BASE.set_cell(cell.x,cell.y,atlas_id,false,false,false,tile)
		pass
	pass

func tilemap_check_bottom_cell(x,y):
	var cell_data = []
	if get_cell(x, y)   == TILES.LOGIC_WALL :  cell_data.append(true)
	if get_cell(x, y)   == TILES.LOGIC_VOID :  cell_data.append(true)
	if get_cell(x-1, y) == TILES.LOGIC_WALL :  cell_data.append(true)
	if get_cell(x-1, y) == TILES.LOGIC_VOID :  cell_data.append(true)
	if get_cell(x+1, y) == TILES.LOGIC_WALL :  cell_data.append(true)
	if get_cell(x+1, y) == TILES.LOGIC_VOID :  cell_data.append(true)
	return cell_data

# UTILITY FUNCTIONS
#---------------------------------------------------------------------------------------
func sort_room_vectors_custom(vector_a,vector_b):
	if vector_a[0] > vector_b[0]:
		return true
	return false

func util_clear_deadends():
	var done = false

	while !done:
		done = true

		for cell in get_used_cells():
			if get_cellv(cell) != TILES.LOGIC_FLOOR: continue

			var wall_count = util_check_nearby_tile_4(cell.x, cell.y, TILES.LOGIC_WALL)
			if wall_count == 3:
				set_cellv(cell, TILES.LOGIC_WALL)
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

func util_create_tunnel(point1, point2, cave, tile_empty, tile_filled):
	randomize()
	var max_steps = 500
	var steps = 0
	var drunk_x = point2[0]
	var drunk_y = point2[1]

	while steps < max_steps and !cave.has(Vector2(drunk_x, drunk_y)):
		steps += 1

		# set initial dir weights
		var n       = 1.0
		var s       = 1.0
		var e       = 1.0
		var w       = 1.0
		var weight  = 1

		# weight the random walk against edges
		if drunk_x < point1.x: # drunkard is left of point1
			e += weight
		elif drunk_x > point1.x: # drunkard is right of point1
			w += weight
		if drunk_y < point1.y: # drunkard is above point1
			s += weight
		elif drunk_y > point1.y: # drunkard is below point1
			n += weight

		# normalize probabilities so they form a range from 0 to 1
		var total = n + s + e + w
		n /= total
		s /= total
		e /= total
		w /= total

		var dx
		var dy

		# choose the direction
		var choice = randf()

		if 0 <= choice and choice < n:
			dx = 0
			dy = -1
		elif n <= choice and choice < (n+s):
			dx = 0
			dy = 1
		elif (n+s) <= choice and choice < (n+s+e):
			dx = 1
			dy = 0
		else:
			dx = -1
			dy = 0

		# ensure not to walk past edge of map
		if (2 < drunk_x + dx and drunk_x + dx < map_width-2) and \
			(2 < drunk_y + dy and drunk_y + dy < map_height-2):
			drunk_x += dx
			drunk_y += dy
			if self.get_cell(drunk_x, drunk_y) == tile_filled:
				self.set_cell(drunk_x, drunk_y, tile_empty)

				# optional: make tunnel wider
				self.set_cell(drunk_x+1, drunk_y, tile_empty)
				self.set_cell(drunk_x+1, drunk_y+1, tile_empty)
