extends KinematicBody2D

onready var NODE_ANIMATED_SPRITE = $AnimatedSprite
onready var NODE_COLLISION_2D = $CollisionShape2D
onready var NODE_RAYCAST_COLLIDE = $RayCastCollide
onready var NODE_SOUND = $Sound
onready var NODE_TWEEN = $Tween
onready var NODE_MAIN = self

const ANIMATIONS= {
	IDLE = "IDLE"
}

const tween_speed = 8
const grid_size = 8

var AI_state = Global.AI_STATE_LIST.STATE_IDLE
var AI_class = Global.AI_CLASS_LIST.CLASS_MELEE

# SOUNDS
#---------------------------------------------------------------------------------------
var sound_on_move = Sound.sfx_move
var sound_on_hit = Sound.sfx_hit_0
var sound_on_ranged = Sound.sfx_shoot
var sound_on_melee = Sound.sfx_punch_0
var sound_on_death = Sound.sfx_death_4

# STATS
#---------------------------------------------------------------------------------------
var stat_ranged_dmg:int = 1
var stat_melee_dmg:int = 2
var stat_ambition:int = 3
var stat_health:int = 8
var stat_speed:int = 1
var stat_ammo:int = 0

# SIGNALS
#---------------------------------------------------------------------------------------
signal on_action_finished

# READY
#---------------------------------------------------------------------------------------
func _ready():
	randomize()
	NODE_ANIMATED_SPRITE.set_animation(ANIMATIONS.IDLE)
	NODE_ANIMATED_SPRITE.set_frame(rand_range(0,NODE_ANIMATED_SPRITE.get_sprite_frames().get_frame_count(ANIMATIONS.IDLE)))
	animation_flip(randi()%2,false)
	
#	Global.NODE_MAIN.connect("on_action_move_finished",self,"on_action_move")
	pass

func animation_flip(is_flip_h:bool, is_flip_v:bool):
	NODE_ANIMATED_SPRITE.flip_h = is_flip_h
	NODE_ANIMATED_SPRITE.flip_v = is_flip_v
	pass

func animation_change(animation_type:String,is_playing:bool,is_random:bool):
	NODE_ANIMATED_SPRITE.set_animation(animation_type)
	NODE_ANIMATED_SPRITE.playing = is_playing
	if is_random == true:
		NODE_ANIMATED_SPRITE.set_frame(rand_range(0,NODE_ANIMATED_SPRITE.get_sprite_frames().get_frame_count(animation_type)))
	if is_random == false:
		pass
	pass

func on_action_move():
	var directions_array = [Vector2.UP,Vector2.DOWN,Vector2.LEFT,Vector2.RIGHT]
	var position_a:Vector2 = Vector2(self.position.x/grid_size,self.position.y/grid_size)
	var position_b:Vector2

	directions_array.shuffle()
	for direction in directions_array:
		position_b = position_a+direction
		raycast_cast_to(NODE_RAYCAST_COLLIDE,position_a,position_b)
		if NODE_RAYCAST_COLLIDE.is_colliding() == false:
			var spawn = get_chance(50)
			if spawn == true:
				var mob_instance = Global.NODE_MAIN.level_mob_spawn_tween("Goo",position_a,position_b)
				mob_instance.AI_state = Global.AI_STATE_LIST.STATE_ENGAGE
				yield(mob_instance.get_node("Tween"),"tween_all_completed")
				break
			if spawn == false:
				break
		elif NODE_RAYCAST_COLLIDE.is_colliding() == true:
			pass
	yield(get_idle_frame(),"completed")
	emit_signal("on_action_finished")
	pass

func on_action_attack():
	yield(self.get_idle_frame(),"completed")
	emit_signal("on_action_finished")
	pass

func action_move_tween(start,finish):
	NODE_TWEEN.interpolate_property(self,'position',start,finish,1.0/tween_speed, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	NODE_TWEEN.start()
	yield(NODE_TWEEN,"tween_completed")
	NODE_TWEEN.emit_signal("tween_all_completed")
	pass

func action_attack_tween(start,finish):
	NODE_TWEEN.interpolate_property(self,"position",start,finish,0.75/tween_speed)
	NODE_TWEEN.start()
	yield(NODE_TWEEN,"tween_completed")
	NODE_TWEEN.interpolate_property(self,"position",finish,start,1.0/tween_speed)
	NODE_TWEEN.start()
	yield(NODE_TWEEN,"tween_completed")
	NODE_TWEEN.emit_signal("tween_all_completed")
	pass

func raycast_cast_to(node_name,cell_start,cell_finish):
	var cell_cast_to = Vector2(((cell_finish.x-cell_start.x)*grid_size),((cell_finish.y-cell_start.y)*grid_size))
	node_name.cast_to = Vector2(cell_cast_to.x,cell_cast_to.y)
	node_name.force_raycast_update()

func get_idle_frame():
	yield(get_tree(),"idle_frame")

func get_chance(percentage):
	randomize()
	if randi() % 100 <= percentage:  
		return true
	else:                     
		return false
