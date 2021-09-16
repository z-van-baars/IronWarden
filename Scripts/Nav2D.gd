extends Navigation2D

onready var grid
onready var width
onready var height
onready var st
onready var res
onready var astar
onready var tile_array = []
onready var _tiles = []
onready var _tile_indices = {}

func set_module_refs():
	grid = get_tree().root.get_node("Main/GameMap/Grid")
	st = get_tree().root.get_node("Main/GameObjects/Structures")
	res = get_tree().root.get_node("Main/GameObjects/Resources")
	astar = AStar2D.new()

func setup(game_map):
	var start = OS.get_ticks_msec()
	import_map_data(game_map)
	create_nav_grid()
	connect_nav_grid()
	block_initial_terrain()
	block_initial_structures()
	# set_nav_tiles()
	
	print("[ - %0 points baked to nav grid in %1 msecs".format(
		[str(astar.get_point_count()),
		 OS.get_ticks_msec() - start], "%_"))
	
func import_map_data(game_map):
	width = game_map.width
	height = game_map.height
	tile_array = grid.tiles

func get_point_index(point_coordinates):
	return _tile_indices[point_coordinates]

func create_nav_grid():
	var tile_index = 0
	for tile_row in tile_array:
		for tile in tile_row:
			_tiles.append(tile)
			astar.add_point(tile_index, tile.get_pos())
			_tile_indices[tile.get_pos()] = tile_index
			tile_index += 1

func connect_nav_grid():
	for point in astar.get_points():
		var non_diagonal_neighbors = Tools.get_neighbor_tiles(astar.get_point_position(point))
		for neighbor in non_diagonal_neighbors:
			astar.connect_points(point, get_point_index(neighbor), true)

func block_initial_terrain():
	var terrain_ids = {}
	for tile_row in tile_array:
		for tile in tile_row:
			if tile.get_deposit_id() == -1:
				continue
			block_tile(tile.get_pos())
			if not terrain_ids.has(tile.get_deposit_id()):
				terrain_ids[tile.get_deposit_id()] = 1
				continue
			terrain_ids[tile.get_deposit_id()] += 1
	# print(terrain_ids)

func block_initial_structures():
	var structure_ids = {}
	for tile_row in tile_array:
		for tile in tile_row:
			if tile.get_structure_id() == -1:
				continue
			block_tile(tile.get_pos())
			if not structure_ids.has(tile.get_structure_id()):
				structure_ids[tile.get_structure_id()] = 1
				continue
			structure_ids[tile.get_structure_id()] += 1
	# print(structure_ids)

func block_tile(tile_coordinates):
	astar.set_point_disabled(
		get_point_index(tile_coordinates), true)
	var neighbors = Tools.get_neighbor_tiles(tile_coordinates, false)
	# var diagonal_neighbors = Tools.get_diagonal_neighbors(tile_coordinates)
	for neighbor in neighbors:
		var id_A = _tile_indices[neighbor]
		for sub_neighbor in neighbors:
			var id_B = _tile_indices[sub_neighbor]
			if id_A == id_B:
				continue
			if astar.are_points_connected(id_A, id_B):
				astar.disconnect_points(id_A, id_B)

func unblock_tile(tile_coordinates):
	astar.set_point_disabled(
		get_point_index(tile_coordinates), false)

func get_tile_path(tile_start, tile_end) -> Array:
	if not Tools.in_map(tile_start):
		return []
	if not Tools.in_map(tile_end):
		tile_end = _tiles[get_closest_point(tile_end)]
	if astar.is_point_disabled(_tile_indices[tile_start]):
		pass
	if astar.is_point_disabled(_tile_indices[tile_end]):
		print("re-checking new end tile " + str(tile_end))
		print("tile index is  " + str(_tile_indices[tile_end]))
		print("tile index is  " + str(_tile_indices[tile_end]))
		print(astar.is_point_disabled(_tile_indices[tile_end]))
		pass
	return astar.get_point_path(
		get_point_index(tile_start),
		get_point_index(tile_end))

func get_rough_path(position_start, position_end) -> Array:
	var position_path = []
	if grid.get_tile(position_start) == null:
		return position_path
	if grid.get_tile(position_end) == null:
		return position_path
	if not astar.is_point_disabled(_tile_indices[grid.get_tile(position_end)]):
		for tile_coordinates in get_tile_path(
			grid.get_tile(position_start), grid.get_tile(position_end)):
			position_path.append(grid.get_world_position(tile_coordinates))
		position_path.pop_back()
		position_path.pop_front()
		return position_path
	
	
	# This does not work the way I'd thought, it returns partial points
	# with float values, not actually locked to the grid
	# var alt_end = get_closest_point(grid.get_tile(position_end))
	
	# new code for an alternative end tile
	var neighbors = Tools.get_neighbor_tiles(grid.get_tile(position_end))
	var enabled_neighbors = []
	for each in neighbors:
		if !astar.is_point_disabled(_tile_indices[each]):
			enabled_neighbors.append(each)
	var new_alt
	if enabled_neighbors.size() < 1:
		print("no valid neighbors!")
		new_alt = Tools.get_closest_tile(grid.get_tile(position_start), neighbors)
	else:
		# new_alt = Tools.r_choice(enabled_neighbors)
		new_alt = Tools.get_closest_tile(grid.get_tile(position_start), enabled_neighbors)
	# position_path.append(grid.get_tile(position_end))
	position_end = grid.get_world_position(new_alt)
	for tile_coordinates in get_tile_path(
		grid.get_tile(position_start), grid.get_tile(position_end)):
		position_path.append(grid.get_world_position(tile_coordinates))
	position_path.pop_front()
	return position_path

func get_smooth_path(position_start, position_end) -> Array:
	var raw_path = get_rough_path(position_start, position_end)
	return smooth(position_start, raw_path)

func smooth(start_position, path):
	var ray = $RayCast2D
	var raw_path = [start_position] + path
	# optional section here to detect static units by turning collision on for that layer
	var smooth_path = []
	var subsections = [] # List of Vector2
	var start_index = 0
	var end_index = 0
	while true:
		assert(end_index <= raw_path.size() - 1)
		ray.position = raw_path[start_index]
		ray.cast_to = raw_path[end_index + 1] - ray.position
		ray.force_raycast_update()
		if raw_path[end_index + 1] == raw_path[-1]:
			if ray.is_colliding():
				subsections.append([raw_path[start_index], raw_path[end_index]])
				start_index = end_index
			subsections.append([raw_path[start_index], raw_path[end_index + 1]])
			break

		if ray.is_colliding():
			subsections.append([raw_path[start_index], raw_path[end_index]])
			start_index = end_index
		end_index += 1

	for subsection in subsections:
		smooth_path.append(subsection[1])
	return smooth_path
		


func find_entry_tile(starting_tile, footprint_tiles):
	# used for finding approach path to a multi-tile footprint entity
	# will return a pair of Vector2s, [final, penultimate], for ideal unblocked entry
	var chosen_edge
	var border_tiles = Tools.get_perimeter_tiles(footprint_tiles)
	var unblocked = []
	for b_tile in border_tiles:
		if !astar.is_point_disabled(_tile_indices[b_tile]):
			unblocked.append(b_tile)
	if unblocked.size() == 0:
		return [null, null]
	if unblocked.size() == 1:
		# [final, penultimate]
		return [unblocked[0], Tools.get_closest_tile(footprint_tiles, unblocked[0])]
	# maybe someday try to find a performant way of quickly getting the closest 
	var closest_unblocked = Tools.get_closest_tile(starting_tile, unblocked)
	# [final, penultimate]
	return [Tools.get_closest_tile(closest_unblocked, footprint_tiles), closest_unblocked]








func set_nav_tile_old():
	$NavMap.clear()
	for y in range(height):
		for x in range(width):
			$NavMap.set_cellv(Vector2(x, y), -1)
	for each in res.get_node("Deposits").get_children():
		$NavMap.set_cellv(each.pos, 1)
	for each in st.get_structures():
		for _tile in each.get_footprint():
			$NavMap.set_cellv(_tile.x, _tile.y, 1)

func add_tile_outline(tile_coords):
	var world_coords = $NavMap.map_to_world(tile_coords)
	# print(tile_coords)
	# print(world_coords)
	var new_outline = PoolVector2Array([
		Vector2(world_coords.x - 48, world_coords.y + 26),
		Vector2(world_coords.x, world_coords.y),
		Vector2(world_coords.x + 48, world_coords.y + 26),
		Vector2(world_coords.x, world_coords.y + 51)])
	$NavPoly.navpoly.add_outline(new_outline)
	#print($NavPoly.navpoly.get_polygon_count())
	
	$NavPoly.navpoly.make_polygons_from_outlines()
	#print($NavPoly.navpoly.get_outline(0))
	#print($NavPoly.navpoly.get_outline(1))
	# print($NavPoly.navpoly.get_polygon_count())

func add_collision_outline(collidable_node):
	var new_polygon = PoolVector2Array()
	var polygon = $NavPoly.get_navigation_polygon()
	print($NavPoly.navpoly.get_polygon_count())
	var polygon_transform = collidable_node.get_node("NavPolygon2D").get_global_transform()
	var polygon_bp = collidable_node.get_node("NavPolygon2D").get_polygon()
	for vertex in polygon_bp:
		new_polygon.append(polygon_transform.xform(vertex))
	polygon.add_outline(new_polygon)
	polygon.make_polygons_from_outlines()
	$NavPoly.set_navigation_polygon(polygon)
	$NavPoly.enabled = false
	$NavPoly.enabled = true
	print($NavPoly.navpoly.get_polygon_count())
	

func update_nav_tile(tile_location, tile_block_id):
	$NavMap.set_cellv(
		tile_location, tile_block_id)
