extends Navigation2D

onready var width
onready var height
onready var tiles = []

func import_map_data(game_map):
	width = game_map.width
	height = game_map.height
	tiles = game_map.tiles
	set_nav_tiles()

func set_nav_tiles():
	$NavMap.clear()
	for y in range(height):
		for x in range(width):
			$NavMap.set_cellv(Vector2(x, y), tiles[y][x])
	print("Number of resources: ", get_tree().root.get_node("Main/Resources/Deposits").get_children().size())
	for each in get_tree().root.get_node("Main/Resources/Deposits").get_children():
		$NavMap.set_cellv(each.pos, -1)


func update_nav_tile(tile_location, tile_block_id):
	$NavMap.set_cellv(
		tile_location, tile_block_id)
