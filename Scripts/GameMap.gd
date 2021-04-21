extends Node2D
onready var grid
onready var tools
onready var res
onready var structures
onready var nav

onready var width = 50
onready var height = 50


onready var n_ore = int(sqrt(width * height) / 3)
onready var n_gem = int(sqrt(width * height) / 5)
# onready var n_forests = int(sqrt(width * height) / 10)
onready var n_forests = 1
# onready var forest_size = int(sqrt(width * height) * 3)
onready var forest_size = 25
onready var forest_radius = 6.5

onready var n_small_forests = 1
onready var small_forest_size = 12
onready var small_forest_radius = 3
onready var n_chicken = int(sqrt(width * height) / 5)


func set_module_refs():
	grid = $Grid
	tools = get_tree().root.get_node("Main/Tools")
	res = get_tree().root.get_node("Main/GameObjects/Resources")
	structures = get_tree().root.get_node("Main/GameObjects/Structures")
	nav = get_tree().root.get_node("Main/Nav2D")

func map_gen():
	tools.set_map_parameters()
	grid.set_module_refs()
	nav.set_module_refs()

	grid.set_map_parameters(width, height)
	$TileMap.clear()
	grid.wipe_map()

	grid.blank_grassland()

	random_resources()
	paint_map_terrain()


func paint_map_terrain():
	for y in range(height):
		for x in range(width):
			var tile_in_question = grid.get_cell(Vector2(x, y))
			$TileMap.set_cellv(
				Vector2(x, y),
				grid.get_cell(Vector2(x, y)).get_base())

func blank_forest():
	for _y in range(grid.tiles.size()):
		print(_y)
		for _x in range(grid.tiles[0].size()):
			res.add_deposit(res.DepositTypes.TREE, Vector2(_x, _y))

func random_resources():
	generate_forests(n_forests, forest_size, forest_radius)
	generate_forests(n_small_forests, small_forest_size, small_forest_radius)

	var ore_deposit_locs = tools.get_random_coordinates(grid.tiles, n_ore)
	var ore_count = 0
	for ore_deposit in ore_deposit_locs:
		if grid.get_cell(ore_deposit).is_buildable():
			res.add_deposit(res.DepositTypes.ORE, ore_deposit)
			ore_count += 1

		# ore clustering
		var ore_neighbors = tools.get_nearby_tiles(ore_deposit, 2)
		var valid_ore_neighbors = []
		for o_n in ore_neighbors:
			if grid.get_cell(o_n).is_buildable():
				valid_ore_neighbors.append(o_n)
		for _x in range(randi()%5+2):
			if valid_ore_neighbors.empty(): break
			var r_neighbor = tools.r_choice(valid_ore_neighbors)
			valid_ore_neighbors.erase(r_neighbor)
			res.add_deposit(res.DepositTypes.ORE, r_neighbor)
			ore_count += 1

	var gem_count = 0
	var gem_deposit_locs = tools.get_random_coordinates(grid.tiles, n_gem)
	for gem_deposit in gem_deposit_locs:
		if grid.get_cell(gem_deposit).is_buildable():
			res.add_deposit(res.DepositTypes.GEM, gem_deposit)
			gem_count += 1

		# clustering
		var gem_neighbors = tools.get_nearby_tiles(gem_deposit, 2)
		var valid_gem_neighbors = []
		for g_n in gem_neighbors:
			if grid.get_cell(g_n).is_buildable():
				valid_gem_neighbors.append(g_n)
		for _x in range(randi()%3+0):
			if valid_gem_neighbors.empty(): break
			var r_neighbor = tools.r_choice(valid_gem_neighbors)
			valid_gem_neighbors.erase(r_neighbor)
			res.add_deposit(res.DepositTypes.GEM, r_neighbor)
			gem_count += 1


	var space_chicken_locs = tools.get_random_coordinates(grid.tiles, n_chicken)
	var chicken_count = 0
	for space_chicken in space_chicken_locs:
		if grid.get_cell(space_chicken).is_buildable():
			res.add_deposit(res.DepositTypes.SPACE_CHICKEN, space_chicken)
			chicken_count += 1
	
	
	print("Ore Deposits: " + str(ore_count) + " / " + str(n_ore))
	print("Gem Deposits: " + str(gem_count) + " / " + str(n_gem))
	print("Chicken Deposits: " + str(chicken_count) + " / " + str(n_chicken))


func generate_forests(n_forests, forest_size, forest_radius):
	for _f in range(n_forests):
		var forest_start
		while true:
			forest_start = tools.get_random_coordinates(grid.tiles, 1)[0]
			if grid.get_cell(forest_start).get_resource() != 1:
				break
		res.add_deposit(res.DepositTypes.TREE, forest_start)
		var evaluated = [forest_start]
		
		var forest_tiles_in_radius = tools.get_nearby_tiles(forest_start, forest_radius)
		for f_tile in forest_tiles_in_radius:
			res.add_deposit(res.DepositTypes.TREE, f_tile)
			evaluated.append(f_tile)

