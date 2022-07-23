extends Mob2D

var AI_state = Global.AI_STATE_LIST.STATE_IDLE
var AI_class = Global.AI_CLASS_LIST.CLASS_MELEE

# SOUNDS
#---------------------------------------------------------------------------------------
var sound_on_move = Sound.sfx_move
var sound_on_hit = Sound.sfx_hit_0
var sound_on_melee = Sound.sfx_punch_0
var sound_on_death = Sound.sfx_death_1

# STATS
#---------------------------------------------------------------------------------------
var stat_ranged_damage:int = 1
var stat_melee_dmg:int = 1
var stat_ambition:int = 3
var stat_health:int = 3
var stat_speed:int = 1
var stat_ammo:int = 0

# SIGNALS
#---------------------------------------------------------------------------------------
signal on_action_finished

# READY
#---------------------------------------------------------------------------------------
func _ready():
	randomize()
	var animation = get_animation(1,4)
	NODE_ANIMATED_SPRITE.set_animation(animation)
	NODE_ANIMATED_SPRITE.set_frame(rand_range(0,NODE_ANIMATED_SPRITE.get_sprite_frames().get_frame_count(animation)))
	animation_flip(randi()%2,false)
	pass

func on_action_move():
	yield(self.get_idle_frame(),"completed")
	emit_signal("on_action_finished")
	pass

func on_action_attack():
	yield(self.get_idle_frame(),"completed")
	emit_signal("on_action_finished")
	pass

func on_action_shoot():
	yield(self.get_idle_frame(),"completed")
	emit_signal("on_action_finished")
	pass
