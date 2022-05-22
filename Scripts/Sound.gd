extends Node

var sfx_pickup = preload("res://Sounds/sfx_pickup.mp3")
var sfx_move = preload("res://Sounds/sfx_move.mp3")
var sfx_shoot = preload("res://Sounds/sfx_shoot.mp3")
var sfx_hit_0 = preload("res://Sounds/sfx_hit_0.mp3")
var sfx_punch_0 = preload("res://Sounds/sfx_punch_0.mp3")
var sfx_noammo = preload("res://Sounds/sfx_noammo.mp3")

func play_sound(entity,sound_name):
	entity.NODE_SOUND.stream = sound_name
	entity.NODE_SOUND.play()
	pass
