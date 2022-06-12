extends Node

var sfx_pickup = preload("res://Sounds/sfx_pickup.mp3")
var sfx_move = preload("res://Sounds/sfx_move.mp3")
var sfx_shoot = preload("res://Sounds/sfx_shoot.mp3")
var sfx_hit_0 = preload("res://Sounds/sfx_hit_0.mp3")
var sfx_punch_0 = preload("res://Sounds/sfx_punch_0.mp3")
var sfx_noammo = preload("res://Sounds/sfx_noammo.mp3")
var sfx_death_0 = preload("res://Sounds/sfx_death_0.mp3")
var sfx_death_1 = preload("res://Sounds/sfx_death_1.mp3")
var sfx_death_2 = preload("res://Sounds/sfx_death_2.mp3")
var sfx_death_3 = preload("res://Sounds/sfx_death_3.mp3")
var sfx_death_4 = preload("res://Sounds/sfx_death_4.mp3")

func play_sound(entity,sound_name):
	entity.NODE_SOUND.stream = sound_name
	entity.NODE_SOUND.play()
	pass

func play_sound_death(entity,sound_name):
	entity.NODE_SOUND_DEATH.stream = sound_name
	entity.NODE_SOUND_DEATH.play()
	pass
