extends StaticBody2D
class_name Item2D

const AMMO_TYPE = {
	BULLET = "stat_ammo_bullet",
	SHELL  = "stat_ammo_shell",
	PLASMA = "stat_ammo_plasma"
}

const PROJECTILE_TYPE = {
	BULLET = "Bullet",
	SHELL = "Shell",
	PLASMA = "Plasma"
}

var ammo_type
var projectile_type
var stat_ranged_damage:int
var sound_on_ranged
var inventory_slot_texture
var inventory_slot_id
var inventory_slot
var count

func _ready():
	pass
	
func item_pickup_weapon():
	var slot = Data.EQUIPMENT[0]
	if slot.empty() == true:
		slot.append(self)
		Global.LEVEL_LAYER_LOGIC.remove_child(self) 
		Global.GUI_WEAPON.add_child(self)
		Global.GUI_WEAPON_ICON.texture = $Sprite.texture
		Sound.play_sound(self,Sound.sfx_pickup)
	elif slot.empty() == false:
		var current_weapon = Global.GUI_WEAPON.get_child(1)
		current_weapon.position = Global.NODE_PLAYER.position
		slot.clear()
		Global.GUI_WEAPON.remove_child(current_weapon)
		Global.LEVEL_LAYER_LOGIC.add_child(current_weapon)
		slot.append(self)
		Global.LEVEL_LAYER_LOGIC.remove_child(self)
		Global.GUI_WEAPON.add_child(self)
		Global.GUI_WEAPON_ICON.texture = $Sprite.texture
		Sound.play_sound(self,Sound.sfx_pickup)
	pass

func item_pickup_consumable():
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
	pass

func item_inventory_remove():
	inventory_slot.clear()
	inventory_slot_texture.set_texture(null)
	inventory_slot_id.remove_child(self)
	self.queue_free()
	pass

func item_remove():
	Global.LEVEL_LAYER_LOGIC.remove_child(self)
	self.queue_free()
	pass

func get_idle_frame():
	yield(get_tree(),"idle_frame")
