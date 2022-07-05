extends Node

onready var NODE_GUI = get_node("/root/Main/GUI")

onready var GUI_LAYER_SHADER = get_node("/root/Main/GUI/GUI_LAYER_SHADER")
onready var GUI_LAYER_MAIN = get_node("/root/Main/GUI/GUI_LAYER_MAIN")
onready var GUI_LAYER_INVENTORY = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY")
onready var GUI_SLOT_1 = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/Inventory/ItemSlot1")
onready var GUI_SLOT_1_ICON = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/Inventory/ItemSlot1/ItemIcon")
onready var GUI_SLOT_2 = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/Inventory/ItemSlot2")
onready var GUI_SLOT_2_ICON = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/Inventory/ItemSlot2/ItemIcon")
onready var GUI_SLOT_3 = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/Inventory/ItemSlot3")
onready var GUI_SLOT_3_ICON = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/Inventory/ItemSlot3/ItemIcon")
onready var GUI_SLOT_4 = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/Inventory/ItemSlot4")
onready var GUI_SLOT_4_ICON = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/Inventory/ItemSlot4/ItemIcon")
onready var GUI_SLOT_5 = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/Inventory/ItemSlot5")
onready var GUI_SLOT_5_ICON = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/Inventory/ItemSlot5/ItemIcon")
onready var GUI_SLOT_6 = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/Inventory/ItemSlot6")
onready var GUI_SLOT_6_ICON = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/Inventory/ItemSlot6/ItemIcon")
onready var GUI_WEAPON = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/EquipmentWeapon")
onready var GUI_WEAPON_ICON = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/EquipmentWeapon/ItemIcon")
onready var GUI_ITEM = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/EquipmentItem")
onready var GUI_ITEM_ICON = get_node("/root/Main/GUI/GUI_LAYER_INVENTORY/EquipmentItem/ItemIcon")

onready var UI_TEXT = get_node("/root/Main/GUI/GUI_LAYER_MAIN/UI_TEXT")
onready var UI_TEXTLOG = get_node("/root/Main/GUI/GUI_LAYER_MAIN/UI_TEXT/UI_TEXTLOG")
onready var UI_MAIN = get_node("/root/Main/GUI/GUI_LAYER_MAIN/UI_MAIN")
onready var UI_HEALTH = get_node("/root/Main/GUI/GUI_LAYER_MAIN/UI_MAIN/UI_HEALTH")
onready var UI_SHIELD = get_node("/root/Main/GUI/GUI_LAYER_MAIN/UI_MAIN/UI_SHIELD")
onready var UI_AMMO = get_node("/root/Main/GUI/GUI_LAYER_MAIN/UI_MAIN/UI_AMMO")
onready var UI_TURN = get_node("/root/Main/GUI/GUI_LAYER_MAIN/UI_MAIN/UI_TURN")

onready var NODE_TEXTLOG = get_node("/root/Main/Control/TextLog")
onready var NODE_MAIN = get_node("/root/Main")

var NODE_PLAYER

# LOADED LEVEL VARIABLES
#---------------------------------------------------------------------------------------
var LEVEL_LAYER_FOG
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
	ITEM = "ITEM",
	WEAPON = "WEAPON",
	PLAYER = "PLAYER",
	HOSTILE = "HOSTILE",
	OBJECT = "OBJECT",
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
func _ready():
	pass

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
