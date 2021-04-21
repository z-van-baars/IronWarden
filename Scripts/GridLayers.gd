extends Node2D

onready var cell_obj = preload("res://Scenes/Cell.tscn")
onready var tiles
onready var map_width
onready var map_height

func set_map_parameters(w, h):
	map_width = w
	map_height = h

func get_cell(coordinates):
	return tiles[coordinates.y][coordinates.x]

func set_cell(coordinates, cell_obj):
	tiles[coordinates.y][coordinates.x] = cell_obj

func set_module_refs():
	pass

func set_resource(coordinates, deposit_id):
	get_cell(coordinates).resource = deposit_id

func init_clean_grid():
	for y in range(map_height):
		var tile_row = []
		for x in range(map_width):
			var new_cell = cell_obj.instance()
			new_cell.initialize()
			new_cell.set_pos(Vector2(x, y))
			tile_row.append(new_cell)
		tiles.append(tile_row)

func wipe_map():
	tiles = []
	init_clean_grid()
			

func blank_grassland():
	for _y in range(tiles.size()):
		for _x in range(tiles[0].size()):
			get_cell(Vector2(_x, _y)).set_base(0)

func set_tiles_to_dirt(tiles):
	for tile in tiles:
		get_parent().get_node("TileMap").set_cellv(Vector2(tile.x, tile.y), 1)


