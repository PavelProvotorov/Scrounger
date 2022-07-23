extends Node

var sfx_pickup = preload("res://Sounds/sfx_pickup.mp3")
var sfx_move = preload("res://Sounds/sfx_move.mp3")
var sfx_spit = preload("res://Sounds/sfx_spit.mp3")
var sfx_shoot_0 = preload("res://Sounds/sfx_shoot_0.mp3")
var sfx_shoot_1 = preload("res://Sounds/sfx_shoot_1.mp3")
var sfx_hit_0 = preload("res://Sounds/sfx_hit_0.mp3")
var sfx_punch_0 = preload("res://Sounds/sfx_punch_0.mp3")
var sfx_noammo = preload("res://Sounds/sfx_noammo.mp3")
var sfx_death_0 = preload("res://Sounds/sfx_death_0.mp3")
var sfx_death_1 = preload("res://Sounds/sfx_death_1.mp3")
var sfx_death_2 = preload("res://Sounds/sfx_death_2.mp3")
var sfx_death_3 = preload("res://Sounds/sfx_death_3.mp3")
var sfx_death_4 = preload("res://Sounds/sfx_death_4.mp3")

# SIGNALS
#---------------------------------------------------------------------------------------
signal on_sound_finished

#---------------------------------------------------------------------------------------
func play_sound(entity,sound_name):
	entity.NODE_SOUND.stream = sound_name
	entity.NODE_SOUND.play()
	pass

func play_sound_deferred(entity,sound_name):
	entity.NODE_SOUND.stream = sound_name
	entity.NODE_SOUND.play()
	emit_signal("on_sound_finished")
	pass

func play_sound_death(entity,sound_name):
	entity.NODE_SOUND_DEATH.stream = sound_name
	entity.NODE_SOUND_DEATH.play()
	pass

func get_idle_frame():
	yield(get_tree(),"idle_frame")
