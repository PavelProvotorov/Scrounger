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
var sound_on_death = Sound.sfx_death_3

# STATS
#---------------------------------------------------------------------------------------
var stat_ranged_dmg:int = 1
var stat_melee_dmg:int = 1
var stat_ambition:int = 1
var stat_health:int = 1
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
	yield(self.get_idle_frame(),"completed")
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