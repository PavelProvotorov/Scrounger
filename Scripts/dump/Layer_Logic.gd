extends TileMap

onready var node_Deco = get_parent().get_node("Deco")
onready var node_Wall = get_parent().get_node("Wall")
onready var node_Base = get_parent().get_node("Base")
onready var node_Logic = get_parent().get_node("Logic")

var iterations:int = 1000
var min_cave_size:int = 10
var empty_chance:int = 50
var neighbors:int = 4
var map_w:int = 30
var map_h:int = 17

enum TILES {
	LOGIC_FLOOR = 0,
	LOGIC_WALL = 1,
	LOGIC_WATER = 2,
	LOGIC_EMPTY = 14,
	LOGIC_VOID = 15
	}
var caves = []

func _ready():
	randomize()
	pass

#-----------------------------# Сaves Generation
func generation_caves():
	clear()
	generation_caves_fill()
	generation_caves_random_empty()
	generation_caves_digger()
	generation_caves_get_caves()
	generation_caves_connect_caves()
#	generation_caves_digger()
	pass

func generation_caves_check_size():
	pass

func generation_caves_fill():
	for x in range(0, map_w):
		for y in range(0, map_h):
			set_cell(x, y, TILES.LOGIC_VOID)
	pass

func generation_caves_random_empty():
		for x in range(1, map_w-1):
			for y in range(1, map_h-1):
				if util_chance(empty_chance):
					set_cell(x, y, TILES.LOGIC_EMPTY)

func generation_caves_digger():
	randomize()
	for i in range(iterations):
		var x = floor(rand_range(1, map_w-1))
		var y = floor(rand_range(1, map_h-1))
		if util_check_nearby_tile(x,y,TILES.LOGIC_VOID) > neighbors:
			set_cell(x, y, TILES.LOGIC_VOID)
		elif util_check_nearby_tile(x,y,TILES.LOGIC_VOID) < neighbors:
			set_cell(x, y, TILES.LOGIC_EMPTY)
	pass

func generation_caves_get_caves():
	caves = []
	for x in range (0, map_w):
		for y in range (0, map_h):
			if get_cell(x, y) == TILES.LOGIC_EMPTY:
				util_flood_fill(x,y)
	for cave in caves:
		for tile in cave:
			set_cellv(tile, TILES.LOGIC_EMPTY)
	pass

func generation_caves_connect_caves():
	var prev_cave = null
	var tunnel_caves = caves.duplicate()

	for cave in tunnel_caves:
		if prev_cave:
			var new_point  = util_choose(cave)
			var prev_point = util_choose(prev_cave)

			# ensure not the same point
			if new_point != prev_point:
				util_create_tunnel(new_point, prev_point, cave, TILES.LOGIC_EMPTY, TILES.LOGIC_VOID)

		prev_cave = cave
	pass
#-----------------------------# Сaves Generation

#-----------------------------# Utility Functions
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
	if get_cell(x, y-1)   == TILE:  count += 1
	if get_cell(x, y+1)   == TILE:  count += 1
	if get_cell(x-1, y)   == TILE:  count += 1
	if get_cell(x+1, y)   == TILE:  count += 1
	if get_cell(x+1, y+1) == TILE:  count += 1
	if get_cell(x+1, y-1) == TILE:  count += 1
	if get_cell(x-1, y+1) == TILE:  count += 1
	if get_cell(x-1, y-1) == TILE:  count += 1
	return count

func util_flood_fill(tilex,tiley):
	var cave = []
	var to_fill = [Vector2(tilex, tiley)]
	while to_fill:
		var tile = to_fill.pop_back()
		if !cave.has(tile):
			cave.append(tile)
			set_cellv(tile, TILES.LOGIC_VOID)
			#check adjacent cells
			var north = Vector2(tile.x, tile.y-1)
			var south = Vector2(tile.x, tile.y+1)
			var east  = Vector2(tile.x+1, tile.y)
			var west  = Vector2(tile.x-1, tile.y)
			#check adjacent cells
			for dir in [north,south,east,west]:
				if get_cellv(dir) == TILES.LOGIC_EMPTY:
					if !to_fill.has(dir) and !cave.has(dir):
						to_fill.append(dir)
	if cave.size() >= min_cave_size:
		caves.append(cave)
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
			if get_cell(drunk_x, drunk_y) == tile_filled:
				set_cell(drunk_x, drunk_y, tile_empty)

				# optional: make tunnel wider
				set_cell(drunk_x+1, drunk_y, tile_empty)
				set_cell(drunk_x+1, drunk_y+1, tile_empty)
#-----------------------------# Utility Functions





