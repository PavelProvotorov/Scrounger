extends KinematicBody2D

onready var NODE_ANIMATED_SPRITE = $AnimatedSprite
onready var NODE_COLLISION_2D = $CollisionShape2D
onready var NODE_CAMERA_2D = $Camera2D
onready var NODE_RAYCAST = $RayCast2D
onready var NODE_TWEEN = $Tween
onready var NODE_MAIN = self

const inputList = {
	"ui_up": Vector2.UP,
	"ui_down": Vector2.DOWN,
	"ui_left": Vector2.LEFT,
	"ui_right": Vector2.RIGHT
	}
const ANIMATIONS= {
	IDLE = "IDLE"
}

const tile_size = 8
const tween_speed = 8

var turn_count:int

# STATS
#---------------------------------------------------------------------------------------
var stat_ranged_dmg:int = 1
var stat_melee_dmg:int = 2
var stat_ambition:int = 3

var stat_shield:int = 0
var stat_health:int = 10
var stat_speed:int = 1
var stat_ammo:int = 0

var hit_pos
var vis_color = Color(.867, .91, .247, 0.1)

# READY
#---------------------------------------------------------------------------------------
func _process(_delta):
	ui_update()

func _ready():
	Global.NODE_PLAYER = self
	
	#PREPARE CAMERA2D
	var map_limits = Global.LEVEL_LAYER_LOGIC.get_used_rect()
	var map_cellsize = Global.LEVEL_LAYER_LOGIC.cell_size
	NODE_CAMERA_2D.limit_left = (map_limits.position.x * map_cellsize.x)
	NODE_CAMERA_2D.limit_right = (map_limits.end.x * map_cellsize.x)
	NODE_CAMERA_2D.limit_top = (map_limits.position.y * map_cellsize.y)
	NODE_CAMERA_2D.limit_bottom = (map_limits.end.y * map_cellsize.y)
	
	#PREPARE STARTING ANIMATIONS
	NODE_ANIMATED_SPRITE.set_animation(ANIMATIONS.IDLE)
	NODE_ANIMATED_SPRITE.set_frame(rand_range(0,NODE_ANIMATED_SPRITE.get_sprite_frames().get_frame_count(ANIMATIONS.IDLE)))
	pass

func _unhandled_input(event):
	if NODE_TWEEN.is_active():
		return
	for input in inputList.keys():
		if event.is_action_pressed(input):
			if Global.GAME_STATE == Global.GAME_STATE_LIST.STATE_PLAYER_TURN:
				_move_player(input)
			else:
				pass

func _move_player(direction):
	var cellA = NODE_MAIN.position
	var cellB = NODE_MAIN.position + (inputList[direction] * tile_size)
	NODE_RAYCAST.cast_to = (inputList[direction] * tile_size)
	NODE_RAYCAST.force_raycast_update()
	
	if NODE_RAYCAST.is_colliding() == false:
		if cellA - cellB == Vector2(-tile_size,0): animation_flip(false,false)
		if cellA - cellB == Vector2(tile_size,0): animation_flip(true,false)
		NODE_MAIN.action_move_tween(cellA,cellB)
		yield(NODE_TWEEN,"tween_all_completed")
		Global.LEVEL_LAYER_LOGIC.fog_update()
		check_turn()

	if NODE_RAYCAST.is_colliding() == true:
		var collider = NODE_RAYCAST.get_collider()
		print(collider)
		if NODE_RAYCAST.get_collider() == Global.LEVEL_LAYER_LOGIC:
			var collider_cell = Vector2(cellB.x/8,cellB.y/8)
			var collider_cell_id = Global.LEVEL_LAYER_LOGIC.get_cell(collider_cell.x,collider_cell.y)
			if collider_cell_id == Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_WALL: pass
			if collider_cell_id == Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_VOID: pass
			if collider_cell_id == Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_DOOR:
				Global.LEVEL_LAYER_LOGIC.set_cell(collider_cell.x,collider_cell.y,Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_FLOOR)
				NODE_MAIN.action_move_tween(cellA,cellB)
				yield(NODE_TWEEN,"tween_all_completed")
				Global.LEVEL_LAYER_LOGIC.fog_update()
				check_turn()
		elif NODE_RAYCAST.get_collider().is_in_group(Global.GROUPS.HOSTILE) == true:
			if cellA - cellB == Vector2(-tile_size,0): animation_flip(false,false)
			if cellA - cellB == Vector2(tile_size,0): animation_flip(true,false)
			NODE_MAIN.z_index += 1
#			NODE_MAIN.animation_change(ANIMATIONS.MELEE_ATTACK,true,false)
			NODE_MAIN.calculate_melee_damage(self,collider)
			NODE_MAIN.action_attack_tween(cellA,cellB)
			yield(NODE_TWEEN,"tween_all_completed")
#			NODE_MAIN.animation_change(ANIMATIONS.MELEE_IDLE,true,false)
			NODE_MAIN.z_index -= 1
			check_turn()
		elif NODE_RAYCAST.get_collider().is_in_group(Global.GROUPS.HOSTILE) == false:
			pass
		else:
			pass
	else:
		return

func raycast_cast_to(cell_start,cell_finish):
	var cell_cast_to = Vector2(((cell_finish.x-cell_start.x)*tile_size),((cell_finish.y-cell_start.y)*tile_size))
	NODE_RAYCAST.cast_to = Vector2(cell_cast_to.x,cell_cast_to.y)
	NODE_RAYCAST.force_raycast_update()

func check_turn():
	turn_count += 1
	if turn_count != stat_speed:
		return
	elif turn_count == stat_speed:
		Global.game_state_manager(Global.GAME_STATE_LIST.STATE_MOB_TURN)
	else:
		pass

func ui_update():
	Global.UI_AMMO.set_text(self.stat_ammo as String)
	Global.UI_HEALTH.set_text(self.stat_health as String)
	Global.UI_SHIELD.set_text(self.stat_shield as String)
	Global.UI_TURN.set_text((self.stat_speed - self.turn_count)as String)

func calculate_melee_damage(is_attacker,is_target):
	is_target.stat_health -= is_attacker.stat_melee_dmg
	if is_target.stat_health <= 0: 
			is_target.queue_free()
			Global.LEVEL_LAYER_LOGIC.remove_child(is_target)

func animation_flip(is_flip_h:bool, is_flip_v:bool):
	NODE_ANIMATED_SPRITE.flip_h = is_flip_h
	NODE_ANIMATED_SPRITE.flip_v = is_flip_v

func animation_change(animation_type:String,is_playing:bool,is_random:bool):
	NODE_ANIMATED_SPRITE.set_animation(animation_type)
	NODE_ANIMATED_SPRITE.playing = is_playing
	if is_random == true:
		NODE_ANIMATED_SPRITE.set_frame(rand_range(0,NODE_ANIMATED_SPRITE.get_sprite_frames().get_frame_count(animation_type)))
	if is_random == false:
		pass

func action_move_tween(start,finish):
	NODE_TWEEN.interpolate_property(self,'position',start,finish,1.0/tween_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	NODE_TWEEN.start()
	yield(NODE_TWEEN,"tween_completed")
	NODE_TWEEN.emit_signal("tween_all_completed")

func action_attack_tween(start,finish):
	NODE_TWEEN.interpolate_property(self,"position",start,finish,0.5/tween_speed)
	NODE_TWEEN.start()
	yield(NODE_TWEEN,"tween_completed")
	NODE_TWEEN.interpolate_property(self,"position",finish,start,1.0/tween_speed)
	NODE_TWEEN.start()
	yield(NODE_TWEEN,"tween_completed")
	NODE_TWEEN.emit_signal("tween_all_completed")
