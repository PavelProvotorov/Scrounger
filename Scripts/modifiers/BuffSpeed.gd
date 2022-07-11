extends Modifier2D

# READY
#---------------------------------------------------------------------------------------
func _ready():
#	yield(self.get_idle_frame(),"completed")
	on_action_add()
	pass

# ACTIONS
#---------------------------------------------------------------------------------------
func on_action_add():
	yield(self.get_idle_frame(),"completed")
	modifier_duration = 6
	modifier_owner.stat_speed += 1

func on_action_tick():
	var remove = check_duration()
	if remove == true: on_action_remove()

func on_action_remove():
	modifier_owner.stat_speed -= 1
	modifier_owner.turn_count -= 1
	modifier_remove()
