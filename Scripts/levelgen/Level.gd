extends Node2D

func _ready():
	Global.LEVEL = self
	Global.LEVEL_LAYER_FOG = $Fog
	Global.LEVEL_LAYER_DECO = $Deco
	Global.LEVEL_LAYER_BASE = $Base
	Global.LEVEL_LAYER_LOGIC = $Logic
	self.z_index = -1
	pass
	
	
