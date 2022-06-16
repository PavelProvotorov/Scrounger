extends StaticBody2D

onready var NODE_SOUND = $Sound
var inventory_slot_texture
var inventory_slot_id
var inventory_slot
var count

func _ready():
	randomize()
	NODE_SOUND.stream = Sound.sfx_pickup
	count = round(rand_range(1,2))
	pass

func on_action_pickup():
	for key in Data.INVENTORY:
		var slot = Data.INVENTORY[key]
		if slot.empty() == true:
			slot.append(self)
			inventory_slot = Data.INVENTORY[key]
			inventory_slot_id = Data.INVENTORY_SLOT[key][0]
			inventory_slot_texture = Data.INVENTORY_SLOT_ICON[key][0]
			Global.LEVEL_LAYER_LOGIC.remove_child(self) 
			Data.INVENTORY_SLOT[key][0].add_child(self)
			Data.INVENTORY_SLOT_ICON[key][0].texture = $Sprite.texture
			Sound.play_sound(self,Sound.sfx_pickup)
			break
	yield(self.get_idle_frame(),"completed")

func on_action_use():
	Global.NODE_PLAYER.stat_health += count
	Sound.play_sound(self,Sound.sfx_pickup)
	
	# REMOVE FROM INVENTORY
	inventory_slot.clear()
	inventory_slot_texture.set_texture(null)
	inventory_slot_id.remove_child(self)
	self.queue_free()

func on_action_tick():
	pass

func get_idle_frame():
	yield(get_tree(),"idle_frame")
