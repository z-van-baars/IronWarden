extends Node2D
onready var cell_scn = preload("res://Scenes/Cell.tscn")
onready var tools
onready var tiles
onready var map_width
onready var map_height
onready var units
onready var st
onready var visible_tiles = []
onready var tile_map

func set_module_refs():
	tools = get_tree().root.get_node("Main/Tools")
	units = get_tree().root.get_node("Main/GameObjects/Units")
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	tile_map = get_parent().get_node("TileMap")

func set_map_parameters(w, h):
	map_width = w
	map_height = h

func get_cell(coordinates):
	return tiles[coordinates.y][coordinates.x]

func set_cell(coordinates, cell_obj):
	tiles[coordinates.y][coordinates.x] = cell_obj

func get_tile(map_position):
	return tile_map.world_to_map(map_position)

func set_resource(coordinates, deposit_id):
	get_cell(coordinates).set_resource_id(deposit_id)

func set_structure(footprint_tiles, structure_obj):
	for tile_coords in footprint_tiles:
		var tile = get_cell(tile_coords)
		tile.set_structure_id(structure_obj.get_id())
		tile.set_structure(structure_obj)

func init_clean_grid():
	for y in range(map_height):
		var tile_row = []
		for x in range(map_width):
			var new_cell = cell_scn.instance()
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

func set_tiles_to_dirt(tiles_to_set):
	for tile in tiles_to_set:
		get_parent().get_node("TileMap").set_cellv(Vector2(tile.x, tile.y), 1)

func get_revealed():
	return tools.get_nearby_tiles(
		Vector2(int(map_width / 2), int(map_height / 2)), 10, true)

func get_visible_tiles(location, radius):
	var tile_location = tile_map.world_to_map(location)
	return tools.get_nearby_tiles(
		tile_location, radius, true)

func check_visible():
	var all_visible = []
	for unit in units.get_children():
		var new_tiles = get_visible_tiles(unit.position, unit.get_sight())
		for _new_tile in new_tiles:
			if tools.in_map(_new_tile) and not _new_tile in all_visible:
				all_visible.append(_new_tile)
	for structure in st.get_node("All").get_children():
		var new_tiles = get_visible_tiles(structure.position, structure.get_sight())
		for _new_tile in new_tiles:
			if tools.in_map(_new_tile) and not _new_tile in all_visible:
				all_visible.append(_new_tile)
	return all_visible

func mark_explored():
	for tile in visible_tiles:
		tiles[tile.y][tile.x].set_explored(true)

func get_explored():
	var explored_tiles = []
	for _y in range(tiles.size()):
		for _x in range(tiles[0].size()):
			if tiles[_y][_x].get_explored(): explored_tiles.append(Vector2(_x, _y))
	return explored_tiles

func get_structure_at(map_coords):
	var tile = get_cell(get_tile(map_coords))
	return tile.get_structure()



func get_visible():
	return visible_tiles

func update_fog_of_war():
	visible_tiles = check_visible()
	mark_explored()

func construction_site_clear(tile_coordinates, structure_type):
	var site_tiles = st.get_footprint_tiles(structure_type, tile_coordinates)
	for tile in site_tiles:
		if not get_cell(tile).is_buildable(): return false
	return true
