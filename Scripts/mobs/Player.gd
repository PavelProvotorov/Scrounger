extends KinematicBody2D

onready var NODE_ANIMATED_SPRITE = $AnimatedSprite
onready var NODE_COLLISION_2D = $CollisionShape2D
onready var NODE_CAMERA_2D = $Camera2D
onready var NODE_RAYCAST_MOB = $RayCastMob
onready var NODE_RAYCAST_FOG = $RayCastFog
onready var NODE_RAYCAST_COLLIDE = $RayCastCollide
onready var NODE_SOUND_DEATH = $SoundDeath
onready var NODE_SOUND = $Sound
onready var NODE_TWEEN = $Tween
onready var NODE_MAIN = self

const INPUT_LIST = {
	UI_UP    = "ui_up",
	UI_DOWN  = "ui_down",
	UI_LEFT  = "ui_left",
	UI_RIGHT = "ui_right",
	UI_PICK  = "ui_pick",
	UI_SHOOT = "ui_shoot",
	UI_SKIP  = "ui_skip"
}

const ANIMATIONS= {
	IDLE = "IDLE"
}

const grid_size = 8
const tween_speed = 8

var turn_count:int

var PLAYER_ACTION_SHOOT = false
var PLAYER_ACTION_INPUT = false

# SOUNDS
#---------------------------------------------------------------------------------------
var sound_on_move = Sound.sfx_move
var sound_on_hit = Sound.sfx_hit_0
var sound_on_ranged = Sound.sfx_shoot
var sound_on_melee = Sound.sfx_punch_0
var sound_on_death

# STATS
#---------------------------------------------------------------------------------------
var stat_visibility:int = 2
var stat_ranged_dmg:int = 4
var stat_melee_dmg:int = 2
var stat_ambition:int = 3

var stat_shield:int = 0
var stat_health:int = 10
var stat_speed:int = 1
var stat_ammo:int = 16

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

func _unhandled_input(key):
	if NODE_TWEEN.is_active():
		return
	for input in INPUT_LIST.values():
		if key.is_action_pressed(input):
			print(PLAYER_ACTION_SHOOT)
			if Global.GAME_STATE == Global.GAME_STATE_LIST.STATE_PLAYER_TURN:
				if PLAYER_ACTION_INPUT == false && PLAYER_ACTION_SHOOT == false:
					if input == INPUT_LIST.UI_UP:    action_collision_check(Vector2.UP)
					if input == INPUT_LIST.UI_DOWN:  action_collision_check(Vector2.DOWN)
					if input == INPUT_LIST.UI_LEFT:  action_collision_check(Vector2.LEFT)
					if input == INPUT_LIST.UI_RIGHT: action_collision_check(Vector2.RIGHT)
					if input == INPUT_LIST.UI_PICK:  action_interact(Vector2(0,0))
					if input == INPUT_LIST.UI_SHOOT: check_ammo()
					if input == INPUT_LIST.UI_SKIP:  check_turn()

				elif PLAYER_ACTION_INPUT == false && PLAYER_ACTION_SHOOT == true:
					if input == INPUT_LIST.UI_UP:    action_shoot(Vector2.UP)
					if input == INPUT_LIST.UI_DOWN:  action_shoot(Vector2.DOWN)
					if input == INPUT_LIST.UI_LEFT:  action_shoot(Vector2.LEFT)
					if input == INPUT_LIST.UI_RIGHT: action_shoot(Vector2.RIGHT)
					if input == INPUT_LIST.UI_SHOOT: PLAYER_ACTION_SHOOT = false
					if input == INPUT_LIST.UI_SKIP:  check_turn()
				else:
					pass

func action_collision_check(direction):
	PLAYER_ACTION_INPUT = true
	
	var done = false
	while done == false:
		NODE_RAYCAST_COLLIDE.cast_to = (direction*grid_size)
		NODE_RAYCAST_COLLIDE.force_raycast_update()
	
		if NODE_RAYCAST_COLLIDE.is_colliding() == false: 
			action_move(direction)
			done = true
		if NODE_RAYCAST_COLLIDE.is_colliding() == true:
			var cellA = NODE_MAIN.position
			var cellB = NODE_MAIN.position + (direction * grid_size)
			var collider = NODE_RAYCAST_COLLIDE.get_collider()
			var collider_cell = Vector2(cellB.x/8,cellB.y/8)
			var collider_cell_id = Global.LEVEL_LAYER_LOGIC.get_cell(collider_cell.x,collider_cell.y)

			if collider.get_class() == "KinematicBody2D":
				if collider.is_in_group(Global.GROUPS.HOSTILE) == true: 
					action_attack(direction,collider)
					done = true
			if collider.get_class() == "StaticBody2D":
				if collider.is_in_group(Global.GROUPS.ITEM) == true:
					NODE_RAYCAST_COLLIDE.add_exception(collider)
			if collider.get_class() == "TileMap":
				if collider_cell_id == Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_DOOR:
					Global.LEVEL_LAYER_LOGIC.set_cell(collider_cell.x,collider_cell.y,Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_FLOOR)
					Global.LEVEL_LAYER_LOGIC.tilemap_texture_set_fixed(Global.LEVEL_LAYER_LOGIC.TILESET_BASE.TILE_DOOR_OPEN,collider_cell,0)
					Global.LEVEL_LAYER_LOGIC.update_dirty_quadrants()
					yield(self.get_idle_frame(),"completed")
					Global.LEVEL_LAYER_LOGIC.fog_update()
					check_turn()
					done = true
				else:
					done = true
					
	NODE_RAYCAST_COLLIDE.clear_exceptions()
	PLAYER_ACTION_INPUT = false

func action_shoot(direction):
	PLAYER_ACTION_INPUT = true

	var done = false
	while done == false:
		NODE_RAYCAST_COLLIDE.cast_to = (direction*(grid_size*3))
		NODE_RAYCAST_COLLIDE.force_raycast_update()

		if NODE_RAYCAST_COLLIDE.is_colliding() == false:
			done = true
		if NODE_RAYCAST_COLLIDE.is_colliding() == true:
			var collider = NODE_RAYCAST_COLLIDE.get_collider()
			
			if collider.get_class() == "KinematicBody2D":
				if collider.is_in_group(Global.GROUPS.HOSTILE) == true: 
					var cellA = NODE_MAIN.position
					var cellB = NODE_MAIN.position + (direction * grid_size)
					
					#ANIMATION FLIP CHECK
					if cellA - cellB == Vector2(-grid_size,0): animation_flip(false,false)
					if cellA - cellB == Vector2(grid_size,0): animation_flip(true,false)
					
					action_shoot_tween(cellA,get_negative_vector(cellA,cellB))
					NODE_MAIN.calculate_ranged_damage(self,collider)
					NODE_MAIN.stat_ammo -= 1
					Sound.play_sound(self,sound_on_ranged)
					yield(self.NODE_TWEEN,"tween_all_completed")
					yield(self.NODE_SOUND,"finished")
					done = true
			elif collider.get_class() == "StaticBody2D":
				if collider.is_in_group(Global.GROUPS.ITEM) == true:
					NODE_RAYCAST_COLLIDE.add_exception(collider)
			elif collider.get_class() == "TileMap": 
				done = true
			else:
				pass
	NODE_RAYCAST_COLLIDE.clear_exceptions()
	PLAYER_ACTION_INPUT = false
	PLAYER_ACTION_SHOOT = false
	check_turn()

func action_interact(direction):
	PLAYER_ACTION_INPUT = true
	
	NODE_RAYCAST_COLLIDE.cast_to = (direction)
	NODE_RAYCAST_COLLIDE.force_raycast_update()
	
	if NODE_RAYCAST_COLLIDE.is_colliding() == false:
		var cell_player = NODE_MAIN.position
		var cell = Global.LEVEL_LAYER_LOGIC.get_cellv(Vector2(cell_player.x/grid_size,cell_player.y/grid_size))
		if cell == Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_EXIT:
			Global.LEVEL_LAYER_LOGIC.bsp_generator()
			pass
		pass
	if NODE_RAYCAST_COLLIDE.is_colliding() == true:
		var collider = NODE_RAYCAST_COLLIDE.get_collider()
		if collider.get_class() == "StaticBody2D":
			if collider.is_in_group(Global.GROUPS.ITEM) == true:
						collider.on_pickup()
						yield(collider.NODE_SOUND,"finished")
						Global.LEVEL_LAYER_LOGIC.remove_child(collider)
						collider.queue_free()
						check_turn()
	PLAYER_ACTION_INPUT = false

func action_move(direction):
	var cellA = NODE_MAIN.position
	var cellB = NODE_MAIN.position + (direction * grid_size)
	
	#ANIMATION FLIP CHECK
	if cellA - cellB == Vector2(-grid_size,0): animation_flip(false,false)
	if cellA - cellB == Vector2(grid_size,0): animation_flip(true,false)
	
	NODE_MAIN.action_move_tween(cellA,cellB)
	Sound.play_sound(self,sound_on_move)
	yield(NODE_TWEEN,"tween_all_completed")
	Global.LEVEL_LAYER_LOGIC.fog_update()
	check_turn()

func action_attack(direction,collider):
	var cellA = NODE_MAIN.position
	var cellB = NODE_MAIN.position + (direction * grid_size)
	
	#ANIMATION FLIP CHECK
	if cellA - cellB == Vector2(-grid_size,0): animation_flip(false,false)
	if cellA - cellB == Vector2(grid_size,0): animation_flip(true,false)

	NODE_MAIN.z_index += 1
	NODE_MAIN.calculate_melee_damage(self,collider)
	NODE_MAIN.action_attack_tween(cellA,cellB)
	Sound.play_sound(self,sound_on_melee)
	yield(NODE_TWEEN,"tween_all_completed")
	NODE_MAIN.z_index -= 1
	check_turn()

func raycast_cast_to(node_name,cell_start,cell_finish):
	var cell_cast_to = Vector2(((cell_finish.x-cell_start.x)*grid_size),((cell_finish.y-cell_start.y)*grid_size))
	node_name.cast_to = Vector2(cell_cast_to.x,cell_cast_to.y)
	node_name.force_raycast_update()

func action_finish():
	yield(get_tree(),"idle_frame")
	pass

func check_ammo():
	if stat_ammo >= 1 && PLAYER_ACTION_SHOOT == false:
		PLAYER_ACTION_SHOOT = true
	elif stat_ammo == 0 && PLAYER_ACTION_SHOOT == false:
		Sound.play_sound(self,Sound.sfx_noammo)
	else:
		pass

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
		Sound.play_sound_death(is_attacker,is_target.sound_on_death)
		Global.LEVEL_LAYER_LOGIC.remove_child(is_target)
		is_target.queue_free()
	elif is_target.stat_health > 0:
		Sound.play_sound(is_target,is_target.sound_on_hit)
	yield(self.action_finish(),"completed")

func calculate_ranged_damage(is_attacker,is_target):
	is_target.stat_health -= is_attacker.stat_ranged_dmg
	if is_target.stat_health <= 0: 
		Sound.play_sound_death(is_attacker,is_target.sound_on_death)
		Global.LEVEL_LAYER_LOGIC.remove_child(is_target)
		is_target.queue_free()
	elif is_target.stat_health > 0:
		Sound.play_sound(is_target,is_target.sound_on_hit)
	yield(self.action_finish(),"completed")

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

func action_shoot_tween(start,finish):
	if start - finish == Vector2(0,-grid_size): finish = Vector2(finish.x,finish.y-(grid_size/2))
	if start - finish == Vector2(grid_size,0):  finish = Vector2((grid_size/2)+finish.x,finish.y)
	if start - finish == Vector2(-grid_size,0): finish = Vector2(finish.x-(grid_size/2),finish.y)
	if start - finish == Vector2(0,grid_size):  finish = Vector2(finish.x,finish.y+(grid_size/2))
	
	NODE_TWEEN.interpolate_property(self,"position",start,finish,0.5/tween_speed)
	NODE_TWEEN.start()
	yield(NODE_TWEEN,"tween_completed")
	NODE_TWEEN.interpolate_property(self,"position",finish,start,1.0/tween_speed)
	NODE_TWEEN.start()
	yield(NODE_TWEEN,"tween_completed")
	NODE_TWEEN.emit_signal("tween_all_completed")

func get_negative_vector(origin_vector, destination_vector):
	var negative_vector = (destination_vector - origin_vector).tangent().tangent() + origin_vector
	return Vector2(negative_vector.x,negative_vector.y)

func get_idle_frame():
	yield(get_tree(),"idle_frame")
