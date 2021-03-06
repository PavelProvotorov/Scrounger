extends Mob2D

onready var NODE_RAYCAST_MOB = $RayCastMob
onready var NODE_RAYCAST_FOG = $RayCastFog
onready var NODE_SOUND_DEATH = $SoundDeath
onready var NODE_CAMERA_2D = $Camera2D

const INPUT_LIST = {
	UI_UP    = "ui_up",
	UI_DOWN  = "ui_down",
	UI_LEFT  = "ui_left",
	UI_RIGHT = "ui_right",
	UI_PICK  = "ui_pick",
	UI_SHOOT = "ui_shoot",
	UI_SKIP  = "ui_skip",
	UI_1     = "ui_1",
	UI_2     = "ui_2",
	UI_3     = "ui_3",
	UI_4     = "ui_4",
	UI_5     = "ui_5",
	UI_6     = "ui_6"
}

var turn_count:int

var PLAYER_ACTION_SHOOT = false
var PLAYER_ACTION_INPUT = false
var PLAYER_ACTION_TEXT = false

# SIGNALS
#---------------------------------------------------------------------------------------
signal on_action_finished

# SOUNDS
#---------------------------------------------------------------------------------------
var sound_on_move = Sound.sfx_move
var sound_on_hit = Sound.sfx_hit_0
var sound_on_melee = Sound.sfx_punch_0
var sound_on_death = Sound.sfx_death_0

# STATS
#---------------------------------------------------------------------------------------
var stat_visibility:int = 2
var stat_melee_dmg:int = 2
var stat_ambition:int = 3

var stat_shield:int = 0
var stat_speed:int = 1

const stat_health_max:int = 99
var stat_health:int = 10

const stat_ammo_bullet_max:int = 99
var stat_ammo_bullet:int = 10

const stat_ammo_shell_max:int = 99
var stat_ammo_shell:int = 30

const stat_ammo_plasma_max:int = 99
var stat_ammo_plasma:int = 0

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
	NODE_ANIMATED_SPRITE.set_animation(ANIMATIONS.MELEE)
	NODE_ANIMATED_SPRITE.set_frame(rand_range(0,NODE_ANIMATED_SPRITE.get_sprite_frames().get_frame_count(ANIMATIONS.IDLE)))
	pass

func _unhandled_input(key):
	if NODE_TWEEN.is_active():
		return
	for input in INPUT_LIST.values():
		if key.is_action_pressed(input):
			if Global.GAME_STATE == Global.GAME_STATE_LIST.STATE_PLAYER_TURN:
				if PLAYER_ACTION_INPUT == false && PLAYER_ACTION_SHOOT == false && PLAYER_ACTION_TEXT == false:
					if input == INPUT_LIST.UI_SHOOT && Data.EQUIPMENT[0].empty() == false: check_ammo(Global.GUI_WEAPON.get_child(1).ammo_type)
					if input == INPUT_LIST.UI_UP:    action_collision_check(Vector2.UP)
					if input == INPUT_LIST.UI_DOWN:  action_collision_check(Vector2.DOWN)
					if input == INPUT_LIST.UI_LEFT:  action_collision_check(Vector2.LEFT)
					if input == INPUT_LIST.UI_RIGHT: action_collision_check(Vector2.RIGHT)
					if input == INPUT_LIST.UI_PICK:  action_interact(Vector2(0,0))
					if input == INPUT_LIST.UI_SKIP:  check_turn()
					if input == INPUT_LIST.UI_1: action_use(1,Global.GUI_SLOT_1)
					if input == INPUT_LIST.UI_2: action_use(2,Global.GUI_SLOT_2)
					if input == INPUT_LIST.UI_3: action_use(3,Global.GUI_SLOT_3)
					if input == INPUT_LIST.UI_4: action_use(4,Global.GUI_SLOT_4)
					if input == INPUT_LIST.UI_5: action_use(5,Global.GUI_SLOT_5)
					if input == INPUT_LIST.UI_6: action_use(6,Global.GUI_SLOT_6)

				elif PLAYER_ACTION_INPUT == false && PLAYER_ACTION_SHOOT == true && PLAYER_ACTION_TEXT == false:
					if input == INPUT_LIST.UI_UP:    
						action_shoot(Vector2.UP)
					if input == INPUT_LIST.UI_DOWN:  
						action_shoot(Vector2.DOWN)
					if input == INPUT_LIST.UI_LEFT:  
						action_shoot(Vector2.LEFT)
					if input == INPUT_LIST.UI_RIGHT: 
						action_shoot(Vector2.RIGHT)
					if input == INPUT_LIST.UI_SHOOT:
						NODE_ANIMATED_SPRITE.set_animation(ANIMATIONS.MELEE)
						PLAYER_ACTION_SHOOT = false
					if input == INPUT_LIST.UI_SKIP:  
						check_turn()
				
				elif PLAYER_ACTION_INPUT == false && PLAYER_ACTION_SHOOT == false && PLAYER_ACTION_TEXT == true:
					Global.UI_TEXT.hide()
					PLAYER_ACTION_TEXT = false
					pass
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
					var cell_to_check = Global.LEVEL_LAYER_LOGIC.get_cellv(collider_cell+Vector2.DOWN)
					Global.LEVEL_LAYER_LOGIC.set_cell(collider_cell.x,collider_cell.y,Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_FLOOR)
					if cell_to_check == Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_FLOOR:
						Global.LEVEL_LAYER_LOGIC.tilemap_texture_set_fixed(Global.LEVEL_LAYER_BASE,Global.LEVEL_LAYER_LOGIC.TILESET_BASE.TILE_DOOR_OPEN,collider_cell,0)
						Global.LEVEL_LAYER_LOGIC.tilemap_texture_set_fixed(Global.LEVEL_LAYER_WALL,Global.LEVEL_LAYER_LOGIC.TILESET_BASE.TILE_WALL,collider_cell+Vector2.DOWN,7)
					if cell_to_check != Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_FLOOR:
						Global.LEVEL_LAYER_LOGIC.tilemap_texture_set_fixed(Global.LEVEL_LAYER_BASE,Global.LEVEL_LAYER_LOGIC.TILESET_BASE.TILE_DOOR_OPEN,collider_cell,0)
					Global.LEVEL_LAYER_LOGIC.update_dirty_quadrants()
					yield(self.get_idle_frame(),"completed")
					Global.LEVEL_LAYER_LOGIC.fog_update()
					check_turn()
					done = true
				elif collider_cell_id == Global.LEVEL_LAYER_LOGIC.TILESET_LOGIC.TILE_OBJECT:
					var object_array = get_tree().get_nodes_in_group(Global.GROUPS.OBJECT)
					for object in object_array:
						if object.position == cellB:
							print(object)
							pass
					PLAYER_ACTION_TEXT = true
					action_textlog()
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
					Global.LEVEL_LAYER_LOGIC.level_projectile_spawn(Global.GUI_WEAPON.get_child(1).projectile_type,NODE_POSITION_2D,direction,false)
					action_shoot_tween(cellA,get_negative_vector(cellA,cellB))
					NODE_MAIN.calculate_ranged_damage(self,collider,Global.GUI_WEAPON.get_child(1).stat_ranged_damage,Global.GUI_WEAPON.get_child(1).ammo_type)
					Sound.play_sound(self,Global.GUI_WEAPON.get_child(1).sound_on_ranged)
					yield(self.NODE_TWEEN,"tween_all_completed")
					yield(self,"on_action_finished")
					done = true
			elif collider.get_class() == "StaticBody2D":
				if collider.is_in_group(Global.GROUPS.ITEM) == true:
					NODE_RAYCAST_COLLIDE.add_exception(collider)
			elif collider.get_class() == "TileMap": 
				done = true
			else:
				pass
	yield(self.get_idle_frame(),"completed")
	NODE_RAYCAST_COLLIDE.clear_exceptions()
	PLAYER_ACTION_INPUT = false
	NODE_ANIMATED_SPRITE.set_animation(ANIMATIONS.MELEE)
	PLAYER_ACTION_SHOOT = false
	check_turn()

func action_textlog():
	Global.UI_TEXT.show()
	Global.UI_TEXTLOG.text = "< We did it boyz, we got a text inside a textlog....but now what...my life feels so empty now that I have accomplished my goals...just...why is life cruel to me D: >"
	Global.UI_TEXTLOG.show_text()
	pass

func action_use(slot_id,slot_ui):
	PLAYER_ACTION_INPUT = true
	
	var slot = Data.INVENTORY[slot_id]
	if slot.empty() == false:
		var item = slot[0]
		item.on_action_use()
		yield(self.get_idle_frame(),"completed")
		check_turn()
	yield(self.get_idle_frame(),"completed")
	PLAYER_ACTION_INPUT = false
	pass

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
						collider.on_action_pickup()
						yield(self.get_idle_frame(),"completed")
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
#	yield(self,"on_action_finished")
	NODE_MAIN.z_index -= 1
	check_turn()

func raycast_cast_to(node_name,cell_start,cell_finish):
	var cell_cast_to = Vector2(((cell_finish.x-cell_start.x)*grid_size),((cell_finish.y-cell_start.y)*grid_size))
	node_name.cast_to = Vector2(cell_cast_to.x,cell_cast_to.y)
	node_name.force_raycast_update()

func action_finish():
	yield(get_tree(),"idle_frame")
	pass

func check_ammo(ammo_type):
	var ammo = get(ammo_type)
	if ammo >= 1 && PLAYER_ACTION_SHOOT == false:
		NODE_ANIMATED_SPRITE.set_animation(ANIMATIONS.RANGED)
		PLAYER_ACTION_SHOOT = true
	elif ammo == 0 && PLAYER_ACTION_SHOOT == false:
		Sound.play_sound(self,Sound.sfx_noammo)

func check_turn():
	turn_count += 1
	var check_modifier_list = modifier_list
	for modifier in check_modifier_list:
		modifier.on_action_tick()
	if turn_count != stat_speed: pass
	if turn_count == stat_speed: Global.game_state_manager(Global.GAME_STATE_LIST.STATE_MOB_TURN)

func ui_update():
	if Data.EQUIPMENT[0].empty() == false:
		var ammo = get(Global.GUI_WEAPON.get_child(1).ammo_type)
		Global.UI_AMMO.set_text(ammo as String)
	Global.UI_HEALTH.set_text(self.stat_health as String)
	Global.UI_SHIELD.set_text(self.stat_shield as String)
	Global.UI_TURN.set_text((self.stat_speed - self.turn_count)as String)

func calculate_melee_damage(is_attacker,is_target):
	is_target.stat_health -= is_attacker.stat_melee_dmg
	if is_target.stat_health <= 0:
#		is_target.NODE_ANIMATED_SPRITE.hide()
#		Sound.call_deferred("play_sound_deferred",is_target,is_target.sound_on_death)
#		yield(is_target.NODE_SOUND,"finished")
		Sound.play_sound_death(is_attacker,is_target.sound_on_death)
		Global.LEVEL_LAYER_LOGIC.remove_child(is_target)
		is_target.queue_free()
	elif is_target.stat_health > 0:
		Sound.play_sound(is_target,is_target.sound_on_hit)
	yield(self.get_idle_frame(),"completed")

func calculate_ranged_damage(is_attacker,is_target,ranged_damage,ammo_type:String):
	var ammo = get(ammo_type) 
	ammo -= 1
	set(ammo_type,ammo)
	Global.UI_AMMO.set_text(ammo as String)
	is_target.stat_health -= ranged_damage
	if is_target.stat_health <= 0:
		is_target.NODE_ANIMATED_SPRITE.hide()
		Sound.call_deferred("play_sound_deferred",is_target,is_target.sound_on_death)
#		Sound.play_sound_death(is_target,is_target.sound_on_death)
		yield(is_target.NODE_SOUND,"finished")
		Global.LEVEL_LAYER_LOGIC.remove_child(is_target)
		is_target.queue_free()
#		yield(self.get_idle_frame(),"completed")
	elif is_target.stat_health > 0:
		Sound.call_deferred("play_sound_deferred",is_target,is_target.sound_on_hit)
		yield(is_target.NODE_SOUND,"finished")
#		Sound.play_sound(is_target,is_target.sound_on_hit)
#		yield(self.get_idle_frame(),"completed")
	yield(self.get_idle_frame(),"completed")
	emit_signal("on_action_finished")

func get_negative_vector(origin_vector, destination_vector):
	var negative_vector = (destination_vector - origin_vector).tangent().tangent() + origin_vector
	return Vector2(negative_vector.x,negative_vector.y)

func get_idle_frame():
	yield(get_tree(),"idle_frame")
