extends Item2D

onready var NODE_SOUND = $Sound

# READY
#---------------------------------------------------------------------------------------
func _ready():
	randomize()
	stat_ranged_dmg = 3
	stat_ammo = round(rand_range(6,10))
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
