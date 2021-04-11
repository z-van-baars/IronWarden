extends Node2D
onready var tiles = []
onready var width = 50
onready var height = 50
onready var tools = get_tree().root.get_node("Main/Tools")
onready var resources = get_tree().root.get_node("Main/Resources")
onready var structures = get_tree().root.get_node("Main/Structures")
onready var units = get_tree().root.get_node("Main/Units")
onready var scenery = get_tree().root.get_node("Main/Scenery")
onready var n_ore = int(sqrt(width * height) / 3)
onready var n_gem = int(sqrt(width * height) / 5)
onready var n_tree = int(sqrt(width * height) * 2)
onready var n_chicken = int(sqrt(width * height) / 5)


func map_gen():
	wipe_map()
	random_resources()
	random_scenery()
	paint_map_tiles()

func wipe_map():
	$TileMap.clear()
	units = []
	scenery = []
	blank_grassland()


func blank_grassland():
	tiles = []
	resources.tiles = []
	structures.tiles = []
	for y in range(height):
		var tile_row = []
		var resource_row = []
		var structures_row = []
		for x in range(width):
			tile_row.append(0)
			resource_row.append(-1)
			structures_row.append(-1)
		tiles.append(tile_row)
		resources.tiles.append(resource_row)
		structures.tiles.append(structures_row)
		


func paint_map_tiles():
	for y in range(height):
		for x in range(width):
			$TileMap.set_cellv(Vector2(x, y), tiles[y][x])


func random_resources():
	var ore_deposit_locs = tools.get_random_coordinates(tiles, n_ore)
	for ore_deposit in ore_deposit_locs:
		resources.add_deposit("Ore Deposit", ore_deposit)

	var gem_deposit_locs = tools.get_random_coordinates(tiles, n_gem)
	for gem_deposit in gem_deposit_locs:
		resources.add_deposit("Gem Deposit", gem_deposit)

	var tree_locs = tools.get_random_coordinates(tiles, n_tree)
	for tree in tree_locs:
		resources.add_deposit("Tree", tree)

	var space_chicken_locs = tools.get_random_coordinates(tiles, n_chicken)
	for space_chicken in space_chicken_locs:
		resources.add_deposit("Space Chicken", space_chicken)

func random_scenery():
	pass
