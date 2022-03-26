extends TileMap

var tilemap_astar = AStar2D.new()
var tilemap_astar_path:PoolVector2Array
var tilemap_cells_radius:PoolVector2Array
var tilemap_cells_free
var tilemap_scan_node

const DIRECTION_LIST:Array = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT
	]



#---------------------------------------------------------------------------------------
func astar_clear():
	tilemap_astar.clear()
	tilemap_astar_path = []
	tilemap_cells_free = []

func astar_get_cells(id):
	var tilemapIDCells = get_used_cells_by_id(id)
	tilemap_cells_free.append_array(tilemapIDCells)
	tilemapIDCells = []

# Remove specific cells from list
func astar_remove_cells(startPoint,targetPoint):
	tilemap_scan_node = Global.NODE_LEVEL_LAYER_LOGIC
	var size = tilemap_scan_node.get_child_count()
	var idx = 0
	while idx < size:
		var point = tilemap_scan_node.get_child(idx)
		if point.is_in_group("Mob") && point != startPoint:
			if point != targetPoint:
				point = (world_to_map(point.get_global_position()))
				tilemap_cells_free.remove(tilemap_cells_free.find(Vector2(point.x,point.y)))
			elif point == targetPoint:
				pass
			else:
				pass
		elif point.is_in_group("Mob") && point == startPoint:
			pass
		else:
			pass
		idx += 1

func astar_remove_mob_cells():
	tilemap_scan_node = Global.nodeLogic
	for i in tilemap_scan_node.get_child_count():
		var mobCell = tilemap_scan_node.get_child(i)
		mobCell = (world_to_map(mobCell.get_global_position()))
		tilemap_cells_free.remove(tilemap_cells_free.find(Vector2(mobCell.x,mobCell.y)))

func astar_remove_extra_cells(extraPoint):
	tilemap_cells_free.remove(tilemap_cells_free.find(Vector2(extraPoint.x,extraPoint.y)))

# Applying unique IDs to empty cells
func astar_add_points():
	for cell in tilemap_cells_free:
		tilemap_astar.add_point(uuid(cell),cell,1.0)

#Checking neighbour cells in order RIGHT, LEFT, DOWN, UP
func astar_connect_points():
	for cell in tilemap_cells_free:
		var tilemapAdjacentCells = [Vector2(1,0),Vector2(-1,0),Vector2(0,1),Vector2(0,-1)]
		for check in tilemapAdjacentCells:
			var nextCell = cell + check
			if tilemap_cells_free.has(nextCell):
				tilemap_astar.connect_points(uuid(cell),uuid(nextCell),false)

#Building a path between two points
func astar_get_path(start,end):
	tilemap_astar_path = tilemap_astar.get_point_path(uuid(start),uuid(end))
	
# Pairing function for creating unique IDs based on the Vector2 x and y coordinates
func uuid(point):
	var a = point.x
	var b = point.y
	return (a + b) * (a + b + 1) / 2 + b



#---------------------------------------------------------------------------------------

## Remove specific cells from list
#func _astar_remove_points():
#	var tilemapScanNode = get_tree().get_root().get_node("Main/Logic")
#	var size = tilemapScanNode.get_child_count()
#	var idx = 0
#	while idx < size:
#		var pos = tilemapScanNode.get_child(idx)
#		if pos.is_in_group("Mob") && pos != Global.gameMovingNode:
#			pos = (world_to_map(pos.get_global_position()))
#			tilemapFreeCells.remove(tilemapFreeCells.find(Vector2(pos.x,pos.y)))
#		elif pos.is_in_group("Mob") && pos == Global.gameMovingNode:
#			pass
#		else:
#			pass
#		idx += 1

#func _astar_get_cells_radius(point,radius):
#	tilemapRadiusCells = []
#	var vectorCount = 1
#	var vectorFrom
#	while vectorCount < 5:
#		if vectorCount == 0:
#			pass
#		elif vectorCount == 1:
#			vectorFrom = Vector2((point.x)+(Vector2.UP.x * radius),(point.y)+(Vector2.UP.y * radius))
#			tilemapRadiusCells.append(vectorFrom)
#			if radius != 1:
#				for i in radius:
#					if i == 0:
#						continue
#					elif i >= 1:
#						tilemapRadiusCells.append(Vector2((vectorFrom.x)+(1*i),(vectorFrom.y)+(1*i)))
#			else:
#				pass
#		elif vectorCount == 2:
#			vectorFrom = Vector2((point.x)+(Vector2.RIGHT.x * radius),(point.y)+(Vector2.RIGHT.y * radius))
#			tilemapRadiusCells.append(vectorFrom)
#			if radius != 1:
#				for i in radius:
#					if i == 0:
#						continue
#					elif i >= 1:
#						tilemapRadiusCells.append(Vector2((vectorFrom.x)+(-1*i),(vectorFrom.y)+(1*i)))
#			else:
#				pass
#		elif vectorCount == 3:
#			vectorFrom = Vector2((point.x)+(Vector2.DOWN.x * radius),(point.y)+(Vector2.DOWN.y * radius))
#			tilemapRadiusCells.append(vectorFrom)
#			if radius != 1:
#				for i in radius:
#					if i == 0:
#						continue
#					elif i >= 1:
#						tilemapRadiusCells.append(Vector2((vectorFrom.x)+(-1*i),(vectorFrom.y)+(-1*i)))
#			else:
#				pass
#		elif vectorCount == 4:
#			vectorFrom = Vector2((point.x)+(Vector2.LEFT.x * radius),(point.y)+(Vector2.LEFT.y * radius))
#			tilemapRadiusCells.append(vectorFrom)
#			if radius != 1:
#				for i in radius:
#					if i == 0:
#						continue
#					elif i >= 1:
#						tilemapRadiusCells.append(Vector2((vectorFrom.x)+(1*i),(vectorFrom.y)+(-1*i)))
#			else:
#				pass
#		else:
#			pass
#		print("FINISH VECTOR %s" %vectorCount)
#		print("VECTOR FROM WAS %s" %vectorFrom)
#		print(tilemapRadiusCells)
#		vectorCount +=1
