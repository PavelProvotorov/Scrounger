extends Node

onready var NODE_GUI = get_node("/root/Main/GUI")

onready var GUI_LAYER_SHADER = get_node("/root/Main/GUI/GUI_LAYER_SHADER")
onready var GUI_LAYER_INVENTORY = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY")
onready var GUI_LAYER_MAIN = get_node("/root/Main/GUI/GUI_LAYER_MAIN")

onready var UI_HEALTH = get_node("/root/Main/GUI/GUI_LAYER_MAIN/UI_MAIN/UI_HEALTH")
onready var UI_SHIELD = get_node("/root/Main/GUI/GUI_LAYER_MAIN/UI_MAIN/UI_SHIELD")
onready var UI_AMMO = get_node("/root/Main/GUI/GUI_LAYER_MAIN/UI_MAIN/UI_AMMO")
onready var UI_TURN = get_node("/root/Main/GUI/GUI_LAYER_MAIN/UI_MAIN/UI_TURN")

onready var NODE_TEXTLOG = get_node("/root/Main/Control/TextLog")
onready var NODE_MAIN = get_node("/root/Main")

var NODE_PLAYER

# LOADED LEVEL VARIABLES
#---------------------------------------------------------------------------------------
var LEVEL_LAYER_LOGIC
var LEVEL_LAYER_BASE
var LEVEL_LAYER_WALL
var LEVEL_LAYER_DECO
var LEVEL_QUEUE
var LEVEL

#---------------------------------------------------------------------------------------
var GAME_STATE = GAME_STATE_LIST.STATE_PLAYER_TURN

const GAME_WINDOW_SIZE = {
	WINDOW_SIZE_0 = Vector2(480,270),
	WINDOW_SIZE_1 = Vector2(960,540),
	WINDOW_SIZE_2 = Vector2(1280,720),
	WINDOW_SIZE_3 = Vector2(1440,810),
	WINDOW_SIZE_4 = Vector2(1920,1080)
}
const GAME_SET_LANGUAGE = {
	GAME_LANG_RUS = "rus",
	GAME_LANG_ENG = "eng"
}
const GAME_WINDOW_FULL = {
	WINDOW_FULL_0 = false,
	WINDOW_FULL_1 = true
}
const ANIMATIONS = {
	MELEE_ATTACK = "MELEE_ATTACK",
	MELEE_IDLE  = "MELEE_IDLE"
}
const GROUPS = {
	PLAYER = "PLAYER",
	HOSTILE = "HOSTILE",
	ALLY = "ALLY",
	NONE = "NONE"
}
enum AI_STATE_LIST {
	STATE_IDLE,
	STATE_WANDER,
	STATE_ENGAGE,
	STATE_NONE
}
enum AI_CLASS_LIST {
	CLASS_MELEE,
	CLASS_RANGED,
	CLASS_NONE
}
enum GAME_STATE_LIST {
	STATE_PLAYER_TURN,
	STATE_MOB_TURN,
	STATE_PAUSE,
	STATE_NONE
}

var gameTargetNode
var gameMovingNode

#---------------------------------------------------------------------------------------
func game_state_manager(state):
	GAME_STATE = state
	if GAME_STATE == GAME_STATE_LIST.STATE_NONE:
		print("< NO GAME STATE>")
	elif GAME_STATE == GAME_STATE_LIST.STATE_PLAYER_TURN:
		print("< PLAYER MOVEMENT STARTED >")
		NODE_PLAYER.turn_count = 0
	elif GAME_STATE == GAME_STATE_LIST.STATE_MOB_TURN:
		print("< MOB MOVEMENT STARTED >")
		NODE_MAIN.level_queue_prepare()
		NODE_MAIN.manager_mob()
	else:
		pass
	pass
