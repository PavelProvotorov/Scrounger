extends Node2D

# READY
#---------------------------------------------------------------------------------------
func _ready():
	level_load("Level")
	pass

func level_load(level_name:String):
	var level_data = load("res://Scenes/%s.tscn" %level_name)
	var level_instance = level_data.instance()
	add_child(level_instance)
	pass
