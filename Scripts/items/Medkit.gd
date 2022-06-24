extends Item2D

onready var NODE_SOUND = $Sound

# READY
#---------------------------------------------------------------------------------------
func _ready():
	randomize()
	NODE_SOUND.stream = Sound.sfx_pickup
	count = round(rand_range(1,2))
	pass

# ACTIONS
#---------------------------------------------------------------------------------------
func on_action_pickup():
	item_pickup_consumable()
	yield(self.get_idle_frame(),"completed")

func on_action_use():
	Global.NODE_PLAYER.stat_health += count
	Sound.play_sound(self,Sound.sfx_pickup)
	
	# REMOVE FROM INVENTORY
	item_inventory_remove()

func on_action_tick():
	pass
