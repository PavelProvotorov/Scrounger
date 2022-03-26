extends AStarPath

onready var local_nodeMain = Global.nodeMain

var listAIPattern:Array = ["PATTERN_NONE", "PATTERN_NORMAL"]
var listAIClass:Array = ["CLASS_NONE", "CLASS_KING","CLASS_GUARD"]
var listAIState:Array = ["STATE_NONE", "STATE_IDLE", "STATE_CLAIM", "STATE_MOVE", "STATE_GUARD", "STATE_HUNT"]

var mobQueue
var targetNode
var targetNodePos
var movingNode
var movingNodePos

signal on_mob_claim_finished
signal on_mob_guard_finished
signal on_manager_mob_ai_finished

func _ready():
	randomize()
#	var test = local_nodeMain._load_json("rooms","normal_rooms")
#	_fill_rooms(test.get("room_test"))
#	_fill_border()
	print("-----------------")

func _entities_scan():
	mobQueue = []
	var idx = 0
	var nodeToScan = self
	var nodeToScanSize:int = nodeToScan.get_child_count()
	for i in nodeToScanSize:
		var nodeChildGroup = nodeToScan.get_child(idx)
		if nodeChildGroup.is_in_group("Mob"):
			var nodeChildName:String = nodeToScan.get_child(idx).name
			var nodeChildData:int = nodeToScan.get_child(idx).statAmbition
			var nodeChildFetch = [nodeChildData,nodeChildName]
			mobQueue.push_back(nodeChildFetch)
		else:
			pass
		idx += 1
		i += 1
	mobQueue.sort_custom(self,"_entities_sort")
	print(mobQueue)

func _entities_sort(a,b):
	if a[0] > b[0]:
		return true
	return false
#--------------------------------------------------------------------------------------------------------#

func _manager_mob_ai_pattern():
	print("---------------------------------------------------------")
	print("THE QUEUE SIZE IS: %s" %mobQueue.size())
	for i in (mobQueue.size()):
		print(i)
		yield(get_tree().create_timer(0.6),"timeout")
		movingNode = get_node(mobQueue[i][1])
		Global.gameMovingNode = movingNode
		print("Currently Moving: %s" %movingNode.name)
		if movingNode.AIPattern == listAIPattern[0]: #NONE
			pass
		elif movingNode.AIPattern == listAIPattern[1]: #NORMAL
			_manager_mob_ai_normal()
			yield(self,"on_manager_mob_ai_finished")
		else:
			pass
	print("< FOR LOOP FINISHED, CHANGE TO PLAYER >")
	Global._enter_manager("STATE_PLAYER_TURN")
	
func _manager_mob_ai_normal():
	if movingNode.AIClass == listAIClass[0]:#NONE
		pass
	elif movingNode.AIClass == listAIClass[1]: # <CLASS KING>
		if movingNode.AIState == listAIState[0]:#NONE
			pass
		elif movingNode.AIState == listAIState[1]: #IDLE
			_mob_claim()
			yield(self,"on_mob_claim_finished")
		elif movingNode.AIState == listAIState[2]: #CLAIM
			pass
		elif movingNode.AIState == listAIState[3]: #MOVE
			pass
		elif movingNode.AIState == listAIState[4]: #GUARD
			pass
		elif movingNode.AIState == listAIState[5]: #HUNT
			pass
		else:
			pass
	elif movingNode.AIClass == listAIClass[2]: # <CLASS GUARD>
		if movingNode.AIState == listAIState[0]:#NONE
			pass
		elif movingNode.AIState == listAIState[1]: #IDLE
			_mob_guard()
# warning-ignore:standalone_expression
			movingNode.AIState == listAIState[4]
			yield(self,"on_mob_guard_finished")
		elif movingNode.AIState == listAIState[2]: #CLAIM
			pass
		elif movingNode.AIState == listAIState[3]: #MOVE
			pass
		elif movingNode.AIState == listAIState[4]: #GUARD
			pass
		elif movingNode.AIState == listAIState[5]: #HUNT
			pass
		else:
			pass
	else:
		pass
	print("< NORMAL MOB AI MANAGER FINISHED >")
	emit_signal("on_manager_mob_ai_finished")

func _mob_claim():
	var nearbyCells = [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]
	var nearbyCellsID = 0
	for i in movingNode.statSpeed:
		print("TURN NO: %s" %i)
		nearbyCells.shuffle()
		movingNodePos = world_to_map(movingNode.get_global_position())
#		print("MovingNode Position: %s" %movingNodePos)
		targetNodePos = Vector2((nearbyCells[nearbyCellsID].x),(nearbyCells[nearbyCellsID].y))
#		print("TargetNode Position Vector: %s" %targetNodePos)
		targetNodePos = Vector2((movingNodePos.x)+(targetNodePos.x),(movingNodePos.y)+(targetNodePos.y))
#		print("TargetNode Position Result: %s" %targetNodePos)
		_astar_clear()
		_astar_get_cells(0)
		_astar_remove_mob_cells()
#		print("THE FREECELLS ARE")
#		print(tilemapFreeCells)
		if tilemapFreeCells.has(targetNodePos) == true:
			yield(_mob_move(movingNodePos,targetNodePos),"completed")
			print("MOVE COMPLETE IN CLAIM FUNCTION")
		elif tilemapFreeCells.has(targetNodePos) == false:
			for cell in (nearbyCells.size()):
				targetNodePos = Vector2((nearbyCells[cell].x),(nearbyCells[cell].y))
				targetNodePos = Vector2((movingNodePos.x)+(targetNodePos.x),(movingNodePos.y)+(targetNodePos.y))
				print("GOT CELL: %s" %targetNodePos)
				if tilemapFreeCells.has(targetNodePos) == true:
					print("CELL IS VALID")
					yield(_mob_move(movingNodePos,targetNodePos),"completed")
					print("MOVE COMPLETE IN CLAIM FUNCTION")
					break
				elif tilemapFreeCells.has(targetNodePos) == false:
					print("CELL NOT VALID")
					pass
				else:
					pass
		else:
			pass
	print("< MOB CLAIM FINISHED >")
	emit_signal("on_mob_claim_finished")

func _mob_guard():
	for i in movingNode.statSpeed:
		print("TURN NO: %s" %i)
		movingNodePos = world_to_map(movingNode.get_global_position())

	print("< MOB GUARD FINISHED >")
	emit_signal("on_mob_guard_finished")
	pass

func _hunt_mob_ai():
	pass

func _mob_move(cellA,cellB):
	cellA = Vector2((cellA.x)*16,(cellA.y)*16)
	cellB = Vector2((cellB.x)*16,(cellB.y)*16)
	movingNode._move_tween(cellA,cellB)
	yield(movingNode.get_node("Tween"),"tween_all_completed")

func _mob_attack(cellA,cellB):
	cellA = Vector2((cellA.x)*16,(cellA.y)*16)
	cellB = Vector2((cellB.x)*16,(cellB.y)*16)
	movingNode._attack_tween(cellA,cellB)
	yield(movingNode.get_node("Tween"),"tween_all_completed")

func _mob_spawn(mobName,mobPos:Vector2):
	var mobInstance = mobName.instance()
	mobInstance.set_global_position(Vector2((mobPos.x)*16,(mobPos.y)*16))
	add_child(mobInstance)
	
#--------------------------------------------------------------------------------------------------------#

# ---------------------------------------------------- 

# ----------------------------------------------------

#func _movement():
#	targetNode = Global.playerNode
#	var cellA
#	var cellB
#	for i in Global.gameTurnQueue.size():
#		yield(get_tree().create_timer(0.5),"timeout")
#		movingNode = get_node(Global.gameTurnQueue[i][1])
#		Global.gameMovingNode = movingNode
#		Global.gameTargetNode = targetNode
#		for turnCount in movingNode.statSpeed:
#			movingNodePos = world_to_map(movingNode.get_global_position())
#			targetNodePos = world_to_map(targetNode.get_global_position())
#			_start_astar()
#			_astar_get_path(movingNodePos,targetNodePos)
#			tilemapAStarPath.resize(2)
#			cellA = Vector2(tilemapAStarPath[0])
#			cellB = Vector2(tilemapAStarPath[1])
#			if cellB == Vector2(0,0):
#				pass
#			elif cellB == targetNodePos:
#				cellA = Vector2((cellA.x)*16,(cellA.y)*16)
#				cellB = Vector2((cellB.x)*16,(cellB.y)*16)
#				movingNode._attack_tween(cellA,cellB)
#				yield(movingNode.get_node("Tween"),"tween_all_completed")
#			elif cellA != cellB:
#				cellA = Vector2((cellA.x)*16,(cellA.y)*16)
#				cellB = Vector2((cellB.x)*16,(cellB.y)*16)
#				movingNode._move_tween(cellA,cellB)
#				yield(movingNode.get_node("Tween"),"tween_all_completed")
#				cellB = Vector2((cellB.x)/16,(cellB.y)/16)
#			elif cellA == cellB:
#				pass
#			else:
#				pass
#			turnCount += 1
#	Global._change_state("PlayerTurn")
#	Global._manager()

#func _normal_mob_ai_class():
#	if movingNode.AIClass == listAIClass[0]: #NONE
#		pass
#	elif movingNode.AIClass == listAIClass[1]: #KING
#		pass
#	else:
#		pass
#
#func _normal_mob_ai_state():
#	if movingNode.AIState == listAIClass[0]: #NONE
#		pass
#	elif movingNode.AIState == listAIClass[1]: #IDLE
#		pass
#	elif movingNode.AIState == listAIClass[2]: #CLAIM
#		pass
#	elif movingNode.AIState == listAIClass[3]: #MOVE
#		pass
#	elif movingNode.AIState == listAIClass[4]: #HUNT
#		pass
#	else:
#		pass

#func _manager_mob_ai_state():
#	for i in Global.gameTurnQueue.size():
#		yield(get_tree().create_timer(0.6),"timeout")
#		movingNode = get_node(Global.gameTurnQueue[i][1])
#		print(movingNode.name)
#		Global.gameMovingNode = movingNode
#		if 1 == 1:
#			if movingNode.is_in_group("King"):
##				_claim_mob_ai()
##				yield(_claim_mob_ai(),"completed")
#				pass
#			elif movingNode.is_in_group("Minion"):
#				movingNode.settingAIState = "Attack"
#				yield(_move_mob_ai(),"completed")
#			else:
#				pass
#		else:
#			pass
#func _mob_move_old():
#	targetNode = Global.playerNode
#	Global.gameTargetNode = targetNode
#	for i in movingNode.statSpeed:
#		movingNodePos = world_to_map(movingNode.get_global_position())
#		targetNodePos = world_to_map(targetNode.get_global_position())
##		_start_astar()
##		_astar_get_path(movingNodePos,targetNodePos)
#		tilemapAStarPath.resize(2)
#		print(tilemapAStarPath)
#		cellA = Vector2(tilemapAStarPath[0])
#		cellB = Vector2(tilemapAStarPath[1])
#		if cellB == Vector2(0,0):
#			pass
#		elif cellB == targetNodePos:
#			cellA = Vector2((cellA.x)*16,(cellA.y)*16)
#			cellB = Vector2((cellB.x)*16,(cellB.y)*16)
#			movingNode._attack_tween(cellA,cellB)
#			yield(movingNode.get_node("Tween"),"tween_all_completed")
#		elif cellA != cellB:
#			cellA = Vector2((cellA.x)*16,(cellA.y)*16)
#			cellB = Vector2((cellB.x)*16,(cellB.y)*16)
#			movingNode._move_tween(cellA,cellB)
#			yield(movingNode.get_node("Tween"),"tween_all_completed")
#			cellB = Vector2((cellB.x)/16,(cellB.y)/16)
#		elif cellA == cellB:
#			pass
#		else:
#			pass

#	var data1 = Vector2(0,0)
#	var data2 = 3
#	_astar_get_cells_radius(data1,data2)
#	print("END RESULT: %s" %tilemapRadiusCells)
#	var data3 = Vector2(27,1)
#	_mob_spawn(mob_RoyalGuard,data3)

#func _export_room(roomDataRaw:Array):
#	var roomName = room_bottom_center
#	var roomData = roomDataRaw[0]
#	for i in roomData.size():
#		print(roomName[i])
#		self.set_cell(roomName[i].x,roomName[i].y,roomData[i])
#	pass

#var room_border:PoolVector2Array = [Vector2(5, 1), Vector2(6, 1), Vector2(7, 1), Vector2(8, 1), Vector2(9, 1), Vector2(10, 1), Vector2(11, 1), Vector2(12, 1), Vector2(13, 1), Vector2(14, 1), Vector2(15, 1), Vector2(16, 1), Vector2(17, 1), Vector2(18, 1), Vector2(19, 1), Vector2(20, 1), Vector2(21, 1), Vector2(22, 1), Vector2(23, 1), Vector2(24, 1), Vector2(25, 1), Vector2(26, 1), Vector2(27, 1), Vector2(28, 1), Vector2(5, 2), Vector2(28, 2), Vector2(5, 3), Vector2(28, 3), Vector2(5, 4), Vector2(28, 4), Vector2(5, 5), Vector2(28, 5), Vector2(5, 6), Vector2(28, 6), Vector2(5, 7), Vector2(28, 7), Vector2(5, 8), Vector2(28, 8), Vector2(5, 9), Vector2(28, 9), Vector2(5, 10), Vector2(28, 10), Vector2(5, 11), Vector2(28, 11), Vector2(5, 12), Vector2(28, 12), Vector2(5, 13), Vector2(28, 13), Vector2(5, 14), Vector2(28, 14), Vector2(5, 15), Vector2(6, 15), Vector2(7, 15), Vector2(8, 15), Vector2(9, 15), Vector2(10, 15), Vector2(11, 15), Vector2(12, 15), Vector2(13, 15), Vector2(14, 15), Vector2(15, 15), Vector2(16, 15), Vector2(17, 15), Vector2(18, 15), Vector2(19, 15), Vector2(20, 15), Vector2(21, 15), Vector2(22, 15), Vector2(23, 15), Vector2(24, 15), Vector2(25, 15), Vector2(26, 15), Vector2(27, 15), Vector2(28, 15)]
#var room_top_left:PoolVector2Array = [Vector2(5, 1), Vector2(6, 1), Vector2(7, 1), Vector2(8, 1), Vector2(9, 1), Vector2(10, 1), Vector2(11, 1), Vector2(12, 1), Vector2(5, 2), Vector2(6, 2), Vector2(7, 2), Vector2(8, 2), Vector2(9, 2), Vector2(10, 2), Vector2(11, 2), Vector2(12, 2), Vector2(5, 3), Vector2(6, 3), Vector2(7, 3), Vector2(8, 3), Vector2(9, 3), Vector2(10, 3), Vector2(11, 3), Vector2(12, 3), Vector2(5, 4), Vector2(6, 4), Vector2(7, 4), Vector2(8, 4), Vector2(9, 4), Vector2(10, 4), Vector2(11, 4), Vector2(12, 4), Vector2(5, 5), Vector2(6, 5), Vector2(7, 5), Vector2(8, 5), Vector2(9, 5), Vector2(10, 5), Vector2(11, 5), Vector2(12, 5)]
#var room_top_center:PoolVector2Array = [Vector2(13, 1), Vector2(14, 1), Vector2(15, 1), Vector2(16, 1), Vector2(17, 1), Vector2(18, 1), Vector2(19, 1), Vector2(20, 1), Vector2(13, 2), Vector2(14, 2), Vector2(15, 2), Vector2(16, 2), Vector2(17, 2), Vector2(18, 2), Vector2(19, 2), Vector2(20, 2), Vector2(13, 3), Vector2(14, 3), Vector2(15, 3), Vector2(16, 3), Vector2(17, 3), Vector2(18, 3), Vector2(19, 3), Vector2(20, 3), Vector2(13, 4), Vector2(14, 4), Vector2(15, 4), Vector2(16, 4), Vector2(17, 4), Vector2(18, 4), Vector2(19, 4), Vector2(20, 4), Vector2(13, 5), Vector2(14, 5), Vector2(15, 5), Vector2(16, 5), Vector2(17, 5), Vector2(18, 5), Vector2(19, 5), Vector2(20, 5)]
#var room_top_right:PoolVector2Array = [Vector2(21, 1), Vector2(22, 1), Vector2(23, 1), Vector2(24, 1), Vector2(25, 1), Vector2(26, 1), Vector2(27, 1), Vector2(28, 1), Vector2(21, 2), Vector2(22, 2), Vector2(23, 2), Vector2(24, 2), Vector2(25, 2), Vector2(26, 2), Vector2(27, 2), Vector2(28, 2), Vector2(21, 3), Vector2(22, 3), Vector2(23, 3), Vector2(24, 3), Vector2(25, 3), Vector2(26, 3), Vector2(27, 3), Vector2(28, 3), Vector2(21, 4), Vector2(22, 4), Vector2(23, 4), Vector2(24, 4), Vector2(25, 4), Vector2(26, 4), Vector2(27, 4), Vector2(28, 4), Vector2(21, 5), Vector2(22, 5), Vector2(23, 5), Vector2(24, 5), Vector2(25, 5), Vector2(26, 5), Vector2(27, 5), Vector2(28, 5)]
#var room_middle_left:PoolVector2Array = [Vector2(5, 6), Vector2(6, 6), Vector2(7, 6), Vector2(8, 6), Vector2(9, 6), Vector2(10, 6), Vector2(11, 6), Vector2(12, 6), Vector2(5, 7), Vector2(6, 7), Vector2(7, 7), Vector2(8, 7), Vector2(9, 7), Vector2(10, 7), Vector2(11, 7), Vector2(12, 7), Vector2(5, 8), Vector2(6, 8), Vector2(7, 8), Vector2(8, 8), Vector2(9, 8), Vector2(10, 8), Vector2(11, 8), Vector2(12, 8), Vector2(5, 9), Vector2(6, 9), Vector2(7, 9), Vector2(8, 9), Vector2(9, 9), Vector2(10, 9), Vector2(11, 9), Vector2(12, 9), Vector2(5, 10), Vector2(6, 10), Vector2(7, 10), Vector2(8, 10), Vector2(9, 10), Vector2(10, 10), Vector2(11, 10), Vector2(12, 10)]
#var room_middle_center:PoolVector2Array = [Vector2(13, 6), Vector2(14, 6), Vector2(15, 6), Vector2(16, 6), Vector2(17, 6), Vector2(18, 6), Vector2(19, 6), Vector2(20, 6), Vector2(13, 7), Vector2(14, 7), Vector2(15, 7), Vector2(16, 7), Vector2(17, 7), Vector2(18, 7), Vector2(19, 7), Vector2(20, 7), Vector2(13, 8), Vector2(14, 8), Vector2(15, 8), Vector2(16, 8), Vector2(17, 8), Vector2(18, 8), Vector2(19, 8), Vector2(20, 8), Vector2(13, 9), Vector2(14, 9), Vector2(15, 9), Vector2(16, 9), Vector2(17, 9), Vector2(18, 9), Vector2(19, 9), Vector2(20, 9), Vector2(13, 10), Vector2(14, 10), Vector2(15, 10), Vector2(16, 10), Vector2(17, 10), Vector2(18, 10), Vector2(19, 10), Vector2(20, 10)]
#var room_middle_right:PoolVector2Array = [Vector2(21, 6), Vector2(22, 6), Vector2(23, 6), Vector2(24, 6), Vector2(25, 6), Vector2(26, 6), Vector2(27, 6), Vector2(28, 6), Vector2(21, 7), Vector2(22, 7), Vector2(23, 7), Vector2(24, 7), Vector2(25, 7), Vector2(26, 7), Vector2(27, 7), Vector2(28, 7), Vector2(21, 8), Vector2(22, 8), Vector2(23, 8), Vector2(24, 8), Vector2(25, 8), Vector2(26, 8), Vector2(27, 8), Vector2(28, 8), Vector2(21, 9), Vector2(22, 9), Vector2(23, 9), Vector2(24, 9), Vector2(25, 9), Vector2(26, 9), Vector2(27, 9), Vector2(28, 9), Vector2(21, 10), Vector2(22, 10), Vector2(23, 10), Vector2(24, 10), Vector2(25, 10), Vector2(26, 10), Vector2(27, 10), Vector2(28, 10)]
#var room_bottom_left:PoolVector2Array = [Vector2(5, 11), Vector2(6, 11), Vector2(7, 11), Vector2(8, 11), Vector2(9, 11), Vector2(10, 11), Vector2(11, 11), Vector2(12, 11), Vector2(5, 12), Vector2(6, 12), Vector2(7, 12), Vector2(8, 12), Vector2(9, 12), Vector2(10, 12), Vector2(11, 12), Vector2(12, 12), Vector2(5, 13), Vector2(6, 13), Vector2(7, 13), Vector2(8, 13), Vector2(9, 13), Vector2(10, 13), Vector2(11, 13), Vector2(12, 13), Vector2(5, 14), Vector2(6, 14), Vector2(7, 14), Vector2(8, 14), Vector2(9, 14), Vector2(10, 14), Vector2(11, 14), Vector2(12, 14), Vector2(5, 15), Vector2(6, 15), Vector2(7, 15), Vector2(8, 15), Vector2(9, 15), Vector2(10, 15), Vector2(11, 15), Vector2(12, 15)]
#var room_bottom_center:PoolVector2Array = [Vector2(13, 11), Vector2(14, 11), Vector2(15, 11), Vector2(16, 11), Vector2(17, 11), Vector2(18, 11), Vector2(19, 11), Vector2(20, 11), Vector2(13, 12), Vector2(14, 12), Vector2(15, 12), Vector2(16, 12), Vector2(17, 12), Vector2(18, 12), Vector2(19, 12), Vector2(20, 12), Vector2(13, 13), Vector2(14, 13), Vector2(15, 13), Vector2(16, 13), Vector2(17, 13), Vector2(18, 13), Vector2(19, 13), Vector2(20, 13), Vector2(13, 14), Vector2(14, 14), Vector2(15, 14), Vector2(16, 14), Vector2(17, 14), Vector2(18, 14), Vector2(19, 14), Vector2(20, 14), Vector2(13, 15), Vector2(14, 15), Vector2(15, 15), Vector2(16, 15), Vector2(17, 15), Vector2(18, 15), Vector2(19, 15), Vector2(20, 15)]
#var room_bottom_right:PoolVector2Array = [Vector2(21, 11), Vector2(22, 11), Vector2(23, 11), Vector2(24, 11), Vector2(25, 11), Vector2(26, 11), Vector2(27, 11), Vector2(28, 11), Vector2(21, 12), Vector2(22, 12), Vector2(23, 12), Vector2(24, 12), Vector2(25, 12), Vector2(26, 12), Vector2(27, 12), Vector2(28, 12), Vector2(21, 13), Vector2(22, 13), Vector2(23, 13), Vector2(24, 13), Vector2(25, 13), Vector2(26, 13), Vector2(27, 13), Vector2(28, 13), Vector2(21, 14), Vector2(22, 14), Vector2(23, 14), Vector2(24, 14), Vector2(25, 14), Vector2(26, 14), Vector2(27, 14), Vector2(28, 14), Vector2(21, 15), Vector2(22, 15), Vector2(23, 15), Vector2(24, 15), Vector2(25, 15), Vector2(26, 15), Vector2(27, 15), Vector2(28, 15)]

#--------------------------------------------------------------------------------------------------------#
#func _fill_rooms(roomData:Array):
#	var roomName:PoolVector2Array
#	var roomToAdd:Array
#	var roomList = []
#	for room in roomList.size():
#		roomName = roomList[room]
#		roomToAdd = roomData[rand_range(0,roomData.size())]
#		for i in roomToAdd.size():
#			self.set_cell(roomName[i].x,roomName[i].y,roomToAdd[i])
#		pass
#	pass
#
#func _fill_border():
#	for i in room_border.size():
#		self.set_cell(room_border[i].x,room_border[i].y,1)
#	pass

#--------------------------------------------------------------------------------------------------------#

#func map_get_chuncks():
#	var mapChunkList = []
#	var mapTileCountX = map_tiles_count_x
#	var mapTileCountY = map_tiles_count_y
#	var mapChunkX = map_chunk_x
#	var mapChunkY = map_chunk_y
#	var mapEmptyTiles = get_used_cells_by_id(14)
#	pass
