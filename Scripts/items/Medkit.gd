extends StaticBody2D

onready var NODE_SOUND = $Sound
var count

func _ready():
	randomize()
	NODE_SOUND.stream = Sound.sfx_pickup
	count = round(rand_range(1,2))
	pass

func on_pickup():
	Global.NODE_PLAYER.stat_health += count
	Sound.play_sound(self,Sound.sfx_pickup)
	pass
