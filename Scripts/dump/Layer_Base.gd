extends TileMap

onready var node_Deco = get_parent().get_node("Deco")
onready var node_Wall = get_parent().get_node("Wall")
onready var node_Base = get_parent().get_node("Base")
onready var node_Logic = get_parent().get_node("Logic")

func _ready():
	randomize()
	pass

func tilemap_set_cell(atlasID:int,cellList:Array):
	randomize()
	var cell_to_fill_array = cellList
	var tile_array = atlas_get_tiles(atlasID)
	for cell in cell_to_fill_array:
		var tile = tile_array[randi() % tile_array.size()]
		set_cell(cell.x,cell.y,atlasID,false,false,false,tile)
		pass
	pass

func atlas_get_tiles(id):
	var tileset = self.tile_set
	var atlas = tileset.tile_get_region(id)
	var atlas_size_x = atlas.size.x / tileset.autotile_get_size(id).x
	var atlas_size_y = atlas.size.y / tileset.autotile_get_size(id).y
	var atlas_tile_array = []
	for x in range(atlas_size_x):
		for y in range(atlas_size_y):
			var priority = tileset.autotile_get_subtile_priority(id,Vector2(x,y))
			for p in priority:
				atlas_tile_array.append(Vector2(x,y))
	return atlas_tile_array

