extends Item2D

onready var NODE_SOUND = $Sound

# READY
#---------------------------------------------------------------------------------------
func _ready():
	sound_on_ranged = Sound.sfx_shoot_0
	projectile_type = PROJECTILE_TYPE.BULLET
	ammo_type = AMMO_TYPE.BULLET
	stat_ranged_damage = 2
	pass

# ACTIONS
#---------------------------------------------------------------------------------------
func on_action_pickup():
	item_pickup_weapon()
	yield(self.get_idle_frame(),"completed")

func on_action_use():
	pass

func on_action_tick():
	pass
