extends Node2D

onready var nodeDeco = $Deco
onready var nodeWall = $Wall
onready var nodeBase = $Base
onready var nodeLogic = $Logic

var iterations:int = 1000
var min_cave_size:int = 10
var empty_chance:int = 48
var neighbors:int = 4
#var map_w:int = 40
#var map_h:int = 22
#var map_w:int = 80
#var map_h:int = 45
#var map_w:int = 30
#var map_h:int = 17
var map_w:int = 32
var map_h:int = 18
var cell_array = []
var caves_array = []

enum TILES {
	LOGIC_FLOOR = 0,
	LOGIC_WALL = 1,
	LOGIC_WATER = 2,
	LOGIC_EMPTY = 14,
	LOGIC_VOID = 15
	}
enum ATLAS {
	NORMAL_BLOCK = 0,
	NORMAL_WALL  = 1,
	NORMAL_FLOOR = 2
}

func _ready():
	randomize()
	generation_caves()
	cell_array = nodeLogic.get_used_cells_by_id(TILES.LOGIC_VOID)
	tilemap_set_cell_tile(ATLAS.NORMAL_BLOCK,cell_array)
	cell_array = nodeLogic.get_used_cells_by_id(TILES.LOGIC_EMPTY)
	tilemap_set_cell_tile(ATLAS.NORMAL_FLOOR,cell_array)
#	cell_array = nodeLogic.get_used_cells_by_id(TILES.LOGIC_VOID)
#	tilemap_set_wall(ATLAS.NORMAL_WALL,cell_array)
	nodeBase.update_bitmask_region()
	pass

#-----------------------------# Сaves Generation
func generation_caves():
	nodeLogic.clear()
	nodeBase.clear()
	nodeWall.clear()
	nodeDeco.clear()
	generation_caves_fill()
	generation_caves_random_empty()
	generation_caves_digger()
	generation_caves_get_caves()
	generation_caves_connect_caves()
	pass

func generation_caves_fill():
	for x in range(0, map_w):
		for y in range(0, map_h):
			nodeLogic.set_cell(x, y, TILES.LOGIC_VOID)
	pass

func generation_caves_random_empty():
		for x in range(1, map_w-1):
			for y in range(1, map_h-1):
				if util_chance(empty_chance):
					nodeLogic.set_cell(x, y, TILES.LOGIC_EMPTY)

func generation_caves_digger():
	randomize()
	for i in range(iterations):
		var x = floor(rand_range(1, map_w-1))
		var y = floor(rand_range(1, map_h-1))
		if util_check_nearby_tile(x,y,TILES.LOGIC_VOID) > neighbors:
			nodeLogic.set_cell(x, y, TILES.LOGIC_VOID)
		elif util_check_nearby_tile(x,y,TILES.LOGIC_VOID) < neighbors:
			nodeLogic.set_cell(x, y, TILES.LOGIC_EMPTY)
	pass

func generation_caves_get_caves():
	caves_array = []
	for x in range (0, map_w):
		for y in range (0, map_h):
			if nodeLogic.get_cell(x, y) == TILES.LOGIC_EMPTY:
				util_flood_fill(x,y)
	for cave in caves_array:
		for tile in cave:
			nodeLogic.set_cellv(tile, TILES.LOGIC_EMPTY)
	pass

func generation_caves_connect_caves():
	var prev_cave = null
	var tunnel_caves = caves_array.duplicate()

	for cave in tunnel_caves:
		if prev_cave:
			var new_point  = util_choose(cave)
			var prev_point = util_choose(prev_cave)

			# ensure not the same point
			if new_point != prev_point:
				util_create_tunnel(new_point, prev_point, cave, TILES.LOGIC_EMPTY, TILES.LOGIC_VOID)

		prev_cave = cave
	pass

#-----------------------------# Base Layer Functions
func tilemap_set_cell_tile(atlasID:int,cellList:Array):
	randomize()
	var cell_to_fill_array = cellList
	var tile_array = util_atlas_get_tiles(atlasID,nodeBase)
	for cell in cell_to_fill_array:
		var tile = tile_array[randi() % tile_array.size()]
		nodeBase.set_cell(cell.x,cell.y,atlasID,false,false,false,tile)
		pass
	pass

#-----------------------------# Wall Layer Functions
func tilemap_set_wall(atlasID:int,cellList:Array):
	randomize()
	var cell_to_check_array = cellList
	var tile_array = util_atlas_get_tiles(atlasID,nodeWall)
	for cell in cell_to_check_array:
		if tilemap_check_bottom_cell(cell.x,cell.y) == true:
			var tile = tile_array[randi() % tile_array.size()]
			nodeWall.set_cell(cell.x,cell.y+1,atlasID,false,false,false,tile)
		else:
			pass
	pass

func tilemap_check_bottom_cell(x,y):
	if nodeLogic.get_cell(x, y+1) != TILES.LOGIC_VOID:
		return true
	else:
		return false

#-----------------------------# Utility Functions
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

func util_check_nearby_tile(x, y, TILE):
	var count = 0
	if nodeLogic.get_cell(x, y-1)   == TILE:  count += 1
	if nodeLogic.get_cell(x, y+1)   == TILE:  count += 1
	if nodeLogic.get_cell(x-1, y)   == TILE:  count += 1
	if nodeLogic.get_cell(x+1, y)   == TILE:  count += 1
	if nodeLogic.get_cell(x+1, y+1) == TILE:  count += 1
	if nodeLogic.get_cell(x+1, y-1) == TILE:  count += 1
	if nodeLogic.get_cell(x-1, y+1) == TILE:  count += 1
	if nodeLogic.get_cell(x-1, y-1) == TILE:  count += 1
	return count

func util_flood_fill(tilex,tiley):
	var cave = []
	var to_fill = [Vector2(tilex, tiley)]
	while to_fill:
		var tile = to_fill.pop_back()
		if !cave.has(tile):
			cave.append(tile)
			nodeLogic.set_cellv(tile, TILES.LOGIC_VOID)
			#check adjacent cells
			var north = Vector2(tile.x, tile.y-1)
			var south = Vector2(tile.x, tile.y+1)
			var east  = Vector2(tile.x+1, tile.y)
			var west  = Vector2(tile.x-1, tile.y)
			#check adjacent cells
			for dir in [north,south,east,west]:
				if nodeLogic.get_cellv(dir) == TILES.LOGIC_EMPTY:
					if !to_fill.has(dir) and !cave.has(dir):
						to_fill.append(dir)
	if cave.size() >= min_cave_size:
		caves_array.append(cave)
	pass

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
		if (2 < drunk_x + dx and drunk_x + dx < map_w-2) and \
			(2 < drunk_y + dy and drunk_y + dy < map_h-2):
			drunk_x += dx
			drunk_y += dy
			if nodeLogic.get_cell(drunk_x, drunk_y) == tile_filled:
				nodeLogic.set_cell(drunk_x, drunk_y, tile_empty)

				# optional: make tunnel wider
				nodeLogic.set_cell(drunk_x+1, drunk_y, tile_empty)
				nodeLogic.set_cell(drunk_x+1, drunk_y+1, tile_empty)


#func util_flood_fill(tilex,tiley):
#	var cave = []
#	var to_fill = [Vector2(tilex, tiley)]
#	while to_fill:
#		var tile = to_fill.pop_back()
#		if !cave.has(tile):
#			cave.append(tile)
#			self.set_cellv(tile, TILES.LOGIC_VOID)
#			#check adjacent cells
#			var north = Vector2(tile.x, tile.y-1)
#			var south = Vector2(tile.x, tile.y+1)
#			var east  = Vector2(tile.x+1, tile.y)
#			var west  = Vector2(tile.x-1, tile.y)
#			#check adjacent cells
#			for dir in [north,south,east,west]:
#				if self.get_cellv(dir) == TILES.LOGIC_EMPTY:
#					if !to_fill.has(dir) and !cave.has(dir):
#						to_fill.append(dir)
#	if cave.size() >= min_cave_size:
#		caves_array.append(cave)
#	pass


# BSP Generator
#---------------------------------------------------------------------------------------
#func generate():
#	clear()
#	fill_roof()
#	start_tree()
#	create_leaf(0)
#	create_rooms()
##	join_rooms()
##	clear_deadends()
#
#func fill_roof():
#	for x in range(0, map_w):
#		for y in range(0, map_h):
#			set_cell(x, y, TILES.LOGIC_WALL)
#	pass
#
#func start_tree():
#	rooms = []
#	tree = {}
#	leaves = []
#	leaf_id = 0
#
#	tree[leaf_id] = { "x": 1, "y": 1, "w": map_w-2, "h": map_h-2 }
#	leaf_id += 1
#	pass
#
#func create_leaf(parent_id):
#	var x = tree[parent_id].x
#	var y = tree[parent_id].y
#	var w = tree[parent_id].w
#	var h = tree[parent_id].h
#
#	# used to connect the leaves later
#	tree[parent_id].center = { x = floor(x + w/2), y = floor(y + h/2) }
#
#	# whether the tree has space for a split
#	var can_split = false
#
#	# randomly split horizontal or vertical
#	# if not enough width, split horizontal
#	# if not enough height, split vertical
#	var split_type = util_choose(["h", "v"])
#	if   (min_room_factor * w < min_room_size):  split_type = "h"
#	elif (min_room_factor * h < min_room_size):  split_type = "v"
#
#	var leaf1 = {}
#	var leaf2 = {}
#
#	# try and split the current leaf,
#	# if the room will fit
#	if (split_type == "v"):
#		var room_size = min_room_factor * w
#		if (room_size >= min_room_size):
#			var w1 = util_randi_range(room_size, (w - room_size))
#			var w2 = w - w1
#			leaf1 = { x = x, y = y, w = w1, h = h, split = 'v' }
#			leaf2 = { x = x+w1, y = y, w = w2, h = h, split = 'v' }
#			can_split = true
#	else:
#		var room_size = min_room_factor * h
#		if (room_size >= min_room_size):
#			var h1 = util_randi_range(room_size, (h - room_size))
#			var h2 = h - h1
#			leaf1 = { x = x, y = y, w = w, h = h1, split = 'h' }
#			leaf2 = { x = x, y = y+h1, w = w, h = h2, split = 'h' }
#			can_split = true
#
#	# rooms fit, lets split
#	if (can_split):
#		leaf1.parent_id    = parent_id
#		tree[leaf_id]      = leaf1
#		tree[parent_id].l  = leaf_id
#		leaf_id += 1
#
#		leaf2.parent_id    = parent_id
#		tree[leaf_id]      = leaf2
#		tree[parent_id].r  = leaf_id
#		leaf_id += 1
#
#		# append these leaves as branches from the parent
#		leaves.append([tree[parent_id].l, tree[parent_id].r])
#
#		# try and create more leaves
#		create_leaf(tree[parent_id].l)
#		create_leaf(tree[parent_id].r)
#
#func create_rooms():
#	for leaf_id in tree:
#		var leaf = tree[leaf_id]
#		if leaf.has("l"): continue # if node has children, don't build rooms
#
#		if util_chance(100):
#			var room = {}
#			room.id = leaf_id;
#			room.w  = util_randi_range(min_room_size, leaf.w) - 1
#			room.h  = util_randi_range(min_room_size, leaf.h) - 1
#			room.x  = leaf.x + floor((leaf.w-room.w)/2) + 1
#			room.y  = leaf.y + floor((leaf.h-room.h)/2) + 1
#			room.split = leaf.split
#
#			room.center = Vector2()
#			room.center.x = floor(room.x + room.w/2)
#			room.center.y = floor(room.y + room.h/2)
#			rooms.append(room);
#
#	# draw the rooms on the tilemap
#	for i in range(rooms.size()):
#		var r = rooms[i]
#		for x in range(r.x, r.x + r.w):
#			for y in range(r.y, r.y + r.h):
#				set_cell(x, y, TILES.LOGIC_EMPTY)
#	pass
#
#func join_rooms():
#	for sister in leaves:
#		var a = sister[0]
#		var b = sister[1]
#		connect_leaves(tree[a], tree[b])
#	pass
#
#func connect_leaves(leaf1, leaf2):
#	var x = min(leaf1.center.x, leaf2.center.x)
#	var y = min(leaf1.center.y, leaf2.center.y)
#	var w = 1
#	var h = 1
#
#	# Vertical corridor
#	if (leaf1.split == 'h'):
#		x -= floor(w/2)+1
#		h = abs(leaf1.center.y - leaf2.center.y)
#	else:
#		# Horizontal corridor
#		y -= floor(h/2)+1
#		w = abs(leaf1.center.x - leaf2.center.x)
#
#	# Ensure within map
#	x = 0 if (x < 0) else x
#	y = 0 if (y < 0) else y
#
#	for i in range(x, x+w):
#		for j in range(y, y+h):
#			if(get_cell(i, j) == TILES.LOGIC_WALL): set_cell(i, j, TILES.LOGIC_EMPTY)
#	pass
#
#func clear_deadends():
#	var done = false
#
#	while !done:
#		done = true
#
#		for cell in get_used_cells():
#			if get_cellv(cell) != TILES.LOGIC_EMPTY: continue
#
#			var roof_count = util_check_nearby_tile_4(cell.x, cell.y, TILES.LOGIC_WALL)
#			if roof_count == 3:
#				set_cellv(cell, TILES.LOGIC_WALL)
#				done = false
#	pass
