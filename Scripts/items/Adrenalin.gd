extends Item2D

onready var NODE_SOUND = $Sound

# READY
#---------------------------------------------------------------------------------------
func _ready():
	randomize()
	NODE_SOUND.stream = Sound.sfx_pickup
	pass

# ACTIONS
#---------------------------------------------------------------------------------------
func on_action_pickup():
	item_pickup_consumable()

func on_action_use():
	Global.LEVEL_LAYER_LOGIC.level_modifier_spawn("BuffSpeed",Global.NODE_PLAYER)
	item_inventory_remove()

func on_action_tick():
	pass
