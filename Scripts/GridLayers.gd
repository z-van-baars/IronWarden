extends Node2D
onready var cell_scn = preload("res://Scenes/Cell.tscn")
onready var tools
onready var tiles
onready var deposits = {}
onready var map_width
onready var map_height
onready var units
onready var st
onready var tile_map
onready var local_player
onready var fog

func set_module_refs():
	tools = get_tree().root.get_node("Main/Tools")
	units = get_tree().root.get_node("Main/GameObjects/Units")
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	tile_map = get_parent().get_node("TileMap")
	fog = get_tree().root.get_node("Main/GameObjects/Fog")

func set_player_ref():
	local_player = get_tree().root.get_node("Main").local_player

func set_map_parameters(w, h):
	map_width = w
	map_height = h


func get_cell(coordinates):
	if tools.in_map(coordinates):
		return tiles[coordinates.y][coordinates.x]

func set_cell(coordinates, cell_obj):
	tiles[coordinates.y][coordinates.x] = cell_obj

func get_tile(map_position):
	return tile_map.world_to_map(map_position)

func get_world_position(tile_coordinates, centered=true):
	var offset = Vector2.ZERO
	if centered:
		offset.y = 26
	return tile_map.map_to_world(tile_coordinates) + offset

func _on_Dispatcher_deposit_exhausted(deposit):
	get_cell(deposit.get_coordinates()).set_deposit_id(null)

func find_nearby_deposits(search_location, radius, deposit_type):
	var center_tile = tile_map.world_to_map(search_location)
	var tiles_to_search = tools.get_nearby_tiles(center_tile, radius, true)
	var nearby_deposits = []
	for tile in tiles_to_search:
		if get_cell(tile).get_deposit_id() == deposit_type:
			nearby_deposits.append(get_cell(tile))
	if nearby_deposits.size() == 0:
		return null
	elif nearby_deposits.size() == 1:
		return nearby_deposits[0].get_pos()
	else:
		return tools.get_closest_tile(get_cell(center_tile), nearby_deposits).get_pos()

func set_deposit(coordinates, deposit_object):
	get_cell(coordinates).set_deposit_id(deposit_object.get_id())
	deposits[coordinates] = deposit_object

func get_deposit(coordinates):
	return deposits[coordinates]

func _on_Deposit_expired(deposit):
	set_deposit(deposit.get_coordinates(), null)


func set_structure(footprint_tiles, structure_obj):
	for tile_coords in footprint_tiles:
		get_cell(tile_coords).set_structure(structure_obj)

func get_structure_at(map_coords):
	var tile = get_cell(get_tile(map_coords))
	return tile.get_structure()

func initialize_tiles():
	for tile_row in tiles:
		for tile in tile_row:
			tile.initialize_exploration()

func init_clean_grid():
	for y in range(map_height):
		var tile_row = []
		for x in range(map_width):
			var new_cell = cell_scn.instance()
			add_child(new_cell)
			new_cell.initialize()
			new_cell.set_pos(Vector2(x, y))
			tile_row.append(new_cell)
			deposits[Vector2(x, y)] = null
		tiles.append(tile_row)

func wipe_map():
	tiles = []
	init_clean_grid()
			

func blank_grassland():
	for _y in range(tiles.size()):
		for _x in range(tiles[0].size()):
			get_cell(Vector2(_x, _y)).set_base(0)

func set_tiles_to_dirt(tiles_to_set):
	for tile in tiles_to_set:
		get_parent().get_node("TileMap").set_cellv(Vector2(tile.x, tile.y), 1)



func construction_site_clear(tile_coordinates, structure_type, player_number):
	var site_tiles = st.get_footprint_tiles(structure_type, tile_coordinates)
	for tile in site_tiles:
		if (not get_cell(tile) or
			not get_cell(tile).is_buildable() or
			not fog.explored_tiles[player_number][tile]): return false
	return true
	

func update_exploration(newly_explored_tiles):
	for player_number in newly_explored_tiles.keys():
		for tile in newly_explored_tiles[player_number].keys():
			if newly_explored_tiles[player_number][tile] == true:
				get_cell(tile).set_explored(player_number, true)





