extends Node
class_name Modifier2D

var modifier_name
var modifier_owner
var modifier_duration

func _ready():
	pass

func modifier_add(data_owner,data_name,data_duration):
	modifier_name = data_name
	modifier_owner = data_owner
	modifier_duration = data_duration

func modifier_remove():
	modifier_owner.modifier_list.erase(self)
	modifier_owner.remove_child(self)
	self.queue_free()

func check_duration():
	modifier_duration -= 1
	if modifier_duration <= 0: return true
	if modifier_duration >= 1: return false

func get_idle_frame():
	yield(Global.NODE_MAIN.get_tree(),"idle_frame")
