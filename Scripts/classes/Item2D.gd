extends StaticBody2D
class_name Item2D

var stat_ranged_dmg:int
var stat_ammo:int
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
		Global.NODE_PLAYER.stat_ammo = stat_ammo
		stat_ammo = 0
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
		current_weapon.stat_ammo = Global.NODE_PLAYER.stat_ammo
		Global.NODE_PLAYER.stat_ammo = self.stat_ammo
		self.stat_ammo = Global.NODE_PLAYER.stat_ammo
	Global.NODE_PLAYER.stat_ranged_dmg = self.stat_ranged_dmg
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

func get_idle_frame():
	yield(get_tree(),"idle_frame")
