extends Node

# INVENTORY
#---------------------------------------------------------------------------------------
onready var INVENTORY_SLOT_ICON = {
	1: [Global.GUI_SLOT_1_ICON],
	2: [Global.GUI_SLOT_2_ICON],
	3: [Global.GUI_SLOT_3_ICON],
	4: [Global.GUI_SLOT_4_ICON],
	5: [Global.GUI_SLOT_5_ICON],
	6: [Global.GUI_SLOT_6_ICON]
}
onready var INVENTORY_SLOT = {
	1: [Global.GUI_SLOT_1],
	2: [Global.GUI_SLOT_2],
	3: [Global.GUI_SLOT_3],
	4: [Global.GUI_SLOT_4],
	5: [Global.GUI_SLOT_5],
	6: [Global.GUI_SLOT_6]
}
onready var INVENTORY = {
	1: [],
	2: [],
	3: [],
	4: [],
	5: [],
	6: []
}
onready var EQUIPMENT = {
	0: [],
}

# MOBS
#---------------------------------------------------------------------------------------
onready var MOB_LIST = {
	1: {
		"Grunt": 100,
		"Parasite": 35,
		"Hydra": 15,
		"Bloater": 5
	},
	2: {
		"Grunt": 100,
		"Parasite": 40,
		"Hydra": 25,
		"Bloater": 15,
		"Goo": 5
	},
	3: {
		"Grunt": 50,
		"Parasite": 45,
		"Hydra": 30,
		"Bloater": 20,
		"Sludge": 15,
		"Goo": 25
	},
}

# ITEMS
#---------------------------------------------------------------------------------------
onready var ITEM_LIST = {
	1: {
		"Ammo": 100,
		"Medkit": 50,
		"Shotgun": 15,
		"TacticalShotgun":5
	},
	2: {
		"Ammo": 100,
		"Medkit": 45,
		"Shotgun": 10,
		"TacticalShotgun":10
	},
	3: {
		"Ammo": 100,
		"Medkit": 35,
		"Shotgun": 5,
		"TacticalShotgun":15
	},
}

# OBJECTS
#---------------------------------------------------------------------------------------
onready var OBJECT_LIST = {
	1: {
		"Locker": 80,
		"Terminal": 15
	},
	2: {
		"Locker": 80,
		"Terminal": 15
	},
	3: {
		"Locker": 80,
		"Terminal": 15
	},
}
