extends Item2D

onready var NODE_SOUND = $Sound

# READY
#---------------------------------------------------------------------------------------
func _ready():
	randomize()
	NODE_SOUND.stream = Sound.sfx_pickup
	count = round(rand_range(3,6))
	pass

# ACTIONS
#---------------------------------------------------------------------------------------
func on_action_pickup():
	item_pickup_consumable()
	yield(self.get_idle_frame(),"completed")

func on_action_use():
	if Data.EQUIPMENT[0].empty() == false:
		Global.NODE_PLAYER.stat_ammo_bullet += count
		Sound.play_sound(self,Sound.sfx_pickup)
	
		# REMOVE FROM INVENTORY
		item_inventory_remove()

func on_action_tick():
	pass
