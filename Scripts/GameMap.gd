extends Node2D
onready var grid
onready var tools
onready var res
onready var structures
onready var nav

onready var width = 50
onready var height = 50


onready var n_ore = int(sqrt(width * height) / 3)
onready var n_crystal = int(sqrt(width * height) / 5)
# onready var n_forests = int(sqrt(width * height) / 10)
onready var n_forests = 1
# onready var forest_size = int(sqrt(width * height) * 3)
onready var forest_size = 25
onready var forest_radius = 6.5

onready var n_small_forests = 1
onready var small_forest_size = 12
onready var small_forest_radius = 3


func set_module_refs():
	grid = $Grid
	tools = get_tree().root.get_node("Main/Tools")
	res = get_tree().root.get_node("Main/GameObjects/Resources")
	structures = get_tree().root.get_node("Main/GameObjects/Structures")
	nav = get_tree().root.get_node("Main/Nav2D")

func map_gen():
	print(" - Setting Map Parameters...")
	grid.set_module_refs()
	nav.set_module_refs()

	grid.set_map_parameters(width, height)
	$TileMap.clear()
	$GridMap.clear()
	print(" - Clearing Tile Grid...")
	grid.wipe_map()
	print(" - Generating Blank Terrain...")
	grid.blank_grassland()
	print(" - Randomizing Resources...")
	random_resources()
	print(" - Rendering TileMap...")
	paint_map_terrain()


func paint_map_terrain():
	for y in range(height):
		for x in range(width):
			$TileMap.set_cellv(
				Vector2(x, y), grid.get_cell(Vector2(x, y)).get_base())
			$GridMap.set_cellv(
				Vector2(x, y), 0)

func blank_forest():
	for _y in range(grid.tiles.size()):
		print(_y)
		for _x in range(grid.tiles[0].size()):
			res.add_deposit(DepositTypes.DEPOSIT.TREE, Vector2(_x, _y))

func random_resources():
	print("Placing Large Forests...")
	var start = OS.get_unix_time()

	
	generate_forests(n_forests, forest_size, forest_radius)
	var elapsed = (OS.get_unix_time() - start)
	print("Large Forests: [" + str(n_forests) + " / " + str(n_forests) + "]  placed in [ " + str(elapsed) + "s ]")
	print("Placing Small Forests...")
	start = OS.get_unix_time()
	generate_forests(n_small_forests, small_forest_size, small_forest_radius)
	elapsed = (OS.get_unix_time() - start)
	print("Small Forests: [" + str(n_small_forests) + " / " + str(n_small_forests) + "]  placed in [ " + str(elapsed) + "s ]")
	start = OS.get_unix_time()
	print("Placing Ore...")
	var ore_deposit_locs = tools.get_random_coordinates(grid.tiles, n_ore)
	var ore_count = 0
	for ore_deposit in ore_deposit_locs:
		if grid.get_cell(ore_deposit).is_buildable():
			res.add_deposit(DepositTypes.DEPOSIT.ORE, ore_deposit)
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
			res.add_deposit(DepositTypes.DEPOSIT.ORE, r_neighbor)
			ore_count += 1
	elapsed = (OS.get_unix_time() - start)
	print("Ore Deposits: [" + str(ore_count) + " / " + str(n_ore) + "] placed in [ " + str(elapsed) + "s ]")
	start = OS.get_unix_time()
	print("Placing Warpstone Crystals...")
	var crystal_count = 0
	var crystal_deposit_locs = tools.get_random_coordinates(grid.tiles, n_crystal)
	for crystal_deposit in crystal_deposit_locs:
		if grid.get_cell(crystal_deposit).is_buildable():
			res.add_deposit(DepositTypes.DEPOSIT.CRYSTAL, crystal_deposit)
			crystal_count += 1

		# clustering
		var crystal_neighbors = tools.get_nearby_tiles(crystal_deposit, 2)
		var valid_crystal_neighbors = []
		for c_n in crystal_neighbors:
			if grid.get_cell(c_n).is_buildable():
				valid_crystal_neighbors.append(c_n)
		for _x in range(randi()%3+0):
			if valid_crystal_neighbors.empty(): break
			var r_neighbor = tools.r_choice(valid_crystal_neighbors)
			valid_crystal_neighbors.erase(r_neighbor)
			res.add_deposit(DepositTypes.DEPOSIT.CRYSTAL, r_neighbor)
			crystal_count += 1
	elapsed = (OS.get_unix_time() - start)
	print("Crystal Deposits: [" + str(crystal_count) + " / " + str(n_crystal) + "] placed in [ " + str(elapsed) + "s ]")


func generate_forests(n, _fsize, f_radius):
	for _f in range(n):
		var forest_start
		while true:
			forest_start = tools.get_random_coordinates(grid.tiles, 1)[0]
			if grid.get_cell(forest_start).get_deposit_id() != 1:
				break
		res.add_deposit(DepositTypes.DEPOSIT.TREE, forest_start)
		var evaluated = [forest_start]
		
		var forest_tiles_in_radius = tools.get_nearby_tiles(forest_start, f_radius)
		for f_tile in forest_tiles_in_radius:
			res.add_deposit(DepositTypes.DEPOSIT.TREE, f_tile)
			evaluated.append(f_tile)

